from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

root = Path("desktop/src-tauri/icons")
root.mkdir(parents=True, exist_ok=True)

size = 1024
image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)
draw.rounded_rectangle((64, 64, 960, 960), radius=196, fill=(15, 118, 110, 255))
draw.rounded_rectangle((250, 250, 774, 774), radius=96, outline=(204, 251, 241, 255), width=48)

try:
    font = ImageFont.truetype("arial.ttf", 420)
except OSError:
    font = ImageFont.load_default()

draw.text((512, 520), "SB", fill=(240, 253, 250, 255), font=font, anchor="mm")

variants = {
    "32x32.png": 32,
    "128x128.png": 128,
    "128x128@2x.png": 256,
    "icon.png": 512,
}

for name, dim in variants.items():
    image.resize((dim, dim), Image.Resampling.LANCZOS).save(root / name)

image.resize((256, 256), Image.Resampling.LANCZOS).save(
    root / "icon.ico",
    format="ICO",
    sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)

try:
    image.save(root / "icon.icns", format="ICNS")
except ValueError:
    image.resize((256, 256), Image.Resampling.LANCZOS).save(root / "icon.icns")

print(f"Wrote icons to {root}")
