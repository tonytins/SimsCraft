#!/usr/bin/env python3
"""Writes the mock install's walls and floors, all made up.

    python3 Simburbia/MockInstall/generators/mock_build.py

Writes, under MockInstall/TSOClient:

- objectdata/globals/build.iff   the build catalog's strings
- objectdata/globals/walls.iff   wall styles (masks), wall patterns, and junctions
- objectdata/globals/floors.iff  global floors, pool tiles, and water tiles
- housedata/walls/walls.far      two archive wall patterns
- housedata/floors/floors.far    two archive floors

Every sprite is a flat shape in a few colors, sized as FreeSO's WallComponent and
FloorComponent place them, so the client can draw the mock lot. None of it comes from,
or stands for, EA's game data. Like the base game, the mock has only the first archive of
each kind. Writes only the files that don't exist yet, so deleting one remakes it.
"""

import os, struct, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "TSOClient")

# --- IFF and FAR1 ------------------------------------------------------------------------

def iff(chunks):
    """An IFF 2.5 file with no resource map. Each chunk is (type, id, label, data)."""
    out = bytearray(b"IFF FILE 2.5:TYPE FOLLOWED BY SIZE\0 JAMIE DOORNBOS & MAXIS 1".ljust(60, b"\0"))
    out += struct.pack(">I", 0)
    for type_code, chunk_id, label, data in chunks:
        out += type_code.encode("ascii")
        out += struct.pack(">IHH", len(data) + 76, chunk_id, 0x10)
        out += label.encode("ascii").ljust(64, b"\0")[:64]
        out += data
    return bytes(out)

def far1(files):
    """A FAR 1b archive (TSO's layout): header, file data, then the manifest."""
    out = bytearray(b"FAR!byAZ" + struct.pack("<II", 1, 0))
    offsets = []
    for _, data in files:
        offsets.append(len(out))
        out += data
    struct.pack_into("<I", out, 12, len(out))
    out += struct.pack("<I", len(files))
    for (name, data), offset in zip(files, offsets):
        out += struct.pack("<iiih", len(data), len(data), offset, len(name)) + name.encode("ascii")
    return bytes(out)

def strings(values):
    """A STR# in format -1: a count, then C strings."""
    return struct.pack("<hH", -1, len(values)) + b"".join(v.encode("utf-8") + b"\0" for v in values)

# --- Colors ------------------------------------------------------------------------------

# Index 0 is unused: SPR# leaves skipped pixels transparent, SPR2 marks them with a run.
PALETTE = [
    (0, 0, 0),
    (226, 214, 186),  # 1 plaster
    (186, 172, 146),  # 2 plaster, shaded
    (170, 72, 56),    # 3 brick
    (128, 52, 40),    # 4 brick, shaded
    (92, 128, 176),   # 5 blue paint
    (70, 100, 140),   # 6 blue paint, shaded
    (150, 110, 70),   # 7 wood
    (120, 86, 54),    # 8 wood, shaded
    (140, 140, 136),  # 9 stone
    (110, 110, 106),  # 10 stone, shaded
    (70, 140, 200),   # 11 water
    (230, 236, 240),  # 12 pool tile
    (60, 60, 64),     # 13 dark edge
    (176, 54, 96),    # 14 carpet
    (198, 160, 92),   # 15 straw
]

def palt():
    """A PALT of 256 colors: version, count, 8 reserved bytes, RGB triples."""
    colors = PALETTE + [(0, 0, 0)] * (256 - len(PALETTE))
    return struct.pack("<II", 1, 256) + bytes(8) + b"".join(bytes(c) for c in colors)

# --- Sprites -----------------------------------------------------------------------------

def spr_frame(width, height, pixel):
    """A SPR# frame: pixel(x, y) gives a palette index, or 0 for none."""
    out = bytearray(struct.pack("<IHH", 0, height, width))
    for y in range(height):
        row = bytearray()
        x = 0
        while x < width:
            index = pixel(x, y)
            run = 1
            while x + run < width and run < 255 and pixel(x + run, y) == index:
                run += 1
            row += bytes([0x01, run]) if index == 0 else bytes([0x02, run, index, 0])
            x += run
        out += bytes([0x04, len(row) + 2]) + row
    out += bytes([0x05, 0])
    return bytes(out)

