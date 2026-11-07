# Lots

Blueprint XML (FreeSO's `XmlHouseData`) for testing and benchmarks. Each is a lot the owner made;
they name objects by GUID and contain no game files.

| File | Size | What it is |
| --- | --- | --- |
| `tonys-lot.xml` | 64 × 64 | The owner's recreation of their original lot in The Sims Online: 294 walls, 758 floor tiles, and 119 objects. The client opens it by default on a real install |
| `community-lot.xml` | 64 × 64 | A lot the owner built near the end of FreeSO's alpha for group events: 564 walls, 1,242 floor tiles, and 211 objects on two floors |

The oracle loads one with `--blueprint` (objects the install doesn't have are left out), and the
Swift tests find them here by path. `oracle-fixtures.sh` adds them to the room-map comparison.
