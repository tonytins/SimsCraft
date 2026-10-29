#!/usr/bin/env python3
"""Gives MockInstall's made-up Sim what FreeSO needs to create it, all made up:

- body strings (STR# 200) named by the Sim's OBJD BodyStringID, in objiff.far's mocksim.iff;
- the walk (STR# 150) and swim (STR# 158) animation names, in global.iff;
- a one-bone skeleton, adult.skel, in avatardata/skeletons/skeletons.dat;
- the motive tuning, in tuning.dat.

It patches the files in place, once: it was run on 2026-10-29 to make what's committed, and it
stops if the files are already patched. It's kept to show how they were made. Rewrites objiff.far
whole; every other entry is copied byte for byte.

Usage: mock_sim.py NSOClient/MockInstall/TSOClient"""
import os, struct, sys

root = sys.argv[1]
far_path = os.path.join(root, "objectdata/objects/objiff.far")

# --- objiff.far (FAR 1b): read every entry
b = open(far_path, "rb").read()
assert b[:8] == b"FAR!byAZ"
version, manifest = struct.unpack_from("<II", b, 8)
count, = struct.unpack_from("<I", b, manifest)
p, entries = manifest + 4, []
for _ in range(count):
    size1, size2, offset, name_length = struct.unpack_from("<iiih", b, p)
    name = b[p + 14:p + 14 + name_length]
    entries.append([name, b[offset:offset + size1]])
    p += 14 + name_length

def chunks(iff):
    q, out = 64, []
    while q + 76 <= len(iff):
        size, = struct.unpack_from(">I", iff, q + 4)
        out.append([iff[q:q + 4], iff[q + 8:q + 10], iff[q + 10:q + 12], iff[q + 12:q + 76], iff[q + 76:q + size]])
        q += size
    return iff[:64], out

def string_table(strings):
    """STR# format -2: a count, then each string and an empty comment, NUL-terminated."""
    return struct.pack("<hH", -2, len(strings)) + b"".join(t.encode("ascii") + b"\0\0" for t in strings)

def chunk(type_code, chunk_id, label, data):
    return [type_code, struct.pack(">H", chunk_id), struct.pack(">H", 0x10), label.ljust(64, b"\0"), data]

BODY_STRINGS = 200
for entry in entries:
    if entry[0] != b"mocksim.iff":
        continue
    header, parts = chunks(entry[1])
    assert not any(c[0] == b"STR#" and struct.unpack(">H", c[1])[0] == BODY_STRINGS for c in parts), "already patched"
    for c in parts:
        if c[0] == b"OBJD":
            words = bytearray(c[4])
            struct.pack_into("<H", words, 4 + 2 * 17, BODY_STRINGS)   # BodyStringID
            c[4] = bytes(words)
    # The body strings FreeSO's VMAvatar reads, by index: 0 type, 1 body, 2 head, 9 random
    # heads, 10 random bodies, 11 names, 12 gender, 13 age, 14 skin tone. Empty outfits leave
    # FreeSO's default.
    body = ["adult"] + [""] * 10 + ["Mock Sim", "female", "27", "lgt"]
    parts.append(chunk(b"STR#", BODY_STRINGS, b"mock body strings", string_table(body)))
    entry[1] = header + b"".join(c[0] + struct.pack(">I", 76 + len(c[4])) + c[1] + c[2] + c[3] + c[4] for c in parts)
    break
else:
    sys.exit("no mocksim.iff")

data = b"".join(e[1] for e in entries)
out = bytearray(b"FAR!byAZ" + struct.pack("<II", version, 16 + len(data)) + data)
offset = 16
out += struct.pack("<I", len(entries))
for name, contents in entries:
    out += struct.pack("<iiih", len(contents), len(contents), offset, len(name)) + name
    offset += len(contents)
open(far_path, "wb").write(out)

# --- global.iff: the walk (STR# 150) and swim (STR# 158) animation names FreeSO's InitBodyData
# copies for every adult Sim, made up.
global_path = os.path.join(root, "objectdata/globals/global.iff")
header, parts = chunks(open(global_path, "rb").read())
assert not any(c[0] == b"STR#" for c in parts), "global.iff already has string tables"
parts.append(chunk(b"STR#", 150, b"mock walk animations", string_table(["mock-walk", "mock-walk-fast"])))
parts.append(chunk(b"STR#", 158, b"mock swim animations", string_table(["mock-swim"])))
open(global_path, "wb").write(header + b"".join(c[0] + struct.pack(">I", 76 + len(c[4])) + c[1] + c[2] + c[3] + c[4] for c in parts))

