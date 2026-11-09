"""Generate tracing outlines and check masks from open-licence fonts.

Run from the project root:
    python3 tools/generate_letter_assets.py

Outputs:
  assets/letters/outlines/<id>.svg   letter outline shown on the tracing screen
  lib/features/tracing/letter_masks.dart   32x32 check grid per letter

Both use the same glyph and the same fit rule, so a point on the outline
maps to the same cell in the grid. Ids match LetterCatalog: ar_0..ar_27,
en_0..en_25.

Fonts:
  Arabic:  assets/fonts/NotoKufiArabic-Bold.ttf      (SIL OFL 1.1)
  English: tools/source-fonts/Fredoka-Variable.ttf (SIL OFL 1.1). Download from
           https://github.com/google/fonts/tree/main/ofl/fredoka. Not bundled in the app.
"""

import io
import os

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
ARABIC = list('ابتثجحخدذرزسشصضطظعغفقكلمنهوي')
ENGLISH = [chr(c) for c in range(ord('A'), ord('Z') + 1)]
GRID = 32
BOX = 1000.0      # SVG viewBox and mask coordinate space
FIT = 800.0       # glyph is fitted into this square, centred


def load_english_bold(path):
    font = TTFont(path)
    static = instancer.instantiateVariableFont(font, {'wght': 700, 'wdth': 100})
    tmp = io.BytesIO()
    static.save(tmp)
    tmp.seek(0)
    return TTFont(tmp), tmp


def glyph_for(font, ch):
    cmap = font.getBestCmap()
    if ord(ch) not in cmap:
        raise SystemExit(f'Missing glyph for {ch!r} in font')
    return cmap[ord(ch)]


def svg_for(font, ch):
    glyph_name = glyph_for(font, ch)
    glyph_set = font.getGlyphSet()
    bounds = BoundsPen(glyph_set)
    glyph_set[glyph_name].draw(bounds)
    xmin, ymin, xmax, ymax = bounds.bounds
    width = max(xmax - xmin, ymax - ymin)
    scale = FIT / width
    cx = (xmin + xmax) / 2
    cy = (ymin + ymax) / 2
    # Font units are y-up; SVG is y-down. Centre the glyph at (BOX/2, BOX/2).
    tx = BOX / 2 - scale * cx
    ty = BOX / 2 + scale * cy
    pen = SVGPathPen(glyph_set)
    glyph_set[glyph_name].draw(TransformPen(pen, (scale, 0, 0, -scale, tx, ty)))
    d = pen.getCommands()
    svg = (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {int(BOX)} {int(BOX)}">'
        f'<path d="{d}" fill="#000000"/></svg>\n'
    )
    return svg