def spr(frames, palette=1):
    """A SPR# chunk, version 1000, little-endian, from encoded frames."""
    header = struct.pack("<HHII", 1000, 0, len(frames), palette)
    offset = len(header) + 4 * len(frames)
    table, body = bytearray(), bytearray()
    for frame in frames:
        table += struct.pack("<I", offset + len(body))
        body += frame
    return header + bytes(table) + bytes(body)

def spr2_frame(width, height, pixel, depth=None):
    """A SPR2 frame (version 1000): pixel(x, y) gives a palette index, or 0 for transparent.
    With depth(x, y), the frame has a depth layer too."""
    flags = 3 if depth else 1
    out = bytearray(struct.pack("<HHIHHhh", width, height, flags, 1, 0, 0, 0))
    for y in range(height):
        row = bytearray()
        x = 0
        while x < width:
            index = pixel(x, y)
            # A run of transparent pixels, or of colored ones (each keeps its own index).
            run = 1
            while x + run < width and (pixel(x + run, y) == 0) == (index == 0):
                run += 1
            if index == 0:
                row += struct.pack("<H", (0x03 << 13) | run)
            elif depth:
                row += struct.pack("<H", (0x01 << 13) | run)
                for i in range(run):
                    row += bytes([depth(x + i, y), pixel(x + i, y)])
            else:
                row += struct.pack("<H", (0x06 << 13) | run)
                row += bytes(pixel(x + i, y) for i in range(run))
                if run % 2:
                    row += b"\0"
            x += run
        out += struct.pack("<H", len(row) + 2) + row
    out += struct.pack("<H", 0x05 << 13)
    return bytes(out)

def spr2(frames, palette=1):
    """A SPR2 chunk, version 1000, from encoded frames."""
    header = struct.pack("<III", 1000, len(frames), palette)
    offset = len(header) + 4 * len(frames)
    table, body = bytearray(), bytearray()
    for frame in frames:
        table += struct.pack("<I", offset + len(body))
        body += frame
    return header + bytes(table) + bytes(body)

# --- Shapes ------------------------------------------------------------------------------

# Zooms as FreeSO numbers them in walls.iff: far, medium, near, each half the next's size.
ZOOMS = [("far", 4), ("medium", 2), ("near", 1)]

