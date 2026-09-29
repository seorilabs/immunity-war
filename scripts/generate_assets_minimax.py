#!/usr/bin/env python3
"""
Generate game assets via MiniMax `mmx image generate`.

Reads assets/art/asset-manifest.json, calls the CLI once per asset, and stores
raw JPGs under assets/art/raw/<category>/<name>.jpg.

Skips assets whose raw already exists. Use --force to regenerate.
Use --only <name> [<name>...] to generate a subset.

Provider: MiniMax image-01 (mmx image CLI). Anchor contract is NOT used —
style consistency comes from the universal prompt prefix + locked palette.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = REPO_ROOT / "assets" / "art" / "asset-manifest.json"
RAW_ROOT = REPO_ROOT / "assets" / "art" / "raw"


def load_manifest() -> dict:
    with MANIFEST.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def build_prompt(asset: dict, manifest: dict) -> str:
    transparent = asset.get("transparent", True)
    prefix_key = "universal_prefix" if transparent else "scene_prefix"
    prefix = manifest.get(prefix_key, manifest.get("universal_prefix", "")).strip()
    suffix = asset.get("prompt_suffix", "").strip()
    if prefix and suffix:
        return f"{prefix}. Subject: {suffix}"
    return prefix or suffix


def run_one(asset: dict, manifest: dict, raw_dir: Path, force: bool) -> tuple[bool, str]:
    name = asset["name"]
    category = asset.get("category", "misc")
    out_path = raw_dir / category / f"{name}.jpg"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    if out_path.exists() and not force:
        return True, f"[skip] {category}/{name} (already exists)"

    prompt = build_prompt(asset, manifest)
    seed = asset.get("seed", 42)
    size = asset.get("size", 512)
    aspect_ratio = asset.get("aspect_ratio")
    transparent = asset.get("transparent", True)

    cmd = ["mmx", "image", "generate", "--prompt", prompt, "--seed", str(seed), "--n", "1"]
    if aspect_ratio and asset.get("transparent") is False:
        cmd.extend(["--aspect-ratio", aspect_ratio])
    elif size:
        # Square at <size>. MiniMax requires [512, 2048] multiple of 8.
        size = max(512, min(2048, size))
        size = (size // 8) * 8
        cmd.extend(["--width", str(size), "--height", str(size)])
    cmd.extend(["--out", str(out_path)])

    started = time.time()
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=240,
        )
        elapsed = time.time() - started
        if proc.returncode != 0 or not out_path.exists():
            err = (proc.stderr or proc.stdout or "").strip().splitlines()[-1:] or ["unknown"]
            return False, f"[fail] {category}/{name} in {elapsed:.1f}s: {err[0][:200]}"
        return True, f"[ok]   {category}/{name} in {elapsed:.1f}s -> {out_path.relative_to(REPO_ROOT)}"
    except subprocess.TimeoutExpired:
        return False, f"[fail] {category}/{name} timeout after 240s"


def main() -> int:
    parser = argparse.ArgumentParser(description="MiniMax asset batch generator")
    parser.add_argument("--force", action="store_true", help="Regenerate even if raw exists")
    parser.add_argument("--only", nargs="*", default=None, help="Restrict to asset names")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running")
    args = parser.parse_args()

    manifest = load_manifest()
    RAW_ROOT.mkdir(parents=True, exist_ok=True)

    selected = manifest["assets"]
    if args.only:
        wanted = set(args.only)
        selected = [a for a in manifest["assets"] if a["name"] in wanted]
        missing = wanted - {a["name"] for a in selected}
        if missing:
            print(f"[warn] --only names not in manifest: {sorted(missing)}", file=sys.stderr)

    failures = 0
    for asset in selected:
        if args.dry_run:
            print(build_prompt(asset, manifest)[:120] + "…")
            continue
        ok, msg = run_one(asset, manifest, RAW_ROOT, force=args.force)
        print(msg, flush=True)
        if not ok:
            failures += 1

    if args.dry_run:
        return 0
    print(f"\nDone. {len(selected)} assets, {failures} failures.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())