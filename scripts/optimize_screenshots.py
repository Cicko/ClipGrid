#!/usr/bin/env python3
import sys
from pathlib import Path
from PIL import Image

for argument in sys.argv[1:]:
    path = Path(argument)
    image = Image.open(path).convert("RGBA")
    quantized = image.quantize(
        colors=256,
        method=Image.Quantize.FASTOCTREE,
        dither=Image.Dither.FLOYDSTEINBERG,
    )
    quantized.save(path, optimize=True)
    print(f"{path}: {image.width}x{image.height}")