def wall_frames(color, shade, height_fraction=1.0, edge=13):
    """The four sides of a wall (top-left, top-right, horizontal and vertical diagonal), at each
    zoom, sized as FreeSO's DESTINATION_NEAR, _MED, and _FAR. A wall rises 239 rows at near; a
    cut-down one is a fraction of that. Its top row is the dark edge."""
    zooms = []
    for _, scale in ZOOMS:
        sizes = [(64 // scale, 271 // scale), (64 // scale, 271 // scale), (128 // scale, 240 // scale), (max(16 // scale, 2), 232 // scale)]
        rise = 239 // scale
        tall = max(int(rise * height_fraction), 2)
        frames = []
        for side, (width, height) in enumerate(sizes):
            def pixel(x, y, side=side, width=width, height=height):
                if side == 0:    # rises to the right, half a row a column
                    bottom = height - 1 - (x // 2)
                elif side == 1:  # falls to the right
                    bottom = height - 1 - ((width - 1 - x) // 2)
                else:            # the diagonals stand straight on screen
                    bottom = height - 1
                top = bottom - tall + 1
                if y < top or y > bottom:
                    return 0
                if y == top:
                    return edge
                return shade if side in (1, 3) else color
            frames.append(spr_frame(width, height, pixel))
        zooms.append(frames)
    return zooms

def diamond(width, height):
    """Whether (x, y) is inside a floor tile's diamond of this size."""
    def inside(x, y):
        cx, cy = (width - 1) / 2, (height - 1) / 2
        return abs(x - cx) / (width / 2) + abs(y - cy) / (height / 2) <= 1.0
    return inside

# FreeSO's FLOORDEST rectangles: near 127 by 64, medium 63 by 32, far 31 by 16.
FLOOR_SIZES = [(31, 16), (63, 32), (127, 64)]

def floor_sprites(color, accent):
    """A floor tile at each zoom, far first, with a checker of two colors."""
    out = []
    for width, height in FLOOR_SIZES:
        inside = diamond(width, height)
        cell = max(width // 8, 2)
        out.append(spr2([spr2_frame(width, height,
                                    lambda x, y: 0 if not inside(x, y) else (color if ((x // cell + y * 2 // cell) % 2) else accent))]))
    return out

# --- Files -------------------------------------------------------------------------------

def build_iff():
    styles = []
    for price, name in [("0", "Mock Wall"), ("5", "Mock Picket Fence"), ("8", "Mock Iron Fence"),
                        ("6", "Mock Privacy Fence"), ("4", "Mock Banister")]:
        styles += [price, name, "A made-up " + name[5:].lower() + "."]
    # Two global floors, and one more wallpaper than floors, as the real tables have: FreeSO
    # counts the global floors from the wallpaper strings (DIFF-29).
    floors = ["3", "Mock Grass", "A made-up lawn.", "6", "Mock Planks", "Made-up boards."]
    wallpapers = ["2", "Mock Plaster", "Made-up plaster.", "4", "Mock Brick", "Made-up brick.",
                  "3", "Mock Paint", "Made-up blue paint."]
    pools = ["10", "Mock Pool", "A made-up pool tile.", "1", "Mock Water", "Made-up water."]
    return iff([("STR#", 0x81, "Wall", strings(styles)), ("STR#", 0x82, "Floor", strings(floors)),
                ("STR#", 0x83, "Wallpaper", strings(wallpapers)), ("STR#", 0x85, "Pool", strings(pools))])

def walls_iff():
    chunks = [("PALT", 1, "mock palette", palt())]
    # Styles: 1 the wall, 2, 12, 13, 14 the fences and banister (low), 7 and 8 the cutaway
    # styles a wall takes beside a door when walls are cut. Style n's full masks are at 2n
    # (far), 2n + 512 (medium), 2n + 1024 (near); its cut-down ones one after each.
    for style, fraction, down in [(1, 1.0, 0.18), (2, 0.3, None), (7, 1.0, 0.18), (8, 1.0, 0.18),
                                  (12, 0.4, None), (13, 0.3, None), (14, 0.25, None)]:
        # A mask's shape is what counts, so masks are one color.
        for zoom, frames in enumerate(wall_frames(13, 13, fraction, edge=13)):
            chunks.append(("SPR#", style * 2 + zoom * 512, f"style {style} up", spr(frames)))
        if down:
            for zoom, frames in enumerate(wall_frames(13, 13, down, edge=13)):
                chunks.append(("SPR#", style * 2 + 1 + zoom * 512, f"style {style} down", spr(frames)))
    # Patterns: 1 to 3 wallpapers, 248 to 251 the fences' own, 252 and 253 the cutaway
    # overlays. Pattern n is at n + 1536 (far), n + 1792 (medium), n + 2048 (near).
    for pattern, color, shade, fraction in [(1, 1, 2, 1.0), (2, 3, 4, 1.0), (3, 5, 6, 1.0),
                                            (248, 15, 7, 0.3), (249, 7, 8, 0.4), (250, 13, 13, 0.3),
                                            (251, 7, 8, 0.25), (252, 9, 10, 0.18), (253, 9, 10, 0.18)]:
        for zoom, frames in enumerate(wall_frames(color, shade, fraction)):
            chunks.append(("SPR#", pattern + 1536 + zoom * 256, f"pattern {pattern}", spr(frames)))
    # Junctions: 46 ways walls meet, each a small dark cap where the tile's corners are.
    for zoom, (width, height) in enumerate([(32, 16), (64, 32), (128, 64)]):
        cap = max(width // 16, 1)
        def pixel(x, y, width=width, height=height, cap=cap):
            return 13 if abs(x - width // 2) <= cap and abs(y - height // 2) <= cap else 0
        frame = spr_frame(width, height, pixel)
        chunks.append(("SPR#", 4096 + zoom, "junctions", spr([frame] * 46)))
    return iff(chunks)

def floors_iff():
    chunks = [("PALT", 1, "mock palette", palt())]
    # Floor 1, "grass", is straw-colored so it stands apart from the client's green ground.
    for floor, color, accent in [(1, 15, 7), (2, 7, 8)]:
        for zoom, sprite in enumerate(floor_sprites(color, accent)):
            chunks.append(("SPR2", floor + zoom * 256, f"floor {floor}", sprite))
    # Pool tiles: 16 shapes (which of the four sides join another pool tile) at 0x400 (far),
    # 0x410 (medium), and 0x420 (near), then corner pieces at 0x430 up, four a zoom.
    for zoom, (width, height) in enumerate(FLOOR_SIZES):
        inside = diamond(width, height)
        edge = max(width // 16, 1)
        for shape in range(16):
            # A tiled rim at the tile's ends unless all four sides join another pool tile.
            def pixel(x, y, shape=shape, edge=edge, width=width, inside=inside):
                if not inside(x, y):
                    return 0
                return 12 if shape != 0xF and (x < edge or x >= width - edge) else 11
            chunks.append(("SPR2", 0x400 + zoom * 16 + shape, "pool", spr2([spr2_frame(width, height, pixel)])))
        for corner in range(4):
            chunks.append(("SPR2", 0x430 + zoom * 4 + corner, "pool corner",
                           spr2([spr2_frame(max(width // 8, 2), max(height // 8, 2), lambda x, y: 12)])))
    # Water: 16 shapes at 0x800 up, each with three frames (near, medium, far) and a depth layer
    # FreeSO turns into alpha. Every pixel is written, with depth 0 (no alpha) outside the
    # diamond: a transparent run would get depth 255, which becomes opaque black. Inside it's
    # 255: FreeSO's floor copy, which fills the next tile's half of the texture, copies only
    # pixels at alpha 254 or more.
    for shape in range(16):
        frames = []
        for width, height in reversed(FLOOR_SIZES):
            inside = diamond(width, height)
            frames.append(spr2_frame(width, height, lambda x, y: 11,
                                     depth=lambda x, y, inside=inside: 255 if inside(x, y) else 0))
        chunks.append(("SPR2", 0x800 + shape, "water", spr2(frames)))
    return iff(chunks)

def archive_wall(name, price, color, shade):
    chunks = [("STR#", 0, "catalog", strings([name, price, "Made up for the mock install."])),
              ("PALT", 1, "mock palette", palt())]
    for chunk_id, frames in zip([1, 1793, 2049], wall_frames(color, shade)):
        chunks.append(("SPR#", chunk_id, name, spr(frames)))
    return iff(chunks)

def archive_floor(name, price, color, accent):
    chunks = [("STR#", 0, "catalog", strings([name, price, "Made up for the mock install."])),
              ("PALT", 1, "mock palette", palt())]
    for chunk_id, sprite in zip([1, 257, 513], floor_sprites(color, accent)):
        chunks.append(("SPR2", chunk_id, name, sprite))
    return iff(chunks)

def main():
    files = {
        "objectdata/globals/build.iff": build_iff(),
        "objectdata/globals/walls.iff": walls_iff(),
        "objectdata/globals/floors.iff": floors_iff(),
        "housedata/walls/walls.far": far1([("mockstone.wll", archive_wall("Mock Stone", "7", 9, 10)),
                                           ("mockpanel.wll", archive_wall("Mock Panel", "5", 7, 8))]),
        "housedata/floors/floors.far": far1([("mocktile.flr", archive_floor("Mock Tile", "5", 12, 9)),
                                             ("mockcarpet.flr", archive_floor("Mock Carpet", "8", 14, 13))]),
    }
    missing = {path: data for path, data in files.items() if not os.path.exists(os.path.join(ROOT, path))}
    if not missing:
        sys.exit("mock_build.py: every file is already written; delete one to remake it")
    for path, data in missing.items():
        target = os.path.join(ROOT, path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "wb") as out:
            out.write(data)
        print(f"{path}: {len(data)} bytes")

if __name__ == "__main__":
    main()
