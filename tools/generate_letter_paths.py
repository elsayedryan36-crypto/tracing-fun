"""Generate the guide paths the child follows (one list of strokes per letter).

Run from the project root (after tools/generate_letter_assets.py):
    python3 tools/generate_letter_paths.py

Each letter's centre line is found from the glyph shape (skeleton on a 64x64
grid), split into strokes, and written as normalised points (0..1) to
lib/features/tracing/letter_paths.dart. Points are in the same space as the
tracing area, so they line up with the outline and with the check grid.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
import generate_letter_assets as base  # noqa: E402  (same glyphs and fonts)

ROOT = base.ROOT
N = 64            # path resolution
BOX = 1000.0
FIT = 800.0
SAMPLE_EVERY = 3  # keep every 3rd point (dotted spacing)


def ink_grid(ttf_path, ch, n):
    size = 1000
    font = ImageFont.truetype(ttf_path, size)
    canvas = Image.new('L', (size * 2, size * 2), 0)
    ImageDraw.Draw(canvas).text((size // 2, size // 2), ch, font=font, fill=255)
    ink = canvas.getbbox()
    ink_img = canvas.crop(ink)
    w, h = ink_img.size
    scale = FIT / max(w, h)
    new_w, new_h = max(1, round(w * scale)), max(1, round(h * scale))
    ink_img = ink_img.resize((new_w, new_h), Image.LANCZOS)
    board = Image.new('L', (int(BOX), int(BOX)), 0)
    board.paste(ink_img, ((int(BOX) - new_w) // 2, (int(BOX) - new_h) // 2))
    small = board.resize((n, n), Image.BOX)
    return [[1 if small.getpixel((x, y)) >= 128 else 0 for x in range(n)]
            for y in range(n)]


def thin(img, n):
    """Zhang-Suen thinning on an n x n grid (list of rows)."""
    img = [row[:] for row in img]

    def p_of(y, x):
        return [img[y - 1][x], img[y - 1][x + 1], img[y][x + 1], img[y + 1][x + 1],
                img[y + 1][x], img[y + 1][x - 1], img[y][x - 1], img[y - 1][x - 1]]

    changed = True
    while changed:
        changed = False
        for step in (0, 1):
            clear = []
            for y in range(1, n - 1):
                for x in range(1, n - 1):
                    if not img[y][x]:
                        continue
                    p = p_of(y, x)
                    b = sum(p)
                    if b < 2 or b > 6:
                        continue
                    a = sum(1 for i in range(8) if p[i] == 0 and p[(i + 1) % 8] == 1)
                    if a != 1:
                        continue
                    if step == 0:
                        if p[0] * p[2] * p[4] or p[2] * p[4] * p[6]:
                            continue
                    else:
                        if p[0] * p[2] * p[6] or p[0] * p[4] * p[6]:
                            continue
                    clear.append((y, x))
            if clear:
                changed = True
                for y, x in clear:
                    img[y][x] = 0
    return img


def neighbours(cell, pixels):
    r, c = cell
    out = []
    for dr in (-1, 0, 1):
        for dc in (-1, 0, 1):
            if dr == 0 and dc == 0:
                continue
            q = (r + dr, c + dc)
            if q in pixels:
                out.append(q)
    return out


def strokes_from_skeleton(skel):
    pixels = set(skel)
    visited = set()
    strokes = []

    def walk(start):
        path = [start]
        visited.add(start)
        cur = start
        while True:
            nxt = [q for q in neighbours(cur, pixels) if q not in visited]
            if not nxt:
                break
            # prefer straight (4-neighbour) steps to keep the path smooth
            nxt.sort(key=lambda q: abs(q[0] - cur[0]) + abs(q[1] - cur[1]))
            cur = nxt[0]
            visited.add(cur)
            path.append(cur)
        return path

    endpoints = sorted(p for p in pixels if len(neighbours(p, pixels)) <= 1)
    for p in endpoints:
        if p not in visited:
            strokes.append(walk(p))
    for p in sorted(pixels):
        if p not in visited:
            strokes.append(walk(p))

    # Reading order: top to bottom, then right to left (Arabic) / left to right (English)
    # is decided by the caller; here keep the natural order from the walk.
    return [s for s in strokes if s]


def to_points(stroke):
    picked = stroke[::SAMPLE_EVERY]
    if stroke[-1] not in picked:
        picked.append(stroke[-1])
    return [[round((c + 0.5) / N, 4), round((r + 0.5) / N, 4)] for r, c in picked]


def sample_line(line):
    """Points every SPACING along a polyline in normalised units (same dot spacing as the skeletons)."""
    spacing = SAMPLE_EVERY / N
    out = [list(line[0])]
    carry = 0.0
    for (ax, ay), (bx, by) in zip(line, line[1:]):
        seg = ((bx - ax) ** 2 + (by - ay) ** 2) ** 0.5
        d = spacing - carry
        while d <= seg:
            t = d / seg
            out.append([ax + (bx - ax) * t, ay + (by - ay) * t])
            d += spacing
        carry = seg - (d - spacing)
    if abs(out[-1][0] - line[-1][0]) + abs(out[-1][1] - line[-1][1]) > 1e-6:
        out.append(list(line[-1]))
    return [[round(x, 4), round(y, 4)] for x, y in out]


def main():
    ar_ttf = os.path.join(ROOT, 'assets', 'fonts', 'NotoKufiArabic-Bold.ttf')
    en_ttf = os.path.join(ROOT, 'tools', 'source-fonts', 'Fredoka-Variable.ttf')
    en_static, _keep = base.load_english_bold(en_ttf)
    tmp_en = os.path.join(ROOT, 'tools', '.fredoka-bold-paths.ttf')
    en_static.save(tmp_en)

    entries = [(f'ar_{i}', ch, ar_ttf) for i, ch in enumerate(base.ARABIC)]
    entries += [(f'en_{i}', ch, tmp_en) for i, ch in enumerate(base.ENGLISH)]

    lines = [
        '// GENERATED by tools/generate_letter_paths.py. Do not edit by hand.',
        '// Guide paths: for each letter, a list of strokes; each stroke is a list of',
        '// [x, y] points, normalised 0..1 in the tracing area.',
        '',
        'const Map<String, List<List<List<double>>>> letterPaths = {',
    ]
    total = 0
    for item_id, ch, ttf in entries:
        if item_id in base.EXAMPLE_IDS:
            # The A's strokes are the three centre lines drawn for it (see generate_letter_assets.py).
            pts = [sample_line(line) for line in base.example_centre_norm()]
        else:
            grid = ink_grid(ttf, ch, N)
            skel = thin(grid, N)
            pixels = [(r, c) for r in range(N) for c in range(N) if skel[r][c]]
            strokes = strokes_from_skeleton(pixels)
            # Drop tiny specks, but keep single-point strokes (dots such as the dot of ب).
            strokes = [s for s in strokes if len(s) >= 1]
            pts = [to_points(s) for s in strokes]
        total += len(pts)
        lines.append(f"  '{item_id}': [")
        for stroke in pts:
            body = ', '.join(f'[{x}, {y}]' for x, y in stroke)
            lines.append(f'    [{body}],')
        lines.append('  ],')
    lines.append('};')
    lines.append('')

    out = os.path.join(ROOT, 'lib', 'features', 'tracing', 'letter_paths.dart')
    with open(out, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(lines))
    if os.path.exists(tmp_en):
        os.remove(tmp_en)
    print(f'Wrote paths for {len(entries)} letters, {total} strokes.')


if __name__ == '__main__':
    main()