def mask_for(ttf_path, ch):
    """Rasterise at 1000 px, fit ink box into FIT square, downsample to GRID."""
    size = 1000
    font = ImageFont.truetype(ttf_path, size)
    canvas = Image.new('L', (size * 2, size * 2), 0)
    ImageDraw.Draw(canvas).text((size // 2, size // 2), ch, font=font, fill=255)
    ink = canvas.getbbox()
    if ink is None:
        raise SystemExit(f'No ink for {ch!r} in {ttf_path}')
    ink_img = canvas.crop(ink)
    w, h = ink_img.size
    scale = FIT / max(w, h)
    new_w, new_h = max(1, round(w * scale)), max(1, round(h * scale))
    ink_img = ink_img.resize((new_w, new_h), Image.LANCZOS)
    board = Image.new('L', (int(BOX), int(BOX)), 0)
    board.paste(ink_img, ((int(BOX) - new_w) // 2, (int(BOX) - new_h) // 2))
    small = board.resize((GRID, GRID), Image.BOX)
    bits = [1 if small.getpixel((x, y)) >= 128 else 0
            for y in range(GRID) for x in range(GRID)]
    return bits


def bits_to_hex(bits):
    value = 0
    for b in bits:
        value = (value << 1) | b
    return format(value, f'0{GRID * GRID // 4}x')


def thin_zhang_suen(bits):
    """One-cell-wide centre line of a glyph grid (Zhang-Suen thinning)."""
    img = [[bits[y * GRID + x] for x in range(GRID)] for y in range(GRID)]

    def neighbours(y, x):
        # P2..P9 clockwise from north
        return [
            img[y - 1][x], img[y - 1][x + 1], img[y][x + 1], img[y + 1][x + 1],
            img[y + 1][x], img[y + 1][x - 1], img[y][x - 1], img[y - 1][x - 1],
        ]

    changed = True
    while changed:
        changed = False
        for step in (0, 1):
            to_clear = []
            for y in range(1, GRID - 1):
                for x in range(1, GRID - 1):
                    if not img[y][x]:
                        continue
                    p = neighbours(y, x)
                    b = sum(p)
                    if b < 2 or b > 6:
                        continue
                    a = sum(1 for i in range(8) if p[i] == 0 and p[(i + 1) % 8] == 1)
                    if a != 1:
                        continue
                    if step == 0:
                        if p[0] * p[2] * p[4] != 0 or p[2] * p[4] * p[6] != 0:
                            continue
                    else:
                        if p[0] * p[2] * p[6] != 0 or p[0] * p[4] * p[6] != 0:
                            continue
                    to_clear.append((y, x))
            if to_clear:
                changed = True
                for y, x in to_clear:
                    img[y][x] = 0
    return [img[y][x] for y in range(GRID) for x in range(GRID)]


def main():
    outlines_dir = os.path.join(ROOT, 'assets', 'letters', 'outlines')
    os.makedirs(outlines_dir, exist_ok=True)

    ar_ttf = os.path.join(ROOT, 'assets', 'fonts', 'NotoKufiArabic-Bold.ttf')
    en_src = os.path.join(ROOT, 'tools', 'source-fonts', 'Fredoka-Variable.ttf')
    en_static, _keep = load_english_bold(en_src)
    ar_font = TTFont(ar_ttf)

    entries = []
    for i, ch in enumerate(ARABIC):
        entries.append((f'ar_{i}', ch, ar_font, ar_ttf))
    for i, ch in enumerate(ENGLISH):
        entries.append((f'en_{i}', ch, en_static, None))

    masks = {}
    centres = {}
    for item_id, ch, font, ttf_path in entries:
        with open(os.path.join(outlines_dir, f'{item_id}.svg'), 'w', encoding='utf-8') as fh:
            fh.write(svg_for(font, ch))
        if ttf_path is None:
            # Save the bold English instance once so PIL can rasterise it.
            ttf_path = os.path.join(ROOT, 'tools', '.fredoka-bold.ttf')
            if not os.path.exists(ttf_path):
                en_static.save(ttf_path)
        bits = mask_for(ttf_path, ch)
        masks[item_id] = bits_to_hex(bits)
        centres[item_id] = bits_to_hex(thin_zhang_suen(bits))

    tmp = os.path.join(ROOT, 'tools', '.fredoka-bold.ttf')
    if os.path.exists(tmp):
        os.remove(tmp)

    dart_path = os.path.join(ROOT, 'lib', 'features', 'tracing', 'letter_masks.dart')
    lines = [
        '// GENERATED by tools/generate_letter_assets.py. Do not edit by hand.',
        '// Each value is a 32x32 grid, row by row, as hex (1 bit per cell).',
        '// 1 = letter ink. Used to check the child\'s trace (see letter_check.dart).',
        '',
        f'const int letterMaskGrid = {GRID};',
        '',
        'const Map<String, String> letterMaskHex = {',
    ]
    for key, value in masks.items():
        lines.append(f"  '{key}': '{value}',")
    lines.append('};')
    lines.append('')
    lines.append('/// One-cell-wide centre line of each letter (same grid).')
    lines.append('const Map<String, String> letterCentreHex = {')
    for key, value in centres.items():
        lines.append(f"  '{key}': '{value}',")
    lines.append('};')
    lines.append('')
    with open(dart_path, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(lines))

    print(f'Wrote {len(entries)} outlines and {len(masks)} masks.')


if __name__ == '__main__':
    main()
