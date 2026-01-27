#!/usr/bin/env python3
"""Enlarge the 'g' + hat logo relative to black background in icon_square_ios.

Crops to logo bbox, scales it up to fill more of the 1024x1024 canvas,
then centers on black. Use LOGO_FRAC to control size (e.g. 0.75 = 75% of icon).
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ICON = ROOT / "assets" / "images" / "icon_square_ios.png"
OUT = ICON  # overwrite in place
LOGO_FRAC = 0.85  # logo max dimension = 85% of 1024


def main() -> None:
    im = Image.open(ICON).convert("RGB")
    gray = im.convert("L")
    mask = gray.point(lambda p: 0 if p < 25 else 255, "1")
    bbox = mask.getbbox()
    if not bbox:
        raise SystemExit("No logo bbox found")

    x0, y0, x1, y1 = bbox
    pad = 8
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(im.width, x1 + pad)
    y1 = min(im.height, y1 + pad)
    crop = im.crop((x0, y0, x1, y1))

    size = 1024
    target = int(size * LOGO_FRAC)
    # scale crop so longest side = target, keep aspect
    cw, ch = crop.size
    if cw >= ch:
        nw, nh = target, max(1, int(ch * target / cw))
    else:
        nh, nw = target, max(1, int(cw * target / ch))
    scaled = crop.resize((nw, nh), Image.Resampling.LANCZOS)

    canvas = Image.new("RGB", (size, size), (0, 0, 0))
    px = (size - nw) // 2
    py = (size - nh) // 2
    canvas.paste(scaled, (px, py))

    canvas.save(OUT, "PNG", optimize=True)
    print(f"Updated {OUT}: logo ~{LOGO_FRAC*100:.0f}% of icon (was ~39%)")


if __name__ == "__main__":
    main()
