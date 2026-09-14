"""Check the delivered JPEG pack. Requires the already-used Pillow package."""
import json
from pathlib import Path

from PIL import Image

folder = Path(__file__).resolve().parents[1]
manifest = json.loads((folder / 'manifest.json').read_text())
config = json.loads((folder / 'source/screens.json').read_text())
expected = {
    f"exports/{preset['id']}/{screen['id']}.jpg": (preset['width'], preset['height'])
    for preset in config['presets'] for screen in config['screens']
}
expected['exports/play-store-feature.jpg'] = (1024, 500)
assert len(manifest) == len(expected) == 31
assert {row['file'] for row in manifest} == set(expected)
assert {str(p.relative_to(folder)) for p in (folder / 'exports').rglob('*.jpg')} == set(expected)
for row in manifest:
    path = folder / row['file']
    with Image.open(path) as img:
        assert img.size == expected[row['file']] == (row['width'], row['height']), path
        assert img.format == 'JPEG' and img.mode == 'RGB', path
        img.verify()
    assert path.stat().st_size < 8_000_000, path
    assert 0 < len(row['alt']) <= 140, path
    if row['store'] == 'Google Play' and row['device'] != 'Feature graphic':
        assert row['width'] * 16 == row['height'] * 9, path
print('31 JPEGs verified: exact dimensions, RGB/no alpha, valid files, size and alt text.')
