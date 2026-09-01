import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

import generate_app_store_screenshots as generator


class AppStoreScreenshotTests(unittest.TestCase):
    def test_compose_creates_exact_mac_app_store_dimensions(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.png"
            destination = root / "output.png"
            Image.new("RGB", (800, 600), "white").save(source)

            generator.compose(
                source,
                destination,
                title="One shortcut away",
                subtitle="A test subtitle",
            )

            with Image.open(destination) as result:
                self.assertEqual(result.size, (2880, 1800))
                self.assertEqual(result.mode, "RGB")

    def test_crop_background_keeps_visible_window_content(self):
        image = Image.new("RGB", (100, 100), "black")
        for x in range(20, 80):
            for y in range(10, 90):
                image.putpixel((x, y), (240, 240, 240))

        cropped = generator.crop_background(image)

        self.assertEqual(cropped.size, (60, 80))


if __name__ == "__main__":
    unittest.main()
