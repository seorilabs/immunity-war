#!/usr/bin/env python3
"""
Finalize raw MiniMax JPGs into engine-ready PNGs.

Pipeline per asset:
  - transparent:  rembg background removal → alpha bbox-trim → center on
                  transparent square canvas of `size`×`size`
  - opaque:       resize uniformly so the long edge equals `size`, then
                  cover-center-crop to the requested aspect ratio

Reads assets/art/asset-manifest.json and writes PNGs to
godot/assets/sprites/<category>/<name>.png (relative to manifest's
out_dir_final).

Skip-finalized by default. Use --force to overwrite.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

from PIL import Image

# rembg is optional — we want a clean error if it's missing
try:
    from rembg import remove as rembg_remove
except Exception as exc:  # pragma: no cover
    print(f"[error] rembg import failed: {exc}", file=sys.stderr)
    raise

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = REPO_ROOT / "assets" / "art" / "asset-manifest.json"
RAW_ROOT = REPO_ROOT / "assets" / "art" / "raw"


def load_manifest() -> dict:
    with MANIFEST.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def aspect_ratio_to_size(ar: str, max_edge: int) -> tuple[int, int]:
    """Convert 'W:H' ratio into (width, height) bounded by max_edge."""
    try:
        w_str, h_str = ar.split(":", 1)
        w, h = float(w_str), float(h_str)
    except Exception as e:
        raise ValueError(f"invalid aspect ratio '{ar}'") from e
    if w >= h:
        out_w = max_edge
        out_h = int(round(max_edge * h / w))
    else:
        out_h = max_edge
        out_w = int(round(max_edge * w / h))
    out_w -= out_w % 8
    out_h -= out_h % 8
    return out_w, out_h


def transparent_finalize(raw_path: Path, size: int) -> Image.Image:
    """rembg → bbox trim → centered square canvas."""
    with Image.open(raw_path) as im:
        im.load()
        # rembg returns RGBA (background removed) by default
        rgba = rembg_remove(im.convert("RGBA"))
    bg = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    composite = Image.alpha_composite(bg, rgba)

    # bbox of non-zero alpha
    alpha = composite.split()[-1]
    bbox = alpha.getbbox()
    if not bbox:
        return Image.new("RGBA", (size, size), (0, 0, 0, 0))
    trimmed = composite.crop(bbox)

    # Fit into target square preserving aspect ratio
    tw, th = trimmed.size
    scale = min(size / tw, size / th)
    new_w = max(1, int(round(tw * scale)))
    new_h = max(1, int(round(th * scale)))
    trimmed = trimmed.resize((new_w, new_h), Image.LANCZOS)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(trimmed, ((size - new_w) // 2, (size - new_h) // 2), trimmed)
    return canvas


def opaque_finalize(raw_path: Path, size: int, aspect_ratio: str | None) -> Image.Image:
    with Image.open(raw_path) as im:
        im.load()
        rgb = im.convert("RGB")
    if aspect_ratio:
        out_w, out_h = aspect_ratio_to_size(aspect_ratio, size)
    else:
        out_w, out_h = size, size
    # Resize so long edge matches target long edge, then cover-center-crop
    src_w, src_h = rgb.size
    long_edge_target = max(out_w, out_h)
    if src_w >= src_h:
        new_w = long_edge_target
        new_h = int(round(src_h * new_w / src_w))
    else:
        new_h = long_edge_target
        new_w = int(round(src_w * new_h / src_h))
    rgb = rgb.resize((new_w, new_h), Image.LANCZOS)
    left = (new_w - out_w) // 2
    top = (new_h - out_h) // 2
    return rgb.crop((left, top, left + out_w, top + out_h))


def finalize_asset(asset: dict, manifest: dict, final_root: Path, force: bool) -> tuple[bool, str]:
    name = asset["name"]
    category = asset.get("category", "misc")
    raw_path = RAW_ROOT / category / f"{name}.jpg"
    if not raw_path.exists():
        return False, f"[skip] {category}/{name}: no raw at {raw_path.relative_to(REPO_ROOT)}"

    final_path = final_root / category / f"{name}.png"
    final_path.parent.mkdir(parents=True, exist_ok=True)
    if final_path.exists() and not force:
        return True, f"[skip] {category}/{name} final exists"

    size = max(64, min(2048, asset.get("size", 512)))
    size = (size // 8) * 8
    transparent = asset.get("transparent", True)
    aspect_ratio = asset.get("aspect_ratio")

    try:
        if transparent:
            img = transparent_finalize(raw_path, size)
        else:
            img = opaque_finalize(raw_path, size, aspect_ratio)
        img.save(final_path, "PNG", optimize=True)
        return True, f"[ok]   {category}/{name} -> {final_path.relative_to(REPO_ROOT)} ({img.size[0]}x{img.size[1]})"
    except Exception as e:
        return False, f"[fail] {category}/{name}: {e}"


def main() -> int:
    parser = argparse.ArgumentParser(description="MiniMax asset batch finalizer")
    parser.add_argument("--force", action="store_true", help="Overwrite existing finals")
    parser.add_argument("--only", nargs="*", default=None, help="Restrict to asset names")
    args = parser.parse_args()

    manifest = load_manifest()
    out_dir_final = manifest.get("out_dir_final", "../../godot/assets/sprites")
    final_root = (MANIFEST.parent / out_dir_final).resolve()

    selected = manifest["assets"]
    if args.only:
        wanted = set(args.only)
        selected = [a for a in manifest["assets"] if a["name"] in wanted]
        missing = wanted - {a["name"] for a in selected}
        if missing:
            print(f"[warn] --only names not in manifest: {sorted(missing)}", file=sys.stderr)

    failures = 0
    for asset in selected:
        ok, msg = finalize_asset(asset, manifest, final_root, force=args.force)
        print(msg, flush=True)
        if not ok:
            failures += 1

    print(f"\nDone. {len(selected)} assets, {failures} failures.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())