"""Generate assets/textures/paper_grain.png (run once; output is committed).

A seamless 256x256 tile of dark and light specks plus short fibres, drawn
as grey + alpha so one tile works on light and dark paper stocks.

    python3 tool/gen_paper_grain.py
"""
import random

from PIL import Image, ImageDraw, ImageFilter

SIZE = 256
random.seed(7)

tile = Image.new("LA", (SIZE, SIZE), (128, 0))
px = tile.load()
for y in range(SIZE):
    for x in range(SIZE):
        alpha = min(60, int(abs(random.gauss(0, 1)) * 18))
        alpha -= alpha % 6  # coarse steps keep the PNG small
        if alpha:
            px[x, y] = (20 if random.random() < 0.5 else 245, alpha)

fibres = ImageDraw.Draw(tile)
for _ in range(40):
    x, y = random.uniform(0, SIZE), random.uniform(0, SIZE)
    dx, dy = random.uniform(-9, 9), random.uniform(-3, 3)
    shade = 30 if random.random() < 0.5 else 235
    fibres.line([(x, y), (x + dx, y + dy)], fill=(shade, 38), width=1)

# Blur a 3x3 repeat and crop the centre, so the edges wrap without seams.
big = Image.new("LA", (SIZE * 3, SIZE * 3))
for i in range(3):
    for j in range(3):
        big.paste(tile, (i * SIZE, j * SIZE))
big = big.filter(ImageFilter.GaussianBlur(0.6))
out = big.crop((SIZE, SIZE, SIZE * 2, SIZE * 2))
# Re-quantise after the blur: two grey levels, alpha in steps of 8.
grey, alpha = out.split()
grey = grey.point(lambda v: 20 if v < 128 else 245)
alpha = alpha.point(lambda v: v - v % 8)
Image.merge("LA", (grey, alpha)).save(
    "assets/textures/paper_grain.png", optimize=True
)
