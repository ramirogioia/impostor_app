#!/usr/bin/env python3
"""Generate iOS LaunchImage splash from icon_square_ios.png.

Creates @1x, @2x, @3x images: black background, icon centered, scaled to fit width.
High-quality resampling to avoid pixelation.
"""

from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Install Pillow: pip install Pillow")

# Portrait aspect ~1:2 (typical phone splash)
WIDTH_1X = 400
HEIGHT_1X = 800

ROOT = Path(__file__).resolve().parent.parent
ICON = ROOT / "assets" / "images" / "icon_square_ios.png"
OUT_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"


def main() -> None:
    if not ICON.exists():
        raise SystemExit(f"Icon not found: {ICON}")

    im = Image.open(ICON)
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
    else:
        im = im.convert("RGB")

    for scale, suffix in [(1, ""), (2, "@2x"), (3, "@3x")]:
        w = WIDTH_1X * scale
        h = HEIGHT_1X * scale
        icon_size = w  # square, fit to width
        canvas = Image.new("RGB", (w, h), (0, 0, 0))
        resized = im.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        if resized.mode == "RGBA":
            canvas.paste(resized, ((w - icon_size) // 2, (h - icon_size) // 2), resized)
        else:
            canvas.paste(resized, ((w - icon_size) // 2, (h - icon_size) // 2))

        out = OUT_DIR / f"LaunchImage{suffix}.png"
        canvas.save(out, "PNG", optimize=True)
        print(f"Wrote {out} ({w}x{h})")

    print("Done. Update LaunchScreen storyboard image size to", WIDTH_1X, "x", HEIGHT_1X)


if __name__ == "__main__":
    main()
