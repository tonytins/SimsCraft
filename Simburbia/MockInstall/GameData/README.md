# Mock Sim

Before Maxis knew what Sims would look like, The Sims had a placeholder Sim of its own. This
folder is Simburbia's: a stand-in Sim that's free to ship, so the game can run, and be shown,
without a copy of The Sims Online. It's also the first test of custom Sims and NPCs, which in
The Sims 1 were made the same way, as custom meshes, and which Simburbia's custom content
support will take.

It's **Animated Characters 3** (version 1.1) by [Kenney](https://www.kenney.nl), released under
[CC0](http://creativecommons.org/publicdomain/zero/1.0/) (`License.txt`). Nothing here is from The
Sims Online, and credit isn't required, but it's given: thank you, Kenney.

| File | Holds |
| --- | --- |
| `characterMedium.gltf` | The character converted to glTF 2.0 (with glTF-Transform): one skinned mesh and a skeleton of 58 joints, with Kenney's bone names (`Hips`, `Spine`, `Head`, `LeftArm`, and so on). No animations |
| `buffer.bin` | The glTF's binary buffer: the mesh's vertices, the skin's weights, and the joints' bind matrices. The glTF names it, so the two stay side by side |
| `Skins/` | Four 256 by 256 skins: `humanFemaleA`, `humanMaleA`, `zombieFemaleA`, `zombieMaleA` |
| `Preview.png` | Kenney's preview of the pack |
| `License.txt` | Kenney's license |

## How it will be used

Queen Margaret's fourth pass (Sims) turns it into TSO's avatar formats, written by a generator in
`../generators/` so the result can be made again: a skeleton, meshes, bindings, outfits, an
appearance, and textures, with Kenney's bones renamed to TSO's, since objects and animations name
bones. Until then the mock install's Sim keeps its made-up one-bone skeleton, which is enough for
FreeSO to create a Sim but not for one to move.
