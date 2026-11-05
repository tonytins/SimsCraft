#!/usr/bin/env python3
"""Writes MockInstall's tuning.dat: the global tuning a Sim's motives read (FreeSO's
VMAvatarMotiveDecay and VMMotiveChange), with made-up values.

- simmotives: small decay rates and 16 waking hours, as mock_sim.py first wrote them;
- lotmotives: every weight 1 for the None category, which the mock lots have, so their runs and
  the hand-worked decay tests keep simple numbers; the other categories get made-up weights that
  don't divide 1000 evenly, so Set Motive Deltas' scaling (a rate times 1000 over the weight)
  truncates, as it does on a real install.

A Persist container (body type 1) around a RefPack stream of literal runs; strings are a 7-bit
length and their bytes plus 13, as FreeSO's Tuning reads. It rewrites the file each run, byte for
byte the same.

Usage: mock_tuning.py Simburbia/MockInstall"""
import os, struct, sys

root = os.path.join(sys.argv[1], "TSOClient")

CATEGORIES = ["None", "Money", "Offbeat", "Romance", "Services", "Shopping", "Skills", "Welcome",
              "Games", "Entertain", "Residence"]
MOTIVES = ["Hunger", "Comfort", "Hygiene", "Bladder", "Energy", "Fun", "Social"]
# Made up: a weight per motive, times a factor per category; None stays at 1.
BASE = [1.1, 0.7, 1.3, 0.9, 1.7, 0.6, 1.9]
FACTOR = [None, 1.25, 0.85, 0.8, 1.0, 1.1, 1.35, 0.75, 0.95, 0.65, 1.05]

def weight(category, motive):
    if FACTOR[category] is None: return "1"
    return "%g" % round(BASE[motive] * FACTOR[category], 3)

lot_motives = [(f"{c}_{m}Weight", weight(ci, mi)) for ci, c in enumerate(CATEGORIES) for mi, m in enumerate(MOTIVES)]
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
