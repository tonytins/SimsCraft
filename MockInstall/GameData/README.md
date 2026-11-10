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

## How it's used

`../generators/mock_avatar.py` turns it into TSO's avatar formats in `../FreeSO/TSOClient/avatardata/`: a
skeleton under TSO's bone names (objects and animations name bones; Kenney's are mapped onto TSO's
29, and its control bones dropped), a body and a head mesh cut from Kenney's one mesh, bindings,
appearances, outfits, and textures from the two human skins, and placeholder animations. The
zombie skins aren't used yet. Kenney's character rests in a T-pose with its own joint axes, so
animations written for TSO's skeleton wouldn't fit it; the placeholders are made for it.
