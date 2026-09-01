#!/usr/bin/env python3
"""Create privacy-safe 2880×1800 Mac App Store screenshots."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

CANVAS_SIZE = (2880, 1800)

SCREENSHOTS = (
    (
        "docs/screenshots/01-overview.png",
        "docs/app-store/01-clipboard-overview.png",
        "Your clipboard, one shortcut away",
        "Press Option–Command–C, then choose any clip with 1–9 or A–Z.",
    ),
    (
        "docs/screenshots/02-safari-links-filter.png",
        "docs/app-store/02-link-filter.png",
        "Find the right link instantly",
        "Filter by content type and source application.",
    ),
    (
        "docs/screenshots/03-finder-pdf-filter.png",
        "docs/app-store/03-file-filter.png",
        "Narrow file clips by app and type",
        "Find entries containing PDFs while keeping each copied file group intact.",
    ),
    (
        "docs/screenshots/04-images-filter.png",
        "docs/app-store/04-image-previews.png",
        "See copied images at a glance",
        "Visual previews make recent image clips easy to recognize.",
    ),
)


def crop_background(image: Image.Image) -> Image.Image:
    """Remove a solid black capture margin without touching visible UI."""
    rgba = image.convert("RGBA")
    flattened = Image.new("RGBA", rgba.size, "black")
    flattened.alpha_composite(rgba)
    rgb = flattened.convert("RGB")
    difference = ImageChops.difference(rgb, Image.new("RGB", rgb.size, "black"))
    bounds = difference.getbbox()
    return rgb.crop(bounds) if bounds else rgb


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    names = (
        "/System/Library/Fonts/SFNSDisplay-Bold.otf" if bold else "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    )
    for name in names:
        path = Path(name)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def _gradient(size: tuple[int, int]) -> Image.Image:
    width, height = size
    top = (25, 18, 58)
    bottom = (46, 91, 120)
    canvas = Image.new("RGB", size)
    draw = ImageDraw.Draw(canvas)
    for y in range(height):
        ratio = y / max(height - 1, 1)
        color = tuple(round(a + (b - a) * ratio) for a, b in zip(top, bottom))
        draw.line((0, y, width, y), fill=color)
    return canvas


def compose(
    source: Path,
    destination: Path,
    *,
    title: str,
    subtitle: str,
) -> None:
    canvas = _gradient(CANVAS_SIZE)
    draw = ImageDraw.Draw(canvas)
    title_font = _font(88, bold=True)
    subtitle_font = _font(42)

    draw.text(
        (CANVAS_SIZE[0] // 2, 105),
        title,
        font=title_font,
        fill=(255, 255, 255),
        anchor="ma",
    )
    draw.text(
        (CANVAS_SIZE[0] // 2, 230),
        subtitle,
        font=subtitle_font,
        fill=(211, 224, 242),
        anchor="ma",
    )

    with Image.open(source) as raw:
        screenshot = crop_background(raw)
    screenshot = ImageOps.contain(screenshot, (2580, 1370), Image.Resampling.LANCZOS)

    x = (CANVAS_SIZE[0] - screenshot.width) // 2
    y = 355 + (1370 - screenshot.height) // 2

    shadow = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (x - 30, y - 20, x + screenshot.width + 30, y + screenshot.height + 45),
        radius=60,
        fill=(0, 0, 0, 150),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(35))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    canvas.paste(screenshot, (x, y))

    destination.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(destination, format="PNG", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="ClipGrid repository root",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="Optional output directory; defaults to docs/app-store under the repository root",
    )
    args = parser.parse_args()

    for source, destination, title, subtitle in SCREENSHOTS:
        output = (
            args.output_dir / Path(destination).name
            if args.output_dir
            else args.root / destination
        )
        compose(args.root / source, output, title=title, subtitle=subtitle)
        print(f"{output}: {CANVAS_SIZE[0]}x{CANVAS_SIZE[1]}")


if __name__ == "__main__":
    main()
