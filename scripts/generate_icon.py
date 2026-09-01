#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
support = root / "Support"
iconset = support / "AppIcon.iconset"
iconset.mkdir(parents=True, exist_ok=True)

size = 1024
image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
pixels = image.load()
assert pixels is not None
for y in range(size):
    for x in range(size):
        t = (x + y) / (2 * size)
        pixels[x, y] = (
            int(100 + 145 * t),
            int(92 + 25 * t),
            int(246 - 90 * t),
            255,
        )

mask = Image.new("L", (size, size), 0)
ImageDraw.Draw(mask).rounded_rectangle((54, 54, 970, 970), radius=225, fill=255)
image.putalpha(mask)
draw = ImageDraw.Draw(image, "RGBA")

cell = 190
gap = 34
start = (size - (cell * 3 + gap * 2)) // 2
colors = [
    (255, 255, 255, 235), (229, 245, 255, 220), (255, 232, 239, 225),
    (223, 255, 241, 225), (255, 255, 255, 245), (255, 242, 211, 225),
    (239, 228, 255, 225), (218, 250, 251, 225), (255, 255, 255, 235),
]
for row in range(3):
    for col in range(3):
        x = start + col * (cell + gap)
        y = start + row * (cell + gap)
        draw.rounded_rectangle((x, y, x + cell, y + cell), radius=48, fill=colors[row * 3 + col])

master = support / "AppIcon-1024.png"
image.save(master)
for logical in (16, 32, 128, 256, 512):
    image.resize((logical, logical), Image.Resampling.LANCZOS).save(iconset / f"icon_{logical}x{logical}.png")
    image.resize((logical * 2, logical * 2), Image.Resampling.LANCZOS).save(iconset / f"icon_{logical}x{logical}@2x.png")
