#!/usr/bin/env python3
"""
Build a QA contact sheet from finalized assets.

Groups by category, lays them out on dark/light backgrounds, shows the asset
name beneath each tile. The script never claims visual correctness — the
operator must read the produced image and judge consistency.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = REPO_ROOT / "assets" / "art" / "asset-manifest.json"
OUT_DIR = REPO_ROOT / "assets" / "art" / "qa"

# Try a system font, fall back to PIL default.
_FONT_CANDIDATES = [
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    str(REPO_ROOT / "godot" / "assets" / "fonts" / "NotoSansKR-wght.ttf"),
]


def get_font(size: int) -> ImageFont.ImageFont:
    for path in _FONT_CANDIDATES:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def load_manifest() -> dict:
    with MANIFEST.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def tile(img: Image.Image, cell: int) -> Image.Image:
    canvas = Image.new("RGBA", (cell, cell), (0, 0, 0, 0))
    src = img.copy()
    src.thumbnail((cell - 8, cell - 8), Image.LANCZOS)
    x = (cell - src.width) // 2
    y = (cell - src.height) // 2
    canvas.paste(src, (x, y), src if src.mode == "RGBA" else None)
    return canvas


def render_sheet(category: str, items: list[tuple[str, Image.Image]], bg: tuple[int, int, int]) -> Image.Image:
    cols = 4 if category != "backgrounds" else 2
    rows = (len(items) + cols - 1) // cols
    cell = 256
    pad = 16
    label_h = 36
    sheet_w = pad + cols * (cell + pad)
    sheet_h = pad + rows * (cell + label_h + pad) + 64

    sheet = Image.new("RGB", (sheet_w, sheet_h), bg)
    draw = ImageDraw.Draw(sheet)
    title_font = get_font(28)
    label_font = get_font(16)
    draw.text((pad, 16), f"{category}  ({len(items)} assets)  on {'dark' if sum(bg) < 384 else 'light'} bg",
              fill=(220, 220, 220) if sum(bg) < 384 else (40, 40, 40), font=title_font)

    for i, (name, img) in enumerate(items):
        col = i % cols
        row = i // cols
        x = pad + col * (cell + pad)
        y = 64 + row * (cell + label_h + pad)
        sheet.paste(tile(img, cell), (x, y), )
        text_color = (220, 220, 220) if sum(bg) < 384 else (40, 40, 40)
        draw.text((x + 4, y + cell + 4), name, fill=text_color, font=label_font)

    return sheet


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-prefix", default=None)
    args = parser.parse_args()
    manifest = load_manifest()
    final_root = (MANIFEST.parent / manifest["out_dir_final"]).resolve()

    by_cat: dict[str, list[tuple[str, Image.Image]]] = defaultdict(list)
    for asset in manifest["assets"]:
        cat = asset.get("category", "misc")
        path = final_root / cat / f"{asset['name']}.png"
        if not path.exists():
            print(f"[skip] {cat}/{asset['name']} (no final)", file=sys.stderr)
            continue
        with Image.open(path) as im:
            by_cat[cat].append((asset["name"], im.copy()))

    if not by_cat:
        print("[error] no finals found", file=sys.stderr)
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_prefix = args.out_prefix or "contact_sheet"
    sheets = []
    for cat, items in by_cat.items():
        for bg_name, bg_color in (("dark", (16, 16, 18)), ("light", (240, 240, 240))):
            sheet = render_sheet(cat, items, bg_color)
            sheet_path = OUT_DIR / f"{out_prefix}_{cat}_{bg_name}.png"
            sheet.save(sheet_path, "PNG", optimize=True)
            sheets.append(sheet_path)
            print(f"[ok] {sheet_path.relative_to(REPO_ROOT)}")

    return 0


if __name__ == "__main__":
    sys.exit(main())