# --- adult.skel: FreeSO's Skeleton.Read reads integers big-endian and floats little-endian.
def pascal(text):
    return bytes([len(text)]) + text.encode("ascii")

bone = (struct.pack(">i", 0) + pascal("ROOT") + pascal("NULL") + b"\0"
        + struct.pack("<3f", 0, 0, 0)            # translation (FreeSO negates x)
        + struct.pack("<4f", 0, 0, 0, -1)        # rotation x, y, z, w; FreeSO negates y, z, w: identity
        + struct.pack(">3i", 1, 1, 1)            # can translate, rotate, blend
        + struct.pack("<2f", 0, 0))              # wiggle value and power
skeleton = struct.pack(">I", 1) + pascal("mock adult") + struct.pack(">h", 1) + bone

# --- skeletons.dat (FAR 3): one uncompressed entry, adult.skel, type 5, file 1, as 1.1097 has it.
name = b"adult.skel"
far3 = bytearray(b"FAR!byAZ" + struct.pack("<II", 3, 16 + len(skeleton)) + skeleton)
far3 += struct.pack("<I", 1)
far3 += struct.pack("<I", len(skeleton)) + len(skeleton).to_bytes(3, "little") + b"\0"
far3 += struct.pack("<IBBH", 16, 0, 0, len(name)) + struct.pack("<II", 5, 1) + name
os.makedirs(os.path.join(root, "avatardata/skeletons"), exist_ok=True)
open(os.path.join(root, "avatardata/skeletons/skeletons.dat"), "wb").write(far3)
print(f"patched mocksim.iff; wrote skeletons.dat ({len(far3)} bytes, adult.skel {len(skeleton)} bytes)")

# --- tuning.dat: the global tuning a Sim's motives read (FreeSO's VMAvatarMotiveDecay and
# VMMotiveChange), with made-up values. A Persist container (body type 1) around a RefPack stream
# of literal runs; strings are a 7-bit length and their bytes plus 13, as FreeSO's Tuning reads.
CATEGORIES = ["None", "Money", "Offbeat", "Romance", "Services", "Shopping", "Skills", "Welcome",
              "Games", "Entertain", "Residence"]
MOTIVES = ["Hunger", "Comfort", "Hygiene", "Bladder", "Energy", "Fun", "Social"]
lot_motives = [(f"{c}_{m}Weight", "1") for c in CATEGORIES for m in MOTIVES]
sim_motives = [("HungerDecrementRatio", "0.5"), ("ComfortDecrementActive", "0.5"),
               ("HygieneDecrementAwake", "0.5"), ("HygieneDecrementAsleep", "0.25"),
               ("BladderDecrementAwake", "0.5"), ("BladderDecrementAsleep", "0.25"),
               ("HungerToBladderMultiplier", "0.5"), ("EnergySpan", "100"), ("WakeHours", "16"),
               ("EntDecrementAwake", "0.5"), ("SocialDecrementBase", "0.25"), ("SocialDecrementMultiplier", "0.5")]

def tuning_string(text):
    raw = bytes((ord(ch) + 13) & 0xFF for ch in text)
    length, prefix = len(raw), bytearray()
    while True:
        byte = length & 0x7F; length >>= 7
        prefix.append(byte | (0x80 if length else 0))
        if not length: break
    return bytes(prefix) + raw

body = struct.pack("<I", 2)
for name, values in [("lotmotives", lot_motives), ("simmotives", sim_motives)]:
    body += tuning_string(name) + struct.pack("<I", len(values))
    for key, value in values:
        body += tuning_string(key) + tuning_string(value)

# RefPack, literals only: runs of up to 112 bytes (a multiple of 4), then a stop code with the
# last 0 to 3 bytes.
stream, rest = bytearray(), body
while len(rest) >= 4:
    run = min(112, len(rest) - len(rest) % 4)
    stream.append(0xE0 | ((run - 4) >> 2)); stream += rest[:run]; rest = rest[run:]
stream.append(0xFC | len(rest)); stream += rest
tuning = (bytes([1]) + struct.pack("<III", len(body), len(stream), len(stream) + 5)
          + struct.pack("<H", 0xFB10) + len(body).to_bytes(3, "big") + bytes(stream))
open(os.path.join(root, "tuning.dat"), "wb").write(tuning)
print(f"wrote tuning.dat ({len(tuning)} bytes: lotmotives {len(lot_motives)} keys, simmotives {len(sim_motives)})")
