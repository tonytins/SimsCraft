# Install differences

How the installed copies of *The Sims Online* differ, file by file, from the oldest to the newest.
Each section compares one copy with the next newer one, so it shows what the patches between them
changed. The copies are named by the environment variables that pointed `tsofiles-check` at them:
`TSO_BETA_DIR` is a beta, `TSO_CLASSIC_DIR` an older production copy, and `TSO_GAME_DIR` the copy
closest to the one FreeSO was built against. `tsofiles-check` wrote this on 2026-10-30. It names files,
archive entries, IFF chunks (the resources inside the game's object files), and object IDs (GUIDs);
it holds none of the game's own data.

When NSOClient, or FreeSO (which NSOClient is checked against), behaves differently on two copies,
this shows what changed in the game's files, before anyone looks for a bug in the code. It's
written once: delete it and run `tsofiles-check` with the variables set to write it again. What the
differences mean for NewSO is noted by hand beside it, in `install-notes.md`.

## Summary

| Step | Identical | Only in the older | Only in the newer | Different |
| --- | ---: | ---: | ---: | ---: |
| `TSO_BETA_DIR` (1.3.2.121) to `TSO_CLASSIC_DIR` (1.145.1.0) | 1541 | 77 | 20 | 125 |
| `TSO_CLASSIC_DIR` (1.145.1.0) to `TSO_GAME_DIR` (1.1097.1.0) | 1369 | 167 | 741 | 150 |

## `TSO_BETA_DIR` (1.3.2.121) to `TSO_CLASSIC_DIR` (1.145.1.0)

### Only in `TSO_BETA_DIR` (1.3.2.121)

- `cities/city_0001/elevation.server`
- `cities/city_0001/terraintype.server`
- `cities/city_0002/elevation.server`
- `cities/city_0002/terraintype.server`
- `cities/city_0003/elevation.server`
- `cities/city_0003/terraintype.server`
- `cities/city_0004/elevation.server`
- `cities/city_0004/terraintype.server`
- `cities/city_0005/elevation.server`
- `cities/city_0005/terraintype.server`
- `cities/city_0006/elevation.server`
- `cities/city_0006/terraintype.server`
- `cities/city_0007/elevation.server`
- `cities/city_0007/terraintype.server`
- `cities/city_0008/elevation.server`
- `cities/city_0008/terraintype.server`
- `cities/city_0009/elevation.server`
- `cities/city_0009/terraintype.server`
- `cities/city_0010/elevation.server`
- `cities/city_0010/terraintype.server`
- `cities/city_0011/elevation.server`
- `cities/city_0011/terraintype.server`
- `cities/city_0012/elevation.server`
- `cities/city_0012/terraintype.server`
- `cities/city_0013/elevation.server`
- `cities/city_0013/terraintype.server`
- `cities/city_0014/elevation.server`
- `cities/city_0014/terraintype.server`
- `cities/city_0015/elevation.server`
- `cities/city_0015/terraintype.server`
- `cities/city_0016/elevation.server`
- `cities/city_0016/terraintype.server`
- `cities/city_0017/elevation.server`
- `cities/city_0017/terraintype.server`
- `cities/city_0018/elevation.server`
- `cities/city_0018/terraintype.server`
- `cities/city_0019/elevation.server`
- `cities/city_0019/terraintype.server`
- `cities/city_0020/elevation.server`
- `cities/city_0020/terraintype.server`
- `cities/city_0021/elevation.server`
- `cities/city_0021/terraintype.server`
- `cities/city_0022/elevation.server`
- `cities/city_0022/terraintype.server`
- `cities/city_0023/elevation.server`
- `cities/city_0023/terraintype.server`
- `cities/city_0024/elevation.server`
- `cities/city_0024/terraintype.server`
- `cities/city_0025/city_0001/elevation.bmp`
- `cities/city_0025/city_0001/elevation.server`
- `cities/city_0025/city_0001/forestdensity.bmp`
- `cities/city_0025/city_0001/foresttype.bmp`
- `cities/city_0025/city_0001/roadmap.bmp`
- `cities/city_0025/city_0001/terraintype.bmp`
- `cities/city_0025/city_0001/terraintype.server`
- `cities/city_0025/city_0001/thumbnail.bmp`
- `cities/city_0025/city_0001/vertexcolor.bmp`
- `cities/city_0025/elevation.server`
- `cities/city_0025/terraintype.server`
- `cities/city_0026/elevation.server`
- `cities/city_0026/terraintype.server`
- `cities/city_0027/elevation.server`
- `cities/city_0027/terraintype.server`
- `cities/city_0028/elevation.server`
- `cities/city_0028/terraintype.server`
- `cities/city_0029/elevation.server`
- `cities/city_0029/terraintype.server`
- `cities/city_0030/elevation.server`
- `cities/city_0030/terraintype.server`
- `music/modes/create/user/readme.txt`
- `music/modes/load/user/readme.txt`
- `music/modes/map/tsobuild4.mp3`
- `music/modes/map/tsobuild6.mp3`
- `music/modes/map/user/readme.txt`
- `music/modes/select/user/readme.txt`
- `sounddata/tsov2.hot`
- `sounddata/tsov2.hsm`

### Only in `TSO_CLASSIC_DIR` (1.145.1.0)

- `gamedata/uiscripts/fwebcommenteditdialog.uis`
- `gamedata/uitext.dir/_255_fwebcommenteditdlgstrings.cst`
- `housedata/default_house.xml`
- `objectdata/objects/objspf9.far`
- `uigraphics/customcontent/cc_bodiesbtn.bmp`
- `uigraphics/customcontent/cc_dropdown.bmp`
- `uigraphics/customcontent/cc_dropdownbtn.bmp`
- `uigraphics/customcontent/cc_dropdowntextline.bmp`
- `uigraphics/customcontent/cc_floorsbtn.bmp`
- `uigraphics/customcontent/cc_headsbtn.bmp`
- `uigraphics/customcontent/cc_objectsbtn.bmp`
- `uigraphics/customcontent/cc_textentry.bmp`
- `uigraphics/customcontent/cc_wallsbtn.bmp`
- `uigraphics/hints/hint_chasemaze.bmp`
- `uigraphics/hints/hint_mazepizza.bmp`
- `uigraphics/hints/hint_mechanicskill.bmp`
- `uigraphics/hints/hint_parental_bookmark.bmp`
- `uigraphics/hints/hint_pizza.bmp`
- `uigraphics/hints/hint_pizzachase.bmp`
- `video/tsointromovie.dat`

### Different files

#### `.castanet/index.mrb`

87585 bytes in the older, 84755 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `.castanet/properties.txt`

180 bytes in the older, 180 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `.castanet/publish.mrb`

102651 bytes in the older, 99366 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `AssetManagerD.dll`

503808 bytes in the older, 503808 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `avatardata/accessories/appearances/appearances.dat`

FAR3, 47127 bytes in the older, 47287 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 0.

#### `avatardata/accessories/bindings/bindings.dat`

FAR3, 164997 bytes in the older, 165413 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 0.

#### `avatardata/accessories/meshes/meshes.dat`

FAR3, 2044403 bytes in the older, 2114381 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 0.

#### `avatardata/accessories/textures/textures.dat`

FAR3, 2398861 bytes in the older, 2400339 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 0.

#### `avatardata/animations/animations.dat`

FAR3, 160775206 bytes in the older, 161003506 in the newer.

Entries only in the older: 4659, only in the newer: 4668, changed: 17.

#### `avatardata/bodies/appearances/appearances.dat`

FAR3, 182863 bytes in the older, 202387 in the newer.

Entries only in the older: 0, only in the newer: 270, changed: 0.

#### `avatardata/bodies/bindings/bindings.dat`

FAR3, 263708 bytes in the older, 291344 in the newer.

Entries only in the older: 0, only in the newer: 270, changed: 0.

#### `avatardata/bodies/collections/collections.dat`

FAR3, 7318 bytes in the older, 7955 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 5.

#### `avatardata/bodies/meshes/meshes.dat`

FAR3, 6966551 bytes in the older, 7191963 in the newer.

Entries only in the older: 0, only in the newer: 6, changed: 1.

#### `avatardata/bodies/outfits/outfits.dat`

FAR3, 73883 bytes in the older, 81741 in the newer.

Entries only in the older: 0, only in the newer: 90, changed: 0.

#### `avatardata/bodies/purchasables/purchasables.dat`

FAR3, 58731 bytes in the older, 65059 in the newer.

Entries only in the older: 0, only in the newer: 90, changed: 0.

#### `avatardata/bodies/textures/textures.dat`

FAR3, 64992490 bytes in the older, 70812152 in the newer.

Entries only in the older: 0, only in the newer: 270, changed: 28.

#### `avatardata/bodies/thumbnails/thumbnails.dat`

FAR3, 3680269 bytes in the older, 4055494 in the newer.

Entries only in the older: 0, only in the newer: 270, changed: 30.

#### `avatardata/hands/groups/groups.dat`

FAR3, 4599 bytes in the older, 4603 in the newer.
Every entry is the same; the container's layout differs.

#### `avatardata/hands/meshes/meshes.dat`

FAR3, 23191 bytes in the older, 23434 in the newer.
Every entry is the same; the container's layout differs.

#### `avatardata/heads/appearances/appearances.dat`

FAR3, 87498 bytes in the older, 88101 in the newer.

Entries only in the older: 0, only in the newer: 9, changed: 0.

#### `avatardata/heads/bindings/bindings.dat`

FAR3, 122328 bytes in the older, 123171 in the newer.

Entries only in the older: 0, only in the newer: 9, changed: 0.

#### `avatardata/heads/collections/collections.dat`

FAR3, 2670 bytes in the older, 2700 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `avatardata/heads/meshes/meshes.dat`

FAR3, 2091320 bytes in the older, 2144911 in the newer.

Entries only in the older: 0, only in the newer: 3, changed: 0.

#### `avatardata/heads/outfits/outfits.dat`

FAR3, 35243 bytes in the older, 35489 in the newer.

Entries only in the older: 0, only in the newer: 3, changed: 0.

#### `avatardata/heads/purchasables/purchasables.dat`

FAR3, 27757 bytes in the older, 27952 in the newer.

Entries only in the older: 0, only in the newer: 3, changed: 0.

#### `avatardata/heads/textures/textures.dat`

FAR3, 10532147 bytes in the older, 10616050 in the newer.

Entries only in the older: 0, only in the newer: 9, changed: 3.

#### `avatardata/heads/thumbnails/thumbnails.dat`

FAR3, 1588881 bytes in the older, 1601850 in the newer.

Entries only in the older: 0, only in the newer: 9, changed: 3.

#### `censor/censor.dat`

3434 bytes in the older, 3481 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `cities/city_0022/vertexcolor.bmp`

786488 bytes in the older, 786488 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `cities/city_0024/vertexcolor.bmp`

786488 bytes in the older, 786488 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `DBAppServiceClientD.dll`

372736 bytes in the older, 393216 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/housepage.uis`

12085 bytes in the older, 12364 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/jobobjband.uis`

3181 bytes in the older, 5290 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/querypanel.uis`

11840 bytes in the older, 12127 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_137_placementerrs.cst`

2776 bytes in the older, 2841 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_159_objecttts.cst`

495 bytes in the older, 567 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_172_buildpanelstrings.cst`

253 bytes in the older, 271 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_206_querypanelstrings.cst`

1006 bytes in the older, 1027 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_208_roommateprotocolstrings.cst`

13296 bytes in the older, 13296 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_209_logindlgstrings.cst`

115 bytes in the older, 119 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_210_cityselprotocolstrings.cst`

2799 bytes in the older, 3172 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_211_housesimloginstrings.cst`

2912 bytes in the older, 2915 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_222_loginprotocol.cst`

996 bytes in the older, 1676 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_223_hostvisitorprotocol.cst`

1730 bytes in the older, 1751 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_227_friendshipweb.cst`

65 bytes in the older, 91 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_231_pppetitionformdlg.cst`

2038 bytes in the older, 2030 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_238_citydescriptionstrings.cst`

12389 bytes in the older, 14385 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_242_creditsstrings.cst`

26574 bytes in the older, 31939 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_245_buybuildmodestrings.cst`

266 bytes in the older, 693 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_246_lotpurchasedlgstrings.cst`

787 bytes in the older, 797 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_247_lotnameeditdlgstrings.cst`

941 bytes in the older, 946 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_248_hintsstrings.cst`

2791 bytes in the older, 7701 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_252_lotcategoryselectiondlgstrings.cst`

186 bytes in the older, 495 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uitext.dir/_253_jobobjband.cst`

43 bytes in the older, 466 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `GZFont.dll`

282624 bytes in the older, 282624 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `HitLabServiceD.dll`

339968 bytes in the older, 339968 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `HitListsTemp.dat`

DBPF, 96380 bytes in the older, 96165 in the newer.

Entries only in the older: 2, only in the newer: 16, changed: 35.

#### `HitMp3DecodeD.dll`

200704 bytes in the older, 200704 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `InternetServiceD.dll`

102400 bytes in the older, 102400 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/bathe.iff`

IFF, 10488 bytes in the older, 7581 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8192, 8193, 8194, 8195, 8196, 8197; TRCN 8192, 8193, 8194, 8195, 8196, 8197 |  | rsmp 0 |  |

#### `objectdata/globals/behavior.iff`

IFF, 37984 bytes in the older, 37988 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 128, 129, 130, 131, 132, 134, 135, 136, 137, 139, 141, 142, 150, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 167, 168, 169, 170, 171, 172, 173, 174, 176, 177, 178, 200, 201, 202, 203, 204, 205, 206, 207, 208, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510; rsmp 0 |  |

#### `objectdata/globals/build.iff`

IFF, 23907 bytes in the older, 23907 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 128, 129, 130, 131, 132, 133, 134, 135 |  |

#### `objectdata/globals/carglobals.iff`

IFF, 6183 bytes in the older, 6183 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | TTAs 129 |  |

#### `objectdata/globals/catglobals.iff`

IFF, 75972 bytes in the older, 68731 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8202; TRCN 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8202 |  | STR# 305, 8192; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/clothingrackssemiglobal.iff`

IFF, 8031 bytes in the older, 7800 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8193; TRCN 8193 |  | TTAs 129; rsmp 0 |  |

#### `objectdata/globals/counterglobals.iff`

IFF, 19963 bytes in the older, 19757 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8196; TRCN 8196 |  | BHAV 8216, 8217, 8218, 8225, 8227; TPRP 8216, 8217, 8218, 8225, 8227; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/credits.iff`

IFF, 4716 bytes in the older, 4716 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 163 |  |

#### `objectdata/globals/decoration.iff`

IFF, 8145 bytes in the older, 5238 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8192, 8193, 8194, 8195, 8196, 8197; TRCN 8192, 8193, 8194, 8195, 8196, 8197 |  | rsmp 0 |  |

#### `objectdata/globals/dogglobals.iff`

IFF, 75996 bytes in the older, 67439 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8202; TRCN 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208 |  | STR# 305, 8192; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/doorglobals.iff`

IFF, 23324 bytes in the older, 22860 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8194, 8198; TRCN 8194, 8198 |  | STR# 256, 8192; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/global.iff`

IFF, 122456 bytes in the older, 123817 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | TRCN 272 | BCON 271; FCNS 5 | BHAV 265, 430; FCNS 1; STR# 128, 130, 150, 152, 153, 154, 156, 158, 159, 170, 171, 257, 301, 303, 304, 305, 501, 502, 503, 504, 505; TPRP 265; TRCN 271; rsmp 0 |  |

#### `objectdata/globals/lightglobals.iff`

IFF, 15811 bytes in the older, 15386 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BCON 8193; TRCN 8193 | BHAV 8228; TPRP 8228 | BHAV 8206, 8221; TPRP 8206; TTAB 129; TTAs 129, 130; rsmp 0 |  |

#### `objectdata/globals/live.iff`

IFF, 13212 bytes in the older, 13212 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 130, 131, 132, 133, 134, 135, 136, 137, 138, 139 |  |

#### `objectdata/globals/personglobals.iff`

IFF, 226706 bytes in the older, 226313 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8197, 8202, 8310, 8408, 8409, 8570; STR# 301, 304, 305, 8192; TPRP 8408, 8570; TTAs 129, 130, 131; rsmp 0 |  |

#### `objectdata/globals/petsitglobals.iff`

IFF, 9441 bytes in the older, 8903 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | TRCN 8192, 8193, 8194 |  | rsmp 0 |  |

#### `objectdata/globals/skillobjects.iff`

IFF, 19275 bytes in the older, 19324 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8212; STR# 256, 301, 303; rsmp 0 |  |

#### `objectdata/globals/skillobjects.otf`

5700 bytes in the older, 5762 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/social2siminobjectsemiglobal.iff`

IFF, 12220 bytes in the older, 10626 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | TRCN 8194, 8195, 8196, 8197, 8198 |  | rsmp 0 |  |

#### `objectdata/globals/socialglobals.iff`

IFF, 39484 bytes in the older, 38498 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | TRCN 8192 |  | rsmp 0 |  |

#### `objectdata/globals/sofaglobals.iff`

IFF, 48046 bytes in the older, 48082 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8216, 8254, 8296, 8297, 8298, 8299, 8301; TTAs 129, 130; rsmp 0 |  |

#### `objectdata/globals/surfaceplacementsemiglobal.iff`

IFF, 2464 bytes in the older, 1964 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | TRCN 4096, 4097 |  | TTAs 129; rsmp 0 |  |

#### `objectdata/globals/trunkglobals.iff`

IFF, 5859 bytes in the older, 5859 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | TTAs 129 |  |

#### `objectdata/objects/objiff.far`

FAR1, 17921477 bytes in the older, 17726000 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `2personportal.iff` | TRCN 4097 |  | STR# 129, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `animtester.iff` |  |  | STR# 300; TTAs 129 |  |
| `aquarium1.iff` | BCON 4096; TRCN 4096, 4097 |  | BHAV 4103, 4113, 4125; OBJD 16807; STR# 129, 130, 256, 257, 301, 304; TPRP 4113, 4125; TTAs 129; rsmp 0 | 98e0f8bd |
| `ash.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `athleticsbench.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `awnings.iff` | TRCN 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `awnings2x2unleashed.iff` | BCON 4099; TRCN 4097, 4098, 4099 |  | rsmp 0 |  |
| `awnings3.iff` | BCON 4099; TRCN 4097, 4098, 4099 |  | BHAV 4128; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `awnings4.iff` | BCON 4099; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104 |  | rsmp 0 |  |
| `awningthatch.iff` | BCON 4099; TRCN 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `backdroptheater.iff` |  |  | STR# 129, 256, 257, 302; TTAs 129 |  |
| `bannerlamp.iff` | BCON 4097; TRCN 4097 |  | rsmp 0 |  |
| `bar.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 303; TTAs 129 |  |
| `barbeach.iff` | BCON 4096, 4101; TRCN 4096, 4101 |  | STR# 129, 130, 256, 257, 301, 303; rsmp 0 |  |
| `bars.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 300, 301, 303, 304; TTAs 128; rsmp 0 |  |
| `bars2.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 300, 301, 303, 304; TTAs 128; rsmp 0 |  |
| `bars3.iff` |  |  | STR# 129, 130, 256, 257, 301, 303, 304; TTAs 128 |  |
| `bball.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 302, 304; TTAs 129; rsmp 0 |  |
| `bbq.iff` |  |  | BHAV 4134, 4135; STR# 129, 256, 257, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `bedheart.iff` | BCON 4096, 4098, 4101, 4102, 4103; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 | BHAV 4191, 4194, 4195, 4196; OBJf 16811, 16813, 16814, 16815, 16817, 16818, 16819, 16821; TPRP 4191, 4194, 4195, 4196 | BHAV 4096, 4099, 4109, 4110, 4111, 4119, 4130, 4147, 4148, 4149, 4150, 4157, 4165, 4189, 4215, 4216, 4219, 4220, 4221, 4223, 4225, 4229; OBJD 16807, 16811, 16813, 16814, 16815, 16817, 16818, 16819, 16821, 16822; OBJf 16808, 16810, 16816, 16820; STR# 129, 130, 131, 132, 256, 257, 258, 301, 302, 303; TPRP 4099, 4130, 4148, 4149, 4150, 4215, 4219, 4221, 4225; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | 2ad15359, 2a65180b, 2af942e3, 29b837ac, 2a21356e, b2df4c76, 8ad53356, 2bdd1e0b, 45c779d5, 2d8a27c2 |
| `bedinteractions.iff` | TRCN 4096, 4097 | STR# 303 | BHAV 4115, 4116; STR# 129, 256, 401; TTAs 129; rsmp 0 |  |
| `beds.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098, 4099 |  | BHAV 4113, 4153; OBJD 16824; STR# 129, 130, 256, 257, 258, 301; TPRP 4113; TTAs 129, 130, 131, 132, 133; rsmp 0 | 82e04c5b |
| `beds2.iff` | BCON 4096, 4098; TRCN 4096, 4098 |  | BHAV 4153; STR# 129, 130, 131, 132, 256, 257, 258, 301; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `beds3.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098, 4099 |  | TTAs 129; rsmp 0 |  |
| `bedsbunkbed.iff` |  |  | BHAV 4097, 4103, 4134; CTSS 2002; OBJD 16824; STR# 129, 130, 256, 257, 258, 301; TTAs 129, 130, 131, 132, 133; rsmp 0 | 33e463cd |
| `bedssingle2.iff` | BCON 4096, 4098; TRCN 4096, 4098 |  | STR# 129, 130, 256, 257, 258, 301; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `bedssingle22.iff` | TRCN 4097, 4099 |  | STR# 129, 130, 256, 257, 258, 301; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `birthdaycake.iff` | BCON 4099, 4101, 4102, 4103, 4104, 4105; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105 |  | STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 |  |
| `bjdealer.iff` |  |  | STR# 129, 130, 200, 256, 257, 301, 303, 304 |  |
| `blackjack.iff` | BCON 4096; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 301, 302, 303, 304, 305, 4097, 4098; TTAs 129; rsmp 0 |  |
| `bookcases.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 256, 301, 304; TTAs 129, 130, 131; rsmp 0 |  |
| `bookcases2.iff` |  |  | STR# 129, 130, 256, 301, 304; TTAs 129, 130, 131 |  |
| `bookcases3.iff` |  |  | STR# 129, 130, 256, 301, 304; TTAs 129, 130, 131 |  |
| `bubblemaker.iff` | TRCN 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 302, 304; TTAs 129; rsmp 0 |  |
| `bubbles.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `buffettable.iff` |  |  | BHAV 4129; STR# 129, 256, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `buffettablevacation.iff` |  |  | BHAV 4100; STR# 129, 256, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `buildingsigns.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 301; TTAs 130; rsmp 0 |  |
| `bunnyrabbit.iff` | TRCN 4096 |  | rsmp 0 |  |
| `campfire.iff` | BCON 4098, 4099; TRCN 4098, 4099 |  | STR# 129, 130, 256, 257, 302, 304; TTAs 128, 129; rsmp 0 |  |
| `campfireghost.iff` |  |  | STR# 129, 200, 256, 257, 303, 304; TTAs 129 |  |
| `canningstation.iff` | TRCN 4096, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 256, 257, 300, 301, 303, 304, 305; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `cannon.iff` | TRCN 4097, 4098 |  | STR# 129, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `cannonball.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `carbentley.iff` |  | whole entry |  |  |
| `cardboardbox.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 257, 303; rsmp 0 |  |
| `carjunk.iff` |  | whole entry |  |  |
| `carlimo.iff` |  | whole entry |  |  |
| `carmjeep.iff` |  | whole entry |  |  |
| `carportal.iff` |  | whole entry |  |  |
| `carpublictransit.iff` | BCON 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `carsquad.iff` |  | whole entry |  |  |
| `carstaff.iff` |  | whole entry |  |  |
| `carstd.iff` |  | whole entry |  |  |
| `carsuv.iff` |  | whole entry |  |  |
| `cartown.iff` |  | whole entry |  |  |
| `cartunleashed.iff` | BCON 4096, 4097, 4099, 4101; TRCN 4096, 4097, 4099, 4101 |  | rsmp 0 |  |
| `cashregisters.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256, 257, 301, 302, 304; TTAs 128; rsmp 0 |  |
| `castlefence.iff` | BCON 4099; TRCN 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `chairconnecting.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128; rsmp 0 |  |
| `chairconnectingtheater.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128; rsmp 0 |  |
| `chairdinmoroccan.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `chairsdiningunleashed.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `chairshd_hd.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131; rsmp 0 |  |
| `chairslr1tile.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `chairslr1tilehd.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130; rsmp 0 |  |
| `chairslr2.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `chairslr3.iff` | BCON 4097; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `chairslr4.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | STR# 129, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `chairslr5.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | CTSS 2000; OBJD 16812; STR# 129, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 | 35490203 |
| `chairslrunleashed.iff` | BCON 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `chaiselounge.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `chalkboard.iff` | TRCN 4098 |  | STR# 129, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `charades.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 258, 301; TTAs 129, 130; rsmp 0 |  |
| `chemistryset.iff` |  |  | STR# 129, 130, 256, 300, 301, 303, 304, 305; TTAs 129, 130, 131, 132, 133 |  |
| `chesstable.iff` | TRCN 4097, 4098, 4099 |  | BHAV 4118, 4128; STR# 129, 130, 256, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `christmastree.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `clockoffice.iff` | BCON 4096; TRCN 4096 |  | BHAV 4101; STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `clockpost.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257; rsmp 0 |  |
| `clockpostswiss.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257; rsmp 0 |  |
| `clothingboothvac.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | OBJD 16821; rsmp 0 | 1f0dc8f1 |
| `clothingrack2.iff` | BCON 4097, 4098, 4102; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | OBJD 16807, 16809; STR# 129, 256, 257, 300, 301, 303, 304; TTAs 131; rsmp 0 | 2e4bc8c6, 2e6980cc |
| `clothingracks.iff` | TRCN 4096, 4097 |  | OBJD 16815, 16816, 16819, 16820; STR# 129, 256, 257, 301, 302; rsmp 0 | 32a7f175, 81affe1d, 743498da, 4666b58a |
| `coffeeesp.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `coffeem.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 304; TTAs 130; rsmp 0 |  |
| `collar_cat_blue.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `collar_cat_blue_ribbon.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_cat_brown.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_cat_pink.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_cat_pink_ribbon.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `collar_cat_red.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_cat_red_ribbon.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `collar_cat_spike.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_blue.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_blue_ribbon.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_brown.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_pink.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_pink_ribbon.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_red.iff` | TRCN 4097 |  | rsmp 0 |  |
| `collar_dog_red_ribbon.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `collar_dog_spike.iff` | TRCN 4097 |  | rsmp 0 |  |
| `column3.iff` |  |  | CTSS 2000; rsmp 0 |  |
| `columnarch.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchaquaduct.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchbeach.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchcarnival.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchmoroccan.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchromantiled.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchscifi.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchstone.iff` |  |  | STR# 129, 130, 256, 257, 303 |  |
| `comeandsee.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 258, 303, 304, 500; TTAs 129 |  |
| `computers.iff` | TRCN 4096 |  | STR# 129, 256, 257, 301, 303, 4096, 4097; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `computers5.iff` | TRCN 4098, 4099 |  | BHAV 4105; STR# 129, 256, 257, 301, 303, 4096, 4097; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `cone.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `constructionhorse.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `control-garden.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `control-petshow.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `conveyorbelt.iff` | BCON 4099; TRCN 4099, 4100 |  | STR# 129, 256, 257, 300, 303, 304; TTAs 128; rsmp 0 |  |
| `conveyorcontrol.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `costumesports.iff` | TRCN 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `costumetrunk.iff` | TRCN 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `costumetrunktoga.iff` | TRCN 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `countercasino.iff` | BCON 4097, 4098, 4099; TRCN 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `counterdisplay.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 302, 303; TTAs 129, 130, 131; rsmp 0 |  |
| `counterdisplayvacation.iff` | TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `counters.iff` | BCON 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099, 4100 |  | BHAV 4097, 4103, 4104, 4110, 4112; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4097, 4103, 4104, 4110, 4112; rsmp 0 |  |
| `counters2.iff` | BCON 4097, 4098, 4099; TRCN 4097, 4098, 4099, 4100 |  | BHAV 4097, 4103, 4112; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4097, 4103, 4112; rsmp 0 |  |
| `counters3.iff` | BCON 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099, 4100 |  | BHAV 4097, 4103, 4112, 4113, 4139, 4141; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4097, 4103, 4112, 4113; TTAs 128; rsmp 0 |  |
| `counters4.iff` | BCON 4098; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `counters5.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `counters6.iff` | BCON 4098; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `counterwall.iff` | BCON 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099, 4100 |  | BHAV 4097, 4103, 4112, 4117; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4097, 4103, 4112, 4117; rsmp 0 |  |
| `ctoldworld.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `ctscifi.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `ctuniform.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `ctvaudeville.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `ctvegas.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `cuckooclock.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 129; rsmp 0 |  |
| `curtain.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 301, 304; TTAs 129; rsmp 0 |  |
| `curtainsunleashed.iff` | BCON 4099; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104 |  | rsmp 0 |  |
| `dancecage.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 301, 304; TTAs 129 |  |
| `dancefloor.iff` |  |  | OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 301, 303, 304; TTAs 129 | 1e8b9ea7 |
| `deadmouse.iff` | BCON 4098, 4099; TRCN 4098, 4099 |  | rsmp 0 |  |
| `desks.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | BHAV 4098, 4100, 4104, 4105; STR# 129, 257, 303; TPRP 4098, 4100, 4104, 4105; rsmp 0 |  |
| `desks2.iff` |  |  | BHAV 4098, 4100, 4104; STR# 129, 257, 303; TPRP 4098, 4100, 4104; rsmp 0 |  |
| `desks3.iff` |  |  | BHAV 4098, 4100, 4104, 4105, 4107; CTSS 2001; OBJD 16810; STR# 129, 257, 303; TPRP 4098, 4100, 4104, 4105, 4107; rsmp 0 | 29db9b3a |
| `destination.iff` |  |  | STR# 129, 256, 257, 301, 302; TTAs 128 |  |
| `devcheats.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 301, 304, 4096; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 |  |
| `dfcontroller.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `dice.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `diningbooth.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4117, 4118; STR# 129, 130, 257, 303; TPRP 4100, 4111, 4117; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `diningchairs.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `diningchairs2.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `diningchairs3.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `diningchairs4.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `diningpodium.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 303; TTAs 129 |  |
| `diningtable2x1.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | BHAV 4098, 4100, 4104; STR# 129, 257, 303; TPRP 4098, 4100, 4104; rsmp 0 |  |
| `diningtablecircular.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4117, 4118; STR# 129, 130, 257, 303; TPRP 4111, 4117; rsmp 0 |  |
| `diningtabledeuce.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4117, 4118; STR# 129, 130, 257, 303; TPRP 4100, 4111, 4117, 4118; rsmp 0 |  |
| `diningtablelodge.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4117, 4118; TPRP 4100, 4111, 4113, 4117, 4118; rsmp 0 |  |
| `diningtables.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4114, 4117, 4118, 4121; STR# 129, 130, 257, 303; rsmp 0 |  |
| `diningtables2.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4117, 4118; STR# 129, 130, 257, 303; TPRP 4100, 4113, 4117, 4118; rsmp 0 |  |
| `diningtables3.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4118, 4121; STR# 129, 130, 257, 303; TPRP 4100, 4111, 4113, 4118, 4121; rsmp 0 |  |
| `diningtablesbeach.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4117, 4118, 4121; TPRP 4100, 4111, 4113, 4117, 4118, 4121; rsmp 0 |  |
| `dishwashers.iff` | BCON 4097, 4098, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | BHAV 4114, 4116, 4117, 4130; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4114, 4116, 4117, 4130; TTAs 128, 129; rsmp 0 |  |
| `displaycases.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257, 302, 303; TTAs 129, 130, 131; rsmp 0 |  |
| `displaycaseunleashed.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `displaycounterunleashed.iff` | TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `displayfloorpetpen.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `displayrack_collars.iff` | TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `djbooth.iff` | BCON 4097, 4100, 4103; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | OBJD 16808; STR# 129, 130, 131, 132, 256, 257, 258, 303, 304; TTAs 131; rsmp 0 | e8e88d38 |
| `dogfightcloud.iff` | BCON 4100, 4102, 4103, 4105; TRCN 4100, 4102, 4103, 4105 |  | rsmp 0 |  |
| `doghole.iff` | BCON 4098, 4099; TRCN 4098, 4099 |  | rsmp 0 |  |
| `doghouse.iff` | BCON 4096, 4098; TRCN 4096, 4098 |  | rsmp 0 |  |
| `dollhouse.iff` |  |  | STR# 129, 130, 256, 257; TTAs 129 |  |
| `dooroneway.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 129, 130; rsmp 0 |  |
| `doors.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301; TTAs 130; rsmp 0 |  |
| `doors2.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 303; TTAs 130; rsmp 0 |  |
| `doors3.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | CTSS 2001, 2002; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 130, 131; rsmp 0 |  |
| `doors4.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 130; rsmp 0 |  |
| `doors5.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 130; rsmp 0 |  |
| `doors6.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 130; rsmp 0 |  |
| `doorstar.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 130; rsmp 0 |  |
| `doorsunleashed.iff` | BCON 4098; TRCN 4098 |  | rsmp 0 |  |
| `dressers.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 129; rsmp 0 |  |
| `dressers2.iff` |  |  | STR# 129, 130, 256, 257; TTAs 129 |  |
| `dropdest.iff` |  |  | STR# 256, 257; TTAs 128 |  |
| `duck.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257, 300; TTAs 129; rsmp 0 |  |
| `easel.iff` | TRCN 4097 |  | STR# 129, 130, 256, 257, 301, 304; TTAs 129; rsmp 0 |  |
| `elevatorfreight.iff` | TRCN 4098 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `elevatorhotel.iff` | TRCN 4098 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `elevatormodern.iff` | TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `elevatorteleporter.iff` | TRCN 4098 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `execchair.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `exercisemachine.iff` |  |  | STR# 129, 130, 256, 257, 301; TTAs 129 |  |
| `fencecarnival.iff` | BCON 4097, 4098, 4099; TRCN 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fenceflowersnow.iff` |  |  | STR# 129, 130, 256, 257, 303 |  |
| `fenceoffice.iff` | BCON 4099; TRCN 4096, 4097, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fenceparty.iff` | TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fences.iff` | TRCN 4096, 4097, 4098, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fenceshd.iff` |  |  | STR# 129, 130, 256, 257, 300, 303, 304 |  |
| `fencesstonevacation.iff` | BCON 4098; TRCN 4098 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `fencesunleashed.iff` | BCON 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | rsmp 0 |  |
| `fetchtester.iff` | BCON 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `filingcabinet.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `fire.iff` | BCON 4096, 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `fireplaces.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `fireplaces2.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `fishingpier.iff` | BCON 4096, 4097, 4100; TRCN 4096, 4097, 4100 |  | STR# 129, 130, 256, 301, 303, 304; TTAs 132; rsmp 0 |  |
| `fishtankbig.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `flamingo.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 130, 257, 3; TTAs 131; rsmp 0 |  |
| `flies.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `flood.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 301, 304; TTAs 129; rsmp 0 |  |
| `flowerscoped.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 301, 303, 304; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `flowersoutdoor.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | CTSS 2001, 2002; STR# 129, 130, 256, 257, 301, 303, 304; TTAs 129, 130, 131, 132, 133; rsmp 0 |  |
| `flowersunleashed.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `food.iff` |  | BHAV 4161; TPRP 4161 | BHAV 4097, 4109, 4116, 4124, 4132, 4133, 4136, 4170, 4183; OBJf 16807, 16808, 16809, 16810, 16811, 16814, 16815, 16816, 16817; STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TPRP 4097, 4116, 4124, 4136, 4183; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 |  |
| `foodcounter.iff` | TRCN 4097 |  | BHAV 4105, 4109, 4122, 4125, 4147; STR# 129, 130, 256, 257, 301, 302, 303, 304; TPRP 4122; TTAs 128, 129, 130, 131; rsmp 0 |  |
| `foodcounterunleashed.iff` | BCON 4096, 4097, 4099, 4101; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | BHAV 4109; TPRP 4109; rsmp 0 |  |
| `foodproc.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 303; TTAs 128; rsmp 0 |  |
| `foodunleashed.iff` | BCON 4099, 4101, 4102, 4103, 4104; TRCN 4099, 4101, 4102, 4103, 4104 |  | rsmp 0 |  |
| `founders.iff` |  | whole entry |  |  |
| `fountain.iff` | TRCN 4096, 4097 |  | OBJD 16807; STR# 129, 130, 256; TTAs 129; rsmp 0 | a82ca08e |
| `fountainlargehd.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256; TTAs 129; rsmp 0 |  |
| `fountainrock.iff` | TRCN 4097 |  | STR# 129, 130, 256; TTAs 129; rsmp 0 |  |
| `fountainsunleashed.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `fridges.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 128, 129, 130; rsmp 0 | 675c18af |
| `fridges2.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 128, 129, 130; rsmp 0 |  |
| `frontdesks.iff` | BCON 4096, 4097; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `gameball.iff` |  |  | STR# 129, 256, 257, 301, 303, 304; TTAs 129 |  |
| `gamecompdrawacard.iff` | BCON 4097; TRCN 4096, 4097 | BHAV 4108; TPRP 4108 | BHAV 4104; STR# 129, 256, 257, 301, 302, 304; TTAB 129; TTAs 129, 130; rsmp 0 |  |
| `gamecomponentballcontainer.iff` | BCON 4096; TRCN 4096 |  | BHAV 4102; STR# 129, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `gamecomponentballtarget.iff` | BCON 4096; TRCN 4096, 4097 |  | BHAV 4101; STR# 256, 257, 302; TTAs 129; rsmp 0 |  |
| `gamecomponentpiece.iff` | BCON 4096; TRCN 4096 |  | STR# 256, 257, 301; TTAs 129; rsmp 0 |  |
| `gamecomponentpiececontainer.iff` | BCON 4097; TRCN 4097 |  | STR# 257, 301, 303; TTAs 129; rsmp 0 |  |
| `gamecomponentscoreboard.iff` |  |  | STR# 129, 256, 257, 304; TTAs 129 |  |
| `gamerugarrow.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `gamerugbackred.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `gamerugbackwhite.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `gamerugstar.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `gardencrops.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `gardener.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 200, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `gardengnome.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `gardenpest.iff` | BCON 4096; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | rsmp 0 |  |
| `gardenplot.iff` | BCON 4096, 4100; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | rsmp 0 |  |
| `geniegoldpile.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 302, 304; TTAs 129; rsmp 0 |  |
| `ggworkbench.iff` | TRCN 4096, 4098 |  | BHAV 4110; CTSS 2000; OBJD 16811; STR# 129, 256, 257, 300, 301, 304, 305; TTAs 129; rsmp 0 | 4ddf498c |
| `giftflowers.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 258, 304; TTAs 129; rsmp 0 |  |
| `grandclock.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `grimreaperdbd.iff` |  |  | STR# 129, 130, 200, 256, 257, 304; TTAs 129 |  |
| `guitar.iff` |  | BHAV 4123; TPRP 4123 | BHAV 4096, 4111; OBJf 16807; STR# 129, 130, 131, 132, 256, 301, 304; TPRP 4096, 4111; TTAs 129; rsmp 0 |  |
| `hatrack.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `helpsystem.iff` | BCON 4097; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | STR# 129, 130, 256, 258, 259, 300, 301, 303; TTAs 129; rsmp 0 |  |
| `hottub.iff` | TRCN 4096, 4097 |  | BHAV 4098; STR# 129, 130, 256, 257, 301, 302, 304; TTAs 129; rsmp 0 |  |
| `hottubvacation.iff` | BCON 4098, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110; TRCN 4098, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110 |  | STR# 129, 130, 256, 257, 301, 302, 304; TTAs 129; rsmp 0 |  |
| `icecream.iff` | BCON 4099, 4104; TRCN 4099, 4101, 4102, 4103, 4104 |  | STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 |  |
| `jackolantern.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 131, 132, 256, 257, 301, 304; TTAs 128; rsmp 0 |  |
| `jobdegrade.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 257, 301, 303, 304, 305; rsmp 0 |  |
| `jobfinder.iff` |  |  | STR# 129, 256, 257 |  |
| `jobobjband.iff` | BHAV 4124, 4125; TPRP 4124, 4125 | BCON 4102, 4103; BHAV 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122; STR# 304; TPRP 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122; TRCN 4102, 4103 | BCON 4101; BHAV 4096, 4099, 4101, 4102, 4103, 4104, 4105, 4107; OBJD 16811, 16813, 16814, 16817, 16818, 16819, 16822, 16823; STR# 129, 130, 256, 257, 301, 302, 4096, 4097, 4098, 4099; TPRP 4102, 4103, 4105, 4107; TRCN 4101; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | ba378b65, fd57c400, 5b1294f4, 7f958de5, 374c95d9, 9f01de7b, 7df2dd66, 7a6aa560 |
| `jobobject2person.iff` | BCON 4096; TRCN 4096, 4097, 4098 |  | BHAV 4102, 4121, 4128; OBJD 16807; STR# 129, 130, 256, 257, 301, 302, 303, 304; TTAs 129; rsmp 0 | 6a245660 |
| `jobpaperchase.iff` | TRCN 4096, 4098 |  | OBJD 16807; STR# 129, 256, 257, 301, 304, 4096, 4097, 4098; TTAs 129, 130, 131, 132; rsmp 0 | 52817ee1 |
| `jukebox.iff` | BCON 4097, 4100, 4101; TRCN 4097, 4100, 4101 |  | STR# 129, 130, 256, 257, 258, 303; TTAs 131; rsmp 0 |  |
| `koiboat.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `koipond.iff` |  |  | STR# 129, 130, 256, 304; TTAs 129 |  |
| `lampceiling2.iff` | BCON 4096; TRCN 4096 |  | STR# 256; rsmp 0 |  |
| `lampceiling3.iff` | BCON 4096; TRCN 4096 |  | STR# 256; rsmp 0 |  |
| `lampceilingunleashed.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `lampfloorstage.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `lampgarden.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256; TTAs 129; rsmp 0 |  |
| `lampgarden2.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256; TTAs 129; rsmp 0 |  |
| `lamphula.iff` | TRCN 4096 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `lamps.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `lamps2.iff` | BCON 4097; TRCN 4096, 4097 |  | CTSS 2001; OBJD 16809; STR# 129, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 94f5cda8 |
| `lamps3.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `lamps4.iff` | BCON 4097; TRCN 4097 |  | STR# 256, 257; rsmp 0 |  |
| `lampsflooranimated.iff` | BCON 4097; TRCN 4096, 4097 |  | CTSS 2001; OBJD 16808; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | da746262 |
| `lampsflooranimated2.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `lampsstreet.iff` |  |  | STR# 129, 256 |  |
| `lampsstreet22.iff` | BCON 4096; TRCN 4096 |  | STR# 256; rsmp 0 |  |
| `lampsunleashed.iff` | BCON 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `lampswall2.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `lampswall3.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `lampswall4.iff` | BCON 4097; TRCN 4097 |  | STR# 256, 257; rsmp 0 |  |
| `lampswallgameshow.iff` | BCON 4097; TRCN 4096, 4097 |  | CTSS 2000; OBJD 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 2a296a67 |
| `lampunleashedcandle.iff` | BCON 4097; TRCN 4097 |  | rsmp 0 |  |
| `lampwallapplausesign.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `lampwallmoroccan.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `lampwallonairsign.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `lampwallvictorian.iff` | BCON 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `leavelot.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 303, 304; TTAs 129 |  |
| `lotexit.iff` |  |  | STR# 129, 130, 256, 257, 258, 301, 302, 303; TTAs 129, 130, 132 |  |
| `lovetubhd.iff` | BCON 4098, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110 |  | STR# 129, 130, 256, 257, 301, 302, 304; TTAs 129; rsmp 0 |  |
| `magazine_inv1.iff` | TRCN 4097 |  | STR# 129, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `magazine_inv2.iff` | TRCN 4097 |  | STR# 129, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `magazine_inv3.iff` | TRCN 4097 |  | STR# 129, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `magazine_inv4.iff` | TRCN 4097 |  | STR# 129, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `magazine_inv5.iff` | TRCN 4097 |  | STR# 129, 301, 302, 303, 304; TTAs 129; rsmp 0 |  |
| `magazinestack.iff` |  |  | STR# 129, 130, 256, 301, 302, 303, 304; TTAs 129 |  |
| `magazinestand.iff` | TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 256, 257, 300, 302, 303; TTAs 128; rsmp 0 |  |
| `magicalendtableunleashed.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `maid.iff` | BCON 4096; TRCN 4096 |  | STR# 200, 256, 257, 301, 303; TTAs 129; rsmp 0 |  |
| `mailbox.iff` | BCON 4096; TRCN 4096 | OBJf 16808 | BHAV 4096, 4097, 4098, 4101, 4109, 4110; OBJD 16808; STR# 129, 130, 256, 257, 258, 301, 303, 304; TPRP 4096, 4098, 4109, 4110; TTAs 129; rsmp 0 | ef121974 |
| `mailboxvacation.iff` | BCON 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `mask.iff` | BCON 4097; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | rsmp 0 |  |
| `mechanicalbull.iff` |  |  | BHAV 4105; STR# 129, 130, 131, 132, 256, 257, 301, 304; TPRP 4105; TTAs 129; rsmp 0 |  |
| `medicinecabinet.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `menorah.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `mice.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `microphone.iff` | BCON 4097; TRCN 4096, 4097, 4098 | BHAV 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109; TPRP 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109 | BHAV 4098, 4099; OBJD 16807; STR# 129, 130, 256, 257, 303; TPRP 4099; TTAB 129; TTAs 129; rsmp 0 | ff15db89 |
| `microphonepodiumgameshow.iff` | BCON 4097; TRCN 4096, 4097, 4098 | BHAV 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109; TPRP 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109 | STR# 129, 130, 256, 257, 303; TTAB 129; TTAs 129; rsmp 0 |  |
| `microphonepulpit.iff` | BCON 4097; TRCN 4096, 4097, 4098 | BHAV 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109; TPRP 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109 | BHAV 4098; STR# 129, 130, 256, 257, 303; TTAB 129; TTAs 129; rsmp 0 |  |
| `mirrorfloorvacation.iff` | TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `mirrors.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129, 130 |  |
| `mirrors2.iff` | TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `mirrors3.iff` | TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `mirrorvacation.iff` | TRCN 4096 |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `moosehead.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256; TTAs 130; rsmp 0 |  |
| `neighborhoodpedmarker.iff` | BCON 4096, 4098; TRCN 4096, 4098 |  | rsmp 0 |  |
| `neighborhoodphoneplugin.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | rsmp 0 |  |
| `newspaper.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 258, 301, 304; TTAs 129; rsmp 0 |  |
| `newyears.iff` |  | whole entry |  |  |
| `npc_cartvendorfl.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_cartvendorfl_drk.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_cartvendorfl_med.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_icecreamvendor.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_icv_dark.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_icv_med.iff` |  |  | STR# 129, 200, 256, 257, 300, 304 |  |
| `npc_unleashed_animalcontrolpp.iff` | BCON 4097; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | rsmp 0 |  |
| `npc_unleashed_controller.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `npc_unleashed_maintenance.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `npc_unleashed_organgrinder.iff` | BCON 4096, 4097, 4099; TRCN 4096, 4097, 4099 |  | rsmp 0 |  |
| `npc_unleashed_palmreader.iff` | BCON 4096, 4099; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `npc_unleashed_raccoon.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `npc_unleashed_saxplayer.iff` | BCON 4096, 4097, 4099; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `npc_unleashed_skunk.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `npccontroller.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 301, 303, 304, 305 |  |
| `npcdealer.iff` | TRCN 4096 |  | STR# 200, 256, 257, 258, 303; TTAs 129; rsmp 0 |  |
| `npcrobotsi.iff` | BCON 4101, 4102, 4112, 4113, 4116, 4117; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122 |  | STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305; TTAs 129; rsmp 0 |  |
| `npcsocials.iff` | BCON 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122; TRCN 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122 |  | rsmp 0 |  |
| `officechair.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `officecubicle.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 257, 303; rsmp 0 |  |
| `officeplant.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 |  |
| `officer.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 200, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `paintings.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256; TTAs 130; rsmp 0 |  |
| `paintings2.iff` | BCON 4096; TRCN 4096 |  | CTSS 2002; OBJD 16811; STR# 129, 130, 256; TTAs 130; rsmp 0 | a13f39cf |
| `paintings3.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 301; TTAs 130; rsmp 0 |  |
| `paintings4.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 301; TTAs 130; rsmp 0 |  |
| `paintings5.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 301; TTAs 130; rsmp 0 |  |
| `paintings6.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 301; TTAs 130; rsmp 0 |  |
| `paintings7.iff` | BCON 4097; TRCN 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `pantryunleashed.iff` | BCON 4096, 4097, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `papercarrierf1.iff` |  |  | STR# 130, 200, 256, 257, 301, 303, 304 |  |
| `parkgrill.iff` | BCON 4100, 4101; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | STR# 129, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `parkrockers.iff` | BCON 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `partyballoons.iff` | BCON 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `pedportal.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257, 258, 301, 303, 304, 305; TTAs 129; rsmp 0 |  |
| `pet_inventory_fish.iff` | TRCN 4097 |  | rsmp 0 |  |
| `pet_inventory_iguana.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `pet_inventory_lovebirds.iff` | TRCN 4097 |  | rsmp 0 |  |
| `pet_inventory_parakeet.iff` | TRCN 4097 |  | rsmp 0 |  |
| `pet_inventory_turtle.iff` | TRCN 4097 |  | rsmp 0 |  |
| `petbath.iff` | BCON 4096; TRCN 4096, 4097 |  | rsmp 0 |  |
| `petbed.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `petbirdcage.iff` | BCON 4098, 4099; TRCN 4098, 4099 |  | rsmp 0 |  |
| `petcatlitterbox.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | rsmp 0 |  |
| `petcatsit.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `petdogsit.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `petfishbowl.iff` | BCON 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `petfoodbowl.iff` | BCON 4096; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `petgym.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `pethouse.iff` | BCON 4096, 4098; TRCN 4096, 4098 |  | rsmp 0 |  |
| `petiguana.iff` | BCON 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | rsmp 0 |  |
| `petmaternitybox.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `petparrot.iff` | BCON 4097, 4099; TRCN 4097, 4099 |  | rsmp 0 |  |
| `petpedestal.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `petplayfountain.iff` | BCON 4098; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | rsmp 0 |  |
| `petpost.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `petturtle.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `phoneline.iff` |  |  | STR# 256, 257, 258, 303 |  |
| `piano.iff` | TRCN 4097 | BHAV 4112; TPRP 4112 | OBJf 16810; STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `piano2.iff` | TRCN 4097 | BHAV 4120; TPRP 4120 | OBJf 16810; STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `piano3.iff` | TRCN 4097 | BHAV 4124; TPRP 4099, 4124 | BHAV 4096, 4099, 4102, 4105, 4107, 4119; OBJf 16810; STR# 129, 130, 131, 132, 256, 257, 301, 303; TPRP 4096, 4102, 4105, 4107, 4119; TTAs 129; rsmp 0 |  |
| `pinata.iff` | TRCN 4096, 4098 |  | STR# 128, 129, 256, 257, 301, 304; TTAs 129; rsmp 0 |  |
| `pinballmachine.iff` | TRCN 4097 |  | STR# 129, 256, 257, 301, 302, 303, 304; TTAs 128; rsmp 0 |  |
| `pizzamaker.iff` | TRCN 4096, 4097, 4098, 4099, 4102, 4103, 4104, 4105, 4106, 4107, 4108 |  | OBJD 16807; STR# 129, 256, 257, 301, 304; TTAs 129; rsmp 0 | 1d8a0c11 |
| `placeholder.iff` |  |  | STR# 257 |  |
| `plantboxfence.iff` | BCON 4098; TRCN 4098 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `plantboxfenceunleashed.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102 |  | rsmp 0 |  |
| `plantflowersurn.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129; rsmp 0 |  |
| `plantmoroccan.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129; rsmp 0 |  |
| `plantpottedalien.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129; rsmp 0 |  |
| `plants.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 |  |
| `plants2.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 |  |
| `plants3.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 304, 4096; TTAs 129; rsmp 0 |  |
| `plantshanginghd.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256; TTAs 129; rsmp 0 |  |
| `podium.iff` | BCON 4097; TRCN 4097, 4098 | BHAV 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109; TPRP 4100, 4102, 4103, 4104, 4105, 4107, 4108, 4109 | BHAV 4098, 4099; OBJD 16807; STR# 129, 130, 256, 257, 303; TPRP 4099; TTAB 129; TTAs 129; rsmp 0 | 83d9387d |
| `pondduck.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 256, 257, 300; TTAs 129; rsmp 0 |  |
| `pool.iff` |  |  | STR# 129, 256, 301, 303, 304; TTAs 130 |  |
| `pooldivbrd.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257, 303; TTAs 129, 130; rsmp 0 |  |
| `poolfilter.iff` |  |  | STR# 129, 257; TTAs 129 |  |
| `poolladder.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257, 302, 303; TTAs 130, 131; rsmp 0 |  |
| `poolslide.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 303; TTAs 129, 130; rsmp 0 |  |
| `pooltable.iff` | TRCN 4096, 4097, 4098 | BHAV 4139; TPRP 4139 | BHAV 4130, 4132, 4149; STR# 129, 130, 256, 257, 258, 303, 304; TPRP 4149; TTAs 129; rsmp 0 |  |
| `poop.iff` | BCON 4098, 4099; TRCN 4098, 4099 |  | rsmp 0 |  |
| `porchswinghd.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 304; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142 |  |
| `property_deeds.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `punchbowl.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 258, 301, 303, 304; TTAs 128, 129; rsmp 0 |  |
| `puppetangry.iff` | TRCN 4096, 4097 |  | STR# 129, 304; TTAs 129; rsmp 0 |  |
| `puppetattitude.iff` | TRCN 4097 |  | STR# 129, 256, 304; TTAs 129; rsmp 0 |  |
| `puppetbonus.iff` | TRCN 4096, 4097 |  | STR# 129, 304; TTAs 129; rsmp 0 |  |
| `puppetbored.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 304; TTAs 129; rsmp 0 |  |
| `puppetcool.iff` | TRCN 4096, 4097 |  | STR# 129, 304; TTAs 129; rsmp 0 |  |
| `puppetdance.iff` | TRCN 4096, 4097 |  | STR# 129, 130; TTAs 129; rsmp 0 |  |
| `puppetdisgusted.iff` | TRCN 4096, 4097 |  | STR# 129; TTAs 129; rsmp 0 |  |
| `puppethappy.iff` | TRCN 4096, 4097 |  | STR# 129, 130; TTAs 129; rsmp 0 |  |
| `puppetsad.iff` | TRCN 4096, 4097 |  | STR# 129; TTAs 129; rsmp 0 |  |
| `puppetsilly.iff` | TRCN 4096, 4097 |  | STR# 129; TTAB 129; TTAs 129; rsmp 0 |  |
| `queueropes.iff` | TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `reclinerdoublevacation.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 128; rsmp 0 |  |
| `recliners.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 128, 129; rsmp 0 |  |
| `repairman.iff` | BCON 4096; TRCN 4096 |  | STR# 200, 256, 257, 258, 301, 303; TTAs 129; rsmp 0 |  |
| `repoman.iff` |  |  | STR# 200, 256, 257, 301, 304 |  |
| `repomanfx.iff` | TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `reservetile.iff` |  |  | STR# 257 |  |
| `roaches.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `roulette.iff` | TRCN 4097, 4098 |  | STR# 129, 256, 257, 301, 302, 303, 4096; TTAs 129; rsmp 0 |  |
| `rugmoroccanrunner.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `rugmoroccansquare.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `rugs.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `rugs2.iff` | BCON 4096; TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `rugs3.iff` | BCON 4096; TRCN 4096 |  | TTAs 129; rsmp 0 |  |
| `scheduler.iff` |  |  | STR# 256, 303 |  |
| `sculpturedressingscreen.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculpturegopher.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `sculptures.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculptures2.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculptures3.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculptures4.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `sculptures5.iff` | TRCN 4096 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculptures6.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `sculptures7.iff` | BCON 4097; TRCN 4097 |  | rsmp 0 |  |
| `sculptureweddingtopiary.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `seeds.iff` | TRCN 4097 |  | rsmp 0 |  |
| `showeraluminum.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 300, 301, 304; TTAs 129; rsmp 0 |  |
| `showerc.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 300, 301, 304; TTAs 129; rsmp 0 |  |
| `showers2.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 300, 301, 304; TTAs 129; rsmp 0 |  |
| `showertiki.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 300, 301, 304; TTAs 129; rsmp 0 |  |
| `showertub.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `showertubunleashed.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 301; rsmp 0 |  |
| `shutters.iff` | TRCN 4096 |  | STR# 129, 301; TTAs 130; rsmp 0 |  |
| `signs.iff` |  |  | BHAV 4106, 4109; STR# 129, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `sinkaluminum.iff` | BCON 4096, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 256, 257, 303, 304; TTAs 128, 129, 130; rsmp 0 |  |
| `sinks.iff` | BCON 4096, 4098, 4099; TRCN 4096, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 128, 129, 130; rsmp 0 |  |
| `sinks2.iff` | BCON 4096, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 128, 129, 130; rsmp 0 |  |
| `sinks3.iff` |  |  | STR# 129, 130, 256, 257, 303, 304; TTAs 128, 129, 130 |  |
| `sinkvacation.iff` | BCON 4096, 4098, 4099; TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 128; rsmp 0 |  |
| `skilltracker.iff` |  |  | STR# 256, 257, 304; TTAs 129 |  |
| `slotmachine.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 131, 132, 256, 257, 258, 302, 304; TTAs 129; rsmp 0 |  |
| `snackmachine.iff` | BCON 4096, 4097, 4099; TRCN 4096, 4097, 4098, 4099 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 128, 129, 130; rsmp 0 |  |
| `snowman.iff` | BCON 4097, 4099, 4103; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103 |  | STR# 257; rsmp 0 |  |
| `soccerball.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257, 300; TTAs 129; rsmp 0 |  |
| `soccernet.iff` | BCON 4097; TRCN 4097 |  | STR# 256; TTAs 129; rsmp 0 |  |
| `social2.iff` |  |  | STR# 129, 130, 256, 257, 258, 301, 303, 304, 305; TTAs 129, 130, 131 |  |
| `social2siminteractions.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4104, 4105, 4107, 4111, 4118, 4123, 4155, 4156, 4157, 4158, 4160, 4161, 4162, 4163, 4164 | BHAV 4411, 4412, 4413, 4414; TPRP 4411, 4412, 4413, 4414 | BHAV 4147, 4210, 4275, 4278, 4308, 4309, 4358, 4401, 4402; STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305, 401; TPRP 4147, 4275, 4278; TTAB 130; TTAs 129, 130; rsmp 0 |  |
| `socialapprove.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256; TTAs 129; rsmp 0 |  |
| `socialgreet.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256; TTAs 129; rsmp 0 |  |
| `socialinteractions.iff` | BCON 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123; TRCN 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123 |  | STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305, 401; TTAs 129; rsmp 0 |  |
| `socialmean.iff` | TRCN 4097 |  | STR# 129, 256; TTAs 129; rsmp 0 |  |
| `socialnice.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256, 301; TTAs 129; rsmp 0 |  |
| `socialplay.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256, 304; TTAs 129; rsmp 0 |  |
| `socialreject.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 130, 131, 132, 256; TTAs 129; rsmp 0 |  |
| `socialromance.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 129, 256; TTAs 129; rsmp 0 |  |
| `sodamachine2.iff` | BCON 4096; TRCN 4096, 4097, 4098, 4099 |  | BHAV 4112; STR# 129, 130, 256, 257, 300, 301, 302, 303, 304; TTAs 128, 129, 130; rsmp 0 |  |
| `sofabenchvacation.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | STR# 129, 130, 256, 257, 301, 302; TTAs 129, 130, 131; rsmp 0 |  |
| `sofacuddleinteractions.iff` | BCON 4096; TRCN 4096, 4097 | BHAV 4115, 4116, 4117, 4118; TPRP 4115, 4116, 4117, 4118 | BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4103, 4104, 4105, 4106, 4107; STR# 129, 256, 401; TTAs 129; rsmp 0 |  |
| `sofas.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `sofas2.iff` |  |  | STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142 |  |
| `sofas3.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `sofas4.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `sofas5.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `sofashd.iff` | TRCN 4101 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131; rsmp 0 |  |
| `sofaslodge.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | STR# 129, 130, 256, 257, 301, 302; TTAs 129, 130, 131; rsmp 0 |  |
| `sofasunleashed.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `sofaweddingpew.iff` | BCON 4096, 4097, 4098, 4099, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 |  |
| `souvenircabinets.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 257; rsmp 0 |  |
| `spinbottle.iff` |  |  | STR# 129, 256, 257, 401; TTAs 129 |  |
| `splitrailfence.iff` | BCON 4099; TRCN 4099, 4100 |  | STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `stair.iff` |  |  | STR# 129, 130, 256, 257, 302, 400; TTAs 129 |  |
| `stair2.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257, 302, 400; TTAs 129; rsmp 0 |  |
| `stair3.iff` |  |  | STR# 129, 130, 256, 257, 302, 400; TTAs 129 |  |
| `stair4.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257, 302, 400; rsmp 0 |  |
| `stairsspiral.iff` | TRCN 4096 |  | rsmp 0 |  |
| `stereos.iff` | BCON 4097, 4100, 4101; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | BHAV 4120; STR# 129, 130, 256, 257, 258, 303; TTAs 129, 130, 131; rsmp 0 |  |
| `stereos2.iff` | BCON 4097; TRCN 4097, 4098, 4099, 4100, 4101 |  | STR# 129, 256, 303, 304; TTAs 129; rsmp 0 |  |
| `stereospeakers.iff` | BCON 4100, 4102, 4103; TRCN 4100, 4102, 4103 |  | STR# 129, 130, 131, 132, 256, 257, 258, 303, 304; TTAs 131; rsmp 0 |  |
| `stereowallunleashed.iff` | TRCN 4096, 4097, 4098, 4099, 4100 |  | rsmp 0 |  |
| `stopsign.iff` | BCON 4096; TRCN 4096, 4097 |  | STR# 303; TTAs 132; rsmp 0 |  |
| `stoves.iff` | BCON 4097, 4098, 4100, 4101; TRCN 4097, 4098, 4100, 4101 |  | BHAV 4114; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4114; TTAs 129; rsmp 0 |  |
| `stoves2.iff` | BCON 4097, 4098, 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | BHAV 4109, 4114, 4131; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4109, 4114, 4131; TTAs 129; rsmp 0 |  |
| `tablecoffee.iff` |  |  | STR# 129, 256, 257, 303 |  |
| `tablecoffee2.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257, 303; rsmp 0 |  |
| `tablecoffeeunleashed.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `tablediningunleashed.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `tableendwedding.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `tablegiftshop.iff` | BCON 4096; TRCN 4096 |  | OBJD 16836; rsmp 0 | 29b19fbc |
| `tablemoroccan1x1.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4111, 4113, 4117, 4118, 4121; STR# 129, 130, 257, 303; TPRP 4100, 4111, 4113, 4117, 4118, 4121; rsmp 0 |  |
| `tablepicnic.iff` |  |  | BHAV 4100, 4105, 4111, 4113, 4117, 4118; STR# 129, 130, 257, 303; TPRP 4100, 4105, 4111, 4113, 4117, 4118; TTAs 129; rsmp 0 |  |
| `tablepicnic2.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4102, 4111, 4117, 4121; STR# 129, 130, 257, 303; TPRP 4100, 4102, 4111, 4121; TTAs 129; rsmp 0 |  |
| `tablerave.iff` | BCON 4096; TRCN 4096 |  | BHAV 4100, 4102, 4111, 4113, 4117, 4118, 4121; STR# 129, 130, 257, 303; TPRP 4100, 4102, 4111, 4113, 4117, 4118, 4121; rsmp 0 |  |
| `tablesend.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | BHAV 4098, 4100, 4102, 4103, 4104; STR# 129, 130, 256, 257, 303; TPRP 4102, 4103; TTAs 129; rsmp 0 |  |
| `tablesend2.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | BHAV 4098, 4100, 4102, 4103; STR# 129, 130, 256, 257, 303; TPRP 4098, 4100, 4102, 4103; rsmp 0 |  |
| `tablesend4.iff` |  |  | BHAV 4098, 4100, 4103, 4109, 4110, 4112, 4114, 4115; STR# 129, 130, 256, 257, 303; TPRP 4098, 4100, 4103, 4109, 4110, 4112, 4114, 4115; rsmp 0 |  |
| `tablesend5.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | BHAV 4103, 4104, 4109, 4110, 4112, 4115; STR# 129, 130, 256, 257, 303; TPRP 4104, 4109, 4110, 4112, 4115; rsmp 0 |  |
| `tableshd.iff` | BCON 4096; TRCN 4096 |  | BHAV 4097, 4100, 4102, 4111, 4113, 4117, 4118, 4121; STR# 129, 130, 257, 303; TPRP 4097, 4100, 4102, 4111, 4113, 4117, 4118, 4121; rsmp 0 |  |
| `telemarketingstation.iff` |  |  | STR# 129, 130, 256, 257, 301, 303, 304; TTAs 129 |  |
| `teleporter.iff` |  |  | STR# 129, 256, 257, 301, 303, 304; TTAs 129 |  |
| `telescope.iff` |  |  | STR# 129, 130, 256, 301, 304; TTAs 129, 130 |  |
| `templatecat.iff` | TRCN 4096 |  | rsmp 0 |  |
| `templatedog.iff` | TRCN 4096 |  | rsmp 0 |  |
| `templatenpc.iff` | TRCN 4096 |  | STR# 200, 256, 257, 258, 303; TTAs 129; rsmp 0 |  |
| `templateperson.iff` |  |  | OBJD 128; STR# 200, 256, 257, 300, 304 | 7fd96b54 |
| `tent.iff` | BCON 4097, 4098, 4099, 4100, 4101, 4102; TRCN 4097, 4098, 4099, 4100, 4101, 4102 |  | STR# 129, 130, 131, 256, 257, 258, 301, 302, 303; TTAs 132; rsmp 0 |  |
| `timer.iff` | BCON 4098; TRCN 4098 |  | STR# 129, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `tipjar.iff` | TRCN 4097 |  | SLOT 128; STR# 129, 256, 257, 301, 304; TTAs 128; rsmp 0 |  |
| `toiletaluminum.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `toiletportable.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 304; TTAs 129, 130; rsmp 0 | eac3d84f |
| `toilets.iff` | BCON 4097; TRCN 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `toilets2.iff` | BCON 4097; TRCN 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `toilets3.iff` | BCON 4097; TRCN 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `toiletstall.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `toiletsunleashed.iff` | BCON 4097; TRCN 4097, 4098 |  | rsmp 0 |  |
| `toileturinal.iff` | BCON 4097; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `tokensunleashed.iff` | TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112 |  | rsmp 0 |  |
| `toyrocket.iff` | BCON 4096; TRCN 4096 |  | BHAV 4096, 4103, 4104; CTSS 2000; OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4096, 4104; TTAs 129; rsmp 0 | 405046ff |
| `tragicclown.iff` |  |  | STR# 129, 130, 131, 132, 200, 256, 257, 301, 304, 305; TTAs 129 |  |
| `trainsets.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129, 130; rsmp 0 |  |
| `trash1.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 | 83e0af58 |
| `trash2.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `trashcandt.iff` |  |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129 |  |
| `trashcanvacation.iff` | BCON 4096, 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `trashcompactor.iff` | BCON 4096, 4097, 4098; TRCN 4096, 4097, 4098 |  | BHAV 4096, 4130; STR# 129, 130, 256, 300, 303, 304; TPRP 4096, 4130; TTAs 128; rsmp 0 |  |
| `trashflower.iff` | BCON 4096, 4098, 4099; TRCN 4096, 4098, 4099 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `trashoutside.iff` |  | BHAV 4097; TPRP 4097 | BHAV 4098; STR# 129, 130, 256, 257, 301, 304; rsmp 0 |  |
| `trashpile.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `trclownhole.iff` | BCON 4096; TRCN 4096 |  | STR# 129, 130, 256, 304; TTAs 129; rsmp 0 |  |
| `trclownsi.iff` | BCON 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122 |  | STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305; TTAs 129; rsmp 0 |  |
| `treasurehunt.iff` |  |  | STR# 129, 130, 256, 257, 301, 303, 304; TTAs 129 |  |
| `treecurb.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; rsmp 0 |  |
| `trees.iff` | TRCN 4096, 4097 |  | STR# 129, 130, 256, 257; rsmp 0 |  |
| `trees3.iff` |  |  | CTSS 2006; STR# 129, 130, 256, 257; rsmp 0 |  |
| `trees4.iff` |  |  | STR# 129, 256, 257; TTAs 129, 130, 131 |  |
| `treeshd.iff` | TRCN 4096, 4097 |  | STR# 256, 257; rsmp 0 |  |
| `treesunleashed.iff` | TRCN 4096, 4097 |  | rsmp 0 |  |
| `tubc.iff` | TRCN 4097 | BHAV 4133, 4134; OBJf 16808, 16809; TPRP 4133, 4134 | BHAV 4103; OBJD 16807, 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129; rsmp 0 | 85e00942, 6145c66d, 93908eb9 |
| `tubcastle.iff` | TRCN 4097 | BHAV 4137; TPRP 4137 | BHAV 4099, 4101, 4103, 4120, 4134; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4099, 4101, 4103, 4120, 4134; TTAs 129; rsmp 0 |  |
| `tubm.iff` | TRCN 4097 | BHAV 4134, 4137; OBJf 16808; TPRP 4134, 4137 | BHAV 4103, 4107; OBJD 16807, 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4103, 4107; TTAs 129; rsmp 0 | dbeb6614, dbea7e83 |
| `tubx.iff` | TRCN 4097 |  | STR# 129, 130, 131, 132, 256, 257, 304; TTAs 129; rsmp 0 |  |
| `turkey.iff` | BCON 4099, 4101, 4102, 4103, 4104, 4105; TRCN 4099, 4101, 4102, 4103, 4104, 4105 |  | STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 |  |
| `turnstiledoor.iff` | BCON 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 131; rsmp 0 |  |
| `tutorial.iff` |  |  | STR# 129, 256, 257, 301 |  |
| `tvs.iff` |  |  | STR# 129, 130, 256, 257, 258, 302, 304; TTAs 129, 130, 132 |  |
| `typewriter.iff` | TRCN 4097, 4098 |  | STR# 129, 130, 256, 257, 301, 303; TTAs 129; rsmp 0 |  |
| `unleashedcontroller.iff` | BCON 4096, 4101, 4102, 4103, 4104, 4105, 4107, 4108; TRCN 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109 |  | rsmp 0 |  |
| `urnstone.iff` | BCON 4097; TRCN 4097 |  | STR# 129, 130, 131, 132, 256, 257, 301; TTAs 129; rsmp 0 |  |
| `urnstonepet.iff` | BCON 4097; TRCN 4096, 4097 |  | rsmp 0 |  |
| `vacationgrill.iff` | BCON 4100, 4101; TRCN 4096, 4097, 4098, 4099, 4100, 4101 |  | rsmp 0 |  |
| `villagecontrol.iff` | BCON 4096, 4098; TRCN 4096, 4097, 4098 |  | rsmp 0 |  |
| `vrhelmet.iff` | BCON 4096; TRCN 4096 |  | BHAV 4097; STR# 129, 130, 256, 304; TTAB 129; TTAs 129; rsmp 0 |  |
| `walllite.iff` | TRCN 4096 |  | STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |
| `wargame.iff` |  |  | STR# 129, 256, 257, 301, 302, 303, 304, 4096, 4097, 4098, 4099; TTAs 129 |  |
| `watercooler.iff` | BCON 4097, 4098; TRCN 4097, 4098 |  | STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `wedcandelabra.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `weddingarch.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `weddingballoons.iff` | BCON 4100; TRCN 4096, 4097, 4098, 4099, 4100 |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129; rsmp 0 |  |
| `weddingcake.iff` |  |  | STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137 |  |
| `weddingchairfolding.iff` | BCON 4097, 4098; TRCN 4096, 4097, 4098 |  | STR# 129, 130, 256, 257; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 |  |
| `weddingflowers.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `weddingqueueropes.iff` | TRCN 4100 |  | STR# 129, 300, 303; rsmp 0 |  |
| `weddingrugrunner.iff` | TRCN 4096 |  | STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `weddingsign.iff` | BCON 4097; TRCN 4096, 4097 |  | STR# 129, 256, 257; TTAs 129; rsmp 0 |  |
| `weddingtrunk.iff` | TRCN 4096, 4097 |  | STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `windows.iff` |  |  | CTSS 2013; rsmp 0 |  |
| `windows2.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `windows3.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `windows4.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `windows5.iff` | BCON 4096; TRCN 4096 |  | CTSS 2001; rsmp 0 |  |
| `windows6.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `windowsbeach.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |
| `windowslodge.iff` | BCON 4096; TRCN 4096 |  | rsmp 0 |  |

#### `objectdata/objects/objotf.far`

FAR1, 419643 bytes in the older, 421249 in the newer.

Entries only in the older: 0, only in the newer: 2, changed: 24.

#### `objectdata/objects/objspf4.far`

FAR1, 52513576 bytes in the older, 52434953 in the newer.

Entries only in the older: 1, only in the newer: 1, changed: 0.

#### `objectdata/objects/objspf5.far`

FAR1, 54257647 bytes in the older, 52632705 in the newer.

Entries only in the older: 1, only in the newer: 1, changed: 0.

#### `packingslips/accessorytable.xml`

57826 bytes in the older, 57915 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/animtable.xml`

535615 bytes in the older, 536506 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/catalog.xml`

101011 bytes in the older, 107697 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/objecttable.xml`

172515 bytes in the older, 183844 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/packingslip.log`

2720853 bytes in the older, 2838001 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/packingslips.dat`

FAR3, 4781652 bytes in the older, 4984795 in the newer.

Entries only in the older: 0, only in the newer: 1365, changed: 4768.

#### `packingslips/textable.xml`

453173 bytes in the older, 482261 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `properties.txt`

85 bytes in the older, 85 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/eventlist.txt`

49355 bytes in the older, 49091 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsov2.evt`

32112 bytes in the older, 32552 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsov2.hit`

27400 bytes in the older, 27803 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/cityselector.ini`

537 bytes in the older, 581 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/hintmanager.ini`

325 bytes in the older, 2099 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/nametohostmap.ini`

4303 bytes in the older, 4534 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOAnimD.dll`

344064 bytes in the older, 344064 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOAudio.dat`

DBPF, 74350010 bytes in the older, 74598227 in the newer.

Entries only in the older: 6, only in the newer: 31, changed: 2.

#### `TSOAudioViewD.dll`

380928 bytes in the older, 380928 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOClient.exe`

307200 bytes in the older, 307200 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOData_datadefinition.dat`

6474 bytes in the older, 6789 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSODataServiceClientD.dll`

671744 bytes in the older, 638976 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOEdithPluginClientD.dll`

389120 bytes in the older, 393216 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOGimexD.dll`

368640 bytes in the older, 368640 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOGraphicD.dll`

765952 bytes in the older, 765952 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSONetServiceSimClientD.dll`

704512 bytes in the older, 704512 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOServiceClientD.dll`

569344 bytes in the older, 569344 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOSimulatorClientD.dll`

942080 bytes in the older, 966656 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `tsov2.dat`

DBPF, 118185153 bytes in the older, 117349763 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 10.

#### `TSOViewerClientD.dll`

479232 bytes in the older, 483328 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOWinAppD.dll`

2093056 bytes in the older, 2138112 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOWorldClientD.dll`

270336 bytes in the older, 274432 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `tuning.dat`

1751 bytes in the older, 2361 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `uigraphics/eods/eods.dat`

FAR3, 2472656 bytes in the older, 2996200 in the newer.

Entries only in the older: 0, only in the newer: 12, changed: 9.

#### `uigraphics/hints/hint_solojob1.bmp`

8508 bytes in the older, 8572 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `uigraphics/housepage/housepage.dat`

FAR3, 505272 bytes in the older, 504620 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 2.

#### `uigraphics/matchmaker/matchmaker.dat`

FAR3, 43230 bytes in the older, 44146 in the newer.

Entries only in the older: 0, only in the newer: 2, changed: 0.

#### `uigraphics/other/other.dat`

FAR3, 1005555 bytes in the older, 1005614 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `uigraphics/personselection/personselection.dat`

FAR3, 892314 bytes in the older, 1535651 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 0.

#### `uigraphics/ucp/ucp.dat`

FAR3, 3838897 bytes in the older, 3981791 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 4.

#### `version`

38 bytes in the older, 9 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

## `TSO_CLASSIC_DIR` (1.145.1.0) to `TSO_GAME_DIR` (1.1097.1.0)

### Only in `TSO_CLASSIC_DIR` (1.145.1.0)

- `AssetManagerD.dll`
- `GZFont.dll`
- `HitLabServiceD.dll`
- `expat.dll`
- `gamedata/uiscripts/chathistory.uis`
- `gamedata/uitext.dir/_128_pickfamilystrs.cst`
- `gamedata/uitext.dir/_129_designfamilystrs.cst`
- `gamedata/uitext.dir/_130_designcharstrs.cst`
- `gamedata/uitext.dir/_131_evictmodestrs.cst`
- `gamedata/uitext.dir/_132_moveinmodestrs.cst`
- `gamedata/uitext.dir/_133_regularmodestrs.cst`
- `gamedata/uitext.dir/_134_nghrollover.cst`
- `gamedata/uitext.dir/_136_disposebuttonstrs.cst`
- `gamedata/uitext.dir/_137_placementerrs.cst`
- `gamedata/uitext.dir/_138_vctltips.cst`
- `gamedata/uitext.dir/_139_bldtips.cst`
- `gamedata/uitext.dir/_142_objdialogs.cst`
- `gamedata/uitext.dir/_145_optionstrs.cst`
- `gamedata/uitext.dir/_146_budgetstrs.cst`
- `gamedata/uitext.dir/_147_roofpanelstrs.cst`
- `gamedata/uitext.dir/_148_pause.cst`
- `gamedata/uitext.dir/_149_dirttoolerrs.cst`
- `gamedata/uitext.dir/_150_buymodecatalogsorttips.cst`
- `gamedata/uitext.dir/_152_defaultdialogbuttons.cst`
- `gamedata/uitext.dir/_153_appstrings.cst`
- `gamedata/uitext.dir/_154_miscstrings.cst`
- `gamedata/uitext.dir/_155_splashprogress.cst`
- `gamedata/uitext.dir/_156_pipstrings.cst`
- `gamedata/uitext.dir/_157_configstrings.cst`
- `gamedata/uitext.dir/_159_objecttts.cst`
- `gamedata/uitext.dir/_160_catalogratings.cst`
- `gamedata/uitext.dir/_161_localkeys.cst`
- `gamedata/uitext.dir/_169_pickasimstrings.cst`
- `gamedata/uitext.dir/_170_createasimstrings.cst`
- `gamedata/uitext.dir/_171_ucpstrings.cst`
- `gamedata/uitext.dir/_172_buildpanelstrings.cst`
- `gamedata/uitext.dir/_173_buypanelstrings.cst`
- `gamedata/uitext.dir/_174_livepanelstrings.cst`
- `gamedata/uitext.dir/_175_housepanelstrings.cst`
- `gamedata/uitext.dir/_176_admitbanpanelstrings.cst`
- `gamedata/uitext.dir/_177_logpanelstrings.cst`
- `gamedata/uitext.dir/_178_roommatespanelstrings.cst`
- `gamedata/uitext.dir/_179_statisticspanelstrings.cst`
- `gamedata/uitext.dir/_180_envpanelstrings.cst`
- `gamedata/uitext.dir/_181_lightingpanelstrings.cst`
- `gamedata/uitext.dir/_182_timeofdaypanelstrings.cst`
- `gamedata/uitext.dir/_183_soundspanelstrings.cst`
- `gamedata/uitext.dir/_184_graphicspanelstrings.cst`
- `gamedata/uitext.dir/_185_optionspanelstrings.cst`
- `gamedata/uitext.dir/_186_playpanelstrings.cst`
- `gamedata/uitext.dir/_187_soundpanelstrings.cst`
- `gamedata/uitext.dir/_188_gizmostrings.cst`
- `gamedata/uitext.dir/_189_personpagestrings.cst`
- `gamedata/uitext.dir/_190_housepagestrings.cst`
- `gamedata/uitext.dir/_191_gmpetitionstrings.cst`
- `gamedata/uitext.dir/_192_doorpermissioneodstrings.cst`
- `gamedata/uitext.dir/_193_signseodstrings.cst`
- `gamedata/uitext.dir/_194_bookmarksstrings.cst`
- `gamedata/uitext.dir/_195_messagestrings.cst`
- `gamedata/uitext.dir/_196_messageiconstrings.cst`
- `gamedata/uitext.dir/_197_trunkeodstrings.cst`
- `gamedata/uitext.dir/_198_timereodstrings.cst`
- `gamedata/uitext.dir/_199_scoreboardeodstrings.cst`
- `gamedata/uitext.dir/_200_messageinboxstrings.cst`
- `gamedata/uitext.dir/_201_messageinboxmenustrings.cst`
- `gamedata/uitext.dir/_202_buildableareapanelstrings.cst`
- `gamedata/uitext.dir/_203_gamecompdrawacardeodstrings.cst`
- `gamedata/uitext.dir/_204_jobobjectpizzaeodstrings.cst`
- `gamedata/uitext.dir/_205_banignoredialogstrings.cst`
- `gamedata/uitext.dir/_206_querypanelstrings.cst`
- `gamedata/uitext.dir/_207_danceflooreodstrings.cst`
- `gamedata/uitext.dir/_208_roommateprotocolstrings.cst`
- `gamedata/uitext.dir/_209_logindlgstrings.cst`
- `gamedata/uitext.dir/_210_cityselprotocolstrings.cst`
- `gamedata/uitext.dir/_211_housesimloginstrings.cst`
- `gamedata/uitext.dir/_212_housepagestrings.cst`
- `gamedata/uitext.dir/_213_datahandler.cst`
- `gamedata/uitext.dir/_214_winskinbrowser.cst`
- `gamedata/uitext.dir/_215_matchmakerclosezoom.cst`
- `gamedata/uitext.dir/_216_buildableareapanel.cst`
- `gamedata/uitext.dir/_217_personicon.cst`
- `gamedata/uitext.dir/_218_neighborhood.cst`
- `gamedata/uitext.dir/_219_searchresultsvec.cst`
- `gamedata/uitext.dir/_220_lotreserves.cst`
- `gamedata/uitext.dir/_221_cpstate.cst`
- `gamedata/uitext.dir/_222_loginprotocol.cst`
- `gamedata/uitext.dir/_223_hostvisitorprotocol.cst`
- `gamedata/uitext.dir/_224_securetrading.cst`
- `gamedata/uitext.dir/_225_messagemanager.cst`
- `gamedata/uitext.dir/_226_skillprogressheadline.cst`
- `gamedata/uitext.dir/_227_friendshipweb.cst`
- `gamedata/uitext.dir/_228_exitdialog.cst`
- `gamedata/uitext.dir/_229_pphelptoc.cst`
- `gamedata/uitext.dir/_230_ppshared.cst`
- `gamedata/uitext.dir/_231_pppetitionformdlg.cst`
- `gamedata/uitext.dir/_232_ppcomplaindlg.cst`
- `gamedata/uitext.dir/_233_profanitypanelstrings.cst`
- `gamedata/uitext.dir/_234_cityselector.cst`
- `gamedata/uitext.dir/_235_twopersonjobobjectmazeeodstrings.cst`
- `gamedata/uitext.dir/_236_paperchaseeodstrings.cst`
- `gamedata/uitext.dir/_237_passworddlgstrings.cst`
- `gamedata/uitext.dir/_238_citydescriptionstrings.cst`
- `gamedata/uitext.dir/_239_asyncsale.cst`
- `gamedata/uitext.dir/_240_timeoutdlgstrings.cst`
- `gamedata/uitext.dir/_241_creditsdlgstrings.cst`
- `gamedata/uitext.dir/_242_creditsstrings.cst`
- `gamedata/uitext.dir/_243_csrtools.cst`
- `gamedata/uitext.dir/_244_csreject.cst`
- `gamedata/uitext.dir/_245_buybuildmodestrings.cst`
- `gamedata/uitext.dir/_246_lotpurchasedlgstrings.cst`
- `gamedata/uitext.dir/_247_lotnameeditdlgstrings.cst`
- `gamedata/uitext.dir/_248_hintsstrings.cst`
- `gamedata/uitext.dir/_249_userinputdlg.cst`
- `gamedata/uitext.dir/_250_doorcodedlg.cst`
- `gamedata/uitext.dir/_251_connectprogressdialog.cst`
- `gamedata/uitext.dir/_252_lotcategoryselectiondlgstrings.cst`
- `gamedata/uitext.dir/_253_jobobjband.cst`
- `gamedata/uitext.dir/_255_fwebcommenteditdlgstrings.cst`
- `objectdata/globals/decoration.iff`
- `objectdata/globals/decoration.otf`
- `packingslips/packingslip.log`
- `uigraphics/fonts/font12j.fon`
- `uigraphics/fonts/font12k.fon`
- `uigraphics/fonts/font16b5.fon`
- `uigraphics/fonts/font16gb.fon`
- `uigraphics/fonts/font16j.fon`
- `uigraphics/fonts/font16k.fon`
- `uigraphics/fonts/font20th.fon`
- `uigraphics/fonts/simdialo.pfb`
- `uigraphics/fonts/simdialo.pfm`
- `uigraphics/fonts/variablesans_07.bmp`
- `uigraphics/fonts/variablesans_07.ffn`
- `uigraphics/fonts/variablesans_07.fot`
- `uigraphics/fonts/variablesans_08.bmp`
- `uigraphics/fonts/variablesans_08.ffn`
- `uigraphics/fonts/variablesans_08.fot`
- `uigraphics/fonts/variablesans_09.bmp`
- `uigraphics/fonts/variablesans_09.ffn`
- `uigraphics/fonts/variablesans_09.fot`
- `uigraphics/fonts/variablesans_10.bmp`
- `uigraphics/fonts/variablesans_10.ffn`
- `uigraphics/fonts/variablesans_10.fot`
- `uigraphics/fonts/variablesans_11.bmp`
- `uigraphics/fonts/variablesans_11.ffn`
- `uigraphics/fonts/variablesans_11.fot`
- `uigraphics/fonts/variablesans_11_bs.ffn`
- `uigraphics/fonts/variablesans_11_s.ffn`
- `uigraphics/fonts/variablesans_12.bmp`
- `uigraphics/fonts/variablesans_12.ffn`
- `uigraphics/fonts/variablesans_12.fot`
- `uigraphics/fonts/variablesans_12_bs.ffn`
- `uigraphics/fonts/variablesans_14.bmp`
- `uigraphics/fonts/variablesans_14.ffn`
- `uigraphics/fonts/variablesans_14.fot`
- `uigraphics/fonts/variablesans_14_bs.ffn`
- `uigraphics/fonts/variablesans_16.bmp`
- `uigraphics/fonts/variablesans_16.ffn`
- `uigraphics/fonts/variablesans_16.fot`
- `uigraphics/fonts/variablesans_18.bmp`
- `uigraphics/fonts/variablesans_18.ffn`
- `uigraphics/fonts/variablesans_18.fot`
- `uigraphics/fonts/variablesans_20.bmp`
- `uigraphics/fonts/variablesans_20.ffn`
- `uigraphics/fonts/variablesans_20.fot`
- `uigraphics/fonts/variablesans_48.bmp`
- `uigraphics/fonts/variablesans_48.ffn`
- `uigraphics/fonts/variablesans_48.fot`

### Only in `TSO_GAME_DIR` (1.1097.1.0)

- `TSOFont.dll`
- `TSOPersistD.dll`
- `TSOPersistToolsD.dll`
- `TSOPresentationLayerD.dll`
- `avatardata/skeletons/skeletons.dat`
- `avatardata2/accessories/appearances/appearances.dat`
- `avatardata2/accessories/bindings/bindings.dat`
- `avatardata2/accessories/meshes/meshes.dat`
- `avatardata2/accessories/textures/textures.dat`
- `avatardata2/animations/animations.dat`
- `avatardata2/bodies/appearances/appearances.dat`
- `avatardata2/bodies/bindings/bindings.dat`
- `avatardata2/bodies/collections/collections.dat`
- `avatardata2/bodies/meshes/meshes.dat`
- `avatardata2/bodies/outfits/outfits.dat`
- `avatardata2/bodies/purchasables/purchasables.dat`
- `avatardata2/bodies/textures/textures.dat`
- `avatardata2/bodies/thumbnails/thumbnails.dat`
- `avatardata2/hands/appearances/appearances.dat`
- `avatardata2/hands/bindings/bindings.dat`
- `avatardata2/hands/groups/groups.dat`
- `avatardata2/hands/meshes/meshes.dat`
- `avatardata2/hands/textures/textures.dat`
- `avatardata2/heads/appearances/appearances.dat`
- `avatardata2/heads/bindings/bindings.dat`
- `avatardata2/heads/collections/collections.dat`
- `avatardata2/heads/meshes/meshes.dat`
- `avatardata2/heads/outfits/outfits.dat`
- `avatardata2/heads/purchasables/purchasables.dat`
- `avatardata2/heads/textures/textures.dat`
- `avatardata2/heads/thumbnails/thumbnails.dat`
- `avatardata2/skeletons/cat.skel`
- `avatardata2/skeletons/dog.skel`
- `avatardata2/skeletons/skeletons.dat`
- `avatardata3/accessories/appearances/appearances.dat`
- `avatardata3/accessories/bindings/bindings.dat`
- `avatardata3/accessories/meshes/meshes.dat`
- `avatardata3/accessories/textures/textures.dat`
- `avatardata3/animations/animations.dat`
- `avatardata3/bodies/appearances/appearances.dat`
- `avatardata3/bodies/bindings/bindings.dat`
- `avatardata3/bodies/collections/collections.dat`
- `avatardata3/bodies/meshes/meshes.dat`
- `avatardata3/bodies/outfits/outfits.dat`
- `avatardata3/bodies/purchasables/purchasables.dat`
- `avatardata3/bodies/textures/textures.dat`
- `avatardata3/bodies/thumbnails/thumbnails.dat`
- `avatardata3/hands/appearances/appearances.dat`
- `avatardata3/hands/bindings/bindings.dat`
- `avatardata3/hands/groups/groups.dat`
- `avatardata3/hands/meshes/meshes.dat`
- `avatardata3/hands/textures/textures.dat`
- `avatardata3/heads/appearances/appearances.dat`
- `avatardata3/heads/bindings/bindings.dat`
- `avatardata3/heads/collections/collections.dat`
- `avatardata3/heads/meshes/meshes.dat`
- `avatardata3/heads/outfits/outfits.dat`
- `avatardata3/heads/purchasables/purchasables.dat`
- `avatardata3/heads/textures/textures.dat`
- `avatardata3/heads/thumbnails/thumbnails.dat`
- `avatardata3/skeletons/skeletons.dat`
- `gamedata/menulights.ini`
- `gamedata/sys/ambience.ini`
- `gamedata/sys/cityselector.ini`
- `gamedata/sys/default.ini`
- `gamedata/sys/gameentry.ini`
- `gamedata/sys/hintmanager.ini`
- `gamedata/sys/nametohostmap.ini`
- `gamedata/sys/radio.ini`
- `gamedata/sys/tsoaudio.ini`
- `gamedata/sys/tsochatcolors.ini`
- `gamedata/sys/tsopersist.ini`
- `gamedata/sys/tsosounddata.ini`
- `gamedata/uiscripts/blackjackeod.uis`
- `gamedata/uiscripts/buildpanel1024.uis`
- `gamedata/uiscripts/buypanel1024.uis`
- `gamedata/uiscripts/carddeck.uis`
- `gamedata/uiscripts/chatdialog.uis`
- `gamedata/uiscripts/chefeod.uis`
- `gamedata/uiscripts/danceplatformeod.uis`
- `gamedata/uiscripts/djstationeod.uis`
- `gamedata/uiscripts/dressereod.uis`
- `gamedata/uiscripts/fwebcontrols.uis`
- `gamedata/uiscripts/fwebcontrols1024.uis`
- `gamedata/uiscripts/livepanel1024.uis`
- `gamedata/uiscripts/neighborhoodpage.uis`
- `gamedata/uiscripts/neighborhoods.uis`
- `gamedata/uiscripts/personselection1024.uis`
- `gamedata/uiscripts/personselectionedit1024.uis`
- `gamedata/uiscripts/querypanel1024.uis`
- `gamedata/uiscripts/rackeod.uis`
- `gamedata/uiscripts/rackownereod.uis`
- `gamedata/uiscripts/rouletteeod.uis`
- `gamedata/uiscripts/securetradingeod1024.uis`
- `gamedata/uiscripts/slotseod.uis`
- `gamedata/uiscripts/visitorbonusdialog.uis`
- `gamedata/uiscripts/wargameeod.uis`
- `gamedata/uitext/english.dir/_128_pickfamilystrs.cst`
- `gamedata/uitext/english.dir/_129_designfamilystrs.cst`
- `gamedata/uitext/english.dir/_130_designcharstrs.cst`
- `gamedata/uitext/english.dir/_131_evictmodestrs.cst`
- `gamedata/uitext/english.dir/_132_moveinmodestrs.cst`
- `gamedata/uitext/english.dir/_133_regularmodestrs.cst`
- `gamedata/uitext/english.dir/_134_nghrollover.cst`
- `gamedata/uitext/english.dir/_136_disposebuttonstrs.cst`
- `gamedata/uitext/english.dir/_137_placementerrs.cst`
- `gamedata/uitext/english.dir/_138_vctltips.cst`
- `gamedata/uitext/english.dir/_139_bldtips.cst`
- `gamedata/uitext/english.dir/_142_objdialogs.cst`
- `gamedata/uitext/english.dir/_145_optionstrs.cst`
- `gamedata/uitext/english.dir/_146_budgetstrs.cst`
- `gamedata/uitext/english.dir/_147_roofpanelstrs.cst`
- `gamedata/uitext/english.dir/_148_pause.cst`
- `gamedata/uitext/english.dir/_149_dirttoolerrs.cst`
- `gamedata/uitext/english.dir/_150_buymodecatalogsorttips.cst`
- `gamedata/uitext/english.dir/_152_defaultdialogbuttons.cst`
- `gamedata/uitext/english.dir/_153_appstrings.cst`
- `gamedata/uitext/english.dir/_154_miscstrings.cst`
- `gamedata/uitext/english.dir/_155_splashprogress.cst`
- `gamedata/uitext/english.dir/_156_pipstrings.cst`
- `gamedata/uitext/english.dir/_157_configstrings.cst`
- `gamedata/uitext/english.dir/_159_objecttts.cst`
- `gamedata/uitext/english.dir/_160_catalogratings.cst`
- `gamedata/uitext/english.dir/_161_localkeys.cst`
- `gamedata/uitext/english.dir/_169_pickasimstrings.cst`
- `gamedata/uitext/english.dir/_170_createasimstrings.cst`
- `gamedata/uitext/english.dir/_171_ucpstrings.cst`
- `gamedata/uitext/english.dir/_172_buildpanelstrings.cst`
- `gamedata/uitext/english.dir/_173_buypanelstrings.cst`
- `gamedata/uitext/english.dir/_174_livepanelstrings.cst`
- `gamedata/uitext/english.dir/_175_housepanelstrings.cst`
- `gamedata/uitext/english.dir/_176_admitbanpanelstrings.cst`
- `gamedata/uitext/english.dir/_177_logpanelstrings.cst`
- `gamedata/uitext/english.dir/_178_roommatespanelstrings.cst`
- `gamedata/uitext/english.dir/_179_statisticspanelstrings.cst`
- `gamedata/uitext/english.dir/_180_envpanelstrings.cst`
- `gamedata/uitext/english.dir/_181_lightingpanelstrings.cst`
- `gamedata/uitext/english.dir/_182_timeofdaypanelstrings.cst`
- `gamedata/uitext/english.dir/_183_soundspanelstrings.cst`
- `gamedata/uitext/english.dir/_184_graphicspanelstrings.cst`
- `gamedata/uitext/english.dir/_185_optionspanelstrings.cst`
- `gamedata/uitext/english.dir/_186_playpanelstrings.cst`
- `gamedata/uitext/english.dir/_187_soundpanelstrings.cst`
- `gamedata/uitext/english.dir/_188_gizmostrings.cst`
- `gamedata/uitext/english.dir/_189_personpagestrings.cst`
- `gamedata/uitext/english.dir/_190_housepagestrings.cst`
- `gamedata/uitext/english.dir/_191_gmpetitionstrings.cst`
- `gamedata/uitext/english.dir/_192_doorpermissioneodstrings.cst`
- `gamedata/uitext/english.dir/_193_signseodstrings.cst`
- `gamedata/uitext/english.dir/_194_bookmarksstrings.cst`
- `gamedata/uitext/english.dir/_195_messagestrings.cst`
- `gamedata/uitext/english.dir/_196_messageiconstrings.cst`
- `gamedata/uitext/english.dir/_197_trunkeodstrings.cst`
- `gamedata/uitext/english.dir/_198_timereodstrings.cst`
- `gamedata/uitext/english.dir/_199_scoreboardeodstrings.cst`
- `gamedata/uitext/english.dir/_200_messageinboxstrings.cst`
- `gamedata/uitext/english.dir/_201_messageinboxmenustrings.cst`
- `gamedata/uitext/english.dir/_202_buildableareapanelstrings.cst`
- `gamedata/uitext/english.dir/_203_gamecompdrawacardeodstrings.cst`
- `gamedata/uitext/english.dir/_204_jobobjectpizzaeodstrings.cst`
- `gamedata/uitext/english.dir/_205_banignoredialogstrings.cst`
- `gamedata/uitext/english.dir/_206_querypanelstrings.cst`
- `gamedata/uitext/english.dir/_207_danceflooreodstrings.cst`
- `gamedata/uitext/english.dir/_208_roommateprotocolstrings.cst`
- `gamedata/uitext/english.dir/_209_logindlgstrings.cst`
- `gamedata/uitext/english.dir/_210_cityselprotocolstrings.cst`
- `gamedata/uitext/english.dir/_211_housesimloginstrings.cst`
- `gamedata/uitext/english.dir/_212_housepagestrings.cst`
- `gamedata/uitext/english.dir/_213_datahandler.cst`
- `gamedata/uitext/english.dir/_214_winskinbrowser.cst`
- `gamedata/uitext/english.dir/_215_matchmakerclosezoom.cst`
- `gamedata/uitext/english.dir/_216_buildableareapanel.cst`
- `gamedata/uitext/english.dir/_217_personicon.cst`
- `gamedata/uitext/english.dir/_218_neighborhood.cst`
- `gamedata/uitext/english.dir/_219_searchresultsvec.cst`
- `gamedata/uitext/english.dir/_220_lotreserves.cst`
- `gamedata/uitext/english.dir/_221_cpstate.cst`
- `gamedata/uitext/english.dir/_222_loginprotocol.cst`
- `gamedata/uitext/english.dir/_223_hostvisitorprotocol.cst`
- `gamedata/uitext/english.dir/_224_securetrading.cst`
- `gamedata/uitext/english.dir/_225_messagemanager.cst`
- `gamedata/uitext/english.dir/_226_skillprogressheadline.cst`
- `gamedata/uitext/english.dir/_227_friendshipweb.cst`
- `gamedata/uitext/english.dir/_228_exitdialog.cst`
- `gamedata/uitext/english.dir/_229_pphelptoc.cst`
- `gamedata/uitext/english.dir/_230_ppshared.cst`
- `gamedata/uitext/english.dir/_231_pppetitionformdlg.cst`
- `gamedata/uitext/english.dir/_232_ppcomplaindlg.cst`
- `gamedata/uitext/english.dir/_233_profanitypanelstrings.cst`
- `gamedata/uitext/english.dir/_234_cityselector.cst`
- `gamedata/uitext/english.dir/_235_twopersonjobobjectmazeeodstrings.cst`
- `gamedata/uitext/english.dir/_236_paperchaseeodstrings.cst`
- `gamedata/uitext/english.dir/_237_passworddlgstrings.cst`
- `gamedata/uitext/english.dir/_238_citydescriptionstrings.cst`
- `gamedata/uitext/english.dir/_239_asyncsale.cst`
- `gamedata/uitext/english.dir/_240_timeoutdlgstrings.cst`
- `gamedata/uitext/english.dir/_241_creditsdlgstrings.cst`
- `gamedata/uitext/english.dir/_242_creditsstrings.cst`
- `gamedata/uitext/english.dir/_243_csrtools.cst`
- `gamedata/uitext/english.dir/_244_csreject.cst`
- `gamedata/uitext/english.dir/_245_buybuildmodestrings.cst`
- `gamedata/uitext/english.dir/_246_lotpurchasedlgstrings.cst`
- `gamedata/uitext/english.dir/_247_lotnameeditdlgstrings.cst`
- `gamedata/uitext/english.dir/_248_hintsstrings.cst`
- `gamedata/uitext/english.dir/_249_userinputdlg.cst`
- `gamedata/uitext/english.dir/_250_doorcodedlg.cst`
- `gamedata/uitext/english.dir/_251_connectprogressdialog.cst`
- `gamedata/uitext/english.dir/_252_lotcategoryselectiondlgstrings.cst`
- `gamedata/uitext/english.dir/_253_jobobjband.cst`
- `gamedata/uitext/english.dir/_254_bookmarkerrorstrings.cst`
- `gamedata/uitext/english.dir/_255_fwebcommenteditdlgstrings.cst`
- `gamedata/uitext/english.dir/_256_visitorbonusdialog.cst`
- `gamedata/uitext/english.dir/_257_neighborhooddlgstrings.cst`
- `gamedata/uitext/english.dir/_258_roulettetableeodstrings.cst`
- `gamedata/uitext/english.dir/_259_slotseodstrings.cst`
- `gamedata/uitext/english.dir/_260_neighborhooddlgstrings.cst`
- `gamedata/uitext/english.dir/_261_chatdlgstrings.cst`
- `gamedata/uitext/english.dir/_262_carddeckstrings.cst`
- `gamedata/uitext/english.dir/_263_blackjackeodstrings.cst`
- `gamedata/uitext/english.dir/_264_rackeodstrings.cst`
- `gamedata/uitext/english.dir/_265_rackownereodstrings.cst`
- `gamedata/uitext/english.dir/_266_dressereodstrings.cst`
- `gamedata/uitext/english.dir/_267_incomeexpensecategorystrings.cst`
- `gamedata/uitext/english.dir/_268_offlottransactiondialogstrings.cst`
- `gamedata/uitext/english.dir/_269_headhunterstrings.cst`
- `gamedata/uitext/english.dir/_270_djstationstrings.cst`
- `gamedata/uitext/english.dir/_272_jobtitlestrings.cst`
- `gamedata/uitext/english.dir/_273_wargameeodstrings.cst`
- `gamedata/uitext/english.dir/_274_fwebstrings.cst`
- `gamedata/uitext/english.dir/_275_lmsonlinejobsglobals.cst`
- `gamedata/uitext/english.dir/_276_lmsroommateprotocolstrings.cst`
- `gamedata/uitext/english.dir/_277_lms_miscstring.cst`
- `gamedata/uitext/english.dir/_278_miscstring.cst`
- `gamedata/uitext/english.dir/_279_lms_petletters.cst`
- `gamedata/userinfo.ini`
- `housedata/blueprints/blueprint.dtd`
- `housedata/blueprints/nightclub00_00.xml`
- `housedata/blueprints/nightclub00_01.xml`
- `housedata/blueprints/nightclub01_00.xml`
- `housedata/blueprints/nightclub02_00.xml`
- `housedata/blueprints/nightclub03_00.xml`
- `housedata/blueprints/restaurant00_00.xml`
- `housedata/blueprints/restaurant01_00.xml`
- `housedata/blueprints/restaurant02_00.xml`
- `housedata/blueprints/restaurant03_00.xml`
- `housedata/blueprints/restaurant04_00.xml`
- `housedata/blueprints/restaurant07_00.xml`
- `housedata/blueprints/restaurant08_00.xml`
- `housedata/blueprints/robotfactory00_00.xml`
- `housedata/blueprints/robotfactory01_00.xml`
- `housedata/blueprints/robotfactory02_00.xml`
- `housedata/blueprints/robotfactory03_00.xml`
- `housedata/blueprints/robotfactory04_00.xml`
- `housedata/blueprints/robotfactory05_00.xml`
- `housedata/blueprints/robotfactory06_00.xml`
- `housedata/blueprints/robotfactory07_00.xml`
- `housedata/blueprints/robotfactory08_00.xml`
- `housedata/blueprints/robotfactory09_00.xml`
- `housedata/blueprints/robotfactory10_00.xml`
- `housedata/floors2/floors2.far`
- `housedata/floors3/floors3.far`
- `housedata/floors4/floors4.far`
- `housedata/walls2/walls2.far`
- `housedata/walls3/walls3.far`
- `housedata/walls4/walls4.far`
- `libexpat.dll`
- `objectdata/globals/balloonsemiglobal.iff`
- `objectdata/globals/bbq_global.iff`
- `objectdata/globals/bedsemiglobal.iff`
- `objectdata/globals/blackjacksemiglobal.iff`
- `objectdata/globals/blackjacksemiglobal.otf`
- `objectdata/globals/buffetsemiglobal.iff`
- `objectdata/globals/carglobals.otf`
- `objectdata/globals/dressersemiglobal.iff`
- `objectdata/globals/flowersemiglobal.iff`
- `objectdata/globals/flowersemiglobal.otf`
- `objectdata/globals/foodsemiglobal.iff`
- `objectdata/globals/fridgesemiglobal.iff`
- `objectdata/globals/mailsemiglobal.iff`
- `objectdata/globals/microphonesemiglobal.iff`
- `objectdata/globals/npc_restaurant_semiglobal.iff`
- `objectdata/globals/npc_restaurant_semiglobal.otf`
- `objectdata/globals/npc_service_semiglobal.iff`
- `objectdata/globals/npc_service_semiglobal.otf`
- `objectdata/globals/oj-rest-npc-staffglobals.iff`
- `objectdata/globals/oj-rest-tableglobals.iff`
- `objectdata/globals/oj-rest-tableglobals.otf`
- `objectdata/globals/onlinejobsglobals.iff`
- `objectdata/globals/onlinejobsglobals.otf`
- `objectdata/globals/pestsemiglobal.iff`
- `objectdata/globals/pestsemiglobal.otf`
- `objectdata/globals/petbedsemiglobal.iff`
- `objectdata/globals/petbedsemiglobal.otf`
- `objectdata/globals/petsemiglobal.iff`
- `objectdata/globals/petsemiglobal.otf`
- `objectdata/globals/plantsemiglobal.iff`
- `objectdata/globals/roulettesemiglobal.iff`
- `objectdata/globals/roulettesemiglobal.otf`
- `objectdata/globals/sinksemiglobal.iff`
- `objectdata/globals/skillcontrollersemiglobal.iff`
- `objectdata/globals/skillcontrollersemiglobal.otf`
- `objectdata/globals/toiletsemiglobal.iff`
- `objectdata/globals/toiletsemiglobal.otf`
- `objectdata/globals/tub_semiglobal.iff`
- `objectdata/globals/wetbarsemiglobal.iff`
- `packingslips/packingslips.txt`
- `packingslips/purchasable.xml`
- `sounddata/nightclubsounds/nc_bass_bass_11_0000afc8.xa`
- `sounddata/nightclubsounds/nc_bass_bass_12_0000afc9.xa`
- `sounddata/nightclubsounds/nc_bass_bass_13_0000afca.xa`
- `sounddata/nightclubsounds/nc_bass_bass_14_0000afcb.xa`
- `sounddata/nightclubsounds/nc_bass_bass_21_0000afcc.xa`
- `sounddata/nightclubsounds/nc_bass_bass_22_0000afcd.xa`
- `sounddata/nightclubsounds/nc_bass_bass_23_0000afce.xa`
- `sounddata/nightclubsounds/nc_bass_bass_24_0000afcf.xa`
- `sounddata/nightclubsounds/nc_bass_bass_31_0000afd0.xa`
- `sounddata/nightclubsounds/nc_bass_bass_32_0000afd1.xa`
- `sounddata/nightclubsounds/nc_bass_bass_33_0000afd2.xa`
- `sounddata/nightclubsounds/nc_bass_bass_34_0000afd3.xa`
- `sounddata/nightclubsounds/nc_bass_bass_41_0000afd4.xa`
- `sounddata/nightclubsounds/nc_bass_bass_42_0000afd5.xa`
- `sounddata/nightclubsounds/nc_bass_bass_43_0000afd6.xa`
- `sounddata/nightclubsounds/nc_bass_bass_44_0000afd7.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_11_0000afd8.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_12_0000afd9.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_13_0000afda.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_14_0000afdb.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_21_0000afdc.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_22_0000afdd.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_23_0000afde.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_24_0000afdf.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_31_0000afe0.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_32_0000afe1.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_33_0000afe2.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_34_0000afe3.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_41_0000afe4.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_42_0000afe5.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_43_0000afe6.xa`
- `sounddata/nightclubsounds/nc_bass_housebass_44_0000afe7.xa`
- `sounddata/nightclubsounds/nc_bass_sub_11_0000afe8.xa`
- `sounddata/nightclubsounds/nc_bass_sub_12_0000afe9.xa`
- `sounddata/nightclubsounds/nc_bass_sub_13_0000afea.xa`
- `sounddata/nightclubsounds/nc_bass_sub_14_0000afeb.xa`
- `sounddata/nightclubsounds/nc_bass_sub_21_0000afec.xa`
- `sounddata/nightclubsounds/nc_bass_sub_22_0000afed.xa`
- `sounddata/nightclubsounds/nc_bass_sub_23_0000afee.xa`
- `sounddata/nightclubsounds/nc_bass_sub_24_0000afef.xa`
- `sounddata/nightclubsounds/nc_bass_sub_31_0000aff0.xa`
- `sounddata/nightclubsounds/nc_bass_sub_32_0000aff1.xa`
- `sounddata/nightclubsounds/nc_bass_sub_33_0000aff2.xa`
- `sounddata/nightclubsounds/nc_bass_sub_34_0000aff3.xa`
- `sounddata/nightclubsounds/nc_bass_sub_41_0000aff4.xa`
- `sounddata/nightclubsounds/nc_bass_sub_42_0000aff5.xa`
- `sounddata/nightclubsounds/nc_bass_sub_43_0000aff6.xa`
- `sounddata/nightclubsounds/nc_bass_sub_44_0000aff7.xa`
- `sounddata/nightclubsounds/nc_bass_techy_11_0000aff8.xa`
- `sounddata/nightclubsounds/nc_bass_techy_12_0000aff9.xa`
- `sounddata/nightclubsounds/nc_bass_techy_13_0000affa.xa`
- `sounddata/nightclubsounds/nc_bass_techy_14_0000affb.xa`
- `sounddata/nightclubsounds/nc_bass_techy_21_0000affc.xa`
- `sounddata/nightclubsounds/nc_bass_techy_22_0000affd.xa`
- `sounddata/nightclubsounds/nc_bass_techy_23_0000affe.xa`
- `sounddata/nightclubsounds/nc_bass_techy_24_0000afff.xa`
- `sounddata/nightclubsounds/nc_bass_techy_31_0000b000.xa`
- `sounddata/nightclubsounds/nc_bass_techy_32_0000b001.xa`
- `sounddata/nightclubsounds/nc_bass_techy_33_0000b002.xa`
- `sounddata/nightclubsounds/nc_bass_techy_34_0000b003.xa`
- `sounddata/nightclubsounds/nc_bass_techy_41_0000b004.xa`
- `sounddata/nightclubsounds/nc_bass_techy_42_0000b005.xa`
- `sounddata/nightclubsounds/nc_bass_techy_43_0000b006.xa`
- `sounddata/nightclubsounds/nc_bass_techy_44_0000b007.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_11_0000b008.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_12_0000b009.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_13_0000b00a.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_14_0000b00b.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_21_0000b00c.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_22_0000b00d.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_23_0000b00e.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_24_0000b00f.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_31_0000b010.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_32_0000b011.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_33_0000b012.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_34_0000b013.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_41_0000b014.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_42_0000b015.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_43_0000b016.xa`
- `sounddata/nightclubsounds/nc_drums_hardd1_44_0000b017.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_11_0000b018.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_12_0000b019.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_13_0000b01a.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_14_0000b01b.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_21_0000b01c.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_22_0000b01d.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_23_0000b01e.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_24_0000b01f.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_31_0000b020.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_32_0000b021.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_33_0000b022.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_34_0000b023.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_41_0000b024.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_42_0000b025.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_43_0000b026.xa`
- `sounddata/nightclubsounds/nc_drums_hardd2_44_0000b027.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_11_0000b028.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_12_0000b029.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_13_0000b02a.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_14_0000b02b.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_21_0000b02c.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_22_0000b02d.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_23_0000b02e.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_24_0000b02f.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_31_0000b030.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_32_0000b031.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_33_0000b032.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_34_0000b033.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_41_0000b034.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_42_0000b035.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_43_0000b036.xa`
- `sounddata/nightclubsounds/nc_drums_hdrums_44_0000b037.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_11_0000b038.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_12_0000b039.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_13_0000b03a.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_14_0000b03b.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_21_0000b03c.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_22_0000b03d.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_23_0000b03e.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_24_0000b03f.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_31_0000b040.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_32_0000b041.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_33_0000b042.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_34_0000b043.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_41_0000b044.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_42_0000b045.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_43_0000b046.xa`
- `sounddata/nightclubsounds/nc_drums_xdrums_44_0000b047.xa`
- `sounddata/nightclubsounds/nc_leads_arp_11_0000b048.xa`
- `sounddata/nightclubsounds/nc_leads_arp_12_0000b049.xa`
- `sounddata/nightclubsounds/nc_leads_arp_13_0000b04a.xa`
- `sounddata/nightclubsounds/nc_leads_arp_14_0000b04b.xa`
- `sounddata/nightclubsounds/nc_leads_arp_21_0000b04c.xa`
- `sounddata/nightclubsounds/nc_leads_arp_22_0000b04d.xa`
- `sounddata/nightclubsounds/nc_leads_arp_23_0000b04e.xa`
- `sounddata/nightclubsounds/nc_leads_arp_24_0000b04f.xa`
- `sounddata/nightclubsounds/nc_leads_arp_31_0000b050.xa`
- `sounddata/nightclubsounds/nc_leads_arp_32_0000b051.xa`
- `sounddata/nightclubsounds/nc_leads_arp_33_0000b052.xa`
- `sounddata/nightclubsounds/nc_leads_arp_34_0000b053.xa`
- `sounddata/nightclubsounds/nc_leads_arp_41_0000b054.xa`
- `sounddata/nightclubsounds/nc_leads_arp_42_0000b055.xa`
- `sounddata/nightclubsounds/nc_leads_arp_43_0000b056.xa`
- `sounddata/nightclubsounds/nc_leads_arp_44_0000b057.xa`
- `sounddata/nightclubsounds/nc_leads_keys_11_0000b058.xa`
- `sounddata/nightclubsounds/nc_leads_keys_12_0000b059.xa`
- `sounddata/nightclubsounds/nc_leads_keys_13_0000b05a.xa`
- `sounddata/nightclubsounds/nc_leads_keys_14_0000b05b.xa`
- `sounddata/nightclubsounds/nc_leads_keys_21_0000b05c.xa`
- `sounddata/nightclubsounds/nc_leads_keys_22_0000b05d.xa`
- `sounddata/nightclubsounds/nc_leads_keys_23_0000b05e.xa`
- `sounddata/nightclubsounds/nc_leads_keys_24_0000b05f.xa`
- `sounddata/nightclubsounds/nc_leads_keys_31_0000b060.xa`
- `sounddata/nightclubsounds/nc_leads_keys_32_0000b061.xa`
- `sounddata/nightclubsounds/nc_leads_keys_33_0000b062.xa`
- `sounddata/nightclubsounds/nc_leads_keys_34_0000b063.xa`
- `sounddata/nightclubsounds/nc_leads_keys_41_0000b064.xa`
- `sounddata/nightclubsounds/nc_leads_keys_42_0000b065.xa`
- `sounddata/nightclubsounds/nc_leads_keys_43_0000b066.xa`
- `sounddata/nightclubsounds/nc_leads_keys_44_0000b067.xa`
- `sounddata/nightclubsounds/nc_leads_pad_11_0000b068.xa`
- `sounddata/nightclubsounds/nc_leads_pad_12_0000b069.xa`
- `sounddata/nightclubsounds/nc_leads_pad_13_0000b06a.xa`
- `sounddata/nightclubsounds/nc_leads_pad_14_0000b06b.xa`
- `sounddata/nightclubsounds/nc_leads_pad_21_0000b06c.xa`
- `sounddata/nightclubsounds/nc_leads_pad_22_0000b06d.xa`
- `sounddata/nightclubsounds/nc_leads_pad_23_0000b06e.xa`
- `sounddata/nightclubsounds/nc_leads_pad_24_0000b06f.xa`
- `sounddata/nightclubsounds/nc_leads_pad_31_0000b070.xa`
- `sounddata/nightclubsounds/nc_leads_pad_32_0000b071.xa`
- `sounddata/nightclubsounds/nc_leads_pad_33_0000b072.xa`
- `sounddata/nightclubsounds/nc_leads_pad_34_0000b073.xa`
- `sounddata/nightclubsounds/nc_leads_pad_41_0000b074.xa`
- `sounddata/nightclubsounds/nc_leads_pad_42_0000b075.xa`
- `sounddata/nightclubsounds/nc_leads_pad_43_0000b076.xa`
- `sounddata/nightclubsounds/nc_leads_pad_44_0000b077.xa`
- `sounddata/nightclubsounds/nc_leads_synth_11_0000b078.xa`
- `sounddata/nightclubsounds/nc_leads_synth_12_0000b079.xa`
- `sounddata/nightclubsounds/nc_leads_synth_13_0000b07a.xa`
- `sounddata/nightclubsounds/nc_leads_synth_14_0000b07b.xa`
- `sounddata/nightclubsounds/nc_leads_synth_21_0000b07c.xa`
- `sounddata/nightclubsounds/nc_leads_synth_22_0000b07d.xa`
- `sounddata/nightclubsounds/nc_leads_synth_23_0000b07e.xa`
- `sounddata/nightclubsounds/nc_leads_synth_24_0000b07f.xa`
- `sounddata/nightclubsounds/nc_leads_synth_31_0000b080.xa`
- `sounddata/nightclubsounds/nc_leads_synth_32_0000b081.xa`
- `sounddata/nightclubsounds/nc_leads_synth_33_0000b082.xa`
- `sounddata/nightclubsounds/nc_leads_synth_34_0000b083.xa`
- `sounddata/nightclubsounds/nc_leads_synth_41_0000b084.xa`
- `sounddata/nightclubsounds/nc_leads_synth_42_0000b085.xa`
- `sounddata/nightclubsounds/nc_leads_synth_43_0000b086.xa`
- `sounddata/nightclubsounds/nc_leads_synth_44_0000b087.xa`
- `sounddata/nightclubsounds/nc_sfx_electrovox_01_0000b088.xa`
- `sounddata/nightclubsounds/nc_sfx_electrovox_02_0000b089.xa`
- `sounddata/nightclubsounds/nc_sfx_electrovox_03_0000b08a.xa`
- `sounddata/nightclubsounds/nc_sfx_electrovox_04_0000b08b.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_01_0000b08c.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_02_0000b08d.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_03_0000b08e.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_04_0000b08f.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_05_0000b090.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_06_0000b091.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_07_0000b092.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_08_0000b093.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_09_0000b094.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_10_0000b095.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_11_0000b096.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_12_0000b097.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_13_0000b098.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_14_0000b099.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_15_0000b09a.xa`
- `sounddata/nightclubsounds/nc_sfx_perc_16_0000b09b.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_11_0000b09c.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_12_0000b09d.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_13_0000b09e.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_14_0000b09f.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_21_0000b0a0.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_22_0000b0a1.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_23_0000b0a2.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_24_0000b0a3.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_31_0000b0a4.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_32_0000b0a5.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_33_0000b0a6.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_34_0000b0a7.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_41_0000b0a8.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_42_0000b0a9.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_43_0000b0aa.xa`
- `sounddata/nightclubsounds/nc_sfx_scratch_44_0000b0ab.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_01_0000b0b4.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_02_0000b0b5.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_03_0000b0b6.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_04_0000b0b7.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_05_0000b0b8.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_06_0000b0b9.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_07_0000b0ba.xa`
- `sounddata/nightclubsounds/nc_sfx_sfx_08_0000b0bb.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_01_0000b0ac.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_02_0000b0ad.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_03_0000b0ae.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_04_0000b0af.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_05_0000b0b0.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_06_0000b0b1.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_07_0000b0b2.xa`
- `sounddata/nightclubsounds/nc_sfx_sfxcut_08_0000b0b3.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_01_0000b0bc.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_02_0000b0bd.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_03_0000b0be.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_04_0000b0bf.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_05_0000b0c0.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_06_0000b0c1.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_07_0000b0c2.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_08_0000b0c3.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_09_0000b0c4.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_10_0000b0c5.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_11_0000b0c6.xa`
- `sounddata/nightclubsounds/nc_sfx_vox_12_0000b0c7.xa`
- `sounddata/relationships.evt`
- `sounddata/relationships.hit`
- `sounddata/relationships.hot`
- `sounddata/relationships.hsm`
- `sounddata/relationships.txt`
- `sounddata/relationships/vox_cheerupee_motiv_negf4_0000b0f4.xa`
- `sounddata/relationships/vox_cheerupee_motiv_negf6_0000b0f5.xa`
- `sounddata/relationships/vox_cheerupee_motiv_negf8_0000b0f6.xa`
- `sounddata/relationships/vox_cheerupee_motiv_negm3_0000b0f7.xa`
- `sounddata/relationships/vox_cheerupee_motiv_negm5_0000b0f8.xa`
- `sounddata/relationships/vox_cheerupee_motiv_negm9_0000b0f9.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negf2_0000b0fa.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negf4_0000b0fb.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negf6_0000b0fc.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negm3_0000b0fd.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negm5_0000b0fe.xa`
- `sounddata/relationships/vox_cheeruper_motiv_negm7_0000b0ff.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectf15_0000b100.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectf17_0000b101.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectf8_0000b102.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectm22_0000b104.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectm23_0000b105.xa`
- `sounddata/relationships/vox_greet_hshakee_rejectm2_0000b103.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectf3_0000b106.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectf5_0000b107.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectf7_0000b108.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectm14_0000b109.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectm2_0000b10a.xa`
- `sounddata/relationships/vox_greet_hshaker_rejectm8_0000b10b.xa`
- `sounddata/relationships/vox_handkissee_boredf10_0000b10c.xa`
- `sounddata/relationships/vox_handkissee_boredf18_0000b10d.xa`
- `sounddata/relationships/vox_handkissee_boredf4_0000b10e.xa`
- `sounddata/relationships/vox_handkissee_boredm13_0000b10f.xa`
- `sounddata/relationships/vox_handkissee_boredm17_0000b110.xa`
- `sounddata/relationships/vox_handkissee_boredm3_0000b111.xa`
- `sounddata/relationships/vox_handkissee_boredm9_0000b112.xa`
- `sounddata/relationships/vox_handkisser_boredf4_0000b113.xa`
- `sounddata/relationships/vox_handkisser_boredf6_0000b114.xa`
- `sounddata/relationships/vox_handkisser_boredf8_0000b115.xa`
- `sounddata/relationships/vox_handkisser_boredm3_0000b116.xa`
- `sounddata/relationships/vox_handkisser_boredm5_0000b117.xa`
- `sounddata/relationships/vox_handkisser_boredm7_0000b118.xa`
- `sounddata/relationships/vox_handkisser_startf15_0000b164.xa`
- `sounddata/relationships/vox_handkisser_startf21_0000b165.xa`
- `sounddata/relationships/vox_handkisser_startf5_0000b166.xa`
- `sounddata/relationships/vox_handkisser_startm16_0000b167.xa`
- `sounddata/relationships/vox_handkisser_startm18_0000b168.xa`
- `sounddata/relationships/vox_handkisser_startm20_0000b169.xa`
- `sounddata/relationships/vox_kissee_dip_rejectf3_0000b11f.xa`
- `sounddata/relationships/vox_kissee_dip_rejectf5_0000b120.xa`
- `sounddata/relationships/vox_kissee_dip_rejectf7_0000b121.xa`
- `sounddata/relationships/vox_kissee_dip_rejectm2_0000b122.xa`
- `sounddata/relationships/vox_kissee_dip_rejectm4_0000b123.xa`
- `sounddata/relationships/vox_kissee_dip_rejectm6_0000b124.xa`
- `sounddata/relationships/vox_kissee_dipf2_0000b119.xa`
- `sounddata/relationships/vox_kissee_dipf6_0000b11a.xa`
- `sounddata/relationships/vox_kissee_dipf8_0000b11b.xa`
- `sounddata/relationships/vox_kissee_dipm3_0000b11c.xa`
- `sounddata/relationships/vox_kissee_dipm5_0000b11d.xa`
- `sounddata/relationships/vox_kissee_dipm7_0000b11e.xa`
- `sounddata/relationships/vox_kisser_dip_rejectf12_0000b12b.xa`
- `sounddata/relationships/vox_kisser_dip_rejectf2_0000b12c.xa`
- `sounddata/relationships/vox_kisser_dip_rejectf6_0000b12d.xa`
- `sounddata/relationships/vox_kisser_dip_rejectm3_0000b12e.xa`
- `sounddata/relationships/vox_kisser_dip_rejectm5_0000b12f.xa`
- `sounddata/relationships/vox_kisser_dip_rejectm9_0000b130.xa`
- `sounddata/relationships/vox_kisser_dipf11_0000b125.xa`
- `sounddata/relationships/vox_kisser_dipf13_0000b126.xa`
- `sounddata/relationships/vox_kisser_dipf15_0000b127.xa`
- `sounddata/relationships/vox_kisser_dipm10_0000b128.xa`
- `sounddata/relationships/vox_kisser_dipm12_0000b129.xa`
- `sounddata/relationships/vox_kisser_dipm8_0000b12a.xa`
- `sounddata/relationships/vox_sdancee_loopbf10_0000b131.xa`
- `sounddata/relationships/vox_sdancee_loopbf3_0000b132.xa`
- `sounddata/relationships/vox_sdancee_loopbf5_0000b133.xa`
- `sounddata/relationships/vox_sdancee_loopbm11_0000b134.xa`
- `sounddata/relationships/vox_sdancee_loopbm6_0000b135.xa`
- `sounddata/relationships/vox_sdancee_loopbm9_0000b136.xa`
- `sounddata/relationships/vox_sdancee_startf10_0000b137.xa`
- `sounddata/relationships/vox_sdancee_startf17_0000b138.xa`
- `sounddata/relationships/vox_sdancee_startf19_0000b139.xa`
- `sounddata/relationships/vox_sdancee_startm10_0000b13a.xa`
- `sounddata/relationships/vox_sdancee_startm17_0000b13b.xa`
- `sounddata/relationships/vox_sdancee_startm8_0000b13c.xa`
- `sounddata/relationships/vox_sdancee_stopf12_0000b13d.xa`
- `sounddata/relationships/vox_sdancee_stopf14_0000b13e.xa`
- `sounddata/relationships/vox_sdancee_stopf2_0000b13f.xa`
- `sounddata/relationships/vox_sdancee_stopm13_0000b140.xa`
- `sounddata/relationships/vox_sdancee_stopm3_0000b141.xa`
- `sounddata/relationships/vox_sdancer_loopbf10_0000b142.xa`
- `sounddata/relationships/vox_sdancer_loopbf12_0000b143.xa`
- `sounddata/relationships/vox_sdancer_loopbf14_0000b144.xa`
- `sounddata/relationships/vox_sdancer_loopbm13_0000b145.xa`
- `sounddata/relationships/vox_sdancer_loopbm2_0000b146.xa`
- `sounddata/relationships/vox_sdancer_loopbm4_0000b147.xa`
- `sounddata/relationships/vox_sdancer_startf14_0000b148.xa`
- `sounddata/relationships/vox_sdancer_startf18_0000b149.xa`
- `sounddata/relationships/vox_sdancer_startf22_0000b14a.xa`
- `sounddata/relationships/vox_sdancer_startm11_0000b14b.xa`
- `sounddata/relationships/vox_sdancer_startm15_0000b14c.xa`
- `sounddata/relationships/vox_sdancer_startm9_0000b14d.xa`
- `sounddata/relationships/vox_sdancer_stopf12_0000b14e.xa`
- `sounddata/relationships/vox_sdancer_stopf22_0000b14f.xa`
- `sounddata/relationships/vox_sdancer_stopf8_0000b150.xa`
- `sounddata/relationships/vox_sdancer_stopm1_0000b151.xa`
- `sounddata/relationships/vox_sdancer_stopm24_0000b152.xa`
- `sounddata/relationships/vox_sdancer_stopm7_0000b153.xa`
- `sounddata/tsov3.evt`
- `sounddata/tsov3.hit`
- `sounddata/tsov3.hot`
- `sounddata/tsov3.hsm`
- `sounddata/tsov3.txt`
- `sounddata/tsov3_userdata.txt`
- `sounddata/turkey.evt`
- `sounddata/turkey.hit`
- `sounddata/turkey.hot`
- `sounddata/turkey.hsm`
- `sounddata/turkey.txt`
- `sys/blueprints.ini`
- `sys/tsopersist.ini`
- `tuning_hardcore.ini`
- `uigraphics/fonts/simdialogue-uni-game.ttf`
- `uigraphics/friendshipweb/f-web_backbtn.bmp`
- `uigraphics/friendshipweb/f-web_backbtn2.bmp`
- `uigraphics/friendshipweb/f-web_refreshbtn.bmp`
- `uigraphics/friendshipweb/f-webbaremptygreen.tga`
- `uigraphics/friendshipweb/f-webbaremptygreen_c.tga`
- `uigraphics/friendshipweb/f-webbaremptygreen_l.tga`
- `uigraphics/friendshipweb/f-webbaremptygreen_r.tga`
- `uigraphics/friendshipweb/f-webbaremptyred.tga`
- `uigraphics/friendshipweb/f-webbaremptyred_c.tga`
- `uigraphics/friendshipweb/f-webbaremptyred_l.tga`
- `uigraphics/friendshipweb/f-webbaremptyred_r.tga`
- `uigraphics/friendshipweb/f-webbarfilledgreen.tga`
- `uigraphics/friendshipweb/f-webbarfilledgreen_c.tga`
- `uigraphics/friendshipweb/f-webbarfilledgreen_l.tga`
- `uigraphics/friendshipweb/f-webbarfilledgreen_r.tga`
- `uigraphics/friendshipweb/f-webbarfilledred.tga`
- `uigraphics/friendshipweb/f-webbarfilledred_c.tga`
- `uigraphics/friendshipweb/f-webbarfilledred_l.tga`
- `uigraphics/friendshipweb/f-webbarfilledred_r.tga`
- `uigraphics/friendshipweb/f-webcenter_in.tga`
- `uigraphics/friendshipweb/f-webcenter_out.tga`
- `uigraphics/friendshipweb/f-webcenterframeblack.tga`
- `uigraphics/friendshipweb/f-webcenterframebluegrey.tga`
- `uigraphics/friendshipweb/f-webcenterframegreen.tga`
- `uigraphics/friendshipweb/f-webcenterframered.tga`
- `uigraphics/friendshipweb/f-webchat_l.tga`
- `uigraphics/friendshipweb/f-webchat_m.tga`
- `uigraphics/friendshipweb/f-webchat_s.tga`
- `uigraphics/friendshipweb/f-webinnerframeblack.tga`
- `uigraphics/friendshipweb/f-webinnerframebluegrey.tga`
- `uigraphics/friendshipweb/f-webouterframeblack.tga`
- `uigraphics/friendshipweb/f-webouterframebluegrey.tga`
- `uigraphics/friendshipweb/f_web_closebtn.bmp`
- `uigraphics/friendshipweb/f_web_controlback.tga`
- `uigraphics/friendshipweb/f_web_controlback2.tga`
- `uigraphics/friendshipweb/f_web_controlback3.tga`
- `uigraphics/friendshipweb/f_web_inbtn.bmp`
- `uigraphics/friendshipweb/f_web_numberback.tga`
- `uigraphics/friendshipweb/f_web_numberbtn.bmp`
- `uigraphics/friendshipweb/f_web_outbtn.bmp`
- `uigraphics/friendshipweb/friendshipweb_menualpha.tga`
- `uigraphics/hints/hint_nightclub.bmp`
- `uigraphics/hints/hint_restaurant.bmp`
- `uigraphics/hints/hint_robotfactory.bmp`
- `uigraphics/hints/hint_travelcost.bmp`
- `uigraphics/holiday/setup_halloween.bmp`
- `uigraphics/holiday/setup_paddys_day.png`
- `uigraphics/holiday/setup_thanksgiving.bmp`
- `uigraphics/holiday/setup_valentine.png`
- `uigraphics/holiday/setup_xmas.png`
- `uigraphics/shared/cursors/addlock.cur`
- `uigraphics/shared/cursors/removelock.cur`
- `uigraphics/shared/cursors/resizeleftright.cur`
- `uigraphics/shared/cursors/resizelefttop.cur`
- `uigraphics/shared/cursors/resizerighttop.cur`
- `uigraphics/shared/cursors/resizetopbottom.cur`

### Different files

#### `.castanet/index.mrb`

84755 bytes in the older, 120027 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `.castanet/properties.txt`

180 bytes in the older, 183 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `.castanet/publish.mrb`

99366 bytes in the older, 139230 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `avatardata/accessories/appearances/appearances.dat`

FAR3, 47287 bytes in the older, 48466 in the newer.

Entries only in the older: 0, only in the newer: 14, changed: 2.

#### `avatardata/accessories/bindings/bindings.dat`

FAR3, 165413 bytes in the older, 169508 in the newer.

Entries only in the older: 6, only in the newer: 43, changed: 2.

#### `avatardata/accessories/meshes/meshes.dat`

FAR3, 2114381 bytes in the older, 2604362 in the newer.

Entries only in the older: 6, only in the newer: 41, changed: 8.

#### `avatardata/accessories/textures/textures.dat`

FAR3, 2400339 bytes in the older, 2319641 in the newer.

Entries only in the older: 1, only in the newer: 14, changed: 5.

#### `avatardata/animations/animations.dat`

FAR3, 161003506 bytes in the older, 161222803 in the newer.

Entries only in the older: 4722, only in the newer: 4730, changed: 1.

#### `avatardata/bodies/appearances/appearances.dat`

FAR3, 202387 bytes in the older, 202989 in the newer.

Entries only in the older: 10, only in the newer: 18, changed: 0.

#### `avatardata/bodies/bindings/bindings.dat`

FAR3, 291344 bytes in the older, 292186 in the newer.

Entries only in the older: 10, only in the newer: 18, changed: 0.

#### `avatardata/bodies/collections/collections.dat`

FAR3, 7955 bytes in the older, 7954 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 4.

#### `avatardata/bodies/meshes/meshes.dat`

FAR3, 7191963 bytes in the older, 7206006 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 0.

#### `avatardata/bodies/outfits/outfits.dat`

FAR3, 81741 bytes in the older, 81925 in the newer.

Entries only in the older: 4, only in the newer: 6, changed: 0.

#### `avatardata/bodies/purchasables/purchasables.dat`

FAR3, 65059 bytes in the older, 68831 in the newer.

Entries only in the older: 1, only in the newer: 0, changed: 960.

#### `avatardata/bodies/textures/textures.dat`

FAR3, 70812152 bytes in the older, 70970754 in the newer.

Entries only in the older: 0, only in the newer: 9, changed: 0.

#### `avatardata/bodies/thumbnails/thumbnails.dat`

FAR3, 4055494 bytes in the older, 3616047 in the newer.

Entries only in the older: 9, only in the newer: 18, changed: 2883.

#### `avatardata/hands/appearances/appearances.dat`

FAR3, 30998 bytes in the older, 32858 in the newer.

Entries only in the older: 0, only in the newer: 24, changed: 0.

#### `avatardata/hands/bindings/bindings.dat`

FAR3, 44282 bytes in the older, 46918 in the newer.

Entries only in the older: 0, only in the newer: 24, changed: 0.

#### `avatardata/hands/groups/groups.dat`

FAR3, 4603 bytes in the older, 4983 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 0.

#### `avatardata/hands/textures/textures.dat`

FAR3, 474353 bytes in the older, 486224 in the newer.

Entries only in the older: 0, only in the newer: 6, changed: 0.

#### `avatardata/heads/appearances/appearances.dat`

FAR3, 88101 bytes in the older, 88682 in the newer.

Entries only in the older: 1, only in the newer: 9, changed: 0.

#### `avatardata/heads/bindings/bindings.dat`

FAR3, 123171 bytes in the older, 123960 in the newer.

Entries only in the older: 1, only in the newer: 9, changed: 0.

#### `avatardata/heads/collections/collections.dat`

FAR3, 2700 bytes in the older, 2708 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `avatardata/heads/meshes/meshes.dat`

FAR3, 2144911 bytes in the older, 2047253 in the newer.

Entries only in the older: 1, only in the newer: 2, changed: 19.

#### `avatardata/heads/outfits/outfits.dat`

FAR3, 35489 bytes in the older, 35751 in the newer.

Entries only in the older: 0, only in the newer: 3, changed: 0.

#### `avatardata/heads/purchasables/purchasables.dat`

FAR3, 27952 bytes in the older, 29717 in the newer.

Entries only in the older: 0, only in the newer: 1, changed: 424.

#### `avatardata/heads/textures/textures.dat`

FAR3, 10616050 bytes in the older, 10635054 in the newer.

Entries only in the older: 1, only in the newer: 9, changed: 0.

#### `avatardata/heads/thumbnails/thumbnails.dat`

FAR3, 1601850 bytes in the older, 1437967 in the newer.

Entries only in the older: 1, only in the newer: 9, changed: 1284.

#### `censor/censor.dat`

3481 bytes in the older, 3577 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `DBAppServiceClientD.dll`

393216 bytes in the older, 561152 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `EP5Samps.dat`

DBPF, 113324797 bytes in the older, 113414910 in the newer.

Entries only in the older: 0, only in the newer: 7, changed: 0.

#### `gamedata/uiscripts/asyncprice.uis`

3473 bytes in the older, 2997 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/budget.uis`

7830 bytes in the older, 7810 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/buypanel.uis`

10075 bytes in the older, 10558 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/gizmo.uis`

14383 bytes in the older, 14504 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/housepage.uis`

12364 bytes in the older, 13574 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/jobobjband.uis`

5290 bytes in the older, 6012 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/livepanel.uis`

9785 bytes in the older, 12765 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/message.uis`

9307 bytes in the older, 9779 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/messageinbox.uis`

8734 bytes in the older, 9331 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/personpage.uis`

16958 bytes in the older, 29193 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/personselection.uis`

12333 bytes in the older, 12730 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/personselectionedit.uis`

7159 bytes in the older, 7287 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/pphelptocdialog.uis`

3759 bytes in the older, 4012 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/profanitypanel.uis`

3257 bytes in the older, 4106 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/querypanel.uis`

12127 bytes in the older, 14465 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/roommatespanel.uis`

943 bytes in the older, 1755 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/securetradingeod.uis`

5846 bytes in the older, 5352 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/signseod.uis`

7631 bytes in the older, 7745 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/soundpanel.uis`

2073 bytes in the older, 2073 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/trunkeod.uis`

2189 bytes in the older, 2159 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/twopersonjobobjectmazecharisma.uis`

4600 bytes in the older, 4662 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/twopersonjobobjectmazelogic.uis`

3268 bytes in the older, 3333 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `gamedata/uiscripts/ucp.uis`

10143 bytes in the older, 10201 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `HitListsTemp.dat`

DBPF, 96165 bytes in the older, 103762 in the newer.

Entries only in the older: 0, only in the newer: 108, changed: 1.

#### `HitMp3DecodeD.dll`

200704 bytes in the older, 229376 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `housedata/default_house.xml`

2532 bytes in the older, 3981 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `housedata/floors/floors.far`

FAR1, 2319372 bytes in the older, 2320285 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `asian01.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `asian02.flr` |  |  | STR# 0; XXXX 0; rsmp 0 |  |
| `asian03.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `boomerangblue.flr` |  | XXXX 0 | STR# 0; rsmp 0 |  |
| `deluxefloorromanmarblelight.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `deluxefloorromanmarblemedium.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `deluxefloorromanmosaicgreen.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `deluxefloorscifistarfield.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `deluxefloorscifiwhite.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `diner_tile1.flr` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `diner_tile5.flr` |  | XXXX 0 | STR# 0; rsmp 0 |  |
| `flanksteakbricks.flr` |  | XXXX 0 | STR# 0; rsmp 0 |  |
| `furrycarpet2.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `gameshow01.flr` | XXXX 46358 | XXXX 46264 | STR# 0; rsmp 0 |  |
| `gameshow02.flr` | XXXX 46358 | XXXX 46264 | STR# 0; rsmp 0 |  |
| `gameshow03.flr` | XXXX 46358 | XXXX 46264 | STR# 0; rsmp 0 |  |
| `gameshow04.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `letagegrange.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moderngoateye.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moderngoateye02.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moroccan01.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moroccan02.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moroccan03.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moroccan04.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `moroccan05.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `plateedges.flr` |  | XXXX 0 | STR# 0; rsmp 0 |  |
| `restx_carpet1-color1.flr` |  |  | STR# 0; rsmp 0 |  |
| `sarasrock.flr` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `vegas01.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `vegas02.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `vegas03.flr` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |

#### `housedata/walls/walls.far`

FAR1, 19071371 bytes in the older, 19062464 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `asian01.wll` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `asian01wainscoting.wll` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `barn-red1.wll` |  | XXXX 37822 | STR# 0; rsmp 0 |  |
| `barn-red2.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `blackplastic.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `bluedamask.wll` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `brushedmetal.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `citrivescence.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `cleenslate.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `colonialclapboard.wll` | XXXX 59716 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `countrywood2.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `decowallred.wll` |  | XXXX 37822 | STR# 0; rsmp 0 |  |
| `decowallwhite.wll` |  | XXXX 37822 | STR# 0; rsmp 0 |  |
| `extraluauwall1.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `extraluauwall2.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `extraluauwall3.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `extraluauwall5.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `grungeegold.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `park_stone3.wll` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `primarilybluepaneling.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `primarilygreenpaneling.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `ravetexture-orange.wll` | XXXX 0 | XXXX 56 | STR# 0; rsmp 0 |  |
| `shop_panel.wll` | XXXX 46358 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `shop_paper1.wll` | XXXX 46358 | XXXX 56 | STR# 0; rsmp 0 |  |
| `street_brick3.wll` |  | XXXX 37822 | STR# 0; rsmp 0 |  |
| `street_brick4.wll` |  | XXXX 0 | STR# 0; rsmp 0 |  |
| `street_brick6.wll` | XXXX 0 | XXXX 56 | STR# 0; rsmp 0 |  |
| `wallromanfrieze.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `wallromanmarblewoodwainscoting.wll` | XXXX 0 | XXXX 37822 | STR# 0; rsmp 0 |  |
| `wallromantilegreen.wll` | XXXX 0 | XXXX 56 | STR# 0; rsmp 0 |  |
| `wallromantilegreenlight.wll` | XXXX 0 | XXXX 56 | STR# 0; rsmp 0 |  |
| `wallscifi03.wll` |  |  | STR# 0; rsmp 0 |  |

#### `InternetServiceD.dll`

102400 bytes in the older, 126976 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/artglobals.iff`

IFF, 3019 bytes in the older, 2496 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BHAV 8192, 8193, 8194, 8195, 8196, 8197, 8198; TPRP 8192, 8193, 8194, 8195, 8196, 8197, 8198 | BCON 8192, 8193; BHAV 8199, 8200, 8201, 8202, 8203; STR# 129, 303; TPRP 8199, 8200, 8201, 8202, 8203 | rsmp 0 |  |

#### `objectdata/globals/bathe.iff`

IFF, 7581 bytes in the older, 9272 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8198, 8199, 8200, 8201, 8202, 8203; TPRP 8198, 8199, 8200, 8201, 8202, 8203 | BHAV 8192; TPRP 8192; rsmp 0 |  |

#### `objectdata/globals/behavior.iff`

IFF, 37988 bytes in the older, 43446 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | STR# 138, 143, 179, 511, 512, 513, 514, 515 | STR# 128, 129, 130, 131, 132, 134, 135, 136, 137, 139, 141, 142, 150, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 167, 168, 169, 170, 171, 172, 173, 174, 176, 177, 178, 200, 201, 202, 203, 204, 205, 206, 207, 208, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510; rsmp 0 |  |

#### `objectdata/globals/build.iff`

IFF, 23907 bytes in the older, 23701 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 128, 129, 130, 131, 132, 133, 134, 135; rsmp 0 |  |

#### `objectdata/globals/carglobals.iff`

IFF, 6183 bytes in the older, 11308 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8207, 8208, 8209, 8210, 8211, 8212, 8213, 8214, 8215, 8216; STR# 256, 303; TPRP 8207, 8208, 8209, 8210, 8211, 8212, 8213, 8214, 8215, 8216; TTAB 130; TTAs 130 | BHAV 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8205, 8206; TPRP 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8204, 8205, 8206; TTAB 129; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/catglobals.iff`

IFF, 68731 bytes in the older, 68693 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8204; STR# 305, 8192; TPRP 8204; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/clothingrackssemiglobal.iff`

IFF, 7800 bytes in the older, 14415 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BHAV 8214; TPRP 8214; TRCN 8192 | BCON 8194, 8195; BHAV 8215, 8216, 8217, 8218, 8219, 8220, 8223, 8224, 8225; SLOT 129; STR# 257, 301, 303; TPRP 8215, 8216, 8217, 8218, 8219, 8220, 8223, 8224, 8225 | BCON 8192; BHAV 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208, 8209, 8210, 8211, 8212, 8213; TPRP 8196, 8197, 8205, 8212; TTAB 129; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/clothingrackssemiglobal.otf`

105 bytes in the older, 200 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/counterglobals.iff`

IFF, 19757 bytes in the older, 19740 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8192, 8196, 8198, 8199, 8201, 8213, 8221, 8223, 8228; TPRP 8192, 8196, 8198, 8199, 8201, 8213, 8221, 8223; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/credits.iff`

IFF, 4716 bytes in the older, 4716 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 163 |  |

#### `objectdata/globals/dogglobals.iff`

IFF, 67439 bytes in the older, 67401 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8204; STR# 305, 8192; TPRP 8204; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/doorglobals.iff`

IFF, 22860 bytes in the older, 25088 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8246, 8247; STR# 301, 303; TPRP 8246, 8247 | BHAV 8202, 8216, 8226, 8232, 8234, 8236, 8237, 8238, 8244; STR# 256, 8192; TPRP 8234; TTAB 129; TTAs 129; rsmp 0 |  |

#### `objectdata/globals/global.iff`

IFF, 123817 bytes in the older, 155788 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | POSI 262, 276 | BCON 272, 274, 275, 276, 277, 279, 281, 283, 285; BHAV 432, 434, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496; FWAV 1000, 1001, 1002, 1003, 1004, 1005, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92; STR# 258, 308, 400, 401, 402, 403, 404, 405, 412, 413, 506; TPRP 262, 276, 432, 434, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496; TRCN 272, 274, 275, 276, 277, 279, 281, 283, 285; TTAB 129; TTAs 129 | BCON 260, 261, 262, 268; BHAV 256, 260, 262, 271, 276, 277, 287, 288, 293, 295, 301, 312, 313, 314, 316, 318, 319, 320, 321, 323, 324, 325, 328, 330, 339, 340, 343, 349, 350, 351, 352, 353, 354, 358, 359, 362, 366, 367, 368, 373, 376, 377, 378, 379, 385, 391, 392, 393, 398, 406, 407, 409, 410, 412, 413, 419, 420, 430; FCNS 1, 4, 5; STR# 128, 130, 150, 152, 153, 154, 156, 158, 159, 170, 171, 257, 301, 303, 304, 305, 501, 502, 503, 504, 505; TPRP 256, 260, 277, 289, 293, 295, 301, 312, 314, 318, 320, 321, 324, 325, 328, 330, 352, 353, 354, 359, 366, 367, 368, 373, 376, 377, 378, 379, 385, 391, 392, 393, 406, 407, 413; TRCN 260, 261, 262, 268; rsmp 0 |  |

#### `objectdata/globals/global.otf`

1518 bytes in the older, 3244 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/lightglobals.iff`

IFF, 15386 bytes in the older, 14795 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BHAV 8209, 8210, 8211, 8220, 8221, 8228; TPRP 8209, 8210, 8211, 8220, 8221, 8228 | BHAV 8229, 8230, 8231, 8232; TPRP 8229, 8230, 8231, 8232 | BHAV 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208, 8212, 8213, 8214, 8215, 8216, 8217, 8218, 8219, 8222, 8223, 8224, 8225, 8226, 8227; TTAB 129, 130; TTAs 129, 130; rsmp 0 |  |

#### `objectdata/globals/lightglobals.otf`

965 bytes in the older, 495 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/live.iff`

IFF, 13212 bytes in the older, 13212 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | STR# 130, 131, 132, 133, 134, 135, 136, 137, 138, 139 |  |

#### `objectdata/globals/personglobals.iff`

IFF, 226313 bytes in the older, 257496 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8659, 8660, 8661, 8662, 8663, 8664, 8665, 8666, 8667, 8668, 8669, 8670, 8671, 8672, 8673, 8674, 8675, 8676, 8677, 8678, 8679, 8680, 8681, 8682, 8683, 8684, 8685, 8686, 8687, 8688, 8689, 8690, 8691, 8692, 8693, 8694, 8695, 8696, 8697, 8698, 8699, 8700, 8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716, 8717, 8718, 8719, 8720, 8721, 8722, 8723, 8724, 8725, 8726, 8727; STR# 302, 303; TPRP 8659, 8660, 8661, 8662, 8663, 8664, 8665, 8666, 8667, 8668, 8669, 8670, 8671, 8672, 8673, 8674, 8675, 8676, 8677, 8678, 8679, 8680, 8681, 8682, 8683, 8684, 8685, 8686, 8687, 8688, 8689, 8690, 8691, 8692, 8693, 8694, 8695, 8696, 8697, 8698, 8699, 8700, 8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716, 8717, 8718, 8719, 8720, 8721, 8722, 8723, 8724, 8725, 8726, 8727 | BHAV 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8201, 8203, 8204, 8207, 8208, 8209, 8210, 8212, 8213, 8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 8227, 8228, 8231, 8232, 8233, 8234, 8235, 8236, 8238, 8240, 8243, 8244, 8245, 8246, 8248, 8249, 8250, 8251, 8252, 8253, 8254, 8255, 8256, 8258, 8259, 8260, 8262, 8263, 8264, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 8281, 8283, 8284, 8285, 8286, 8287, 8288, 8289, 8290, 8293, 8294, 8295, 8296, 8297, 8298, 8299, 8300, 8302, 8304, 8305, 8306, 8307, 8308, 8310, 8311, 8312, 8313, 8314, 8315, 8316, 8317, 8318, 8319, 8320, 8321, 8322, 8323, 8324, 8325, 8326, 8327, 8328, 8330, 8332, 8333, 8334, 8336, 8337, 8338, 8339, 8340, 8342, 8343, 8344, 8345, 8346, 8347, 8348, 8350, 8351, 8353, 8354, 8355, 8356, 8358, 8359, 8360, 8361, 8364, 8366, 8368, 8369, 8370, 8372, 8373, 8375, 8376, 8377, 8378, 8381, 8382, 8384, 8386, 8387, 8388, 8389, 8390, 8391, 8393, 8394, 8395, 8397, 8398, 8400, 8402, 8403, 8404, 8405, 8406, 8407, 8410, 8412, 8414, 8415, 8417, 8418, 8419, 8420, 8421, 8422, 8423, 8424, 8425, 8426, 8427, 8428, 8429, 8430, 8431, 8434, 8437, 8438, 8439, 8440, 8441, 8442, 8445, 8446, 8447, 8448, 8449, 8452, 8453, 8456, 8457, 8458, 8459, 8460, 8462, 8463, 8465, 8466, 8468, 8469, 8470, 8471, 8472, 8473, 8475, 8476, 8477, 8479, 8480, 8487, 8488, 8489, 8491, 8492, 8494, 8495, 8496, 8497, 8498, 8499, 8500, 8501, 8502, 8503, 8504, 8505, 8508, 8510, 8511, 8514, 8515, 8516, 8518, 8519, 8520, 8523, 8524, 8525, 8526, 8527, 8529, 8530, 8537, 8538, 8540, 8541, 8542, 8543, 8544, 8545, 8546, 8547, 8548, 8549, 8550, 8551, 8552, 8555, 8557, 8558, 8561, 8563, 8564, 8568, 8569, 8571, 8572, 8573, 8574, 8575, 8577, 8579, 8581, 8583, 8586, 8587, 8588, 8589, 8592, 8593, 8602, 8603, 8605, 8606, 8607, 8609, 8613, 8614, 8615, 8616, 8617, 8618, 8622, 8629, 8630, 8631, 8632, 8633, 8634, 8635, 8636, 8641, 8642, 8646, 8648, 8649, 8652, 8653, 8654, 8657, 8658; STR# 301, 304, 305, 8192; TPRP 8193, 8194, 8196, 8198, 8201, 8207, 8209, 8212, 8213, 8214, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 8228, 8231, 8232, 8233, 8240, 8245, 8254, 8255, 8258, 8259, 8262, 8263, 8266, 8267, 8268, 8269, 8272, 8273, 8274, 8275, 8276, 8278, 8279, 8281, 8287, 8288, 8289, 8290, 8293, 8294, 8295, 8296, 8297, 8298, 8300, 8302, 8304, 8305, 8306, 8308, 8311, 8312, 8313, 8314, 8315, 8316, 8317, 8318, 8319, 8320, 8321, 8323, 8324, 8325, 8326, 8327, 8373, 8375, 8376, 8378, 8394, 8402, 8410, 8412, 8417, 8418, 8419, 8420, 8421, 8422, 8423, 8424, 8426, 8427, 8428, 8429, 8430, 8431, 8434, 8441, 8448, 8469, 8470, 8518, 8519, 8520, 8537, 8555, 8567, 8613, 8614, 8615, 8617, 8618, 8622, 8654, 8657, 8658; TTAB 130; TTAs 129, 130, 131; rsmp 0 |  |

#### `objectdata/globals/personglobals.otf`

7089 bytes in the older, 8432 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/phoneglobals.iff`

IFF, 57895 bytes in the older, 59106 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8322, 8323, 8324; TPRP 8322, 8323, 8324 | BHAV 8193, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8206, 8207, 8208, 8209, 8210, 8214, 8217, 8219, 8223, 8230, 8236, 8237, 8238, 8240, 8243, 8256, 8258, 8261, 8262, 8263, 8264, 8294, 8296, 8297, 8303, 8304, 8305, 8306, 8307, 8308, 8309, 8310, 8311, 8312, 8313, 8314, 8315, 8316; TPRP 8193, 8197, 8200, 8201, 8202, 8204, 8206, 8207, 8210, 8214, 8217, 8223, 8230, 8236, 8237, 8238, 8240, 8243, 8258, 8264, 8294, 8296, 8297, 8307, 8314; rsmp 0 |  |

#### `objectdata/globals/skillobjects.iff`

IFF, 19324 bytes in the older, 19771 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8230; TPRP 8230 | BCON 8195; BHAV 8192, 8193, 8194, 8196, 8197, 8198, 8201, 8202, 8204, 8205, 8206, 8207, 8208, 8209, 8211, 8215, 8216, 8221, 8222, 8224, 8225; STR# 256, 301, 303; TPRP 8193, 8201, 8202, 8209, 8221, 8222, 8223; TRCN 8195; rsmp 0 |  |

#### `objectdata/globals/skillobjects.otf`

5762 bytes in the older, 6451 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `objectdata/globals/social2siminobjectsemiglobal.iff`

IFF, 10626 bytes in the older, 11119 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8222; TPRP 8222 | BHAV 8195, 8197, 8198, 8199, 8200; rsmp 0 |  |

#### `objectdata/globals/socialglobals.iff`

IFF, 38498 bytes in the older, 2176 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BHAV 8196, 8198, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208, 8209, 8210, 8211, 8212, 8213, 8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 8227, 8228, 8229, 8230, 8231, 8232, 8233, 8234, 8235, 8236, 8237, 8238, 8239, 8240, 8241, 8242, 8243, 8244, 8245, 8246, 8247, 8248, 8249, 8250, 8251, 8252, 8253, 8254, 8255, 8256, 8257, 8258, 8259, 8260, 8261, 8262, 8263, 8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 8281, 8282, 8283, 8284; TPRP 8196, 8198, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208, 8209, 8210, 8211, 8212, 8213, 8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 8227, 8228, 8229, 8230, 8231, 8232, 8233, 8234, 8235, 8236, 8237, 8238, 8239, 8240, 8241, 8242, 8243, 8244, 8245, 8246, 8247, 8248, 8249, 8250, 8251, 8252, 8253, 8254, 8255, 8256, 8257, 8258, 8259, 8260, 8261, 8262, 8263, 8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 8281, 8282, 8283, 8284 |  | BHAV 8192, 8193, 8194, 8195, 8197, 8199; TPRP 8192, 8193, 8194, 8195, 8197, 8199; rsmp 0 |  |

#### `objectdata/globals/sofaglobals.iff`

IFF, 48082 bytes in the older, 47827 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` | BHAV 8194, 8211; TPRP 8194, 8211 | STR# 303 | BHAV 8209, 8220, 8237, 8245, 8255, 8256, 8290; TPRP 8209, 8220, 8245; TTAs 129, 130; rsmp 0 |  |

#### `objectdata/globals/surfaceplacementsemiglobal.iff`

IFF, 1964 bytes in the older, 2998 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  | BHAV 8194, 8196; STR# 303; TPRP 8194, 8196 | TTAs 129; rsmp 0 |  |

#### `objectdata/globals/trunkglobals.iff`

IFF, 5859 bytes in the older, 5871 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `(this file)` |  |  | BHAV 8194; TTAs 129; rsmp 0 |  |

#### `objectdata/objects/objiff.far`

FAR1, 17726000 bytes in the older, 14315402 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `2personportal.iff` |  | BHAV 4125, 4126, 4127; TPRP 4125, 4126, 4127 | BHAV 4100, 4101, 4104, 4106, 4112, 4116, 4117, 4119; CTSS 2000; OBJD 16815, 16818; OBJf 16818; STR# 129, 256, 257, 301; TTAs 129; rsmp 0 | 3a448755, 3a44f86f |
| `accessoryrack.iff` |  | whole entry |  |  |
| `animtester.iff` |  |  | OBJD 16807; STR# 300; TTAs 129 | 3eec206c |
| `anniversary.iff` |  | whole entry |  |  |
| `aquarium1.iff` | FWAV 18 | BHAV 4129, 4130, 4131; FWAV 8; OBJf 16807; TPRP 4129, 4130, 4131 | BHAV 4099, 4105, 4106, 4126; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 301, 304; TPRP 4099, 4106; TTAB 129; TTAs 129; rsmp 0 | 98e0f8bd |
| `ash.iff` |  | BHAV 4110, 4111, 4112, 4113; OBJf 16807; TPRP 4100, 4110, 4111, 4112, 4113 | BHAV 4097, 4099, 4100, 4101, 4103, 4104, 4105, 4107; OBJD 16807; STR# 129, 130, 256, 257, 304; TPRP 4097, 4099, 4101, 4103, 4104, 4105, 4107; TTAB 129; TTAs 129; rsmp 0 | 63416ba1 |
| `athleticsbench.iff` |  |  | CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | 81c7a5e0 |
| `awnings.iff` | BHAV 4100, 4102, 4103, 4105, 4106, 4107, 4135, 4136; POSI 4106; TPRP 4100, 4102, 4103, 4105, 4107, 4135, 4136 |  | BHAV 4096, 4097, 4098, 4101, 4104, 4112, 4116, 4119, 4120, 4128; CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4096, 4101, 4116, 4119, 4120, 4128; rsmp 0 | 360cdfb2, 362a97b8 |
| `awnings3.iff` |  |  | CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | 29d3125f, 29fb5a55 |
| `awnings4.iff` | BHAV 4098, 4102, 4103, 4105, 4106, 4107, 4116, 4136; POSI 4106; TPRP 4098, 4102, 4103, 4105, 4107, 4116, 4136 | STR# 256 | BHAV 4096, 4097, 4099, 4101, 4104, 4108, 4112, 4119, 4120, 4122, 4128, 4129, 4133; OBJD 16807; OBJf 16807; TPRP 4096, 4097, 4099, 4101, 4108, 4112, 4119, 4120, 4122, 4128, 4129; rsmp 0 | 2267cf86 |
| `awningthatch.iff` |  |  | CTSS 2000, 2001; OBJD 16807; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | 369037e1 |
| `backdroptheater.iff` |  |  | CTSS 2000; OBJD 16815; STR# 129, 256, 257, 302; TTAs 129; rsmp 0 | 2f60bebe |
| `bar.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `barbeach.iff` |  |  | STR# 129, 130, 256, 257, 301, 303; rsmp 0 |  |
| `bars.iff` | BHAV 4097, 4102, 4115; TPRP 4097, 4102, 4115 | BHAV 4109; GLOB 1; OBJf 16808; TPRP 4109 | BHAV 4096, 4098, 4100, 4113, 4116, 4117, 4118, 4119, 4130; CTSS 2000; OBJD 16808, 16811; OBJf 16809; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4113, 4116, 4117, 4118, 4119, 4130; TTAB 128; TTAs 128; rsmp 0 | c2a82bb8, c2a91fd0 |
| `bars2.iff` | BHAV 4097, 4102, 4115; TPRP 4097, 4102, 4115 | BHAV 4109; GLOB 1; OBJf 16808; TPRP 4109 | BHAV 4096, 4098, 4100; CTSS 2000; OBJD 16808, 16809, 16811; OBJf 16809; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4098; TTAB 128; TTAs 128; rsmp 0 | b7fc1cd5, b6380442, b62454df |
| `bars3.iff` | BHAV 4097, 4102, 4115; TPRP 4097, 4102, 4115 | BHAV 4110; GLOB 1; TPRP 4110 | BHAV 4096, 4098, 4100, 4130, 4131; CTSS 2000, 2001; OBJD 16811, 16812; OBJf 16808, 16809, 16813, 16814; STR# 129, 130, 256, 257, 301, 303, 304; TPRP 4098, 4100, 4130, 4131; TTAB 128; TTAs 128; rsmp 0 | 5faa302a, da2b8f79 |
| `bball.iff` |  | BHAV 4108, 4109, 4112; TPRP 4108, 4109, 4112 | CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810; STR# 129, 130, 131, 132, 256, 257, 302, 304; TTAB 129; TTAs 129; rsmp 0 | ba9dc16a |
| `bbq.iff` | BHAV 4100, 4101, 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4151; STR# 303; TPRP 4100, 4101, 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4151 | BHAV 4152; GLOB 128; OBJf 16813, 16814, 16815, 16816; TPRP 4152 | BHAV 4097, 4098, 4099, 4105, 4112, 4129; OBJD 16812, 16813, 16814, 16815, 16816; STR# 129, 256, 257, 301, 302, 304; TPRP 4097, 4098, 4099, 4112, 4150; TTAB 129; TTAs 129; rsmp 0 | 253c1a5e, 253f4ac3, 251f5254, 28a8328c, b11c7ae3 |
| `bedheart.iff` | BCON 4097; BHAV 4116, 4123, 4129, 4131, 4132, 4133, 4134, 4137, 4139, 4142, 4143, 4144, 4145, 4149, 4153, 4154, 4155, 4156, 4159, 4161, 4164, 4166, 4167, 4168, 4169, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4192, 4193, 4226, 4234; TPRP 4116, 4123, 4129, 4131, 4132, 4133, 4134, 4137, 4139, 4142, 4143, 4144, 4145, 4149, 4153, 4154, 4155, 4156, 4159, 4161, 4164, 4166, 4167, 4168, 4169, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4192, 4193, 4226, 4234 | BHAV 4197, 4198, 4199, 4200; BMP_ 3000; GLOB 1; TPRP 4197, 4198, 4199, 4200 | BHAV 4096, 4102, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4114, 4115, 4117, 4119, 4120, 4122, 4124, 4126, 4128, 4130, 4146, 4147, 4148, 4150, 4151, 4163, 4165, 4170, 4188, 4189, 4191, 4194, 4215, 4216, 4219, 4220, 4221, 4223, 4225, 4229, 4235; CTSS 2000, 3000; OBJD 16807, 16808, 16810, 16811, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822; OBJf 16808, 16810, 16811, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821; STR# 129, 130, 131, 132, 256, 257, 258, 301, 302, 303; TPRP 4105, 4106, 4111, 4114, 4115, 4122, 4124, 4126, 4128, 4163, 4221, 4223; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | 2ad15359, 298d6731, 29e07fa6, 2a65180b, 2af942e3, 29b837ac, 2a21356e, 181e1c8f, b2df4c76, 8ad53356, 2bdd1e0b, 00006998, 45c779d5, 2d8a27c2 |
| `bedinteractions.iff` | BCON 4096; BHAV 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4117; TPRP 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4117 |  | BHAV 4096, 4097, 4098, 4099, 4115, 4116; STR# 129, 256, 303, 401; TPRP 4096, 4097, 4098, 4099, 4115, 4116; TTAB 129; TTAs 129; rsmp 0 |  |
| `beds.iff` |  | BHAV 4170, 4171, 4172; GLOB 1; OBJf 16808, 16811, 16817, 16818, 16819, 16821, 16822, 16823, 16825, 16826, 16827, 16828, 16829, 16830, 16832, 16833, 16835, 16836, 16837; TPRP 4170, 4171, 4172 | BCON 4099; BHAV 4103, 4105, 4107, 4108, 4110, 4111, 4117, 4124, 4126, 4130, 4134, 4135, 4136, 4147, 4150, 4168; CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16807, 16808, 16810, 16811, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837; OBJf 16810, 16813, 16814, 16815, 16834; STR# 129, 130, 256, 257, 258, 301; TPRP 4105, 4111, 4124, 4126, 4130, 4135, 4150; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | 3089d8d2, 30889380, 3089c968, 308becba, 308af42d, 3088bee5, 308bbc27, 0e82c943, 52e7e5b7, 4f4592f1, 7d828304, 81179ab3, 2664b7af, 7288c037, 5cd0d1b3, 82e04c5b, b1601377, 4add5bbd, 461b8298, a55aafc4, a3ad1308, 4adf741a, 6593d291, 659380ce, 6593e6f9, 6593820c, 6593ca06, 6593adab, 6593f743 |
| `beds2.iff` | TRCN 4097, 4099, 4100 | BHAV 4106, 4107; GLOB 1; TPRP 4106, 4107 | BCON 4099; BHAV 4103, 4105, 4108, 4110, 4111, 4117, 4126, 4130, 4131, 4132, 4147, 4148, 4149, 4150, 4165, 4170, 4188, 4193; CTSS 2000; OBJD 16807, 16808, 16810, 16811, 16813, 16814, 16815; OBJf 16808, 16810, 16811, 16813, 16814, 16815; STR# 129, 130, 131, 132, 256, 257, 258, 301; TPRP 4105, 4108, 4111, 4126, 4130, 4148, 4149, 4150, 4165, 4170, 4188, 4193; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | 17579980, 1420ade8, 1450b57f, 14c8d2d2, 1499883a, 1478fd75, 14f1ffb7 |
| `beds3.iff` |  | BHAV 4135, 4170; CTSS 2000; GLOB 1; OBJf 16808, 16810, 16811, 16813, 16814, 16815, 16832, 16833, 16834, 16835, 16836, 16837; STR# 129, 256, 257, 258, 301; TPRP 4097, 4135, 4170 | BCON 4099; BHAV 4096, 4097, 4098, 4099, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4110, 4111, 4112, 4114, 4117, 4119, 4120, 4124, 4126, 4129, 4136, 4138, 4139, 4140, 4143, 4144, 4146, 4148, 4149, 4150, 4151, 4155, 4156, 4157, 4158, 4159, 4161, 4167, 4168, 4169; OBJD 16807, 16808, 16810, 16811, 16813, 16814, 16815, 16831, 16832, 16833, 16834, 16835, 16836, 16837; TPRP 4096, 4098, 4099, 4101, 4102, 4103, 4104, 4105, 4108, 4114, 4119, 4120, 4124, 4126, 4129, 4136, 4138, 4139, 4140, 4143, 4144, 4146, 4148, 4149, 4150, 4151, 4155, 4156, 4157, 4158, 4159, 4161, 4168, 4169; TTAB 129, 130; TTAs 129, 130; rsmp 0 | 1023e44b, 11e5d023, 1115c8b4, 119daf19, 1071f5f1, 11cd80be, 104f827c, 10dcba33, 10f4a1cf, 10a6970d, 135eded4, 1300a56c, 13fe926c, 124e8925 |
| `bedsbunkbed.iff` |  | GLOB 1; OBJf 16818, 16819, 16821, 16822, 16825, 16826 | BCON 4099; BHAV 4097, 4098, 4103, 4105, 4108, 4109, 4112, 4113, 4117, 4125, 4126, 4130, 4134, 4135, 4136, 4143, 4147, 4150, 4155, 4160; CTSS 2000, 2001, 2002; OBJD 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827; OBJf 16817, 16823, 16827; STR# 129, 130, 256, 257, 258, 301; TPRP 4097, 4126, 4135, 4136, 4143, 4160; TRCN 4099; TTAB 132; TTAs 129, 130, 131, 132, 133; rsmp 0 | 3326407f, 333537f2, 33052649, 33157831, 33770ab7, 337742bd, 33461220, 33566d1a, 33e463cd, 33f4550f, 33fb1cd6, 33db676e |
| `bedssingle2.iff` |  | BHAV 4102, 4110; GLOB 1; OBJf 16817, 16818, 16819, 16821, 16822, 16823, 16825, 16826, 16827, 16829, 16830, 16831; TPRP 4102, 4110, 4113 | BCON 4099; BHAV 4098, 4103, 4104, 4107, 4108, 4109, 4113, 4117, 4125, 4126, 4134, 4135, 4136, 4147, 4150; CTSS 2000, 2001, 2002, 2003; OBJD 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831; STR# 129, 130, 256, 257, 258, 301; TPRP 4104, 4109, 4125, 4126; TRCN 4099; TTAB 132; TTAs 129, 130, 131, 132, 133; rsmp 0 | d73d1f82, d7df565b, d7f72de3, d7911ae3, 738a419a, a6b909eb, 889b5970, fef62657, 2768de7d, 49929649, b53ec6cf, 96b6b9fd, d4bf28f3, 1cd560ca, 01603053, 71024f76 |
| `bedssingle22.iff` |  | BHAV 4110, 4111, 4124; GLOB 1; OBJf 16817, 16818, 16819, 16821, 16822, 16823, 16825, 16826, 16827, 16829, 16830, 16831; TPRP 4110, 4111, 4124 | BCON 4099; BHAV 4097, 4098, 4103, 4107, 4108, 4109, 4117, 4125, 4126, 4135, 4136, 4147, 4150; CTSS 2000, 2001, 2002, 2003; OBJD 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831; STR# 129, 130, 256, 257, 258, 301; TPRP 4097, 4103, 4109, 4125, 4126, 4135, 4150; TTAB 132; TTAs 129, 130, 131, 132, 133; rsmp 0 | a307f2bb, a3258536, a343948c, a361caf4, a28bb873, a2ddf079, a2fba0e4, a319dfde, a395d108, a3b3e7ca, a3d1ae13, a3ffd5ab, 9c1de2ab, 9c3bf9e1, 9c2f9eb3, 9c4db9b1 |
| `birthdaycake.iff` | BHAV 4096, 4097, 4099, 4100, 4101, 4102, 4108, 4110, 4113, 4117, 4120, 4121, 4123, 4125, 4129, 4138, 4139, 4154, 4155, 4156, 4164, 4178, 4210; TPRP 4096, 4097, 4099, 4100, 4101, 4102, 4108, 4110, 4113, 4117, 4120, 4121, 4123, 4125, 4129, 4138, 4139, 4154, 4155, 4156, 4164, 4178, 4210; TTAB 128, 130, 131, 132, 133, 134, 136, 137 | BCON 4106; BHAV 4161, 4162, 4163, 4167, 4168, 4170, 4174, 4177, 4179; FWAV 16; GLOB 1; OBJD 16818; OBJf 16818; TPRP 4161, 4162, 4163, 4167, 4168, 4170, 4174, 4177, 4179 | BHAV 4103, 4104, 4105, 4106, 4107, 4111, 4112, 4114, 4115, 4116, 4119, 4122, 4124, 4132, 4133, 4134, 4136, 4140, 4141, 4146, 4150, 4151, 4152, 4153, 4157, 4165, 4166, 4169, 4171, 4173, 4182, 4186, 4189, 4191, 4194, 4195, 4196, 4197, 4198, 4204, 4205, 4212, 4213, 4214; CTSS 2001; OBJD 16817; OBJf 16817; STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TPRP 4103, 4104, 4105, 4106, 4107, 4111, 4114, 4115, 4116, 4119, 4122, 4124, 4132, 4133, 4134, 4136, 4140, 4141, 4146, 4150, 4151, 4152, 4153, 4157, 4165, 4166, 4169, 4171, 4173, 4186, 4189, 4191, 4194, 4195, 4196, 4197, 4198, 4205, 4212, 4213, 4214; TTAB 129, 135; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 | 8107714e, f730e3c3 |
| `bjdealer.iff` |  |  | OBJD 128; STR# 129, 130, 200, 256, 257, 301, 303, 304; rsmp 0 | 4803f81d |
| `blackjack.iff` | BCON 4098, 4099, 4100; BHAV 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167; TPRP 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167; TTAB 129 | GLOB 128; TRCN 4097 | BCON 4097; BHAV 4096, 4097, 4098; CTSS 2000; OBJD 16807, 16808, 16809; OBJf 16808, 16809; STR# 129, 130, 256, 257, 301, 302, 303, 304, 305, 4097, 4098; TPRP 4096, 4097, 4098; TTAs 129; rsmp 0 | 4305b84e, 624e8e25, c356cd89 |
| `bookcases.iff` |  | BHAV 4129, 4130, 4131; TPRP 4129, 4130, 4131 | BHAV 4102, 4103, 4104, 4105; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809, 16810, 16811; OBJf 16808, 16809, 16810, 16811; STR# 129, 130, 256, 301, 304; TTAB 129, 130, 131; TTAs 129, 130, 131; rsmp 0 | fddca51c, fddcf581, fdd5bd8b, 5cdc712f, 9b3a5cdf |
| `bookcases2.iff` |  | BHAV 4125, 4129, 4130; TPRP 4125, 4129, 4130 | CTSS 2000; OBJD 16810; OBJf 16810; STR# 129, 130, 256, 301, 304; TTAB 131; TTAs 129, 130, 131; rsmp 0 | 42197abc |
| `bookcases3.iff` |  | BHAV 4129, 4130, 4131; TPRP 4129, 4130, 4131 | BHAV 4102, 4103, 4104, 4105; CTSS 2000, 2001; OBJD 16807, 16808, 16811; OBJf 16808, 16809, 16811; STR# 129, 130, 256, 301, 304; TTAB 129, 130; TTAs 129, 130, 131; rsmp 0 | a91403ab, a9101b3c, a91d4963 |
| `bubblemaker.iff` |  | BHAV 4107, 4109, 4113, 4122; TPRP 4107, 4109, 4113, 4122 | BHAV 4126, 4127; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; STR# 129, 130, 256, 257, 302, 304; TTAB 129; TTAs 129; rsmp 0 | f718d902 |
| `bubbles.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `buffettable.iff` |  | BHAV 4121, 4125, 4126; GLOB 1; TPRP 4121, 4125, 4126 | BHAV 4096, 4097, 4098, 4099, 4100, 4107, 4112, 4114, 4118, 4119, 4122, 4123, 4128, 4129; CTSS 2000; OBJD 16835, 16837; OBJf 16836, 16837, 16838; STR# 129, 256, 257, 301, 302, 303; TPRP 4096, 4118, 4119, 4122, 4128; TTAB 129; TTAs 129; rsmp 0 | 8e3520bd, 8e930d83 |
| `buffettablevacation.iff` |  | BHAV 4125, 4126, 4127; GLOB 1; TPRP 4125, 4126, 4127 | BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4107, 4108, 4112, 4117, 4121, 4122, 4123, 4128; CTSS 2000; OBJD 16835, 16837; OBJf 16836, 16837, 16838; STR# 129, 256, 257, 301, 302, 303; TPRP 4096, 4098, 4117, 4128; TTAB 129; TTAs 129; rsmp 0 | 0e46c892, 0e20d005 |
| `buildingsigns.iff` | GLOB 128 | TTAs 129 | CTSS 2000, 2001, 2002; OBJD 16824, 16825, 16826; STR# 129, 130, 256, 301; TTAB 129; TTAs 130; rsmp 0 | 8c9d216b, 161d2344, cf416b82 |
| `buildingsignsunleashed.iff` | BHAV 4096; TPRP 4096 |  | BHAV 4113; OBJD 16810, 16811, 16812, 16813; OBJf 16810, 16811, 16812, 16813; rsmp 0 | 3717cfec, 37cf87e6, 37edd77b, 379fa841 |
| `campfire.iff` |  | BHAV 4111; TPRP 4111 | BHAV 4096, 4097, 4098, 4101, 4103, 4105, 4107, 4109, 4110, 4112, 4113, 4123, 4139, 4153, 4154, 4159, 4160; CTSS 2000; OBJD 16811; STR# 129, 130, 256, 257, 302, 304; TPRP 4103, 4105, 4139, 4159; TTAs 128, 129; rsmp 0 | f0d9ae7f |
| `campfireghost.iff` |  | OBJf 128 | CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 303, 304; TTAs 129; rsmp 0 | 7c411e64 |
| `canningstation.iff` | BHAV 4151; TPRP 4151; TTAB 130, 131, 132, 133 | BHAV 4131, 4132, 4133, 4134; OBJf 16813; TPRP 4131, 4132, 4133, 4134 | BHAV 4096, 4103, 4106, 4107, 4121, 4122, 4127, 4135; CTSS 2000; OBJD 16811, 16813; OBJf 16812; STR# 129, 256, 257, 300, 301, 303, 304, 305; TPRP 4096, 4103, 4121; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | ad0b9dd6, ad278541 |
| `cannon.iff` | FWAV 0; TRCN 4096 | BCON 4098; BHAV 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126; FWAV 129, 130; STR# 301; TPRP 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126 | BCON 4096; BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112; CTSS 2000; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813; OBJf 16808, 16809, 16810, 16811, 16812, 16813; SLOT 128; STR# 129, 256, 257, 303, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112; TTAB 129; TTAs 129; rsmp 0 | 9750ea9d, d66adc8a, 38cc9816, 084cc8b6, 6a21a5f6, 5e4dc28f, 4ddbb50f |
| `cannonball.iff` | FWAV 0; SLOT 100, 128; STR# 258, 300; TRCN 4096 | BCON 4097; BHAV 4110, 4111, 4112, 4113, 4114; CTSS 2000; FWAV 129, 130, 131, 132, 135, 137, 138; OBJD 16810; OBJf 16810; STR# 301; TPRP 4110, 4111, 4112, 4113, 4114; TTAB 130; TTAs 130 | BCON 4096; BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; SLOT 129; STR# 129, 256, 257; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109; TTAB 129; TTAs 129; rsmp 0 | d066406c, c3216190, d87db8a0, d84136a8 |
| `carbentley.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 303; TPRP 4101; TTAB 129; TTAs 129; rsmp 0 | 17acec22, 17acf7de, 17afa9a6, 17afb81c, 17afcf91, 17aee2f4, 17ae9dce, 17a9cd53, 17ab8559, 17b3849b, 17b2a399, 17b2c4cb, 17b2df81, 17ade881, 17ad9339, 17acdae0, 17b38ec3, 17b0abd6, 17b097ab |
| `cardboardbox.iff` |  |  | CTSS 2000; STR# 129, 130, 257, 303; rsmp 0 |  |
| `carjunk.iff` | BCON 4096; BHAV 4121; TPRP 4121; TTAB 129 | TTAs 130 | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 301, 303; TPRP 4096, 4097, 4101, 4117; TTAs 129; rsmp 0 | 4b71ecda, 4b70f726, 4b70a95e, 4b70b8e4, 4b73cf69, 4b73e20c, 4b729d36, 4b72cdab, 4b5985a1, 4b778463, 4b77a361, 4b77c433, 4b76df79, 4b76e879, 4b7693c1, 4b71da18, 4b748e3b, 4b74ab2e, 4b759753 |
| `carlimo.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 303; TPRP 4096, 4097, 4101, 4117; rsmp 0 | c8ee6e7d, c8ee7581, c8ef4343, c8ef0a9a, c8ec7122, c8ed4622, c8ed5d68, c8ea3a3a, c8ea1d38, c8e51cfa, c8e354f0, c8e3046d, c8e07b57, c8e05632, c8e121bf, c8e13005, 23f544ba, 720069aa, 5e5c1e38 |
| `carmjeep.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258; TPRP 4096, 4097, 4101, 4117; TTAB 129; TTAs 129; rsmp 0 | a6f5ed9a, a6f5f666, a6f5a81e, a6f4b9a4, a6f4ce29, a6f4e34c, a6f79c76, a6f7cceb, a6e784e1, a6f88523, a6f8a221, a6fbc573, a6fbde39, a6fbe939, a6fa9281, a6fadb58, a6f98f7b, a6f9aa6e, a6fe9613 |
| `carportal.iff` | BCON 4096; BHAV 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133; STR# 129, 256, 257, 258, 301, 302, 303; TPRP 4098, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133; TTAB 129 | OBJD 16808; OBJf 16807, 16808 | BHAV 4096, 4097; OBJD 16807; TPRP 4096, 4097; TTAs 129; rsmp 0 | 865a6812, d564c66b |
| `carpublictransit.iff` |  | TTAs 129 | OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831; TTAB 129; rsmp 0 | 2c7fa689, 2db3bd75, 2d9be30d, 2de3f2b7, 2d27853a, 2d75a85f, 2d5dd765, 32a587f8, 32efcff3, 2fdcce30, 2f2ae932, 2cb78e60, 2c9f952a, 2cf1a22a, 2cd9d992, 2c17904b, 2facc468, 2e44e17d, 2e7cdd00, 2e14dae7, 2eccb15c, 2ee4f6d7, 2e96c0e2, 2958cf45, 290acef8 |
| `carsquad.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 303; TPRP 4101; TTAB 129; TTAs 129; rsmp 0 | 76eceda7, 76ecf65b, 76efa823, 76efb999, 76efce14, 76eee371, 76ee9c4b, 76e9ccd6, 76eb84dc, 76f3851e, 76f2a21c, 76f2c54e, 76f2de04, 76ede904, 76ed92bc, 76eddb65, 76f38f46, 76f0aa53, 76f6962e |
| `carstaff.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 301, 303; TPRP 4096, 4097, 4101, 4117; TTAB 129; TTAs 129; rsmp 0 | f72aec44, f72af7b8, f72aa9c0, f725b87a, f725cff7, f724e292, f7249da8, f724cd35, f721853f, f72984fd, f729a3ff, f728c4ad, f728dfe7, f72be8e7, f72b935f, f72bda86, f7298ea5, f72eabb0, f72e97cd |
| `carstd.iff` | BHAV 4121; TPRP 4121; TTAB 129 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 301, 303; TPRP 4096, 4097, 4101, 4117; TTAs 129; rsmp 0 | db6dedb2, db6cf64e, db6ca836, db6cb98c, db6fce01, db6fe364, db6e9c5e, db6eccc3, db6584c9, db70850b, db73a209, db73c55b, db72de11, db72e911, db7292a9, db6ddb70, db708f53, db70aa46, db71963b |
| `carsuv.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 303; TPRP 4096, 4097, 4101, 4117; TTAB 129; TTAs 129; rsmp 0 | 1d3dec63, 1d3cf79f, 1d3ca9e7, 1d3fb85d, 1d3fcfd0, 1d3fe2b5, 1d3e9d8f, 1d3ecd12, 1d358518, 1d4384da, 1d43a3d8, 1d42c48a, 1d42dfc0, 1d42e8c0, 1d3d9378, 1d3ddaa1, 1d408e82, 1d40ab97, 1d4097ea |
| `cartaxi.iff` |  | whole entry |  |  |
| `cartown.iff` | BHAV 4121; TPRP 4121 |  | BHAV 4096, 4097, 4101, 4117; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; STR# 129, 130, 256, 257, 258, 301, 303; TPRP 4096, 4097, 4101, 4117; rsmp 0 | bc3aec18, bc35f7e4, bc35a99c, bc35b826, bc34cfab, bc34e2ce, bc349df4, bc37cd69, bc338563, bc3984a1, bc39a3a3, bc38c4f1, bc3bdfbb, bc3be8bb, bc3b9303, bc3adada, bc398ef9, bc3eabec, bc3e9791 |
| `cashregisters.iff` |  |  | CTSS 2000, 2001; STR# 129, 256, 257, 301, 302, 304; TTAs 128; rsmp 0 |  |
| `castlefence.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 300, 303, 304 |  |
| `chairconnecting.iff` |  |  | BHAV 4098; CTSS 2000; OBJD 16811; STR# 129, 130, 256, 257; TPRP 4098; TTAs 128; rsmp 0 | dc046a4c |
| `chairconnectingtheater.iff` |  |  | BHAV 4098; CTSS 2000; OBJD 16811; STR# 129, 130, 256, 257; TPRP 4098; TTAs 128; rsmp 0 | 59f7b18e |
| `chairdinmoroccan.iff` | TTAB 130, 131, 132 |  | BHAV 4098; CTSS 2000, 2002; OBJD 16807; STR# 129, 130, 256, 257; TPRP 4098; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | 3e056767 |
| `chairsdiningunleashed.iff` | TTAB 128, 129, 131, 132, 133 | CTSS 2000; STR# 129, 130, 256, 257, 258; TTAs 128, 129, 130, 131, 132, 133 | BHAV 4096, 4097, 4098, 4099, 4100, 4103, 4105, 4110, 4112; OBJD 16809; TPRP 4097, 4098, 4099, 4100, 4103, 4105, 4110, 4112; TTAB 130; rsmp 0 | 3b23d027 |
| `chairshd_hd.iff` |  |  | BHAV 4098; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; STR# 129, 130, 256, 257; TTAB 129, 130, 131; TTAs 129, 130, 131; rsmp 0 | 3a48c71a, 3baa9787, 3b8cdf8d |
| `chairslr1tile.iff` |  |  | BHAV 4098; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16809, 16810; STR# 129, 130, 256, 257; TPRP 4098; TTAB 129, 130, 131, 132; TTAs 129, 130, 131, 132; rsmp 0 | 82e0f146, f79a89c2, 22920f55, 99120547 |
| `chairslr1tilehd.iff` |  |  | BHAV 4097, 4098, 4099, 4100, 4102; CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256, 257; TPRP 4097, 4098, 4100, 4102; TTAB 129, 130; TTAs 129, 130; rsmp 0 | 34559788, 35b7df82 |
| `chairslr2.iff` |  |  | BHAV 4098, 4099; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813; STR# 129, 130, 256, 257; TPRP 4098, 4099; TTAB 129, 130, 131, 132; TTAs 129, 130, 131, 132; rsmp 0 | 9985a06f, 996de865, 994fb8f8, 41fdd8d8, 795e70b6, 502367de, b6236b64 |
| `chairslr3.iff` | BCON 4096; BHAV 4104, 4108, 4111, 4112, 4113; TPRP 4104, 4108, 4111, 4112, 4113; TRCN 4096 | BHAV 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4122, 4123; CTSS 2008; FWAV 1000, 1001, 1002; GLOB 1; OBJD 16815; OBJf 16815; STR# 301; TPRP 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4122, 4123 | BHAV 4096, 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4109, 4110; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814; OBJf 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814; STR# 129, 130, 256, 257; TPRP 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4110; TTAB 129, 130, 131, 132; TTAs 129, 130, 131, 132; rsmp 0 | eec5748a, d2944a33, 6585d104, 0f8beda7, 55bcbc04, cbe53119, 24dad5c4, 0924bc1f, 027960ec |
| `chairslr4.iff` | TTAB 130, 131, 132 |  | BHAV 4096, 4098, 4099, 4110; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 256, 257; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | 36e6f00f |
| `chairslr5.iff` | TTAB 130, 131, 132 |  | BHAV 4098, 4099; CTSS 2000; OBJD 16812; STR# 129, 256, 257; TPRP 4098; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | 35490203 |
| `chairslrunleashed.iff` |  | STR# 129, 130, 256, 257; TPRP 4098; TTAs 128 | BHAV 4096, 4097, 4098, 4099, 4100, 4104; OBJD 16811; TPRP 4097, 4099, 4100, 4104; TTAB 128; rsmp 0 | 2ab2d032 |
| `chaiselounge.iff` |  |  | BHAV 4101, 4102, 4103, 4104, 4119, 4120; CTSS 2000, 2001; OBJD 16823; STR# 129, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | 1bc6159e |
| `chalkboard.iff` |  | BHAV 4122, 4123, 4124; TPRP 4122, 4123, 4124 | BHAV 4096, 4101, 4102, 4108, 4109, 4117; CTSS 2000; OBJD 16807; OBJf 16808, 16809; STR# 129, 256, 257, 301, 303, 304; TPRP 4096; TTAB 129; TTAs 129; rsmp 0 | 76ba6ba8 |
| `charades.iff` |  |  | STR# 129, 130, 256, 257, 258, 301; TTAs 129, 130 |  |
| `chemistryset.iff` |  | BHAV 4206, 4207, 4208; OBJf 16813; TPRP 4206, 4207, 4208 | BHAV 4096, 4115, 4135, 4140, 4160, 4195, 4198, 4200; CTSS 2000; OBJD 16811, 16812, 16813; OBJf 16812; STR# 129, 130, 256, 300, 301, 303, 304, 305; TPRP 4096, 4135; TTAB 129; TTAs 129, 130, 131, 132, 133; rsmp 0 | f662fbb4, f6618c39, f6689d83 |
| `chesstable.iff` | BHAV 4134; TPRP 4134 | BHAV 4102, 4103, 4105; TPRP 4102, 4103, 4105 | BHAV 4114, 4128; CTSS 2000, 3000; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 256, 257, 301, 302, 303; TTAB 129; TTAs 129; rsmp 0 | 94aa32f4, e0f50c0f |
| `christmastree.iff` | BCON 4096, 4097; STR# 258 | BHAV 4123, 4124, 4125, 4126, 4127; FWAV 10, 7, 8, 9; OBJf 16807, 16808; STR# 302; TPRP 4123, 4124, 4125, 4126, 4127 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122; OBJD 16807, 16808, 16815; OBJf 16811, 16812; STR# 129, 130, 256, 257, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4104, 4106, 4109, 4110, 4115, 4119, 4120, 4121, 4122; TTAB 129; TTAs 129; rsmp 0 | 2ab3d14d, 2565ae77, 2ae3c9da |
| `clockoffice.iff` |  | OBJf 16807 | BHAV 4097; CTSS 2000; OBJD 16807; STR# 129, 256, 257; TPRP 4097; TTAs 129; rsmp 0 | cfc9fd08 |
| `clockpost.iff` |  | OBJf 16807, 16808 | BHAV 4096, 4097; CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 256, 257; rsmp 0 | 35a3df98, 35bd9792 |
| `clockpostswiss.iff` |  | OBJf 16807 | BHAV 4096, 4097; OBJD 16807; STR# 129, 256, 257; TPRP 4096, 4097; rsmp 0 | 249ac8e2 |
| `clothingrack2.iff` |  |  | STR# 129, 256, 257, 300, 301, 303, 304; TTAs 131; rsmp 0 |  |
| `clothingracks.iff` |  | BHAV 4096; TPRP 4096 | CTSS 2000, 2001, 2002, 2003; OBJD 16815, 16816, 16817, 16818, 16819, 16820; OBJf 16819; STR# 129, 256, 257, 301, 302; rsmp 0 | 32a7f175, 81affe1d, a7d9b64e, 89f8e6ca, 743498da, 4666b58a |
| `coffeeesp.iff` |  | BHAV 4105, 4110, 4111; TPRP 4105, 4110, 4111 | BHAV 4106, 4107; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 304; TTAB 129; TTAs 129; rsmp 0 | bf137195 |
| `coffeem.iff` |  | BHAV 4100, 4101, 4102; OBJf 16807; TPRP 4100, 4101, 4102; TTAs 129 | CTSS 2000; OBJD 16807; STR# 129, 304; TTAB 129, 130; TTAs 130; rsmp 0 | 85f1a085 |
| `column1.iff` |  |  | CTSS 2000, 2001, 2002; rsmp 0 |  |
| `column2.iff` |  |  | CTSS 2000, 2001, 2002, 2003; rsmp 0 |  |
| `column3.iff` |  |  | CTSS 2000, 2001, 2002; rsmp 0 |  |
| `column5.iff` |  |  | CTSS 2000; rsmp 0 |  |
| `columnarch.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchaquaduct.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchbeach.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchcarnival.iff` |  |  | BCON 4098; BHAV 4096, 4101; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303; rsmp 0 | 3a99379b |
| `columnarchmoroccan.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchromantiled.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchscifi.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchstone.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `columnarchunleashed.iff` | BHAV 4097, 4098, 4099, 4100, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109; TPRP 4097, 4098, 4100, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109 | CTSS 2000, 2001; STR# 256 | BHAV 4096, 4101, 4110, 4111, 4112, 4113, 4114, 4115, 4116; OBJD 16807, 16808; OBJf 16807, 16808; TPRP 4096, 4101, 4110, 4111, 4112, 4113, 4114; rsmp 0 | 27b7d0b0, 266f98ba |
| `columns4.iff` |  |  | CTSS 2000, 2001; rsmp 0 |  |
| `comeandsee.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 258, 303, 304, 500; TTAs 129 |  |
| `computers.iff` | BHAV 4133, 4134; TPRP 4133, 4134; TTAB 130, 131, 132 | BHAV 4113, 4122, 4123, 4127, 4128, 4132; TPRP 4113, 4122, 4123, 4127, 4128, 4132 | BHAV 4098, 4099, 4100, 4101, 4102, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4116, 4117, 4124, 4125, 4126, 4129, 4131, 4140, 4141, 4142, 4143, 4144, 4146, 4148; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16809, 16810; OBJf 16807, 16808, 16809, 16810; STR# 129, 256, 257, 301, 303, 4096, 4097; TPRP 4099, 4111, 4124, 4125, 4131, 4143; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | 835ba084, d191aff7, d191ff6a, afabcc3d |
| `computers5.iff` | BHAV 4131; TPRP 4131; TTAB 129, 130, 132 | BHAV 4122, 4123, 4127, 4128, 4132; STR# 304; TPRP 4122, 4123, 4127, 4128, 4132 | BHAV 4096, 4098, 4099, 4100, 4102, 4104, 4106, 4107, 4108, 4109, 4111, 4116, 4117, 4124, 4125, 4126, 4129, 4133, 4134, 4135, 4136, 4137, 4138, 4141, 4142, 4144, 4146, 4148, 4149; CTSS 2000, 2001, 2002, 2003; OBJD 16809, 16810; OBJf 16809, 16810; STR# 129, 256, 257, 301, 303, 4096, 4097; TPRP 4099, 4100, 4111, 4124, 4125, 4133, 4134, 4135, 4136, 4137, 4138; TTAB 131; TTAs 129, 130, 131, 132; rsmp 0 | 2d878db2, 2deff288 |
| `computerslaptop.iff` |  | whole entry |  |  |
| `cone.iff` |  |  | CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | b123a8e1 |
| `constructionhorse.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 60688651 |
| `conveyorbelt.iff` |  |  | CTSS 2000; STR# 129, 256, 257, 300, 303, 304; TTAs 128; rsmp 0 |  |
| `conveyorcontrol.iff` |  | BHAV 4098; TPRP 4098 | BHAV 4096, 4097; CTSS 2000; STR# 129, 130, 256, 257, 304; TPRP 4096, 4097; TTAs 129; rsmp 0 |  |
| `costumesports.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 38950259 |
| `costumetrunk.iff` |  |  | BHAV 4103, 4104; CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3cec1509 |
| `costumetrunktoga.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3cec0282 |
| `countercasino.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | a7590866 |
| `counterdisplay.iff` |  |  | BHAV 4099, 4100, 4102; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; STR# 129, 130, 256, 257, 302, 303; TPRP 4099, 4100, 4102; TTAs 129, 130, 131; rsmp 0 | fb61e4d2, fba5acd8, fbcdfc45 |
| `counterdisplayvacation.iff` | BHAV 4103; TPRP 4103 |  | BHAV 4096, 4097, 4098, 4110; OBJf 16812; TPRP 4096, 4097, 4098, 4110; rsmp 0 |  |
| `counters.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2014; OBJD 16807, 16808, 16809, 16810, 16815; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | 91767a36, 47e917c4, 73d6180d, 8bd70015, 1dff3cab |
| `counters2.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | 3480731c |
| `counters3.iff` |  |  | CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16809, 16810; STR# 129, 130, 256, 257, 300, 303, 304; TTAs 128; rsmp 0 | 144a7815, 3658d1aa, 2ab64a1d, 1bbdb732 |
| `counters4.iff` | BHAV 4116; TPRP 4116 |  | BHAV 4096, 4102; CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16807, 16808, 16809, 16810, 16811, 16812; OBJf 16807, 16808, 16809, 16810, 16811, 16812; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4102; rsmp 0 | cb08d52c, cb089d26, cb1bcdbb, cb1bb281, cb3b9fe4, cb3be869 |
| `counters5.iff` | BHAV 4116; TPRP 4116 | CTSS 2001, 2002, 2003; STR# 129, 256, 257, 300, 303, 304; TTAs 128 | BHAV 4096, 4097, 4102; OBJD 16807, 16808, 16809, 16810; OBJf 16808, 16809, 16810; TPRP 4096; TTAB 128; rsmp 0 | 3313814f, 33cbd1d2, 3357c945, 33fdaee8 |
| `counters6.iff` | BHAV 4116; TPRP 4116 | CTSS 2000, 2001, 2002; STR# 129, 256, 257, 300, 303, 304; TTAs 128 | BHAV 4096, 4102; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; TPRP 4096, 4102; TTAB 128; rsmp 0 | 34dc9898, 34f4c805, 343ed092 |
| `counterwall.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | 9f3a38b9 |
| `craftingcomponents.iff` |  | whole entry |  |  |
| `craftingworkbench.iff` |  | whole entry |  |  |
| `ctoldworld.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3ca8467c |
| `ctscifi.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 38decd65 |
| `ctuniform.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3de7b3ca |
| `ctvaudeville.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3cd9ac53 |
| `ctvegas.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3cd9ba8c |
| `cuckooclock.iff` |  | BHAV 4104, 4105, 4106; TPRP 4104, 4105, 4106 | BHAV 4097, 4098, 4100, 4102; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257; TPRP 4097, 4098, 4100, 4102; TTAB 129; TTAs 129; rsmp 0 | 135e770f |
| `curtain.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 301, 304; TTAs 129; rsmp 0 |  |
| `curtainsunleashed.iff` | BCON 4096, 4100, 4101, 4102, 4103, 4104; BHAV 4099, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4112, 4116, 4119, 4120, 4122, 4128, 4129, 4133, 4135, 4136; POSI 4106; TPRP 4099, 4101, 4102, 4103, 4104, 4105, 4107, 4108, 4112, 4116, 4119, 4120, 4122, 4128, 4129, 4133, 4135, 4136 | CTSS 2000, 2001 | BHAV 4096, 4097, 4098; OBJD 16807, 16808; OBJf 16807, 16808; TPRP 4096, 4097, 4098; TTAB 128; rsmp 0 | 2815d0e3, 28cd98e9 |
| `dancecage.iff` |  | BHAV 4131, 4132, 4133; TPRP 4131, 4132, 4133 | BHAV 4096, 4103, 4106; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 301, 304; TPRP 4096; TTAB 129; TTAs 129; rsmp 0 | 9cb1bb9b |
| `dancefloor.iff` | BCON 4098; TRCN 4098 | BHAV 4175, 4216, 4217, 4218, 4219; CTSS 2001; OBJD 16813; OBJf 16813; TPRP 4175, 4216, 4217, 4218, 4219; TTAs 130 | BHAV 4098, 4100, 4118, 4122, 4137, 4151, 4165, 4167, 4168, 4169, 4176, 4205; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16811, 16812; STR# 129, 130, 131, 132, 256, 257, 301, 303, 304; TPRP 4169; TTAB 129; TTAs 129; rsmp 0 | 1e8b9ea7, d481cee5 |
| `deadmouse.iff` | BCON 4096, 4097; BHAV 4101, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4118, 4119, 4120, 4121, 4122, 4123; TPRP 4101, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4118, 4119, 4120, 4121, 4122, 4123; TRCN 4096, 4097 | BHAV 4124, 4125, 4126; OBJf 16807; STR# 129, 256, 304; TPRP 4124, 4125, 4126; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4107, 4116, 4117; OBJD 16807; TPRP 4096, 4097, 4098, 4099, 4100, 4107, 4116, 4117; TTAB 129; rsmp 0 | 3a13d0f1 |
| `death.iff` |  | whole entry |  |  |
| `desks.iff` |  |  | BHAV 4098; CTSS 2000, 2002, 2003; OBJD 16807, 16810, 16813; STR# 129, 257, 303; rsmp 0 | d9a73952, eb6c0a92, a90a7d01 |
| `desks2.iff` |  |  | BHAV 4098; CTSS 2000; OBJD 16807; STR# 129, 257, 303; rsmp 0 | aaf447d6 |
| `desks3.iff` |  |  | BHAV 4098; CTSS 2000, 2001; OBJD 16807, 16810; STR# 129, 257, 303; rsmp 0 | e93c8663, 29db9b3a |
| `destination.iff` | POSI 4100, 4101 | TPRP 4100, 4101 | BHAV 4099, 4100, 4101, 4118, 4119, 4120; CTSS 2000; OBJD 16807; STR# 129, 256, 257, 301, 302; TPRP 4102, 4118, 4119, 4120; TTAB 128; TTAs 128; rsmp 0 | 000007c4 |
| `devcheats.iff` |  |  | CTSS 2000; OBJf 16812; STR# 129, 130, 256, 257, 301, 304, 4096; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 |  |
| `dfcontroller.iff` | BCON 4098; TRCN 4098 |  | BHAV 4097, 4103, 4126, 4160; CTSS 2000; OBJD 16808; STR# 129, 130, 256, 257, 304; TPRP 4097, 4103, 4160; TTAs 129; rsmp 0 | 6271eff3 |
| `dice.iff` |  | BHAV 4108, 4109, 4110; TPRP 4108, 4109, 4110 | BHAV 4101, 4102; CTSS 2000; OBJD 16815; OBJf 16815; STR# 129, 256, 257, 301; TTAB 129; TTAs 129; rsmp 0 | fcd0eada |
| `diningbooth.iff` | BHAV 4096, 4124; STR# 258; TPRP 4096, 4124; TTAB 129, 130, 132 | BHAV 4131; GLOB 1; STR# 304; TPRP 4101, 4131 | BHAV 4101, 4105, 4106, 4107, 4108, 4110, 4111, 4112, 4113, 4119, 4121, 4122, 4123, 4125, 4126, 4128; CTSS 2000, 2001; OBJD 16809, 16810, 16811, 16812, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824; OBJf 16809, 16810, 16811, 16812, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824; SLOT 128; STR# 129, 130, 256, 257, 303; TPRP 4105, 4107, 4112, 4121, 4125, 4126; TTAB 131; TTAs 129, 130, 131, 132; rsmp 0 | 3afd9524, 3a95e2a9, 3a13c77b, 3ac5b841, 3a6097e6, 3a42dfec, 354df313, 3509ad6b, 3521b697, 35d38055, 358bc98c, 35b7b234, 34798534, 34259e7e |
| `diningchairs.iff` |  | BHAV 4115, 4116, 4117, 4118; STR# 301; TPRP 4115, 4116, 4117, 4118 | BHAV 4098; CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16807, 16808, 16809, 16810, 16811, 16812; STR# 129, 130, 256, 257; TPRP 4098; TTAB 128, 129, 130, 131, 132, 133; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | e7938987, 26bfbb29, 6a3889f8, d97681db, 25b82d98, 59c389bc |
| `diningchairs2.iff` |  | TPRP 4098 | BHAV 4098; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; STR# 129, 130, 256, 257; TTAB 128, 129, 130, 131, 132, 133; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | e82917b6, e9f11574, 1584c383 |
| `diningchairs3.iff` |  |  | BHAV 4098; CTSS 2000, 2001; OBJD 16809, 16810; STR# 129, 130, 256, 257; TPRP 4098; TTAB 128, 129, 130, 131, 132, 133; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | 7280cbfc, caf38382 |
| `diningchairs4.iff` |  | BMP_ 2000; TPRP 4098 | BHAV 4098; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; STR# 129, 130, 256, 257; TTAB 128, 129, 130, 131, 132, 133; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | 32611fb1, 32614f2c, 326157bb |
| `diningpodium.iff` |  |  | CTSS 2000, 2001; STR# 129, 130, 256, 257, 301, 302, 303; TTAs 129; rsmp 0 |  |
| `diningtable2x1.iff` |  |  | BHAV 4098, 4104; CTSS 2000; OBJD 16807; STR# 129, 257, 303; rsmp 0 | d84d39ce |
| `diningtablecircular.iff` |  |  | BHAV 4111, 4118; CTSS 2000; OBJD 16835; STR# 129, 130, 257, 303; rsmp 0 | 0967372e |
| `diningtabledeuce.iff` |  |  | BHAV 4111, 4113, 4118; CTSS 2000; OBJD 16836; STR# 129, 130, 257, 303; TPRP 4113; rsmp 0 | ffbb3b82 |
| `diningtablelodge.iff` | BHAV 4101, 4112; TPRP 4112 | GLOB 1; STR# 129, 257, 303 | BHAV 4096, 4099, 4103, 4118; OBJD 16836; OBJf 16836; TPRP 4096, 4099, 4103; rsmp 0 | 21ebc95e |
| `diningtables.iff` |  |  | BHAV 4098, 4111, 4118; CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16815, 16816, 16821, 16828, 16835; STR# 129, 130, 257, 303; TPRP 4098; rsmp 0 | 5a5cda09, 921fda07, c1b6da6a, 0133d442, 8c9e33c9 |
| `diningtables2.iff` |  |  | BHAV 4098, 4111, 4118; CTSS 2000, 2001, 2002; OBJD 16828, 16835, 16842; STR# 129, 130, 257, 303; TPRP 4098; rsmp 0 | 7f283620, 294439e2, 391e258e |
| `diningtables3.iff` |  |  | BHAV 4098, 4118; CTSS 2000; OBJD 16835; STR# 129, 130, 257, 303; TPRP 4098; rsmp 0 | 4a21d3a7 |
| `diningtablesbeach.iff` | BHAV 4101, 4112; TPRP 4112 | GLOB 1; STR# 129, 257, 303 | BHAV 4096, 4098, 4099, 4103, 4118; OBJD 16837; OBJf 16837; TPRP 4096, 4098, 4099; rsmp 0 | 3535c952 |
| `dishwashers.iff` | BHAV 4118, 4119; TPRP 4118, 4119 | BHAV 4139, 4140, 4141, 4142, 4143; OBJf 16808, 16813; TPRP 4139, 4140, 4141, 4142, 4143 | BHAV 4103, 4105, 4112, 4113, 4116, 4117, 4129, 4131, 4138; CTSS 2000, 2001; OBJD 16808, 16811, 16812, 16813; OBJf 16809, 16814; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4098, 4103, 4105, 4112, 4129, 4131; TTAB 128, 129; TTAs 128, 129; rsmp 0 | 29efbb55, eebceb18, a01e500d, 2dd50a87 |
| `displaycases.iff` |  |  | CTSS 2000, 2001, 2002; STR# 129, 130, 256, 257, 302, 303; TTAs 129, 130, 131; rsmp 0 |  |
| `djbooth.iff` | BCON 4102 | BCON 4104, 4117; BHAV 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245, 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255; CTSS 2001; FWAV 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80; GLOB 1; OBJD 16815, 16816, 16817, 16818, 16819, 16820, 16821; OBJf 16815, 16816, 16817, 16818, 16819, 16820, 16821; STR# 301, 308; TPRP 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245, 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255; TTAB 132; TTAs 132 | BCON 4101; BHAV 4097, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4113, 4114, 4115, 4116, 4119, 4120, 4121, 4122, 4124, 4125, 4126, 4129, 4130, 4132, 4133, 4137, 4138, 4139, 4141, 4144, 4147, 4149, 4154, 4155, 4158, 4160, 4161, 4162, 4163, 4164, 4165, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4175, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4197, 4198, 4199, 4200, 4202, 4203, 4204; CTSS 2000; OBJD 16808, 16809, 16810, 16814; OBJf 16809, 16810, 16811, 16812, 16813, 16814; STR# 129, 130, 131, 132, 256, 257, 258, 303, 304; TPRP 4097, 4100, 4101, 4108, 4109, 4110, 4114, 4115, 4116, 4119, 4122, 4124, 4126, 4129, 4130, 4132, 4133, 4139, 4141, 4144, 4147, 4149, 4154, 4155, 4158, 4164, 4165, 4167, 4168, 4175, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4197, 4198, 4199, 4200, 4204; TTAB 131; TTAs 131; rsmp 0 | e8e88d38, f82ec245, 8bb4d5bb, 45d4cc4d, 9e701559, bccf1fcb, f16557d6, c7bf38be, 0aa64794, 53a46aff, a9411d44 |
| `dogfightcloud.iff` | BCON 4096, 4097, 4098, 4099, 4101, 4104, 4106; BHAV 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174; TPRP 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174; TRCN 4096, 4097, 4098, 4099, 4101, 4104, 4106; TTAB 128 | TTAs 129 | BHAV 4096, 4105; OBJf 16822, 16823, 16824, 16825; TPRP 4096, 4105; TTAB 129; rsmp 0 |  |
| `doghouse.iff` | BHAV 4134, 4135, 4136, 4138, 4139, 4143, 4144, 4145, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165; TPRP 4134, 4135, 4136, 4138, 4139, 4143, 4144, 4145, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165 | BCON 4098; BHAV 4127; CTSS 2000, 2001; DGRP 1100, 1101, 1102, 1103, 1300, 1301, 1302, 1303, 1400, 1401, 1402, 1403, 1600, 1601, 1602, 1603, 1700, 1701, 1702, 1703, 1800, 1801, 1802, 1803, 2100, 2101, 2102, 2103, 2300, 2301, 2302, 2303, 2700, 2701, 2702, 2703, 3100, 3101, 3102, 3103, 3300, 3301, 3302, 3303, 3700, 3701, 3702, 3703, 4100, 4101, 4102, 4103, 4300, 4301, 4302, 4303, 4400, 4401, 4402, 4403, 4600, 4601, 4602, 4603, 4700, 4701, 4702, 4703, 4800, 4801, 4802, 4803, 5100, 5101, 5102, 5103, 5300, 5301, 5302, 5303, 5400, 5401, 5402, 5403, 5600, 5601, 5602, 5603, 5700, 5701, 5702, 5703, 5800, 5801, 5802, 5803; GLOB 1; PALT 2, 3, 4, 5, 6; STR# 129, 130, 256, 257, 258, 301; TPRP 4113, 4127; TRCN 4098; TTAB 134; TTAs 129, 130, 131, 132, 133, 134 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4123, 4124, 4125, 4126, 4128, 4129, 4130, 4137, 4140, 4146, 4147, 4148, 4149, 4150, 4151, 4153; OBJD 16817, 16818; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4111, 4112, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4123, 4124, 4125, 4126, 4128, 4129, 4130, 4137, 4140, 4146, 4147, 4148, 4149, 4150, 4151, 4153; TTAB 132; rsmp 0 | bc537c52, 96cb67ae |
| `dollhouse.iff` |  | BHAV 4100, 4104, 4105; OBJf 16807; TPRP 4100, 4104, 4105 | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257; TTAB 129; TTAs 129; rsmp 0 | 00230edc |
| `dooroneway.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 129, 130; rsmp 0 |  |
| `doors.iff` | STR# 130, 258, 300, 301, 400, 401 | BHAV 4106; CTSS 2005; STR# 308; TPRP 4106; TTAB 129, 130 | CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16808, 16815, 16816, 16817; OBJf 15089, 16816, 16817; STR# 129, 256, 257; TTAs 129, 130; rsmp 0 | 2aca7211, 9a0d8249, 6da6f675, f3e2a8bc |
| `doors2.iff` | STR# 130, 258, 300, 301, 303, 400, 401 | CTSS 2007; OBJD 16829, 16830, 16831; OBJf 16830, 16831 | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; STR# 129, 256, 257; TTAs 130; rsmp 0 | be77f24b, 29c6f46e, 0b20bc6c |
| `doors3.iff` | STR# 130, 258, 300, 301, 302, 303, 400, 401 |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011; STR# 129, 256, 257; TTAs 130, 131; rsmp 0 |  |
| `doors4.iff` | STR# 130, 258, 300, 301, 302, 303, 400, 401 | CTSS 2006; OBJD 16827, 16828, 16829, 16830, 16831, 16832; OBJf 16828, 16829, 16831, 16832 | BHAV 4096, 4098, 4124; CTSS 2000, 2001, 2002, 2003, 2004, 2005; STR# 129, 256, 257; TTAs 130; rsmp 0 | e13d1e39, 126a5607, 71590692, eab508f8, b1c90c33, fe554404 |
| `doors5.iff` | STR# 130, 258, 300, 301, 302, 303, 400, 401 |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005; STR# 129, 256, 257; TTAs 130; rsmp 0 |  |
| `doors6.iff` | STR# 130, 258, 300, 301, 302, 303, 400, 401 |  | CTSS 2001, 2002, 2003, 2004; STR# 129, 256, 257; TTAs 130; rsmp 0 |  |
| `doorstar.iff` | STR# 130, 258, 300, 301, 302, 303, 400, 401 |  | CTSS 2000; STR# 129, 256, 257; TTAs 130; rsmp 0 |  |
| `doorsunleashed.iff` | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4122, 4123, 4124, 4141, 4156, 4158, 4161, 4162; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4122, 4123, 4124, 4141, 4156, 4158, 4161, 4162; TTAB 130 | BHAV 4125, 4126; STR# 129, 256, 257; TPRP 4125, 4126 | BHAV 4121; OBJD 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820; OBJf 16813, 16814, 16816, 16817, 16818, 16819; TPRP 4121; TRCN 4097; rsmp 0 | 06d6d186, 068e998c, 06a6c911, 01a0fd79, 0058a301, 000ab8fd, 015eb62b, 01769b4e, 012eecc3 |
| `dressers.iff` | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129; STR# 258; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129; TTAB 129 | BCON 4098, 4099; BHAV 4133; GLOB 1; OBJf 16809, 16810, 16811, 16812, 16817, 16818, 16819, 16820, 16822, 16823, 16824, 16826, 16828, 16829, 16830; TPRP 4133 | CTSS 2000, 2001, 2002, 2005; OBJD 16809, 16810, 16811, 16812, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16826, 16827, 16828, 16829, 16830, 16831; OBJf 16831; STR# 129, 130, 256, 257; TTAs 129; rsmp 0 | 7721cec3, 7721b1f9, 7720e164, 7720a96e, 7726e3a6, 0fd4ccef, ab68bb05, 1d1faa5b, bb69f408, 236def9b, e075d96b, 438f916a, d0f2eab0, 6ae5ddae, 67dca174, 294a48ee, 9cf96500, 33b56fa4, 51a60b1c, 8b454875 |
| `dressers2.iff` | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129; STR# 258; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129; TTAB 129 | BCON 4098, 4099; BHAV 4133; GLOB 1; OBJf 16809, 16811, 16812, 16818, 16819, 16820, 16823, 16824, 16825; TPRP 4133; TRCN 4098, 4099 | CTSS 2000, 2001, 2002; OBJD 16809, 16810, 16811, 16812, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823, 16824, 16825; OBJf 16810, 16817, 16822; STR# 129, 130, 256, 257; TTAs 129; rsmp 0 | a63ebb15, a6589670, a692b9d7, a67ae94a, a6caf1dd, a607cc98, a7e5dd22, a7db835a, a7a398a6, a781ae64, 997beef4, ffd8f982, dfc3f528, 33df87de, 130ccc1f |
| `dropdest.iff` |  |  | STR# 256, 257; TTAs 128 |  |
| `duck.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `easel.iff` |  | BHAV 4126, 4127; TPRP 4126, 4127 | BHAV 4096, 4097, 4098, 4100, 4101, 4107, 4110, 4111, 4113, 4114, 4117; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 301, 304; TPRP 4096, 4110, 4111, 4113, 4114; TTAB 129; TTAs 129; rsmp 0 | 9fb223ce |
| `elevatorfreight.iff` |  |  | BHAV 4120; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 35517cf4 |
| `elevatorhotel.iff` |  |  | BHAV 4120; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 33397ca3 |
| `elevatormodern.iff` |  |  | BHAV 4120; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 652e271c |
| `elevatorteleporter.iff` | BHAV 4116, 4117, 4118, 4119, 4122, 4123; TPRP 4116, 4117, 4118, 4119, 4122, 4123 |  | BHAV 4096, 4097, 4098, 4101, 4102, 4110, 4111, 4112, 4113, 4114, 4115, 4120, 4124; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TPRP 4102; TTAB 129; TTAs 129; rsmp 0 | 322afff2 |
| `execchair.iff` |  |  | BHAV 4098; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257; TPRP 4098; TTAs 129, 130, 131, 132; rsmp 0 | 75bb7a03 |
| `exercisemachine.iff` |  | BHAV 4115, 4116, 4117; TPRP 4115, 4116, 4117 | BHAV 4096, 4097, 4100, 4103, 4106, 4107, 4108, 4109; CTSS 2000; OBJD 16807, 16808, 16810; OBJf 16808, 16809, 16810; STR# 129, 130, 256, 257, 301; TPRP 4096, 4097, 4100, 4103, 4106, 4107, 4108, 4109; TTAB 129; TTAs 129; rsmp 0 | ddecd497, ddeacc00, 23c63866 |
| `fencecarnival.iff` | BHAV 4116, 4128, 4136; STR# 129, 130, 257, 258, 300, 303, 304; TPRP 4116, 4128, 4136 |  | BHAV 4096, 4099, 4101, 4127, 4129, 4131, 4132, 4133; OBJD 16807; OBJf 16807; STR# 256; TPRP 4096, 4099, 4101, 4127, 4129, 4132; rsmp 0 | 2ddec9aa |
| `fenceflowersnow.iff` |  |  | CTSS 2000, 2001; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `fenceoffice.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fenceparty.iff` | BHAV 4116; TPRP 4116 |  | BHAV 4096, 4099, 4101, 4128, 4129, 4132, 4133; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 300, 303, 304; TPRP 4096, 4099, 4101, 4128, 4129, 4132, 4133; rsmp 0 | 2d7d1632 |
| `fences.iff` |  |  | CTSS 2000, 2001; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fenceshd.iff` |  |  | CTSS 2000, 2001, 2002; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `fencesstonevacation.iff` |  |  | CTSS 2000, 2001; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `fencesunleashed.iff` | BHAV 4116, 4136; TPRP 4116, 4136 | STR# 256 | BHAV 4096, 4099, 4101, 4127, 4128, 4129, 4131, 4133; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; TPRP 4096, 4099, 4101, 4127, 4128, 4129, 4131; rsmp 0 | 181bd1f3, 183399f9, 18d1c964 |
| `filingcabinet.iff` |  |  | CTSS 2000; OBJD 16811; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 16f2c4a6 |
| `fire.iff` |  | BHAV 4127, 4128, 4129, 4130, 4131; OBJD 16808; OBJf 16808; TPRP 4127, 4128, 4129, 4130, 4131; TTAB 130; TTAs 130 | BHAV 4096, 4098, 4100, 4101, 4102, 4109, 4110, 4117, 4120, 4122, 4123; STR# 129, 130, 256, 257, 303, 304; TPRP 4096, 4098, 4100, 4101, 4102, 4109, 4110, 4117, 4120, 4122, 4123; TTAs 129; rsmp 0 | d0437134 |
| `fireplaces.iff` | BHAV 4098 | BHAV 4103, 4113; TPRP 4103, 4113 | BHAV 4096, 4097, 4099, 4100, 4101, 4102, 4104, 4105, 4106, 4108, 4109, 4110, 4111, 4112; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16810, 16813, 16816; OBJf 16808, 16809, 16811, 16812, 16814, 16815, 16817, 16818; STR# 129, 256, 257; TPRP 4096, 4099, 4101, 4102, 4104, 4105, 4106, 4108, 4111, 4112; TTAs 129, 130, 131, 132; rsmp 0 | b5215809, 5d6b538a, 8eaa68ad, 497a0c3e |
| `fireplaces2.iff` | BHAV 4112; STR# 258; TPRP 4112; TTAB 131, 132 | BHAV 4107, 4113; TPRP 4098, 4107, 4113 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4108, 4109, 4110, 4111; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16810; OBJf 16808, 16809, 16811, 16812, 16819; STR# 129, 256, 257; TPRP 4096, 4101, 4102, 4106; TTAB 129, 130; TTAs 129, 130, 131, 132; rsmp 0 | 18d4c055, 1b38885f |
| `fishingpier.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 301, 303, 304; TTAs 132 |  |
| `fishtankbig.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 2fc9b87d |
| `flamingo.iff` |  |  | BHAV 4096; CTSS 2000; STR# 129, 130, 257, 3; TPRP 4096; TTAs 131; rsmp 0 |  |
| `flies.iff` |  |  | BHAV 4096, 4099; CTSS 2000; OBJf 16807, 16808; STR# 129, 130, 256, 257, 304; TPRP 4096, 4099; TTAs 129; rsmp 0 |  |
| `flood.iff` |  | BHAV 4111, 4112, 4113, 4114, 4115; TPRP 4111, 4112, 4113, 4114, 4115 | BHAV 4097; OBJf 16807; STR# 129, 130, 256, 257, 301, 304; TPRP 4097; TTAB 129; TTAs 129; rsmp 0 |  |
| `flowerscoped.iff` | BHAV 4096, 4097, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; STR# 130, 257, 258, 301, 303; TPRP 4096, 4097, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; TTAB 129, 130, 131, 132, 133 | GLOB 1; TTAs 134, 135 | CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; STR# 129, 256, 304; TTAs 129, 130, 131, 132, 133; rsmp 0 | 5d767e1f, 5d723615, 5d7b6688 |
| `flowersoutdoor.iff` | BHAV 4096, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; STR# 130, 257, 258, 301, 303; TPRP 4096, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; TTAB 129, 130, 131, 132, 133 | BMP_ 4000, 6000; GLOB 1; OBJf 16808 | CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16809, 16810; OBJf 16807, 16809, 16810; STR# 129, 256, 304; TTAs 129, 130, 131, 132, 133; rsmp 0 | 96e3398d, a2daa08c, 65274a4f, c02b406a |
| `flowersunleashed.iff` | BHAV 4096, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; TPRP 4096, 4098, 4099, 4100, 4103, 4106, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4126, 4127; TTAB 129, 130, 131, 132, 133 | GLOB 1; OBJf 16808; STR# 129, 256, 304; TTAs 130 | OBJD 16808; rsmp 0 | 3478d22e |
| `food.iff` |  | BHAV 4162, 4163, 4231; GLOB 1; TPRP 4162, 4163, 4231 | BHAV 4100, 4102, 4106, 4111, 4112, 4114, 4125, 4126, 4140, 4141, 4147, 4151, 4152, 4159, 4161, 4165, 4169, 4170, 4172, 4175, 4176, 4177, 4178, 4181, 4182, 4184, 4187, 4193, 4195, 4197, 4202, 4209, 4212, 4215, 4219, 4221, 4227; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010; OBJD 16807, 16809, 16814, 16816; OBJf 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817; STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TPRP 4100, 4102, 4106, 4111, 4112, 4114, 4125, 4126, 4147, 4152, 4169, 4175, 4176, 4177, 4178, 4181, 4187, 4193, 4209, 4215, 4219, 4221, 4227; TTAB 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 | bf62f653, 15866694, 500dc12b, d4eab5f6 |
| `foodcounter.iff` |  | BCON 4103; BHAV 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202; BMP_ 2005, 2006; TPRP 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202; TRCN 4103; TTAB 132, 133; TTAs 132, 133 | BHAV 4096, 4097, 4099, 4100, 4101, 4103, 4104, 4106, 4108, 4112, 4116, 4117, 4119, 4120, 4121, 4123, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4138, 4139, 4140, 4141, 4143, 4144, 4146, 4147, 4149, 4151, 4152, 4153, 4154; CTSS 2000, 2001, 2002, 2005, 2006; OBJD 16807, 16808, 16809, 16810, 16811, 16813, 16814, 16815, 16816, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836; OBJf 16808, 16809, 16813, 16814, 16815, 16816, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836; SLOT 128; STR# 129, 130, 256, 257, 301, 302, 303, 304; TPRP 4097, 4103, 4107, 4112, 4119, 4120, 4121, 4128, 4131, 4135, 4139, 4147, 4151; TTAB 128, 131; TTAs 128, 129, 130, 131; rsmp 0 | 245b2fc5, 242a67cf, 242a3752, 242a4868, 242a650d, 242a1280, 242a033a, 243a5d42, 240a46be, 240a707c, 241939a5, 2419421d, 24e9751d, 24f86e56, 24c80904, 24d82e06, 24d8245e, 5343eb0f, fc9da31f, d5a3f339, 38f68c0b, 2302a174, 7694d6cc, 3771c707, 18349976, 6d4e82b1, 446ab47e |
| `foodproc.iff` | POSI 4103 | BHAV 4106, 4107, 4108; TPRP 4103, 4106, 4107, 4108 | BHAV 4097, 4098, 4099, 4102, 4103, 4111; CTSS 2000; OBJD 16808; OBJf 16808; STR# 129, 130, 256, 257, 300, 303; TPRP 4097, 4098, 4099, 4102, 4111; TTAB 128; TTAs 128; rsmp 0 | 9fa148dc |
| `foodunleashed.iff` |  | BHAV 4233; GLOB 1; TPRP 4233; TTAs 128, 130, 131, 137 | BHAV 4106, 4111, 4114, 4141, 4152, 4177, 4181, 4193, 4195, 4209, 4215, 4219, 4221, 4227; OBJf 16807, 16808, 16809, 16814, 16815, 16816, 16817, 16818; TPRP 4106, 4111, 4114, 4141, 4152, 4177, 4181, 4193, 4195, 4209, 4215, 4219, 4221, 4227; TTAB 128, 130, 131, 137; rsmp 0 |  |
| `footmassager.iff` |  | whole entry |  |  |
| `founders.iff` |  |  | BHAV 4105, 4107; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3bdb8294 |
| `fountain.iff` |  |  | BHAV 4100; CTSS 2000; OBJD 16807; STR# 129, 130, 256; TTAs 129; rsmp 0 | a82ca08e |
| `fountainlargehd.iff` |  | BHAV 4108, 4109, 4115, 4116, 4117; OBJf 16808, 16810, 16812, 16814, 16816; TPRP 4108, 4109, 4115, 4116, 4117 | BHAV 4097, 4100, 4114; CTSS 2000; OBJD 16807, 16808, 16810, 16812, 16814, 16816; STR# 129, 130, 256; TPRP 4114; TTAB 129; TTAs 129; rsmp 0 | 3565e02a, 35d3a827, 34d78780, 349add68, 375092aa, 3720bf94 |
| `fountainrock.iff` |  | BHAV 4108, 4109, 4115, 4116; OBJf 16808, 16810, 16814, 16816; TPRP 4108, 4109, 4115, 4116 | BHAV 4097, 4100, 4107, 4110, 4113, 4114; CTSS 2000; OBJD 16807, 16808, 16810, 16814, 16816; STR# 129, 130, 256; TPRP 4107, 4110, 4113; TTAB 129; TTAs 129; rsmp 0 | 1bd3b7b6, 1b97ffbc, 1429d01b, 1565c531, 1501e80f |
| `fountainsunleashed.iff` |  |  | BHAV 4098 |  |
| `fridges.iff` |  | BHAV 4153, 4154, 4155, 4156; GLOB 1; OBJD 16810, 16811, 16812; OBJf 16810, 16811, 16812; TPRP 4153, 4154, 4155, 4156; TTAB 131; TTAs 131 | BHAV 4098, 4099, 4103, 4107, 4109, 4111, 4112, 4113, 4114, 4117, 4118, 4119, 4120, 4122, 4126, 4139, 4140, 4141, 4143; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAB 128, 129, 130; TTAs 128, 129, 130; rsmp 0 | 675c18af, 42c078b3, b94755df, 0a7cd93e, 49ee9104, 9f3fc18c |
| `fridges2.iff` |  | BHAV 4145, 4146; GLOB 1; TPRP 4145, 4146 | BHAV 4098, 4099, 4103, 4107, 4111, 4112, 4113, 4114, 4117, 4118, 4120, 4122, 4124, 4139, 4140, 4141; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 300, 301, 302, 303; TPRP 4124; TTAB 128; TTAs 128, 129, 130; rsmp 0 | cdd887b1 |
| `gameball.iff` |  |  | BHAV 4111, 4125, 4134; CTSS 2000, 2001; STR# 129, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 |  |
| `gamecompdrawacard.iff` |  | BHAV 4109; TPRP 4109 | BHAV 4099, 4101, 4103; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 256, 257, 301, 302, 304; TTAs 129, 130; rsmp 0 | 34e956fe |
| `gamecomponentballcontainer.iff` |  | BHAV 4122; TPRP 4122 | BHAV 4099, 4100, 4102, 4103, 4107, 4118, 4119; CTSS 2000; OBJD 16815; STR# 129, 257, 301, 302, 303; TTAs 129; rsmp 0 | 3ce070b1 |
| `gamecomponentballtarget.iff` |  |  | BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4103, 4106, 4109; CTSS 2000; OBJD 16815; STR# 256, 257, 302; TTAs 129; rsmp 0 | 2e7024a3 |
| `gamecomponentpiece.iff` |  |  | BHAV 4099; CTSS 2000; STR# 256, 257, 301; TTAs 129; rsmp 0 |  |
| `gamecomponentpiececontainer.iff` |  | BHAV 4141; TPRP 4141 | BHAV 4100, 4101, 4104, 4110, 4132, 4138, 4139; CTSS 2000; OBJD 16815; STR# 257, 301, 303; TTAs 129; rsmp 0 | 3cf17080 |
| `gamecomponentscoreboard.iff` |  | BHAV 4113, 4114, 4115, 4116; STR# 301; TPRP 4113, 4114, 4115, 4116 | BHAV 4103; CTSS 2000; OBJD 16815; OBJf 16816, 16817; STR# 129, 256, 257, 304; TPRP 4103; TTAB 129; TTAs 129; rsmp 0 | 3d274a3d |
| `gamerugarrow.iff` |  | BMP_ 2020; CTSS 2020; TTAB 133; TTAs 133, 134 | CTSS 2000; OBJf 16815; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `gamerugbackred.iff` |  |  | CTSS 2000; OBJf 16827, 16839, 16851, 16855; STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `gamerugbackwhite.iff` |  |  | CTSS 2000; OBJf 16827, 16839, 16851, 16855; STR# 130, 256, 257; TTAs 129; rsmp 0 |  |
| `gamerugstar.iff` |  | BHAV 4106; BMP_ 2020; CTSS 2020; STR# 303; TPRP 4106; TTAs 133, 134, 135 | CTSS 2000; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 |  |
| `gardencrops.iff` |  | BHAV 4107, 4108, 4109; TPRP 4107, 4108, 4109; TTAs 129 | BHAV 4097, 4098; OBJf 16807, 16808, 16809, 16810; TPRP 4097, 4098; TTAB 129; rsmp 0 |  |
| `gardener.iff` | BHAV 4102, 4104, 4105, 4106; GLOB 128; STR# 257, 258; TPRP 4102, 4104, 4105, 4106 | GLOB 1; OBJf 128 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4103; OBJD 128; STR# 200, 256, 301, 303, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103; TTAB 129; TTAs 129; rsmp 0 | d62b91b4 |
| `gardengnome.iff` | BHAV 4097, 4098, 4099, 4100, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118; STR# 256, 257; TPRP 4097, 4098, 4100, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118 |  | BHAV 4096, 4101; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 304; TPRP 4096, 4101; TTAB 129; TTAs 129; rsmp 0 | c14849ac |
| `gardenplot.iff` |  | TTAs 130 | OBJf 16808; TTAB 130; rsmp 0 |  |
| `geniegoldpile.iff` |  |  | BHAV 4099; CTSS 2000; OBJf 16807; STR# 129, 130, 256, 302, 304; TPRP 4099; TTAs 129; rsmp 0 |  |
| `ggworkbench.iff` |  | BHAV 4127, 4128, 4129; TPRP 4127, 4128, 4129 | BHAV 4096, 4110, 4111, 4112, 4113, 4116, 4117, 4118; CTSS 2000; OBJD 16811, 16812; OBJf 16812, 16813; STR# 129, 256, 257, 300, 301, 304, 305; TPRP 4096, 4117; TTAB 129; TTAs 129; rsmp 0 | 4ddf498c, 4c2a0186 |
| `giftflowers.iff` |  | BHAV 4107, 4108, 4109; TPRP 4107, 4108, 4109 | BHAV 4097; CTSS 2000; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 258, 304; TPRP 4097; TTAB 129; TTAs 129; rsmp 0 |  |
| `grandclock.iff` |  | BHAV 4103, 4104, 4105; OBJf 16807; TPRP 4103, 4104, 4105 | BHAV 4097; CTSS 2000; OBJD 16807; STR# 129, 256, 257; TPRP 4097; TTAB 129; TTAs 129; rsmp 0 | 8f033944 |
| `grimreaperdbd.iff` |  | OBJf 128 | OBJD 128; STR# 129, 130, 200, 256, 257, 304; TTAs 129; rsmp 0 | 32f8ca29 |
| `guitar.iff` |  | BCON 4097; BHAV 4124, 4125, 4126, 4127, 4128; TPRP 4124, 4125, 4126, 4127, 4128 | BHAV 4097, 4108; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 301, 304; TPRP 4097, 4108; TTAB 129; TTAs 129; rsmp 0 | 21f954a6 |
| `hatrack.iff` | STR# 258 | BHAV 4121, 4125, 4128; TPRP 4121, 4125, 4128 | BHAV 4132; CTSS 2000; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 256, 257, 304; TPRP 4132; TTAB 129; TTAs 129, 130; rsmp 0 | 01dace5c, 55246ea3 |
| `helpsystem.iff` |  | TTAs 128 | CTSS 2000; STR# 129, 130, 256, 258, 259, 300, 301, 303; TTAB 128; TTAs 129; rsmp 0 |  |
| `hottub.iff` |  | BHAV 4143, 4144, 4145; TPRP 4143, 4144, 4145 | BHAV 4098, 4099, 4100, 4101, 4105, 4112, 4116, 4129; CTSS 2000; OBJD 16815; OBJf 16807, 16808, 16811, 16812; STR# 129, 130, 256, 257, 301, 302, 304; TPRP 4112, 4116; TTAB 129; TTAs 129; rsmp 0 | 8fed54c2 |
| `hottubvacation.iff` |  | BHAV 4141, 4176, 4177; TPRP 4141, 4176, 4177 | BHAV 4098, 4099, 4116, 4129; CTSS 2000; OBJf 16807, 16808, 16811, 16812; STR# 129, 130, 256, 257, 301, 302, 304; TPRP 4099, 4116; TTAB 129; TTAs 129; rsmp 0 |  |
| `icecream.iff` | BCON 4096, 4097, 4098, 4100; BHAV 4100, 4101, 4102, 4108, 4109, 4110, 4112, 4115, 4116, 4117, 4122, 4126, 4127, 4129, 4133, 4134, 4135, 4137, 4138, 4139, 4141, 4142, 4143, 4144, 4146, 4147, 4149, 4151, 4152, 4155, 4156, 4160, 4164, 4165, 4171, 4172, 4178, 4179, 4182, 4186, 4188, 4190, 4191, 4192; STR# 258, 300, 402; TPRP 4100, 4101, 4102, 4108, 4109, 4110, 4112, 4115, 4116, 4117, 4122, 4126, 4127, 4129, 4133, 4134, 4135, 4137, 4138, 4139, 4141, 4142, 4143, 4144, 4146, 4147, 4149, 4151, 4152, 4155, 4156, 4160, 4164, 4165, 4171, 4172, 4178, 4179, 4182, 4186, 4188, 4190, 4191, 4192; TRCN 4096, 4097, 4098, 4100; TTAB 128, 129, 130, 131, 132, 133, 134, 135, 136 | BHAV 4103, 4119, 4120, 4123, 4124; CTSS 2002; GLOB 1; OBJD 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817; OBJf 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817; TPRP 4103, 4119, 4120, 4123, 4124; TTAB 138, 139, 140; TTAs 138, 139, 140 | BHAV 4096, 4097, 4098, 4099, 4121, 4128, 4170, 4173, 4174, 4177; CTSS 2000, 2001; OBJD 16808, 16809; OBJf 16808, 16809; STR# 129, 130, 256, 257, 301, 302, 303, 304; TPRP 4096, 4097, 4098, 4099, 4121, 4128, 4170, 4173, 4174, 4177; TTAB 137; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 | 10bc3175, 108c797f, d5a1ba43, c4e97762, 18453f75, 77e36fe1, 01b9e3e7, d64b4354, 2c8f0bab, d3ad4b7b |
| `jackolantern.iff` | BHAV 4101, 4102; TPRP 4101, 4102 | BHAV 4112, 4113, 4114, 4116, 4117, 4118, 4119, 4120, 4121, 4122; TPRP 4112, 4113, 4114, 4116, 4117, 4118, 4119, 4120, 4121, 4122 | BHAV 4096, 4098, 4100, 4105, 4107, 4108, 4110; OBJD 16811; OBJf 16811; STR# 129, 130, 131, 132, 256, 257, 301, 304; TPRP 4096, 4098, 4100, 4105, 4107, 4108, 4110; TTAB 128; TTAs 128; rsmp 0 | c9eaca68 |
| `jobcontroller.iff` |  | whole entry |  |  |
| `jobdegrade.iff` |  |  | BHAV 4096, 4097, 4098; CTSS 2000; OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 301, 303, 304, 305; TPRP 4097; rsmp 0 | 534564d5 |
| `jobfinder.iff` |  |  | STR# 129, 256, 257 |  |
| `jobobjband.iff` |  | BHAV 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132; FWAV 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32; TPRP 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132 | BCON 4101, 4103; BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4103, 4104, 4105, 4107, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4118, 4120, 4121, 4122; CTSS 2000; OBJD 16811, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823; OBJf 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819, 16820, 16821, 16822, 16823; SLOT 128; STR# 129, 130, 256, 257, 301, 302, 304, 4096, 4097, 4098, 4099; TPRP 4102, 4105, 4111, 4118; TRCN 4101, 4103; TTAB 129; TTAs 129, 130, 131, 132; rsmp 0 | ba378b65, fd57c400, 5b1294f4, 99f0ebdf, 787ac627, 7f958de5, 374c95d9, 9f01de7b, cf838e10, f411f0a3, 7df2dd66, 7a6aa560 |
| `jobobject2person.iff` | BHAV 4100, 4107, 4116, 4117, 4120, 4129, 4131; TPRP 4100, 4107, 4116, 4117, 4120, 4129, 4131 | BHAV 4124, 4125, 4126; TPRP 4124, 4125, 4126 | BHAV 4096, 4097, 4098, 4099, 4101, 4102, 4103, 4104, 4105, 4106, 4109, 4114, 4115, 4118, 4119, 4121, 4128, 4130, 4132; CTSS 2000; OBJD 16807, 16808, 16809, 16810; OBJf 16808, 16809, 16810; SLOT 128; STR# 129, 130, 256, 257, 301, 302, 303, 304; TPRP 4099, 4103, 4115, 4118, 4128, 4130; TTAB 129; TTAs 129; rsmp 0 | 6a245660, a71e1098, d21a59ee, faf52aa0 |
| `jobpaperchase.iff` |  | BHAV 4100, 4102, 4103; TPRP 4100, 4102, 4103 | BHAV 4209; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; STR# 129, 256, 257, 301, 304, 4096, 4097, 4098; TPRP 4209; TTAB 130; TTAs 129, 130, 131, 132; rsmp 0 | 52817ee1 |
| `jukebox.iff` | BHAV 4123, 4142, 4155; TPRP 4123, 4142, 4155 | BHAV 4139, 4140, 4145, 4146; FWAV 48, 49, 50; TPRP 4139, 4140, 4145, 4146 | BHAV 4096, 4097, 4098, 4099, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4116, 4117, 4118, 4119, 4121, 4122, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4141, 4143, 4144, 4147, 4149, 4150, 4151, 4152, 4153; CTSS 2000; OBJD 16808; OBJf 16808; STR# 129, 130, 256, 257, 258, 303; TPRP 4096, 4097, 4099, 4112, 4116, 4117, 4118, 4122, 4141, 4147; TTAB 131; TTAs 131; rsmp 0 | 29cb5a51 |
| `koiboat.iff` |  |  | CTSS 2000; STR# 129, 256, 257, 300; TTAs 129; rsmp 0 |  |
| `koipond.iff` |  |  | STR# 129, 130, 256, 304; TTAs 129 |  |
| `lampceiling2.iff` |  | BHAV 4099; FWAV 129, 130, 131; TPRP 4099 | BHAV 4096, 4097, 4098; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 256; rsmp 0 | 38d2393e, 38ea7134 |
| `lampceiling3.iff` |  | BHAV 4099; TPRP 4099 | CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 256; rsmp 0 | 34beeeda, 355ca6d0 |
| `lampceilingunleashed.iff` | BHAV 4103, 4104; TPRP 4103, 4104 | BHAV 4097, 4099, 4100; CTSS 2002; FWAV 129, 130, 131; STR# 256; TPRP 4097, 4099, 4100 | BHAV 4096, 4098, 4106; OBJD 16809; OBJf 16809; TPRP 4096, 4098, 4106; rsmp 0 | 3f3fd2dc |
| `lampfloorstage.iff` | STR# 258 | BHAV 4097; TPRP 4097 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | e27bd12e |
| `lampgarden.iff` | STR# 258 | BHAV 4096, 4097, 4098, 4099; FWAV 129, 130; TPRP 4096, 4097, 4098, 4099 | BHAV 4105; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256; TTAs 129; rsmp 0 | ba67ead2 |
| `lampgarden2.iff` | BHAV 4096, 4098, 4099, 4100, 4102, 4105, 4106, 4109, 4110, 4111, 4112; POSI 4106; STR# 258; TPRP 4096, 4098, 4099, 4100, 4102, 4105, 4109, 4110, 4111, 4112; TTAB 129 | BHAV 4104; FWAV 129, 130; TPRP 4104 | BHAV 4097, 4101, 4103, 4107, 4108; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 256; TPRP 4097, 4107, 4108; TTAs 129; rsmp 0 | fd03db16, f6159793 |
| `lamphula.iff` | STR# 258 | BHAV 4098; TPRP 4098 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 4126d70f |
| `lamps.iff` | BCON 4096; BHAV 4103, 4104, 4105, 4106, 4132, 4133, 4134, 4135; STR# 258; TPRP 4103, 4104, 4105, 4106, 4132, 4133, 4134, 4135; TRCN 4096 | BHAV 4099; TPRP 4099 | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813; OBJf 16807, 16808, 16809, 16810, 16811, 16812, 16813; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 98e09eb3, 2c501364, fe7c3fec, df77ee12, 2c5ac343, fd746ad2, 28975923 |
| `lamps2.iff` | STR# 258 | BHAV 4108; TPRP 4108 | BHAV 4096; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815; OBJf 16807, 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815; STR# 129, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 2f42fc26, a6aebf5b, 94f5cda8, fd938797, efb6a70c, df9adf21, cd39bb3a, 0dfd8714, 6c7caec2 |
| `lamps3.iff` | STR# 258 | BHAV 4097; TPRP 4097 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 4e1ea389 |
| `lamps4.iff` | BCON 4096; STR# 258; TRCN 4096 | BHAV 4098, 4099, 4100, 4101; FWAV 129, 130; TPRP 4098, 4099, 4100, 4101 | BHAV 4096, 4097; CTSS 2000, 2001; OBJD 16814, 16815; OBJf 16814, 16815; STR# 256, 257; rsmp 0 | 3991a80e, 39f9e004 |
| `lampsflooranimated.iff` | STR# 258 | BHAV 4097; TPRP 4097 | BHAV 4117, 4118; CTSS 2000, 2001; OBJD 16808, 16809; OBJf 16808, 16809; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | da746262, da6132ff |
| `lampsflooranimated2.iff` | STR# 258 | BHAV 4097, 4098, 4099, 4100; FWAV 129, 130, 131; TPRP 4097, 4098, 4099, 4100 | BHAV 4118; CTSS 2000; OBJD 16808; OBJf 16808; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 8f667b23 |
| `lampsstreet.iff` |  | BHAV 4096; TPRP 4096 | BHAV 4097, 4101, 4103; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818; STR# 129, 256; rsmp 0 | 74214a95, 7449029f, 74915203 |
| `lampsstreet22.iff` |  | BHAV 4096; TPRP 4096 | CTSS 2000; STR# 256; rsmp 0 |  |
| `lampsunleashed.iff` | BCON 4096; BHAV 4116, 4117, 4118, 4119, 4129, 4130, 4131; TPRP 4116, 4117, 4118, 4119, 4129, 4130, 4131 | BHAV 4096, 4097, 4098, 4099; CTSS 2000; STR# 256; TPRP 4096, 4097, 4098, 4099; TTAs 129 | BHAV 4128; OBJD 16810; OBJf 16810; TPRP 4128; rsmp 0 | 2454d328 |
| `lampswall2.iff` | BCON 4096; STR# 258; TRCN 4096 | BHAV 4096, 4097; TPRP 4096, 4097 | BHAV 4113, 4118, 4120, 4121; CTSS 2000, 2002, 2003, 2004; OBJD 16812, 16814, 16815, 16816; OBJf 16812, 16814, 16815, 16816; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 00e22e1e, c25fcf86, 4a459a5d, b87a8d3f |
| `lampswall3.iff` | STR# 258 | BHAV 4096, 4097, 4098, 4099; FWAV 129, 130, 131; TPRP 4096, 4097, 4098, 4099 | BHAV 4113, 4114; CTSS 2000, 2001, 2002, 2003; OBJD 16814, 16815, 16816, 16817; OBJf 16814, 16815, 16816, 16817; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 77d429bb, 7e09517e, 59b200b5, 29eaef1f |
| `lampswall4.iff` | BCON 4096; BHAV 4096, 4110, 4112, 4117; STR# 258; TPRP 4096, 4110, 4112, 4117; TRCN 4096 | BHAV 4097, 4098, 4099, 4100; FWAV 129, 130, 131; TPRP 4097, 4098, 4099, 4100; TTAB 129; TTAs 129 | BHAV 4116; CTSS 2000, 2001; OBJD 16816, 16817; OBJf 16816, 16817; STR# 256, 257; rsmp 0 | 2ccfe01e, 2c85a814 |
| `lampswallgameshow.iff` |  | BHAV 4098; TPRP 4098 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 2a296a67 |
| `lampunleashedcandle.iff` |  |  | BHAV 4099, 4101, 4123; TPRP 4099, 4101, 4123; rsmp 0 |  |
| `lampwallapplausesign.iff` |  | BHAV 4098; TPRP 4098 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 3da808d7 |
| `lampwallmoroccan.iff` | STR# 258 | BHAV 4097; TPRP 4097 | BHAV 4116; CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 2d8a5e39 |
| `lampwallonairsign.iff` |  | BHAV 4097; TPRP 4097 | CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | e2e0fb6a |
| `lampwallvictorian.iff` | BCON 4096; BHAV 4110, 4112, 4117; TPRP 4110, 4112, 4117 | BHAV 4097, 4098, 4099; CTSS 2000; FWAV 129; STR# 256; TPRP 4097, 4098, 4099; TTAB 129; TTAs 129 | BHAV 4096, 4116; OBJD 16812; OBJf 16812; TPRP 4096; rsmp 0 | 3115d33b |
| `leavelot.iff` |  | BHAV 4099; TPRP 4099 | BHAV 4219; CTSS 2000; OBJD 16808; STR# 129, 130, 256, 257, 301, 302, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 313d2f9a |
| `lotexit.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 258, 301, 302, 303; TTAs 129, 130, 132; rsmp 0 |  |
| `lovetubhd.iff` |  | BHAV 4141, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198; TPRP 4141, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198 | BCON 4099; BHAV 4098, 4099, 4100, 4101, 4102, 4104, 4105, 4106, 4109, 4110, 4111, 4113, 4116, 4117, 4118, 4119, 4123, 4128, 4129, 4132, 4144, 4145, 4146, 4147, 4153, 4154, 4156, 4170, 4172, 4175; CTSS 2000; OBJD 16815; OBJf 16807, 16808, 16811, 16812; STR# 129, 130, 256, 257, 301, 302, 304; TPRP 4099, 4100, 4102, 4104, 4106, 4109, 4110, 4111, 4113, 4116, 4117, 4118, 4119, 4128, 4129, 4132, 4144, 4145, 4146, 4147, 4153, 4154, 4156, 4170, 4172; TTAB 129; TTAs 129; rsmp 0 | 245caadf |
| `lovetubinteractions.iff` |  | whole entry |  |  |
| `magazine_inv1.iff` |  |  | STR# 129, 301, 302, 303, 304; TTAs 129 |  |
| `magazine_inv2.iff` |  |  | STR# 129, 301, 302, 303, 304; TTAs 129 |  |
| `magazine_inv3.iff` |  |  | STR# 129, 301, 302, 303, 304; TTAs 129 |  |
| `magazine_inv4.iff` |  |  | STR# 129, 301, 302, 303, 304; TTAs 129 |  |
| `magazine_inv5.iff` |  |  | STR# 129, 301, 302, 303, 304; TTAs 129 |  |
| `magazinestack.iff` |  | BHAV 4133, 4134, 4135; TPRP 4133, 4134, 4135 | BHAV 4114, 4116, 4128, 4129, 4131; OBJf 16807, 16808, 16809, 16810, 16811; STR# 129, 130, 256, 301, 302, 303, 304; TPRP 4114, 4116, 4128, 4129, 4131; TTAB 129; TTAs 129; rsmp 0 |  |
| `magazinestand.iff` |  |  | STR# 129, 256, 257, 300, 302, 303; TTAs 128 |  |
| `maid.iff` | BHAV 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113; GLOB 128; TPRP 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113 | GLOB 1; OBJf 128; TPRP 4102 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102; OBJD 128; STR# 200, 256, 257, 301, 303; TPRP 4096, 4097, 4098, 4099, 4100, 4101; TTAB 129; TTAs 129; rsmp 0 | c61931dc |
| `mailbox.iff` | BHAV 4096, 4098; TPRP 4096, 4098 | GLOB 1 | BHAV 4097, 4101, 4109, 4110; OBJD 16807, 16808, 16809; STR# 129, 130, 256, 257, 258, 301, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 39ccf441, ef121974, 729c4842 |
| `mailboxvacation.iff` |  | GLOB 1; TTAs 129 | BHAV 4096, 4097, 4101; OBJD 16807; OBJf 16807; TPRP 4096; TTAB 129; rsmp 0 | 1d95c9b0 |
| `mask.iff` |  | TTAs 129 | TTAB 129; rsmp 0 |  |
| `mechanicalbull.iff` |  | BHAV 4140, 4141, 4142; OBJf 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; TPRP 4140, 4141, 4142 | BHAV 4104, 4105, 4106, 4121, 4125; CTSS 2000; OBJD 16807, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 301, 304; TPRP 4104, 4106, 4121; TTAB 129; TTAs 129; rsmp 0 | 5e8b157a, bde84c07, 9cdb40ae, f776325b, dc6d7898, 3b095818, 626b202b, b1a0440b, 9317780d |
| `medicinecabinet.iff` |  | BHAV 4115, 4116, 4117; TPRP 4115, 4116, 4117 | BHAV 4098; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 301, 303, 304; TPRP 4098; TTAB 129; TTAs 129; rsmp 0 | 9d4b03a5 |
| `menorah.iff` | STR# 258; TTAB 129, 130, 131, 132, 133, 134, 135 |  | BHAV 4097, 4098, 4099; CTSS 2000; OBJD 16809; OBJf 16809; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 3dbfc043 |
| `mice.iff` | BHAV 4099, 4102, 4107, 4115; TPRP 4099, 4102, 4107, 4115 | BHAV 4109, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4129, 4130; FWAV 16, 17; GLOB 1; STR# 129, 256, 301, 303, 304; TPRP 4109, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4129, 4130; TTAB 130; TTAs 129, 130 | BHAV 4096, 4097, 4098, 4100, 4101, 4103, 4104, 4105, 4106, 4108, 4111, 4112, 4113, 4114; OBJD 16807, 16808; OBJf 16807, 16808; TPRP 4096, 4097, 4098, 4100, 4101, 4103, 4104, 4105, 4106, 4108, 4111, 4112, 4113, 4114; TTAB 129; rsmp 0 | 3246d303, 32649b09 |
| `microphone.iff` | BHAV 4098, 4099, 4105, 4108, 4109; TPRP 4098, 4099, 4105, 4108, 4109 | GLOB 1 | BHAV 4103; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 303; TTAB 129; TTAs 129; rsmp 0 | ff15db89 |
| `microphonepodiumgameshow.iff` |  | GLOB 1 | CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 303; TTAB 129; TTAs 129; rsmp 0 | 395673ad |
| `microphonepulpit.iff` |  | BHAV 4110, 4111, 4112, 4113, 4114, 4115, 4116; GLOB 1; STR# 301; TPRP 4110, 4111, 4112, 4113, 4114, 4115, 4116 | BHAV 4097, 4099, 4101, 4105; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; SLOT 128; STR# 129, 130, 256, 257, 303; TPRP 4097, 4099, 4101; TTAB 129; TTAs 129; rsmp 0 | cdadda0d, a927dbbd |
| `mirrorfloorvacation.iff` |  | BHAV 4113, 4114, 4115; TPRP 4113, 4114, 4115 | CTSS 2000, 2001; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129; TTAs 129, 130; rsmp 0 | 302be66c |
| `mirrors.iff` |  | BHAV 4113, 4114, 4115; TPRP 4113, 4114, 4115 | BHAV 4098; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129, 130; TTAs 129, 130; rsmp 0 | dfd8f77a, c041ed5b |
| `mirrors2.iff` |  | BHAV 4112, 4113, 4114; TPRP 4112, 4113, 4114 | BHAV 4098; CTSS 2000; OBJD 16808; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 130; TTAs 129, 130; rsmp 0 | 98e9cfe2 |
| `mirrors3.iff` |  | BHAV 4117, 4118, 4119; TPRP 4117, 4118, 4119 | CTSS 2000; OBJD 16808; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129; TTAs 129; rsmp 0 | 3bf2e078 |
| `mirrorvacation.iff` |  | BHAV 4113, 4114, 4115; TPRP 4113, 4114, 4115 | BHAV 4098; CTSS 2000, 2001; OBJD 16808; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129, 130; TTAs 129, 130; rsmp 0 | 3234ade0 |
| `moosehead.iff` |  | TTAs 129 | BHAV 4096, 4099, 4100, 4101, 4107; CTSS 2000; OBJD 16812; STR# 129, 130, 256; TPRP 4096, 4099, 4100, 4101, 4107; TTAB 129, 130; TTAs 130; rsmp 0 | 62b6f3c1 |
| `mystictree.iff` |  | whole entry |  |  |
| `newspaper.iff` | STR# 258 | BCON 4099, 4100; BHAV 4121, 4122, 4123, 4124, 4125, 4126; STR# 303; TPRP 4121, 4122, 4123, 4124, 4125, 4126 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4112, 4113, 4114, 4115, 4116, 4117, 4120; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 301, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4108, 4109, 4110, 4112, 4113, 4114, 4115, 4116, 4117, 4120; TTAB 129; TTAs 129; rsmp 0 | e6b26801 |
| `newyears.iff` | BCON 4096 | BHAV 4103, 4106, 4111, 4112, 4113, 4114, 4115; FWAV 129; STR# 303; TPRP 4103, 4106, 4111, 4112, 4113, 4114, 4115 | BCON 4097, 4098; BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4104, 4105, 4107, 4109, 4110; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 301, 302; TPRP 4096, 4099, 4102, 4110; TTAB 130; TTAs 129, 130, 131, 132; rsmp 0 | 3372216b |
| `npc_cajunvendor_drk.iff` |  | OBJf 128 | BHAV 4096; OBJD 128; rsmp 0 | 24f7d3a1 |
| `npc_cartvendorfl.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 32583144 |
| `npc_cartvendorfl_drk.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 342d3155 |
| `npc_cartvendorfl_med.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 246c31a1 |
| `npc_icecreamvendor.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 31603199 |
| `npc_icv_dark.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 37a731e9 |
| `npc_icv_med.iff` |  | OBJf 128 | BHAV 4096; CTSS 2000; OBJD 128; STR# 129, 200, 256, 257, 300, 304; rsmp 0 | 36bd31e1 |
| `npc_mcd.iff` |  | whole entry |  |  |
| `npc_mcd_dark.iff` |  | whole entry |  |  |
| `npc_mcd_fem.iff` |  | whole entry |  |  |
| `npc_mcd_fem_dark.iff` |  | whole entry |  |  |
| `npc_mcd_fem_med.iff` |  | whole entry |  |  |
| `npc_mcd_med.iff` |  | whole entry |  |  |
| `npc_pasteryvendor.iff` |  | OBJf 128 | BHAV 4096; OBJD 128; TPRP 4096; rsmp 0 | 30d4d3a4 |
| `npc_pen_catfour.iff` |  |  | OBJD 128; rsmp 0 | 30bed3ba |
| `npc_pen_catthree.iff` |  |  | OBJD 128; rsmp 0 | 323dd3b1 |
| `npc_pen_cattwo.iff` |  |  | OBJD 128; rsmp 0 | 2d81d3b7 |
| `npc_pen_dogfour.iff` |  |  | OBJD 128; rsmp 0 | 317dd38b |
| `npc_pen_dogthree.iff` |  |  | OBJD 128; rsmp 0 | 33cad380 |
| `npc_pen_dogtwo.iff` |  |  | OBJD 128; rsmp 0 | 3183d386 |
| `npc_pen_labrador.iff` |  |  | OBJD 128; rsmp 0 | 32efd39c |
| `npc_pen_tabby.iff` |  |  | OBJD 128; rsmp 0 | 3babd391 |
| `npc_register_clerk_lgt.iff` |  | OBJf 128 | OBJD 128; rsmp 0 | 3546d397 |
| `npc_roulette_croupier.iff` |  | whole entry |  |  |
| `npc_travelinjoe_med.iff` |  | OBJf 128 | OBJD 128; rsmp 0 | 35ced3e8 |
| `npc_unleased_animalcontrol.iff` |  | OBJf 128 | OBJD 128; rsmp 0 | 3a5dd3ed |
| `npc_unleashed_controller.iff` |  |  | OBJD 16807; rsmp 0 | 3534d3fd |
| `npc_unleashed_gardener.iff` |  |  | OBJD 128; OBJf 128; rsmp 0 | 31d1d3f1 |
| `npc_unleashed_head_judge.iff` |  |  | OBJD 128; OBJf 128; rsmp 0 | 3721d3f5 |
| `npc_unleashed_maintenance.iff` |  | OBJf 128 | OBJD 128; rsmp 0 | 2cd3d3c8 |
| `npc_unleashed_organgrinder.iff` |  | OBJf 128 | BHAV 4099; OBJD 128; TPRP 4099; rsmp 0 | 3958d3cd |
| `npc_unleashed_palmreader.iff` |  | OBJf 128 | OBJD 128; rsmp 0 | 30c0d3c4 |
| `npc_unleashed_pet_judge-fem.iff` |  |  | OBJD 128; OBJf 128; rsmp 0 | 34a6d3d8 |
| `npc_unleashed_pet_judge.iff` |  |  | OBJD 128; OBJf 128; rsmp 0 | 3a80d3dd |
| `npc_unleashed_raccoon.iff` |  |  | OBJD 128; rsmp 0 | 396cd3d1 |
| `npc_unleashed_saxplayer.iff` |  | OBJf 128 | BHAV 4099; OBJD 128; TPRP 4099; rsmp 0 | 2bdbd42b |
| `npc_unleashed_skunk.iff` |  |  | OBJD 128; rsmp 0 | 2db9d421 |
| `npc_unleashed_trainer.iff` |  |  | OBJD 128; OBJf 128; rsmp 0 | 3883d422 |
| `npccontroller.iff` | BHAV 4136, 4137, 4138, 4139; GLOB 128; STR# 130, 131, 132, 257, 258, 305; TPRP 4136, 4137, 4138, 4139 | BCON 4097; OBJf 16807; STR# 307 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135; CTSS 2000; OBJD 16807; STR# 129, 256, 301, 303, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135; TTAB 129; TTAs 129; rsmp 0 | 70f69082 |
| `npcdealer.iff` |  |  | CTSS 2000; OBJD 128; STR# 200, 256, 257, 258, 303; TTAs 129; rsmp 0 | 3103aa48 |
| `npcportal.iff` |  | whole entry |  |  |
| `npcrobotsi.iff` |  |  | BHAV 4133, 4216; OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305; TPRP 4133, 4216; TTAs 129; rsmp 0 | e4d07d66 |
| `officechair.iff` |  | TPRP 4098 | BHAV 4098, 4101; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257; TPRP 4101; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | 6cc079c2 |
| `officecubicle.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 257, 303; rsmp 0 | c3d8f262 |
| `officeplant.iff` |  | GLOB 1; OBJf 16807; STR# 302 | BHAV 4098, 4099, 4103, 4112, 4113; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4103, 4112, 4113; TTAB 131; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 | 1b96dc22 |
| `officer.iff` |  | OBJf 128; TRCN 4097 | OBJD 128; STR# 129, 200, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 | 7557c98e |
| `oj-conveyertiles.iff` |  | whole entry |  |  |
| `oj-doors.iff` |  | whole entry |  |  |
| `oj-nc-controller.iff` |  | whole entry |  |  |
| `oj-nc-dfcontroller.iff` |  | whole entry |  |  |
| `oj-nc-npc-dancer.iff` |  | whole entry |  |  |
| `oj-nc-npc-standins.iff` |  | whole entry |  |  |
| `oj-nc-portals.iff` |  | whole entry |  |  |
| `oj-obstacles.iff` |  | whole entry |  |  |
| `oj-platform.iff` |  | whole entry |  |  |
| `oj-rest-check.iff` |  | whole entry |  |  |
| `oj-rest-controller.iff` |  | whole entry |  |  |
| `oj-rest-counters.iff` |  | whole entry |  |  |
| `oj-rest-food.iff` |  | whole entry |  |  |
| `oj-rest-npc-busboy.iff` |  | whole entry |  |  |
| `oj-rest-npc-chef.iff` |  | whole entry |  |  |
| `oj-rest-patron.iff` |  | whole entry |  |  |
| `oj-rest-pickup-counters.iff` |  | whole entry |  |  |
| `oj-rest-social.iff` |  | whole entry |  |  |
| `oj-rest-tables1x1.iff` |  | whole entry |  |  |
| `oj-rest-tables2x1.iff` |  | whole entry |  |  |
| `oj-rest-tables2x2.iff` |  | whole entry |  |  |
| `oj-rest-ticketdisplay.iff` |  | whole entry |  |  |
| `oj-rest-ticketholder.iff` |  | whole entry |  |  |
| `oj-robotfactorycontroller.iff` |  | whole entry |  |  |
| `oj-robots.iff` |  | whole entry |  |  |
| `oj-toolstations.iff` |  | whole entry |  |  |
| `oj-workstations.iff` |  | whole entry |  |  |
| `paintings.iff` | GLOB 128 | TTAs 129 | BHAV 4096, 4098; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007; OBJD 16807, 16808, 16811, 16812, 16815, 16818, 16819, 16820; STR# 129, 130, 256; TPRP 4096, 4098; TTAB 129; TTAs 130; rsmp 0 | 8dab571f, 1b490662, bc3ba088, 2ffaa585, 5250b4c1, d9e3bf7b, abe586cd, 7d2089b6 |
| `paintings2.iff` | GLOB 128 | OBJf 16825; TTAs 129 | BHAV 4096, 4104; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011; OBJD 16807, 16808, 16811, 16815, 16818, 16820, 16821, 16824, 16825, 16826, 16827, 16830; STR# 129, 130, 256; TPRP 4096, 4104; TTAB 129; TTAs 130; rsmp 0 | a1d5048a, a1bd4c80, a13f39cf, a1594e42, a11d2875, a2666952, 5880d445, 5d0bbdb6, 8d70f7b3, dc2dd727, 1f15af7e, 855cde99 |
| `paintings3.iff` | GLOB 128 | TTAs 129 | CTSS 2000, 2001, 2003, 2004, 2005, 2006, 2007, 2008; OBJD 16824, 16825, 16829, 16832, 16835, 16836, 16837, 16840; STR# 129, 130, 256, 301; TTAB 129; TTAs 130; rsmp 0 | 89173b24, 5edb929d, 34acf253, 9293b59e, 94fd43dc, 2e7f37ea, 417e691c, 5fb93288 |
| `paintings4.iff` | GLOB 128 | TTAs 129 | CTSS 2000, 2001, 2003; OBJD 16824, 16825, 16840; STR# 129, 130, 256, 301; TTAB 129; TTAs 130; rsmp 0 | 1154994a, 1149ebcd, 16aed8d8 |
| `paintings5.iff` |  | OBJf 16843, 16844, 16845; TTAs 129 | BHAV 4103, 4105; CTSS 2000, 2001, 2002; OBJD 16840, 16841, 16842, 16843, 16844, 16845; STR# 129, 130, 256, 301; TPRP 4103, 4105; TTAB 129; TTAs 130; rsmp 0 | 829e5c87, 8276148d, 82bc0c1a, 82a87320, 82ce5e45, 82ec29c8 |
| `paintings6.iff` | BHAV 4101, 4102, 4103, 4104, 4105, 4107; STR# 256, 258, 301; TPRP 4101, 4102, 4103, 4104, 4105, 4107 | OBJf 16840, 16841, 16842; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100; CTSS 2000, 2001, 2002; OBJD 16840, 16841, 16842; STR# 129, 130; TPRP 4100; TTAB 129, 130; TTAs 130; rsmp 0 | 2af7f8de, 2a31e049, 2ac5a843 |
| `paintings7.iff` | BHAV 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107; TPRP 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107; TTAB 129 | CTSS 2000, 2001, 2002, 2003, 2004; STR# 256; TTAB 131; TTAs 129, 131 | BHAV 4096, 4097, 4108, 4109; OBJD 16840, 16841, 16842, 16843, 16844, 16845, 16846; OBJf 16840, 16841, 16842, 16844, 16845, 16846; TPRP 4096, 4097, 4108, 4109; TTAB 130; TTAs 130; rsmp 0 | 2b8d9c36, 2bc1d43c, 2a49ccab, 2a12b391, 2ae89ef4, 2ab8e97a, 2508f8c0 |
| `pantryunleashed.iff` |  |  | BHAV 4099, 4114, 4139, 4140, 4141; TPRP 4099, 4114, 4139, 4140, 4141; rsmp 0 |  |
| `papercarrierf1.iff` | BHAV 4096; GLOB 128; TPRP 4096 | BHAV 4103; GLOB 1; OBJf 128; TPRP 4098, 4103; TTAB 129; TTAs 129 | BHAV 4097, 4098, 4099, 4100, 4101, 4102; CTSS 2000; OBJD 128; STR# 130, 200, 256, 257, 301, 303, 304; TPRP 4097, 4099, 4100, 4101, 4102; rsmp 0 | dd0a4385 |
| `parkgrill.iff` | BHAV 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141, 4142; TPRP 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141, 4142 | GLOB 128; STR# 302 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4112, 4129, 4134, 4135; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 256, 257, 301, 303, 304; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4112, 4134, 4135; TTAB 129; TTAs 129; rsmp 0 | 35d9e04a |
| `parkrockers.iff` |  | TTAs 130 | TTAB 130; rsmp 0 |  |
| `partyballoons.iff` |  | BHAV 4112; GLOB 1; OBJD 16808; OBJf 16808; TPRP 4112 | BHAV 4096, 4097, 4098, 4100, 4101, 4106, 4116; CTSS 2000; OBJf 16807; STR# 129, 130, 256, 257, 303, 304; TPRP 4097, 4098, 4101, 4106; TTAB 129; TTAs 129; rsmp 0 | b4a5d370 |
| `pedportal.iff` |  |  | BHAV 4096, 4101, 4109; OBJD 16807; STR# 129, 256, 257, 258, 301, 303, 304, 305; TPRP 4096, 4101, 4109; TTAs 129; rsmp 0 | 81e6bef9 |
| `pestmotel.iff` |  | whole entry |  |  |
| `pet_inventory_fish.iff` |  | PALT 1; STR# 130, 131, 132, 302, 303 | BCON 4096; BHAV 4101, 4103, 4106, 4107, 4110; OBJD 16808; rsmp 0 | 1ffe9fff |
| `pet_inventory_iguana.iff` |  | CTSS 2000; PALT 1; STR# 130, 131, 132, 302, 303; TRCN 4096 | BCON 4096; BHAV 4101, 4103, 4106, 4107, 4110; OBJD 16808; rsmp 0 | fd85f29f |
| `pet_inventory_turtle.iff` |  | PALT 1; STR# 130, 131, 132, 302, 303 | BCON 4096; BHAV 4101, 4103, 4106, 4107, 4110; OBJD 16808; rsmp 0 | 05bad275 |
| `petbath.iff` | BHAV 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4135, 4136; TPRP 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4135, 4136 | BHAV 4142; CTSS 2000; FWAV 14; OBJf 16808, 16809; STR# 129, 256, 257, 302, 304; TPRP 4142; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4121, 4122, 4134, 4137, 4138; OBJD 16807, 16808, 16809; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4121, 4122, 4134, 4137, 4138; TTAB 129; rsmp 0 | 3a61d446, 3af6ccd1, 3ac59c4c |
| `petbed.iff` | BCON 4097, 4099; BHAV 4104, 4105, 4108, 4109, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4128, 4129, 4130, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4148, 4149, 4150, 4151, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165; TPRP 4104, 4105, 4108, 4109, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4128, 4129, 4130, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4148, 4149, 4150, 4151, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165; TTAB 129, 130, 131 | BHAV 4101, 4102; CTSS 2000, 2001, 2002; GLOB 1; STR# 129, 256, 257, 258; TPRP 4101, 4102; TTAB 134; TTAs 132, 133, 134 | BHAV 4096, 4097, 4098, 4099, 4100, 4103, 4106, 4107, 4110, 4111, 4112, 4147, 4153; OBJD 16816, 16817, 16818; OBJf 16816, 16817, 16818; SLOT 128; TPRP 4096, 4097, 4098, 4099, 4100, 4103, 4106, 4107, 4110, 4111, 4112, 4147, 4153; TTAB 132, 133; rsmp 0 | 22db9ca9, 2229d4a3, 2291cc34 |
| `petbirdcage.iff` |  | BHAV 4143, 4144, 4145; TPRP 4143, 4144, 4145; TTAs 129 | BHAV 4100, 4122, 4123, 4124; OBJf 16807, 16809, 16810, 16811; TPRP 4122, 4123, 4124; TTAB 129; rsmp 0 |  |
| `petcatlitterbox.iff` | BCON 4096; BHAV 4104, 4105; TPRP 4104, 4105; TRCN 4096 | CTSS 2000; STR# 129, 130, 256, 257, 258, 303, 304; TPRP 4099; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4106, 4107, 4110, 4111; FWAV 0, 1; OBJD 16807; OBJf 16807; SLOT 128; TPRP 4096, 4097, 4098, 4100, 4101, 4102, 4103, 4106, 4107, 4110, 4111; TTAB 129; rsmp 0 | bedd7b26 |
| `petcattemplate.iff` |  | whole entry |  |  |
| `petdogtemplate.iff` |  | whole entry |  |  |
| `petfishbowl.iff` | BCON 4097; BHAV 4111, 4113, 4114, 4117, 4126, 4127, 4128, 4131, 4132, 4134; TPRP 4111, 4113, 4114, 4117, 4126, 4127, 4128, 4131, 4132, 4134 | BCON 4101; BHAV 4101, 4102; CTSS 2000; DGRP 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124; FWAV 3, 4; PALT 1, 3; STR# 129, 256, 258, 301, 303, 304; TPRP 4101, 4102, 4107; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4112, 4115, 4116, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4129, 4130, 4133, 4135, 4136; FWAV 1; OBJD 16807; OBJf 16807; TPRP 4096, 4097, 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4108, 4109, 4110, 4112, 4115, 4116, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4129, 4130, 4133, 4135, 4136; TTAB 129; rsmp 0 | ac262843 |
| `petfoodbowl.iff` | BCON 4097, 4098; BHAV 4118, 4119, 4120, 4121; TPRP 4118, 4119, 4120, 4121 | BHAV 4102, 4104, 4107, 4109; BMP_ 4000, 4001, 6000, 6001; CTSS 2000, 2001, 2002; FWAV 4, 5; OBJD 16837; OBJf 16837; STR# 129, 130, 256, 257, 301, 303, 304; TPRP 4102, 4104, 4107, 4109; TTAB 130, 131; TTAs 129, 130, 131 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4106, 4108, 4110, 4112, 4117, 4128, 4131, 4132; OBJD 16835, 16836; OBJf 16835, 16836; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4106, 4108, 4110, 4112, 4117, 4128, 4131, 4132; TTAB 129; rsmp 0 | 285fd532, 28779d38, fc49430f |
| `petgym.iff` | BHAV 4114; TPRP 4114 | BHAV 4116; CTSS 2000; FWAV 7, 8; STR# 129, 256; TPRP 4099, 4116; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4111, 4112, 4113, 4115; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; TPRP 4096, 4097, 4098, 4102, 4111, 4112, 4113, 4115; TTAB 129; rsmp 0 | 3360d50a |
| `pethouse.iff` | BCON 4097, 4099; BHAV 4124, 4125, 4126, 4128, 4129, 4130, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165; TPRP 4124, 4125, 4126, 4128, 4129, 4130, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165; TRCN 4097, 4099; TTAB 131, 132, 133 | BHAV 4110, 4111; BMP_ 4000, 4001, 6000, 6001; CTSS 2000, 2001; GLOB 1; STR# 129, 256, 257, 258; TPRP 4110, 4111, 4113; TTAs 129, 130, 132, 133 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4153; OBJD 16817, 16818, 16819, 16820, 16821, 16822; OBJf 16818, 16819, 16820, 16821; SLOT 128; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4112, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4153; TTAB 129, 130; rsmp 0 | 304ed568, 30709d62, 3028cdff, 30dab2c5, 308c9fa0, 30a4e82d |
| `petiguana.iff` | BHAV 4113, 4116, 4117, 4118, 4119, 4125, 4126, 4127, 4130, 4131, 4132, 4134, 4135, 4136, 4139, 4140, 4141; TPRP 4113, 4116, 4117, 4118, 4119, 4125, 4126, 4127, 4130, 4131, 4132, 4134, 4135, 4136, 4139, 4140, 4141 | BCON 4100; BHAV 4112; CTSS 2000; DGRP 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412; FWAV 2, 3, 4; SLOT 128; STR# 129, 256, 301, 303, 304; TPRP 4107, 4109, 4112; TRCN 4096, 4097, 4100; TTAs 129 | BCON 4096, 4097; BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4114, 4115, 4120, 4121, 4122, 4123, 4124, 4128, 4129, 4133; OBJD 16807; OBJf 16807; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4108, 4110, 4111, 4114, 4115, 4120, 4121, 4122, 4123, 4124, 4128, 4129, 4133; TTAB 129; rsmp 0 | 8592f25b |
| `petparrot.iff` | BCON 4096; BHAV 4130, 4132, 4133; GLOB 128; TPRP 4130, 4132, 4133; TRCN 4096; TTAB 129, 130, 131 | BHAV 4125, 4126, 4134, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145; CTSS 2000, 2001; FWAV 11; GLOB 1; STR# 129, 256, 257, 301, 304; TPRP 4125, 4126, 4134, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145; TTAs 132, 133 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4127, 4128, 4129, 4131; OBJD 16820, 16821; OBJf 16820, 16821; SLOT 128; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4127, 4128, 4129, 4131; TTAB 132; rsmp 0 | 0389d580, 03bb9d8a |
| `petplayfountain.iff` |  |  | BHAV 4100 |  |
| `petpost.iff` | BCON 4096; BHAV 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4107, 4108, 4109; TPRP 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4108 | BCON 4097; BMP_ 4000, 6000; CTSS 2000; DGRP 103, 104; STR# 129, 130, 256, 257, 258; TRCN 4097; TTAs 129 | BHAV 4096, 4097, 4101, 4102, 4110, 4112; OBJD 16807; TPRP 4096, 4097, 4101, 4102, 4110, 4112; TTAB 129; rsmp 0 | d7404661 |
| `petpuppet.iff` |  | whole entry |  |  |
| `petsocialscat.iff` |  | whole entry |  |  |
| `petsocialsdog.iff` |  | whole entry |  |  |
| `petturtle.iff` | BHAV 4122, 4127, 4128, 4129, 4130, 4131, 4132, 4135, 4144; OBJD 16808; OBJf 16808; TPRP 4122, 4127, 4128, 4129, 4130, 4131, 4132, 4135, 4144; TTAB 129 | BCON 4097; CTSS 2000; DGRP 118, 119, 120, 121, 122, 123, 124, 125; FWAV 29; STR# 129, 130, 256, 257, 258, 301, 304; TRCN 4097; TTAs 130 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4121, 4123, 4124, 4125, 4126, 4133, 4134, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4145, 4146, 4147, 4148; OBJD 16807; OBJf 16807; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4121, 4123, 4124, 4125, 4126, 4133, 4134, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4145, 4146, 4147, 4148; TTAB 130; rsmp 0 | e112d26c, 35a29dd5 |
| `phoneline.iff` |  |  | STR# 256, 257, 258, 303 |  |
| `phones.iff` |  | whole entry |  |  |
| `piano.iff` |  | BHAV 4115, 4120, 4121; TPRP 4115, 4120, 4121 | BHAV 4110; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129; TTAs 129; rsmp 0 | 112039a0 |
| `piano2.iff` |  | BHAV 4121, 4122, 4123; TPRP 4121, 4122, 4123 | BHAV 4110; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813; STR# 129, 130, 131, 132, 256, 257, 301; TTAB 129; TTAs 129; rsmp 0 | 3dcc1abe |
| `piano3.iff` |  | BHAV 4125, 4126, 4127; TPRP 4125, 4126, 4127 | BHAV 4098, 4110; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813; STR# 129, 130, 131, 132, 256, 257, 301, 303; TTAB 129; TTAs 129; rsmp 0 | 379ee047 |
| `pinata.iff` |  | BHAV 4128, 4129, 4130; TPRP 4128, 4129, 4130 | BHAV 4096, 4097, 4098, 4099, 4102, 4109, 4110, 4112, 4113, 4114, 4115, 4117, 4118, 4120, 4121, 4123, 4135; CTSS 2000; OBJD 16811, 16813; OBJf 16812, 16813; STR# 128, 129, 256, 257, 301, 304; TPRP 4096, 4097, 4102, 4109, 4114, 4115, 4135; TTAB 129; TTAs 129; rsmp 0 | 2355af84, 237bb713 |
| `pinballmachine.iff` |  | BHAV 4121, 4122, 4123, 4124; TPRP 4121, 4122, 4123, 4124 | BHAV 4096, 4097, 4098, 4099, 4102, 4106, 4109, 4113, 4114, 4115, 4117; CTSS 2000; OBJD 16811; OBJf 16808, 16809; STR# 129, 256, 257, 301, 302, 303, 304; TPRP 4099; TTAB 128; TTAs 128; rsmp 0 | 481a74ec |
| `pizzamaker.iff` |  | BHAV 4150, 4151, 4152; TPRP 4150, 4151, 4152 | BHAV 4099, 4112, 4134, 4147; CTSS 2000; OBJD 16807; OBJf 16808, 16809, 16810, 16811; STR# 129, 256, 257, 301, 304; TPRP 4147; TTAB 129; TTAs 129; rsmp 0 | 1d8a0c11 |
| `placeholder.iff` |  |  | BHAV 4096; STR# 257; TPRP 4096; rsmp 0 |  |
| `plantboxfence.iff` | BCON 4097; BHAV 4108, 4109; TPRP 4108, 4109; TRCN 4097 |  | BHAV 4096, 4101, 4106, 4107; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 256, 257, 303; TPRP 4096, 4101, 4106, 4107; rsmp 0 | 3473e05f, 342ba855 |
| `plantboxfenceunleashed.iff` | BHAV 4099, 4106, 4107, 4108, 4109; TPRP 4106, 4107, 4108, 4109 |  | BHAV 4096, 4097, 4101, 4111, 4114; OBJD 16808; TPRP 4096, 4101, 4111, 4114; rsmp 0 | 3b8dd61b |
| `plantflowersurn.iff` |  | GLOB 1; STR# 302 | BHAV 4098, 4099, 4111, 4112, 4113; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4099, 4111, 4113; TTAB 129; TTAs 129; rsmp 0 | 23bdd6ec |
| `plantmoroccan.iff` |  | GLOB 1; STR# 302 | BHAV 4098, 4099, 4111, 4112, 4113, 4115, 4116, 4117; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4111, 4112, 4113, 4115, 4116; TTAB 129; TTAs 129; rsmp 0 | 4f609316 |
| `plantpottedalien.iff` |  | GLOB 1; STR# 302 | BHAV 4098, 4099, 4111, 4112, 4113, 4115, 4116, 4117; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4111, 4113, 4115, 4116; TTAB 129; TTAs 129; rsmp 0 | 26f56daa |
| `plants.iff` |  | GLOB 1; OBJf 16807, 16808, 16809, 16810, 16811, 16812; STR# 302 | BHAV 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4108, 4111, 4112, 4113; CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16807, 16808, 16809, 16810, 16811, 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4108, 4111, 4112, 4113; TTAB 129, 130, 131, 132, 133, 134; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 | 9ae018bb, af4a1300, e5293e72, ad12e0d0, 78edcd25, ff97ba8f |
| `plants2.iff` |  | GLOB 1; STR# 302 | BHAV 4098, 4099, 4111, 4112, 4113; CTSS 2000, 2001, 2002, 2003; OBJD 16810, 16811, 16812; OBJf 16809, 16810, 16811, 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4111, 4113; TTAB 132, 133; TTAs 129, 130, 131, 132, 133, 134; rsmp 0 | 15316867, 154522af, 15445522 |
| `plants3.iff` |  | GLOB 1; STR# 302 | BHAV 4098, 4099, 4111, 4112, 4113; CTSS 2000; OBJD 16812; OBJf 16812; STR# 129, 130, 256, 257, 304, 4096; TPRP 4098, 4099, 4111, 4112, 4113; TTAB 129; TTAs 129; rsmp 0 | 38fee0a8 |
| `plantshanginghd.iff` |  |  | BHAV 4097; CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256; TPRP 4097; TTAB 129; TTAs 129; rsmp 0 | 3ba4e0ae, 3a42a8a4 |
| `planttrellisvine.iff` |  | whole entry |  |  |
| `podium.iff` |  | BHAV 4110, 4111, 4112; TPRP 4110, 4111, 4112 | CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 303; TTAB 129; TTAs 129; rsmp 0 | 83d9387d |
| `pondduck.iff` |  |  | CTSS 2000; STR# 129, 256, 257, 300; TTAs 129 |  |
| `pool.iff` |  | TTAs 129 | STR# 129, 256, 301, 303, 304; TTAB 129; TTAs 130; rsmp 0 |  |
| `pooldivbrd.iff` |  |  | BHAV 4105; CTSS 2000; STR# 129, 130, 256, 257, 303; TPRP 4105; TTAB 129, 130; TTAs 129, 130; rsmp 0 |  |
| `poolfilter.iff` |  | BHAV 4097, 4098, 4100; OBJf 16807; TPRP 4097, 4098, 4100 | CTSS 2000; OBJD 16807; STR# 129, 257; TTAB 129; TTAs 129; rsmp 0 | 74982d7f |
| `poolladder.iff` |  | TTAs 129 | BHAV 4105, 4112; CTSS 2000; STR# 129, 130, 256, 257, 302, 303; TTAB 129, 131; TTAs 130, 131; rsmp 0 |  |
| `poolslide.iff` |  | BHAV 4112, 4113, 4114; TPRP 4112, 4113, 4114 | BHAV 4108; CTSS 2000; OBJf 3114; STR# 129, 130, 256, 257, 303; TTAB 129, 130; TTAs 129, 130; rsmp 0 |  |
| `pooltable.iff` |  | BHAV 4145, 4146, 4152; OBJf 16809; TPRP 4145, 4146, 4152 | BHAV 4098, 4102, 4111, 4112, 4113, 4115, 4117, 4118, 4123, 4125, 4126, 4127, 4133, 4135, 4136, 4140, 4141; CTSS 2000; OBJD 16809, 16815; STR# 129, 130, 256, 257, 258, 303, 304; TPRP 4098, 4102, 4111, 4112, 4113, 4115, 4117, 4118, 4123, 4125, 4126, 4127, 4133, 4135, 4136, 4140, 4141; TTAB 129; TTAs 129; rsmp 0 | 47b0f8fc, 47f39f51 |
| `poop.iff` | BCON 4096, 4097; BHAV 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4118, 4119, 4120, 4121, 4122, 4123; TPRP 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4118, 4119, 4120, 4121, 4122, 4123; TRCN 4096, 4097 | BHAV 4124, 4125, 4126; OBJf 16807, 16808; STR# 129, 256, 302, 304; TPRP 4124, 4125, 4126; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4116, 4117; OBJD 16807, 16808; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4116, 4117; TTAB 129; rsmp 0 | 135cd64e, 12ab9e44 |
| `porchswinghd.iff` |  |  | STR# 129, 130, 256, 257, 301, 302, 304; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142 |  |
| `property_deeds.iff` |  |  | CTSS 2000, 2004; STR# 129, 130, 256, 257, 301; TTAs 129, 130; rsmp 0 |  |
| `punchbowl.iff` |  | BHAV 4157; TPRP 4157 | BHAV 4100, 4113, 4123, 4130, 4136, 4147; CTSS 2000; OBJD 16809; OBJf 16809; STR# 129, 130, 256, 257, 258, 301, 303, 304; TPRP 4100, 4113, 4123, 4130, 4136, 4147; TTAB 129; TTAs 128, 129; rsmp 0 | 068ead71 |
| `puppetangry.iff` |  |  | STR# 129, 304; TTAB 129; TTAs 129 |  |
| `puppetattitude.iff` |  | BHAV 4129, 4130; OBJD 16808; OBJf 16808; TPRP 4129, 4130; TTAB 130; TTAs 130 | BHAV 4128; STR# 129, 256, 304; TTAB 129; TTAs 129; rsmp 0 | ff1b7828 |
| `puppetbonus.iff` |  | BCON 4096; BHAV 4118; FWAV 129, 130, 131; TPRP 4118; TRCN 4096 | STR# 129, 304; TTAB 129; TTAs 129; rsmp 0 |  |
| `puppetbored.iff` |  |  | STR# 129, 130, 304; TTAB 129; TTAs 129 |  |
| `puppetcool.iff` |  |  | STR# 129, 304; TTAB 129; TTAs 129 |  |
| `puppetdance.iff` |  |  | STR# 129, 130; TTAB 129; TTAs 129; rsmp 0 |  |
| `puppetdeath.iff` |  | whole entry |  |  |
| `puppetdisgusted.iff` |  |  | STR# 129; TTAB 129; TTAs 129 |  |
| `puppethappy.iff` |  |  | STR# 129, 130; TTAB 129; TTAs 129 |  |
| `puppetsad.iff` |  |  | STR# 129; TTAB 129; TTAs 129; rsmp 0 |  |
| `puppetsilly.iff` |  | BHAV 4107; TPRP 4107 | STR# 129; TTAB 129; TTAs 129; rsmp 0 |  |
| `queueropes.iff` |  |  | CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 | ce4b38cf |
| `reclinerdoublevacation.iff` | BHAV 4110, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4123, 4124; TPRP 4110, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4123, 4124 |  | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4111, 4120, 4121, 4122; CTSS 2000; OBJD 16807, 16808, 16809, 16810, 16811; OBJf 16809, 16811; STR# 129, 130, 256, 257; TPRP 4097, 4098, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4109, 4111, 4120, 4121, 4122; TTAB 128; TTAs 128; rsmp 0 | 2df68719, 2d12e0b4, 2d30a8be, 2d94aa7c, 2ddef823 |
| `recliners.iff` |  |  | BHAV 4098, 4104, 4109, 4114; CTSS 2, 2000, 2001, 3, 4; OBJD 16807, 16810, 16813, 16814, 16815; STR# 129, 130, 256, 257; TPRP 4098; TTAB 128, 129; TTAs 128, 129; rsmp 0 | d8bb3aa8, faf6c024, 994c1bd7, fab75424, db1804b0 |
| `repairman.iff` | BHAV 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112; GLOB 128; STR# 257, 258; TPRP 4101, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112 | GLOB 1; OBJf 128 | BHAV 4096, 4097, 4098, 4099, 4100; OBJD 128; STR# 200, 256, 301, 303; TPRP 4096, 4097, 4098, 4099, 4100; TTAB 129; TTAs 129; rsmp 0 | 565aa54b |
| `repoman.iff` |  | OBJf 128 | CTSS 2000; OBJD 128; STR# 200, 256, 257, 301, 304; rsmp 0 | a82892c3 |
| `repomanfx.iff` |  |  | STR# 129, 130, 256, 257, 303, 304; TTAs 129 |  |
| `reservetile.iff` |  |  | STR# 257 |  |
| `roaches.iff` | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112 | FWAV 16, 17; GLOB 1 | BHAV 4104; CTSS 2000; OBJD 16807; OBJf 16807, 16808; SLOT 128; STR# 129, 130, 256, 257, 304; TPRP 4104; TTAB 129; TTAs 129; rsmp 0 | 4415a98e |
| `roulette.iff` | BCON 4096; BHAV 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4122, 4133, 4134; FWAV 0; OBJD 16810; TPRP 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4122, 4133, 4134; TRCN 4096; TTAB 129 | FWAV 10, 11, 12, 2, 3, 4, 5, 6, 7, 8, 9; GLOB 128; OBJD 16813; OBJf 16813 | BHAV 4096, 4097, 4098, 4099; CTSS 2000; FWAV 1; OBJD 16807, 16811, 16812; OBJf 16811, 16812; SLOT 128; STR# 129, 256, 257, 301, 302, 303, 4096; TPRP 4096, 4097, 4098, 4099; TTAs 129; rsmp 0 | 391466a5, d3574f89, 1337a703, 7501e44b, 23efb12b |
| `rugmoroccanrunner.iff` |  |  | CTSS 2000; OBJD 16820; OBJf 16827, 16851, 16855; STR# 130, 256, 257; TTAs 129; rsmp 0 | 32f914e8 |
| `rugmoroccansquare.iff` |  |  | CTSS 2000; OBJD 16820; OBJf 16827, 16835, 16839, 16847, 16851, 16855; STR# 130, 256, 257; TTAs 129; rsmp 0 | 3413602f |
| `rugs.iff` |  |  | BHAV 4099; CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16807, 16817, 16818, 16819, 16820, 16857; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16821, 16822, 16823, 16825, 16826, 16827, 16828, 16829, 16830, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840, 16841, 16842, 16844, 16845, 16846, 16847, 16848, 16849, 16850, 16851, 16852, 16853, 16854, 16855, 16856, 16858, 16859, 16860, 16861, 16862, 16863, 16864, 16865, 16866; STR# 130, 256, 257; TPRP 4099; TTAs 129; rsmp 0 | 7ab03de4, c26265b3, 1de172c2, 79fa7e6b, 601b0c9a, dc01b7e8 |
| `rugs2.iff` |  |  | BHAV 4099; CTSS 2000, 2001; OBJD 16807, 16820; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16827, 16835, 16839, 16847, 16851, 16855; STR# 130, 256, 257; TPRP 4099; TTAs 129; rsmp 0 | c73c14a4, c4c35536 |
| `rugs3.iff` |  | STR# 256 | CTSS 2000; OBJD 16820; OBJf 16827, 16835, 16839, 16847, 16851, 16855, 16856, 16857, 16858; TTAs 129; rsmp 0 | 27ecbf36 |
| `salvageinteraction.iff` |  | whole entry |  |  |
| `scheduler.iff` |  |  | STR# 256, 303 |  |
| `sculpturedressingscreen.iff` |  | BHAV 4097; TPRP 4097 | BHAV 4104; CTSS 2000; OBJD 16808; OBJf 16809; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 2fecbf66 |
| `sculpturegopher.iff` |  |  | BHAV 4096, 4103, 4106; TPRP 4096, 4103, 4106; rsmp 0 |  |
| `sculptures.iff` | TRCN 4096 | BHAV 4108; TPRP 4108 | BCON 4096; BHAV 4096, 4105; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16811, 16812; OBJf 16811, 16812; STR# 129, 130, 256, 257, 301; TPRP 4096, 4102, 4104, 4105; TTAs 129, 130, 131, 132; rsmp 0 | 52112235, 4b69ea5a, b346903c, 2a7994bf |
| `sculptures2.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010; OBJD 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16820, 16821, 16822, 16825; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | b48a1144, 342a5e00, 4ae4f77c, 95efe015, 877feca1, dac39ea9, 375dd48b, a805e814, a478d407, eff1fdb0, 029c9043 |
| `sculptures3.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16811, 16812, 16813, 16814, 16815, 16818; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 37bfa925, 1e6d621b, b4b333e4, e7d374d8, 01f02564, ec3b09c0 |
| `sculptures4.iff` |  |  | BHAV 4105; CTSS 2000, 2004; OBJD 16811, 16815; STR# 129, 130, 256, 257, 301; TTAs 129, 130; rsmp 0 | c7a3fdcb, c76db5c1 |
| `sculptures5.iff` | BHAV 4102; BMP_ 2000, 2006, 2007; TPRP 4102 | TTAB 133; TTAs 133 | BHAV 4096, 4097, 4100, 4101, 4103, 4104, 4105, 4107, 4108, 4109, 4112, 4113; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007; OBJD 16811, 16812, 16815, 16819, 16820, 16821, 16822, 16823; OBJf 16811, 16813, 16814, 16816, 16817, 16819, 16820, 16821, 16822, 16823; STR# 129, 256, 257, 301; TPRP 4100, 4103, 4105; TTAs 129, 130, 131, 132; rsmp 0 | 895ecb94, 895e839e, 8998815c, 89cbb913, 89eaa2ef, 3ba56a6c, c7a0fd14, 10080233 |
| `sculptures6.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; OBJD 16819, 16820; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3a8d2542, 3abb3dd5 |
| `sculptures7.iff` | BHAV 4099, 4102, 4105; TPRP 4099, 4102, 4105; TTAB 130, 131 | BHAV 4108, 4109, 4112, 4113, 4114, 4115, 4116; CTSS 2000; FWAV 7, 8; STR# 129, 301; TPRP 4108, 4109, 4112, 4113, 4114, 4115, 4116; TTAs 129 | BHAV 4096, 4100, 4101, 4103, 4104, 4107; OBJD 16820, 16821, 16824; OBJf 16821, 16822, 16823, 16824; TPRP 4096, 4100, 4101, 4103, 4104, 4107; TTAB 129, 132; TTAs 132; rsmp 0 | 1454d6ce, 14c59ec4, 17bd9c09 |
| `sculptureweddingtopiary.iff` |  |  | BHAV 4104; CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 4bd3b0a4 |
| `showeraluminum.iff` |  | GLOB 1 | BHAV 4098, 4099, 4100, 4101, 4114; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 300, 301, 304; TPRP 4100, 4101, 4114; TTAB 129; TTAs 129; rsmp 0 | 3e11b182 |
| `showerc.iff` |  |  | BHAV 4098, 4099, 4100, 4101, 4114; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 300, 301, 304; TPRP 4100, 4101; TTAB 129; TTAs 129; rsmp 0 | 85e02a40 |
| `showers2.iff` |  |  | BHAV 4098, 4099, 4100, 4101, 4114, 4119; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 300, 301, 304; TPRP 4100, 4101, 4114, 4119; TTAB 129; TTAs 129; rsmp 0 | e19c2cff |
| `showertiki.iff` |  |  | BHAV 4098, 4099, 4100, 4101, 4114, 4124; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 300, 301, 304; TPRP 4100, 4101, 4114, 4124; TTAB 129; TTAs 129; rsmp 0 | ea71c9dc |
| `showertub.iff` |  | BHAV 4142, 4143, 4144, 4145, 4146, 4147; OBJf 16808, 16809; TPRP 4119, 4142, 4143, 4144, 4145, 4146, 4147 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141; CTSS 2000; OBJD 16807, 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4096, 4097, 4100, 4101, 4107, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4124, 4125, 4129, 4133, 4134, 4137, 4138, 4139; TTAB 129; TTAs 129; rsmp 0 | 1427f80c, 142da891, 1413e09b |
| `showertubunleashed.iff` | STR# 301 | BHAV 4142, 4143, 4144, 4145; OBJf 16808, 16809; STR# 129, 130, 256, 257, 304, 4096; TPRP 4119, 4142, 4143, 4144, 4145; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141; OBJD 16807, 16808, 16809; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141; TTAB 129; rsmp 0 | 6d74d70c, 6dcacf98, 6d129f06 |
| `shrubs.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004; rsmp 0 |  |
| `shrubs2.iff` |  |  | CTSS 2000; rsmp 0 |  |
| `shrubs3.iff` | BHAV 4104; TPRP 4104 |  | BHAV 4099; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; OBJf 16820; rsmp 0 |  |
| `shrubs4.iff` |  |  | BHAV 4096; CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16810; rsmp 0 | 3e65d5a4 |
| `shutters.iff` |  |  | STR# 129, 301; TTAs 130 |  |
| `signs.iff` |  | BHAV 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121; BMP_ 2020; CTSS 2020; OBJD 16820; OBJf 16820; TPRP 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121; TTAB 130; TTAs 130 | BHAV 4107; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010; OBJD 16807, 16810, 16811, 16812, 16813, 16814, 16815, 16816, 16817, 16818, 16819; STR# 129, 256, 257, 301, 303, 304; TTAs 129; rsmp 0 | a996978a, 70bd99f7, 5700d1c5, bfbb8152, a92efe75, 99f6d314, ffeea490, e86bb6d7, dcece8aa, d067f355, eb402c8a, 23295f48 |
| `sinkaluminum.iff` | TTAB 128, 129 | GLOB 1 | BHAV 4113, 4115, 4118, 4120; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 256, 257, 303, 304; TPRP 4115, 4118, 4120; TTAB 130; TTAs 128, 129, 130; rsmp 0 | 3db96806 |
| `sinks.iff` |  | GLOB 1 | BHAV 4113, 4117, 4118, 4120; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; STR# 129, 130, 256, 257, 303, 304; TPRP 4117, 4118, 4120; TTAB 128, 129, 130; TTAs 128, 129, 130; rsmp 0 | 34fe4e17, 75ac188c, 4c727c5d |
| `sinks2.iff` | TTAB 129, 130 | GLOB 1 | BHAV 4118, 4120; CTSS 2000; OBJD 16809; OBJf 16809; STR# 129, 130, 256, 257, 303, 304; TPRP 4118, 4120; TTAB 128; TTAs 128, 129, 130; rsmp 0 | 4ee8b3cf |
| `sinks3.iff` | TTAB 129, 130 | GLOB 1 | BHAV 4117, 4118, 4120; CTSS 2000, 2001; OBJD 16809, 16810; OBJf 16809, 16810; STR# 129, 130, 256, 257, 303, 304; TPRP 4117, 4118, 4120; TTAB 128; TTAs 128, 129, 130; rsmp 0 | 0a8178e9, 6fb00726 |
| `sinkvacation.iff` | TTAB 129, 130 | GLOB 1 | BHAV 4113, 4118, 4120; OBJD 16809; OBJf 16809; STR# 129, 130, 256, 257, 303, 304; TPRP 4118; TTAB 128; TTAs 128; rsmp 0 | 37b6c9b4 |
| `skillcheater.iff` |  | whole entry |  |  |
| `skillcontroller.iff` |  | whole entry |  |  |
| `skilltracker.iff` |  |  | CTSS 2000; OBJD 16808, 16809; STR# 256, 257, 304; TTAs 129; rsmp 0 | 3184835c, 9419adfd |
| `skilltrainer.iff` |  | whole entry |  |  |
| `slotmachine.iff` |  | BCON 4098, 4099; BHAV 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118; STR# 301; TPRP 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118; TRCN 4098, 4099 | BHAV 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809; OBJf 16807, 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 258, 302, 304; TPRP 4098, 4099, 4100, 4101, 4102, 4103, 4105, 4106, 4107, 4108; TTAB 129; TTAs 129; rsmp 0 | 91ed6984, b92dccb1, ad38868d |
| `snackmachine.iff` |  | BHAV 4106, 4107, 4108; TPRP 4106, 4107, 4108 | BHAV 4102, 4105, 4117, 4118; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 300, 301, 302, 303; TPRP 4105; TTAB 128; TTAs 128, 129, 130; rsmp 0 | 53a9396c |
| `snowman.iff` |  | BHAV 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164; CTSS 2000, 2001, 2002, 2003, 2004, 2005; OBJD 16817, 16818, 16819, 16820, 16821; OBJf 16807, 16817, 16818, 16819, 16820, 16821; STR# 129, 256; TPRP 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164; TTAs 129 | BHAV 4096, 4099, 4104, 4126, 4130, 4133; OBJD 16807; OBJf 16808, 16809, 16810, 16811, 16812, 16813, 16814, 16815, 16816; STR# 257; TPRP 4096, 4099, 4126, 4130, 4133; TTAB 129; rsmp 0 | 28bac98e, bc365a52, fff312a8, d51c4228, 04ff3d2e, 64e81052 |
| `soccerball.iff` |  |  | STR# 129, 256, 257, 300; TTAs 129 |  |
| `soccernet.iff` |  |  | CTSS 2000; STR# 256; TTAs 129 |  |
| `social2.iff` | BHAV 4106, 4108, 4110, 4111, 4114, 4116, 4118, 4122, 4123, 4124, 4125, 4126, 4130, 4131, 4132, 4138, 4140, 4147; STR# 301, 303, 304; TPRP 4106, 4108, 4110, 4111, 4114, 4116, 4118, 4122, 4123, 4124, 4125, 4126, 4130, 4131, 4132, 4138, 4140, 4147; TTAB 130, 131 | FWAV 129, 130; OBJf 16808, 16809, 16810, 16811, 16812; STR# 401 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4107, 4109, 4112, 4113, 4117, 4119, 4121, 4127, 4133, 4134, 4135, 4154; OBJD 16807, 16808, 16809, 16810, 16811, 16812; STR# 129, 130, 256, 257, 258, 305; TPRP 4096, 4097, 4098, 4099, 4101, 4104, 4105, 4107, 4109, 4112, 4117, 4119, 4121, 4127, 4133, 4134, 4135; TTAB 129; TTAs 129, 130, 131; rsmp 0 | ffecf6b5, 4740f763, a4e8b034, 9087e0a2, 8b519fa6, 9f6954fb |
| `social2siminteractions.iff` | BCON 4105, 4111, 4123; STR# 305; TTAB 129 | BHAV 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4422, 4423, 4424, 4425, 4426, 4427, 4428, 4429, 4430, 4431, 4432, 4433, 4434, 4435, 4436, 4437, 4438, 4439, 4440, 4441, 4442, 4443, 4444, 4445, 4446, 4447, 4448, 4449, 4450, 4451, 4452, 4453, 4454, 4455, 4456, 4457, 4458, 4459, 4460, 4461, 4462, 4463, 4464, 4465, 4466, 4467, 4468, 4469, 4470, 4471, 4472, 4473, 4474, 4475, 4476, 4477, 4478, 4479, 4480, 4481, 4482, 4483, 4484, 4485, 4486, 4487, 4488, 4489, 4490, 4491, 4492, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500; FWAV 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025; TPRP 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4422, 4423, 4424, 4425, 4426, 4427, 4428, 4429, 4430, 4431, 4432, 4433, 4434, 4435, 4436, 4437, 4438, 4439, 4440, 4441, 4442, 4443, 4444, 4445, 4446, 4447, 4448, 4449, 4450, 4451, 4452, 4453, 4454, 4455, 4456, 4457, 4458, 4459, 4460, 4461, 4462, 4463, 4464, 4465, 4466, 4467, 4468, 4469, 4470, 4471, 4472, 4473, 4474, 4475, 4476, 4477, 4478, 4479, 4480, 4481, 4482, 4483, 4484, 4485, 4486, 4487, 4488, 4489, 4490, 4491, 4492, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500 | BCON 4096, 4097, 4104, 4118; BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245, 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4278, 4279, 4280, 4281, 4282, 4283, 4284, 4285, 4286, 4287, 4288, 4289, 4290, 4291, 4292, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4302, 4303, 4304, 4305, 4307, 4308, 4309, 4310, 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4322, 4323, 4324, 4325, 4326, 4327, 4328, 4329, 4330, 4331, 4332, 4333, 4334, 4335, 4336, 4337, 4338, 4339, 4340, 4341, 4342, 4343, 4344, 4345, 4346, 4347, 4348, 4350, 4351, 4352, 4353, 4354, 4355, 4356, 4357, 4358, 4359, 4360, 4361, 4362, 4363, 4364, 4365, 4366, 4367, 4368, 4369, 4370, 4371, 4372, 4373, 4374, 4375, 4376, 4377, 4378, 4379, 4380, 4381, 4382, 4383, 4384, 4385, 4386, 4387, 4388, 4389, 4390, 4391, 4392, 4393, 4394, 4395, 4396, 4397, 4398, 4399, 4400, 4401, 4402, 4403, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414; FWAV 165; OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 401; TPRP 4097, 4099, 4100, 4101, 4102, 4104, 4106, 4108, 4111, 4112, 4113, 4115, 4116, 4120, 4122, 4123, 4126, 4127, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4150, 4151, 4152, 4153, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4164, 4165, 4166, 4168, 4171, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4191, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4202, 4203, 4207, 4208, 4209, 4210, 4212, 4215, 4219, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4237, 4238, 4239, 4240, 4241, 4242, 4244, 4245, 4246, 4249, 4250, 4251, 4254, 4255, 4258, 4259, 4260, 4261, 4262, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4273, 4274, 4277, 4278, 4280, 4281, 4282, 4284, 4285, 4286, 4287, 4288, 4289, 4290, 4291, 4293, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4302, 4303, 4304, 4305, 4308, 4309, 4310, 4311, 4312, 4313, 4315, 4317, 4318, 4319, 4324, 4325, 4326, 4327, 4328, 4332, 4333, 4335, 4338, 4339, 4341, 4342, 4343, 4344, 4345, 4346, 4347, 4348, 4350, 4353, 4354, 4355, 4356, 4357, 4358, 4359, 4360, 4361, 4362, 4363, 4364, 4366, 4367, 4368, 4369, 4370, 4371, 4372, 4373, 4375, 4376, 4377, 4378, 4379, 4381, 4382, 4383, 4384, 4385, 4386, 4387, 4388, 4389, 4393, 4394, 4395, 4396, 4397, 4398, 4399, 4400, 4401, 4406, 4407, 4408, 4409, 4410, 4411, 4412; TTAB 130; TTAs 129, 130; rsmp 0 | 993da3ec |
| `socialapprove.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4105; STR# 130, 132, 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4103, 4105 | GLOB 1 | BHAV 4097, 4100, 4102, 4104; OBJf 16807; STR# 129, 131, 256; TPRP 4097, 4100, 4102, 4104; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialgreet.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4105; STR# 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4103, 4105 | GLOB 1 | BHAV 4097, 4100, 4102, 4104; OBJf 16807; STR# 129, 256; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialinteractions.iff` |  |  | BHAV 4133, 4216; STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305, 401; TPRP 4133, 4216; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialmean.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4104; STR# 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4103, 4104 | GLOB 1 | BHAV 4097, 4100, 4102, 4105, 4108; OBJf 16807; STR# 129, 256; TPRP 4097, 4100, 4102, 4105, 4108; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialnice.iff` | BHAV 4096, 4098, 4099, 4101, 4102, 4103; STR# 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4102, 4103 | GLOB 1 | BHAV 4097, 4100, 4104, 4105, 4107, 4108; OBJD 16807; OBJf 16807; STR# 129, 256, 301; TPRP 4097, 4100, 4104, 4105, 4107; TTAB 129; TTAs 129; rsmp 0 | 8e324b90 |
| `socialplay.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4104, 4105, 4106; STR# 257, 258; TPRP 4096, 4098, 4099, 4101, 4103, 4104, 4105, 4106 | GLOB 1 | BHAV 4097, 4100, 4102; OBJf 16807; STR# 129, 256, 304; TPRP 4097, 4100; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialreject.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4105; STR# 130, 131, 132, 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4103, 4105 | GLOB 1 | BHAV 4097, 4100, 4102, 4104, 4107; OBJf 16807; STR# 129, 256; TPRP 4097, 4100, 4102, 4104, 4107; TTAB 129; TTAs 129; rsmp 0 |  |
| `socialromance.iff` | BHAV 4096, 4098, 4099, 4101, 4103, 4106; STR# 257, 258, 304; TPRP 4096, 4098, 4099, 4101, 4103, 4106 | GLOB 1 | BHAV 4097, 4100, 4102, 4104, 4105, 4107, 4109; OBJf 16807; STR# 129, 256; TPRP 4097, 4100, 4102, 4104, 4105, 4107, 4109; TTAB 129; TTAs 129; rsmp 0 |  |
| `sodamachine2.iff` |  | BHAV 4097, 4113, 4114, 4115; TPRP 4097, 4113, 4114, 4115 | BHAV 4111; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 300, 301, 302, 303, 304; TTAB 128; TTAs 128, 129, 130; rsmp 0 | 9fee3a72 |
| `sofabenchvacation.iff` |  |  | BHAV 4099; CTSS 2000; OBJD 16832; STR# 129, 130, 256, 257, 301, 302; TTAB 129; TTAs 129, 130, 131; rsmp 0 | 28eae0f9 |
| `sofacuddleinteractions.iff` |  | BHAV 4119, 4120, 4121, 4122, 4123; STR# 303; TPRP 4119, 4120, 4121, 4122, 4123 | BHAV 4096, 4097, 4098, 4101, 4104, 4105, 4106, 4107, 4110, 4115, 4116, 4117, 4118; OBJD 16815; STR# 129, 256, 401; TPRP 4110; TTAs 129; rsmp 0 | 2d774b99 |
| `sofas.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012; OBJD 16807, 16812, 16815, 16819, 16822, 16826, 16830, 16833, 16837, 16841, 16844, 16847, 16850; STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | 9be0e2bf, 4ef4ea16, 7e97444a, 9082401f, 0fbb8bf8, 87d00adc, eeeb7597, 5ede0bc4, 9f12673e, 334f732f, ad4d0d62, 7cb11019, e94250e9 |
| `sofas2.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16815, 16819, 16850, 16854, 16858; STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | c48f31a0, c58b5c78, ddbb7f1d, b99d5c6e, 328ed9e1 |
| `sofas3.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16815, 16819, 16823, 16826, 16827; STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | a9ec8419, 254233ad, feac70dc, 823a9ee0, ed8bea88 |
| `sofas4.iff` |  |  | CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | e6b145d3 |
| `sofas5.iff` |  |  | CTSS 2000, 2001; OBJD 16819, 16823; STR# 129, 256, 257, 302; TTAs 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | 3b8f122e, 3bd0319d |
| `sofashd.iff` |  |  | BHAV 4103; CTSS 2000, 2001; OBJD 16827, 16832, 16833, 16834; STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131; rsmp 0 | 3509a8f7, 35f1aa35, 3551e0fd, 35bdddb9 |
| `sofaslodge.iff` |  |  | BHAV 4097, 4098, 4099, 4104, 4119; CTSS 2001; OBJD 16832; STR# 129, 130, 256, 257, 301, 302; TTAs 129, 130, 131; rsmp 0 | 1c1d8766 |
| `sofasunleashed.iff` |  | CTSS 2000, 2001; STR# 129, 130, 256, 257, 258, 302; TTAs 130, 136 | BHAV 4103, 4104, 4119, 4120, 4128, 4129; OBJD 16819, 16824; TPRP 4103, 4104, 4119, 4120, 4128, 4129; TTAB 130, 136; rsmp 0 | 3326d769, 32efea2c |
| `sofaweddingpew.iff` |  |  | CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16815, 16819, 16830; STR# 129, 130, 256, 257, 302; TTAs 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142; rsmp 0 | 731f404f, 732e58d8, 72543500, 714257cf |
| `souvenircabinets.iff` |  |  | STR# 257 |  |
| `spinbottle.iff` |  |  | BHAV 4099; OBJf 16808; STR# 129, 256, 257, 401; TPRP 4099; TTAs 129; rsmp 0 |  |
| `splitrailfence.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 300, 303, 304; rsmp 0 |  |
| `spotlight.iff` |  | whole entry |  |  |
| `sprinklercontrolpanel.iff` |  | whole entry |  |  |
| `sprinklers.iff` |  | whole entry |  |  |
| `stair.iff` |  |  | BHAV 4105, 4109, 4113, 4118; CTSS 2002, 2003, 2004, 2005; OBJD 16808, 16818, 16821, 16823, 16824, 16825, 16826, 16828, 16831, 16833, 16834, 16835, 16836, 16838, 16841, 16843, 16844, 16845, 16846; STR# 129, 130, 256, 257, 302, 400; TPRP 4105, 4109, 4113, 4118; TTAB 129; TTAs 129; rsmp 0 | bdcf6469, 3c9ea694, 580dc153, 90c49b89, 881c8a3d, e08dd45f, d814cfaa, 6d96dcfa, 82e5bb6f, e9f0e199, d802f02c, 3513ae51, 2516b451, 307ddfa6, 79e2b825, 4184e2c7, b8d0f364, 9470ad19, 821eb6ee |
| `stair2.iff` |  |  | BHAV 4099, 4105, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4118, 4124; CTSS 2000, 2001; OBJD 16808, 16818; STR# 129, 130, 256, 257, 302, 400; TPRP 4099, 4105, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4118, 4124; TTAB 129; TTAs 129; rsmp 0 | e9fc1f39, 5295a7a8 |
| `stair3.iff` |  |  | BHAV 4105, 4109, 4113, 4118; CTSS 2000, 2001; OBJD 16808, 16818; STR# 129, 130, 256, 257, 302, 400; TPRP 4105, 4109, 4113, 4118; TTAB 129; TTAs 129; rsmp 0 | 9667a489, bf1b918e |
| `stair4.iff` |  | TTAs 129 | BHAV 4105, 4109, 4113, 4118; CTSS 2000, 2001; OBJD 16808, 16818; STR# 129, 130, 256, 257, 302, 400; TPRP 4105, 4109, 4113, 4118; TTAB 129; rsmp 0 | 08cef22b, 08ecf5cc |
| `stairsspiral.iff` |  | CTSS 2000, 2001, 2002; OBJf 16820; STR# 129, 256, 257, 258, 302, 400; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125; OBJD 16808, 16814, 16819, 16820, 16821, 16822, 16823, 16824, 16825, 16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840; OBJf 16822, 16829; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125; TTAB 129; rsmp 0 | 2478d764, 260dbe1f, 21e4babc, 20da8dbf, 232696f5, 23a1f1a7, 22f3d6a5, 1dcbdcfd, 1c47f9e9, 1c34c594, 1f06c273, 1f8ea9c8, 19a7ee5c, 18ebd86e, 1b1fd7c9, 1a42d674, 1a7ae70e, 1a18935d, 1a309e4c, 1ade9a56, 1af69ae7, 1a94c217, 157e838e, 15f0eee2 |
| `stereos.iff` | BHAV 4111, 4114, 4115, 4116, 4122, 4123, 4124, 4125, 4130, 4136, 4139, 4140, 4146, 4155, 4160; TPRP 4111, 4114, 4115, 4116, 4122, 4123, 4130, 4136, 4139, 4140, 4146, 4155, 4160 | BHAV 4167, 4168, 4169, 4170; OBJf 16813; TPRP 4167, 4168, 4169, 4170 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4112, 4113, 4117, 4118, 4119, 4120, 4121, 4126, 4127, 4128, 4129, 4131, 4132, 4133, 4134, 4135, 4137, 4138, 4141, 4142, 4143, 4144, 4145, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4157, 4158, 4159, 4161, 4162, 4163, 4164, 4165, 4166; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16811, 16813; OBJf 16807, 16809, 16810, 16812; STR# 129, 130, 256, 257, 258, 303; TPRP 4110, 4112, 4117, 4118, 4134, 4135, 4141; TTAB 129, 130, 131; TTAs 129, 130, 131; rsmp 0 | 46f4e80b, d49346ff, aa2f9672, a2f88598 |
| `stereos2.iff` |  | BHAV 4097, 4105, 4106; TPRP 4097, 4105, 4106 | CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 256, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 0afae8b0, 8da9ffb4 |
| `stereospeakers.iff` |  | BHAV 4116, 4119, 4120, 4122; TPRP 4116, 4119, 4120, 4122 | BHAV 4098, 4099, 4113, 4121; CTSS 2000; OBJD 16808, 16809; OBJf 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 258, 303, 304; TTAB 131; TTAs 131; rsmp 0 | 7e853dea, 4a0c562f |
| `stereowallunleashed.iff` | BCON 4101; BHAV 4114, 4116, 4117, 4118, 4121, 4123, 4141, 4142, 4153, 4154, 4155, 4157, 4158, 4159; TPRP 4114, 4116, 4117, 4118, 4121, 4123, 4141, 4142, 4153, 4154, 4155, 4157, 4158, 4159; TRCN 4101 | BCON 4096, 4097; BHAV 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106; CTSS 2000; STR# 129, 256, 304; TPRP 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106; TRCN 4096, 4097; TTAB 129; TTAs 129 | BHAV 4096, 4097, 4098, 4113; OBJD 16808; OBJf 16808; TPRP 4096, 4097, 4098, 4113; rsmp 0 | 1a56d7ac |
| `stopsign.iff` |  |  | BHAV 4096; CTSS 2000; OBJD 16807; STR# 303; TPRP 4096; TTAs 132; rsmp 0 | 38eae0dd |
| `stoves.iff` |  | BHAV 4142, 4143, 4144; TPRP 4142, 4143, 4144; TTAs 128 | BHAV 4106, 4111; CTSS 2000, 2001, 2002, 2003; OBJD 16807, 16808, 16809, 16810; OBJf 16807, 16808, 16809, 16810; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4106, 4111; TTAB 128, 129; TTAs 129; rsmp 0 | eb686709, ff9f18e0, bb626ef3, ad08fdc0 |
| `stoves2.iff` |  | BHAV 4123, 4125, 4126; TPRP 4123, 4125, 4126; TTAs 128 | BHAV 4106; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 256, 257, 300, 301, 303, 304; TPRP 4106; TTAB 128, 129; TTAs 129; rsmp 0 | e542c148, 882480a6 |
| `tablecoffee.iff` |  | BHAV 4106; TPRP 4106 | BHAV 4098, 4100; CTSS 2000, 2001, 2002; OBJD 16807, 16810, 16811, 16812, 16813; OBJf 16808, 16811, 16814; STR# 129, 256, 257, 303; rsmp 0 | 2e45e0d3, 2e7da8d9, 2ed8877e, 2e8aaa1b, 2e77f844 |
| `tablecoffee2.iff` | BHAV 4097, 4101, 4103, 4104; TPRP 4097, 4101, 4103, 4104 | GLOB 1 | BHAV 4096, 4098, 4100, 4105; CTSS 2000; OBJD 16807, 16808, 16809; OBJf 16808, 16809; STR# 129, 256, 257, 303; TPRP 4105; rsmp 0 | 2ef0f9ba, 2e5fe12d, 2e34a927 |
| `tablecoffeeunleashed.iff` | BHAV 4101, 4103, 4104, 4105; TPRP 4101, 4103, 4104, 4105 | GLOB 1; STR# 129, 256, 257, 303 | BHAV 4096, 4097, 4098, 4099, 4100, 4102; OBJD 16813, 16814, 16815; OBJf 16814, 16815; TPRP 4096, 4097, 4098, 4099, 4100, 4102; rsmp 0 | 354cd7a7, 357e9fac, 351ccf31 |
| `tablediningunleashed.iff` | BHAV 4101, 4112; TPRP 4112 | GLOB 1; STR# 129, 257, 303 | BHAV 4096, 4099, 4103, 4119; OBJD 16836, 16837; OBJf 16836, 16837; TPRP 4096, 4099, 4103; rsmp 0 | 3ba5d7ba, 3a5d9fb0 |
| `tableendwedding.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 130, 256, 257, 303; rsmp 0 | 91054dc1 |
| `tablegiftshop.iff` | BHAV 4112; TPRP 4112 | GLOB 1; STR# 129, 257, 303; TPRP 4101 | BHAV 4096, 4099, 4101, 4103, 4104; OBJD 16836; OBJf 16837, 16838; TPRP 4096, 4099, 4103, 4104; rsmp 0 | 29b19fbc |
| `tablemoroccan1x1.iff` |  |  | BHAV 4118; CTSS 2000; OBJD 16836; STR# 129, 130, 257, 303; rsmp 0 | 5e6574d1 |
| `tablepicnic.iff` | BHAV 4101 | TTAB 130; TTAs 130 | BHAV 4096, 4097, 4098, 4099, 4100, 4102, 4103, 4104, 4106, 4107, 4108, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127; OBJD 16816, 16817, 16818, 16821, 16822; STR# 129, 130, 257, 303; TPRP 4096, 4097, 4098, 4099, 4102, 4103, 4104, 4106, 4107, 4108, 4112, 4114, 4115, 4116, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127; TTAB 129; TTAs 129; rsmp 0 | 2f9da172, 2fbbe978, 2f1fb9e5, 2e2c9c30, 2e4a8d8a |
| `tablepicnic2.iff` | BHAV 4101 | TTAB 130; TTAs 130 | BHAV 4096, 4097, 4098, 4099, 4100, 4103, 4104, 4105, 4106, 4107, 4108, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4122, 4123, 4124, 4126, 4127; CTSS 2000; OBJD 16816, 16817, 16818, 16821, 16822; STR# 129, 130, 257, 303; TPRP 4096, 4097, 4098, 4099, 4104, 4105, 4106, 4112, 4114, 4115, 4116, 4119, 4122, 4126, 4127; TTAs 129; rsmp 0 | 14e3cdc6, 15f8e139, 1590a933, 1413abf1, 14cbdc7c |
| `tablerave.iff` |  |  | CTSS 2000; OBJD 16836; STR# 129, 130, 257, 303; rsmp 0 | 1ad5b840 |
| `tablesend.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; OBJD 16807, 16808, 16809, 16810, 16811, 16812, 16814; STR# 129, 130, 256, 257, 303; TTAs 129; rsmp 0 | 7939d97d, cc944729, 99e0a9b1, 2bd867fe, 3e6fda2f, 02f04067, f1f37c98 |
| `tablesend2.iff` |  |  | CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256, 257, 303; rsmp 0 | e163b26c, e14bfa66 |
| `tablesend4.iff` |  |  | BHAV 4102, 4111, 4114, 4117; CTSS 2000, 2001, 2002; OBJD 16807, 16809; STR# 129, 130, 256, 257, 303; TPRP 4102, 4111, 4114, 4117; rsmp 0 | 0125da9d, 048567b7 |
| `tablesend5.iff` | BHAV 4099, 4107, 4108, 4109, 4110, 4111, 4112, 4114, 4116, 4117, 4118; TPRP 4099, 4107, 4108, 4109, 4110, 4111, 4112, 4114, 4116, 4117, 4118 | GLOB 1 | BHAV 4096, 4097, 4101, 4105, 4106; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303; TPRP 4101, 4105, 4106; rsmp 0 | 3357e13f |
| `tableshd.iff` |  |  | BHAV 4098, 4118; CTSS 2000, 2001, 2002; OBJD 16836, 16837, 16838; STR# 129, 130, 257, 303; TPRP 4098; rsmp 0 | 31b5a938, 319de132, 3067f9a5 |
| `telemarketingstation.iff` |  | BHAV 4139, 4140, 4141; TPRP 4139, 4140, 4141 | BHAV 4096, 4105, 4106, 4109, 4110, 4115, 4118; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 301, 303, 304; TPRP 4096, 4118; TTAB 129; TTAs 129; rsmp 0 | b65d7564 |
| `teleporter.iff` |  | BHAV 4124, 4125, 4126, 4127; TPRP 4124, 4125, 4126, 4127 | BHAV 4097, 4101, 4113, 4114, 4116; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 256, 257, 301, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 96a776ce |
| `telescope.iff` |  | BHAV 4117, 4123, 4124; TPRP 4117, 4123, 4124 | BHAV 4101, 4111; CTSS 2000; OBJD 16811; OBJf 16812; STR# 129, 130, 256, 301, 304; TPRP 4111; TTAB 129; TTAs 129, 130; rsmp 0 | 8f300ef1 |
| `templatecat.iff` |  |  | OBJD 128; rsmp 0 | 3762d78d |
| `templatedog.iff` |  |  | OBJD 128; rsmp 0 | 3ac5d780 |
| `templatenpc.iff` |  |  | OBJD 128; STR# 200, 256, 257, 258, 303; TTAs 129; rsmp 0 | 1e1603fe |
| `templateperson.iff` | GLOB 128 | FWAV 1; GLOB 1; OBJf 128; STR# 129, 301 | BHAV 4096, 4097, 4098; OBJD 128; STR# 200, 256, 257, 300, 304; TPRP 4097, 4098; rsmp 0 | 7fd96b54 |
| `tent.iff` |  |  | BHAV 4121, 4146, 4150; CTSS 2000, 2001; OBJD 16807, 16824; STR# 129, 130, 131, 256, 257, 258, 301, 302, 303; TPRP 4121, 4146, 4150; TTAs 132; rsmp 0 | 018b8cc1, 00adcf97 |
| `timeaccumulator.iff` |  | whole entry |  |  |
| `timer.iff` |  | BHAV 4109, 4110; TPRP 4109, 4110 | BHAV 4107, 4108, 4113; CTSS 2000; OBJD 16815; OBJf 16815; STR# 129, 256, 257, 301; TPRP 4107, 4108; TTAB 129; TTAs 129; rsmp 0 | 39d04c9c |
| `tipjar.iff` |  | STR# 302 | BHAV 4099, 4100, 4104; CTSS 2000; STR# 129, 256, 257, 301, 304; TPRP 4104; TTAB 128; TTAs 128; rsmp 0 |  |
| `toiletaluminum.iff` |  | BHAV 4129, 4130, 4131, 4133, 4134, 4135, 4136; GLOB 1; TPRP 4129, 4130, 4131, 4133, 4134, 4135, 4136 | BHAV 4097, 4102, 4104, 4111, 4112, 4117, 4118, 4128; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4097, 4104, 4111, 4112, 4117, 4118, 4128; TTAB 129; TTAs 129, 130; rsmp 0 | 0bf47549 |
| `toiletportable.iff` |  | BHAV 4103, 4109, 4113, 4114, 4115, 4117; GLOB 1; TPRP 4103, 4109, 4113, 4114, 4115, 4117 | BHAV 4100, 4102, 4104, 4111; CTSS 2000; OBJD 16807; OBJf 16808, 16809; STR# 129, 130, 256, 257, 304; TPRP 4100, 4102, 4104, 4111; TTAB 129; TTAs 129, 130; rsmp 0 | eac3d84f |
| `toilets.iff` |  | BHAV 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135; GLOB 1; TPRP 4111, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135 | BHAV 4102, 4104, 4111, 4117; CTSS 2000, 2001; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4102, 4104; TTAB 129, 130; TTAs 129, 130; rsmp 0 | 84e0774c, 3c566968 |
| `toilets2.iff` |  | BHAV 4099, 4100, 4101, 4102, 4103, 4113; GLOB 1; TPRP 4099, 4100, 4101, 4102, 4103, 4113 | BHAV 4104, 4107, 4111, 4127; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4104, 4107, 4111, 4127; TTAB 129; TTAs 129, 130; rsmp 0 | ebe254b3 |
| `toilets3.iff` |  | BHAV 4129, 4130, 4131, 4132, 4133, 4134, 4135; GLOB 1; TPRP 4129, 4130, 4131, 4132, 4133, 4134, 4135 | BHAV 4102, 4104, 4111, 4117, 4128; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4102, 4104, 4111, 4128; TTAB 129; TTAs 129, 130; rsmp 0 | 00ddfef9 |
| `toiletstall.iff` | BHAV 4117, 4118, 4119, 4120; TPRP 4117, 4118, 4119, 4120; TTAB 130 | BHAV 4099, 4128, 4129, 4130, 4131, 4132; GLOB 1; TPRP 4099, 4128, 4129, 4130, 4131, 4132 | BHAV 4096, 4097, 4098, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4123, 4124, 4125, 4126, 4127; CTSS 2000; OBJD 16807; OBJf 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4096, 4102, 4109, 4111, 4112, 4125, 4127; TTAB 129; TTAs 129, 130; rsmp 0 | d1bc4074 |
| `toiletsunleashed.iff` | BHAV 4120; TPRP 4120; TTAB 130 | BHAV 4121, 4122, 4129; FWAV 129, 130; GLOB 1; STR# 129, 256, 257, 304; TPRP 4121, 4122, 4129; TTAs 129, 130 | BHAV 4096, 4097, 4098, 4100, 4101, 4102, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4116, 4117, 4118, 4119, 4123, 4124, 4125, 4127, 4128; OBJD 16807; OBJf 16808, 16809; TPRP 4096, 4097, 4098, 4100, 4101, 4102, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4117, 4118, 4119, 4123, 4124, 4125, 4127, 4128; TTAB 129; rsmp 0 | 4e9ed7e5 |
| `toileturinal.iff` |  | BHAV 4113, 4114, 4115; GLOB 1; TPRP 4113, 4114, 4115 | BHAV 4100, 4101, 4104, 4105, 4111, 4127; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4100, 4101, 4104, 4105, 4111, 4127; TTAB 129; TTAs 129, 130; rsmp 0 | b7cd406c |
| `topiaries.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004; OBJD 16811; rsmp 0 | e48c2a23 |
| `toyrocket.iff` |  | BHAV 4110, 4111, 4112; TPRP 4110, 4111, 4112 | BHAV 4099, 4102, 4103, 4106; CTSS 2000; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4102, 4106; TTAB 129; TTAs 129; rsmp 0 | 405046ff, de9c3fea |
| `tragicclown.iff` |  | OBJf 128 | OBJD 128; STR# 129, 130, 131, 132, 200, 256, 257, 301, 304, 305; TTAs 129; rsmp 0 | 60344a9b |
| `trainsets.iff` |  | BHAV 4113, 4114, 4115; OBJf 16808, 16809; TPRP 4113, 4114, 4115 | CTSS 2000, 2001; OBJD 16808, 16809, 16810; OBJf 16811, 16812, 16813, 16814, 16815, 16816; STR# 129, 130, 131, 132, 256, 257, 304; TTAB 129, 130; TTAs 129, 130; rsmp 0 | b8a15974, b8be09e9, b499ec29 |
| `trash1.iff` |  | BHAV 4117, 4118, 4119; OBJf 16807; TPRP 4117, 4118, 4119 | BHAV 4097, 4098, 4100, 4106, 4111, 4113, 4114, 4115; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TPRP 4097, 4098, 4100, 4106, 4111, 4113, 4114; TTAB 129; TTAs 129; rsmp 0 | 83e0af58 |
| `trash2.iff` |  | BHAV 4117, 4118, 4119; OBJf 16807; TPRP 4117, 4118, 4119 | BHAV 4097, 4100, 4104, 4106, 4110, 4111, 4114, 4115; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 257, 303, 304; TPRP 4097, 4100, 4104, 4106, 4110, 4111, 4114, 4115; TTAB 129; TTAs 129; rsmp 0 | 21e65bbf |
| `trashcandt.iff` |  | BHAV 4117, 4118, 4119; OBJf 16807, 16808; TPRP 4117, 4118, 4119 | BHAV 4100; CTSS 2000, 2001; OBJD 16807, 16808; STR# 129, 130, 256, 257, 303, 304; TTAB 129; TTAs 129; rsmp 0 | 1ff1da8b, cf2fe69c |
| `trashcanunleashed.iff` | BHAV 4107, 4110, 4113; TPRP 4110, 4113 | BHAV 4118, 4119, 4120; STR# 129, 256, 257, 304; TPRP 4118, 4119, 4120; TTAs 129 | BHAV 4096, 4100, 4101, 4102, 4106, 4109, 4114, 4115; OBJD 16808; OBJf 16808; TPRP 4096, 4100, 4102; TTAB 129; rsmp 0 | 11e4d825 |
| `trashcanvacation.iff` | BHAV 4107, 4110, 4113; STR# 258, 303; TPRP 4110, 4113 | BHAV 4118, 4119, 4120; TPRP 4118, 4119, 4120 | BHAV 4096, 4099, 4100, 4101, 4102, 4106, 4108, 4114, 4115; OBJD 16807, 16808; OBJf 16807, 16808; STR# 129, 130, 256, 257, 304; TPRP 4096, 4099, 4100, 4101, 4102, 4106, 4108; TTAB 129; TTAs 129; rsmp 0 | 2071c9e9, 202981e3 |
| `trashcompactor.iff` | BHAV 4118; TPRP 4118 | BHAV 4133, 4134, 4135, 4136, 4137, 4138; GLOB 1; TPRP 4133, 4134, 4135, 4136, 4137, 4138 | BHAV 4106, 4116, 4117, 4129; CTSS 2000; OBJD 16812, 16813, 16814; OBJf 16813, 16814; STR# 129, 130, 256, 300, 303, 304; TPRP 4106, 4116, 4117, 4129; TTAB 128; TTAs 128; rsmp 0 | 1fac199d, 1fad34f8, 1fad4375 |
| `trashflower.iff` |  | BHAV 4119, 4120; OBJf 16808; TPRP 4119, 4120 | BHAV 4097, 4098, 4103, 4116; OBJD 16808; STR# 129, 130, 256, 257, 303, 304; TPRP 4097, 4098, 4103, 4116; TTAB 129; TTAs 129; rsmp 0 | df8811b4 |
| `trashoutside.iff` |  |  | BHAV 4097, 4098; OBJD 16807; SLOT 128; STR# 129, 130, 256, 257, 301, 304; rsmp 0 | a4258067 |
| `trashpile.iff` | BHAV 4099; TPRP 4099 | BHAV 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133; CTSS 2000; FWAV 130, 133, 134; OBJD 16809, 16810; OBJf 16808, 16809, 16810; TPRP 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133; TTAB 130; TTAs 130 | BHAV 4096, 4098, 4100, 4101, 4103, 4107, 4108, 4109, 4111, 4112, 4114, 4116, 4119, 4120; OBJD 16807, 16808; OBJf 16807; STR# 129, 130, 256, 257, 301, 303, 304; TPRP 4098, 4100, 4101, 4103, 4108, 4109, 4111, 4112, 4114; TTAB 129; TTAs 129; rsmp 0 | 7f907075, ce21b67b, d5737a96, 8aee7f0f |
| `trclownhole.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 304; TTAs 129; rsmp 0 |  |
| `trclownsi.iff` |  |  | STR# 129, 130, 131, 132, 256, 257, 258, 301, 303, 304, 305; TTAs 129 |  |
| `treasurehunt.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 301, 303, 304; TTAs 129 |  |
| `treecurb.iff` |  |  | CTSS 2000, 2001; OBJD 16815, 16816; STR# 129, 130, 256, 257; rsmp 0 | 3698e942, 315ea148 |
| `trees.iff` |  |  | CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257; rsmp 0 | 2b83b971 |
| `trees3.iff` |  |  | CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020; OBJD 16815, 16816, 16821, 16826, 16831, 16836, 16841, 16846, 16851, 16856, 16861, 16867, 16872, 16877, 16878, 16879, 16884, 16889, 16899, 16904, 16909; STR# 129, 130, 256, 257; rsmp 0 | 563504ac, 56040a7b, 56d56301, 8ba56284, 51474702, 5f421524, d297087f, 374b44f3, 21f127af, d8f649ff, 65627ae4, 70e7b9a5, 440087f3, c99ac74e, 2ff38f53, 8c7f5607, e87d6b95, f693720b, d9bd21cd, 7eb57e89, e36b9622 |
| `trees4.iff` |  |  | CTSS 2000, 2001, 2002; OBJD 16826, 16925, 16930; STR# 129, 256, 257; TTAs 129, 130, 131; rsmp 0 | 378ab380, 37a2a8ca, 365acf98 |
| `treeshd.iff` |  |  | CTSS 2018, 2021, 2022; OBJD 16919, 16924, 16925; STR# 256, 257; rsmp 0 | 658e9089, 66bd805a, 6779ed37 |
| `treesunleashed.iff` |  |  | BHAV 4096, 4097, 4104, 4106, 4109, 4110; OBJD 16889, 16899; OBJf 16890, 16900; rsmp 0 | 2839d83e, 24e0ce51 |
| `tubc.iff` |  | BHAV 4137, 4138, 4139; GLOB 1; TPRP 4137, 4138, 4139 | BHAV 4104, 4106; CTSS 2000; OBJD 16807, 16808, 16809; OBJf 16808, 16809; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4106; TTAB 129; TTAs 129; rsmp 0 | 85e00942, 6145c66d, 93908eb9 |
| `tubcastle.iff` |  | BHAV 4138, 4139, 4140; GLOB 1; OBJf 16809; TPRP 4138, 4139, 4140 | BHAV 4104, 4106, 4131, 4135; CTSS 2000; OBJD 16807, 16808, 16809; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4104, 4106, 4131; TTAB 129; TTAs 129; rsmp 0 | 83023da6, 830f2531, 83036d3b |
| `tubm.iff` |  | BHAV 4138, 4139, 4140; GLOB 1; OBJf 16809; TPRP 4138, 4139, 4140 | BHAV 4104, 4106, 4131; CTSS 2000; OBJD 16807, 16809; OBJf 16808; STR# 129, 130, 131, 132, 256, 257, 304; TPRP 4104, 4106, 4131; TTAB 129; TTAs 129; rsmp 0 | dbeb6614, dbea2e1e |
| `tubx.iff` | BHAV 4130 | BHAV 4137, 4138, 4139, 4140, 4141, 4142; TPRP 4137, 4138, 4139, 4140, 4141, 4142 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4131, 4132, 4133, 4134, 4135, 4136; CTSS 2000; OBJD 16807, 16808, 16809, 16810, 16811; OBJf 16808, 16809, 16810, 16811; STR# 129, 130, 131, 132, 256, 257, 304; TTAB 129; TTAs 129; rsmp 0 | e445b4a6, e44bac31, e44ae43b, 9cbabae7, fdf7ce8f |
| `turkey.iff` | BHAV 4104, 4106, 4111, 4114, 4119, 4123, 4129, 4141, 4150, 4153, 4157, 4166, 4171, 4187, 4205, 4211; STR# 258; TPRP 4104, 4106, 4111, 4114, 4119, 4123, 4129, 4141, 4150, 4153, 4157, 4166, 4171, 4187, 4205, 4211; TTAB 128, 130, 131, 132, 133, 134, 135, 136, 137 | BHAV 4161, 4162, 4163, 4167, 4168, 4170, 4174, 4177, 4179, 4180, 4181, 4183; FWAV 16; GLOB 1; OBJD 16818; OBJf 16818; TPRP 4161, 4162, 4163, 4167, 4168, 4170, 4174, 4177, 4179, 4180, 4181, 4183; TTAB 138; TTAs 138 | BHAV 4097, 4101, 4102, 4103, 4105, 4107, 4109, 4112, 4132, 4133, 4149, 4151, 4152, 4165, 4172, 4176, 4178, 4182, 4195, 4196, 4197, 4212, 4214; CTSS 2000, 2001; OBJD 16817; OBJf 16817; STR# 129, 130, 256, 257, 301, 302, 303, 304, 402; TPRP 4097, 4101, 4102, 4103, 4107, 4112, 4132, 4133, 4149, 4151, 4152, 4165, 4172, 4176, 4178, 4195, 4196, 4197, 4212, 4214; TTAB 129; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 | 5190ce3f, 0234ad4b |
| `turnstiledoor.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 300, 301, 302, 303; TTAs 131 |  |
| `tutorial.iff` |  |  | CTSS 2000; STR# 129, 256, 257, 301; rsmp 0 |  |
| `tvs.iff` | BHAV 4150; TPRP 4150; TTAB 131 | BHAV 4127, 4130, 4137, 4139, 4144, 4145; CTSS 2003, 2004; OBJD 16812, 16813, 16814, 16815, 16816, 16817; OBJf 16811, 16813, 16814, 16816, 16817; TPRP 4127, 4130, 4137, 4139, 4144, 4145 | BHAV 4096, 4097, 4101, 4108, 4109, 4118, 4123, 4124, 4129, 4134, 4140, 4143, 4148, 4149, 4152, 4153, 4157; CTSS 2000, 2001, 2002; OBJD 16807, 16808, 16809, 16811; OBJf 16807, 16808, 16810; STR# 129, 130, 256, 257, 258, 302, 304; TPRP 4097, 4108, 4109, 4118, 4129, 4134, 4152, 4153; TRCN 4096; TTAB 129, 130, 132; TTAs 129, 130, 132; rsmp 0 | c192dacc, 5fa381c1, fc8d548b, c0060e30, 0a97230f, 918c6c2e, bbb73ca6, 62cb0e85, b9624784, 54c41711 |
| `typewriter.iff` |  | BHAV 4126, 4127, 4128; TPRP 4126, 4127, 4128 | BHAV 4096, 4105, 4110, 4111, 4115; CTSS 2000; OBJD 16807; OBJf 16807; STR# 129, 130, 256, 257, 301, 303; TPRP 4096; TTAB 129; TTAs 129; rsmp 0 | f77d1200 |
| `urnstone.iff` | BHAV 4103, 4104, 4108, 4109, 4110, 4113; TPRP 4103, 4104, 4108, 4109, 4110, 4113 |  | BHAV 4096, 4098, 4100, 4101, 4107, 4115; CTSS 2000; OBJD 16807; STR# 129, 130, 131, 132, 256, 257, 301; TPRP 4096, 4098, 4100, 4101, 4107, 4115; TTAB 129; TTAs 129; rsmp 0 | 5a6fa529 |
| `urnstonepet.iff` |  |  | BHAV 4096; TPRP 4096; rsmp 0 |  |
| `vacationgrill.iff` | BHAV 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141; TPRP 4102, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4130, 4131, 4132, 4133, 4136, 4137, 4138, 4139, 4140, 4141 | CTSS 2000; GLOB 128; STR# 129, 256, 257, 301, 302, 303, 304; TTAs 129 | BHAV 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4112, 4129, 4134, 4135; OBJD 16812; OBJf 16812; TPRP 4096, 4097, 4098, 4099, 4100, 4101, 4103, 4105, 4112, 4129, 4134, 4135; TTAB 129; rsmp 0 | 3b04c9ea |
| `vrhelmet.iff` |  | BHAV 4102, 4103, 4104; OBJf 16807; TPRP 4099, 4102, 4103, 4104 | BHAV 4099; CTSS 2000; OBJD 16807; STR# 129, 130, 256, 304; TTAB 129; TTAs 129; rsmp 0 | d2a03993 |
| `walllite.iff` | STR# 258 | BHAV 4099; TPRP 4099 | CTSS 2000, 2001, 2002, 2003; OBJD 16810, 16811, 16812, 16813; OBJf 16810, 16811, 16812, 16813; STR# 129, 130, 256, 257; TTAs 129, 130, 131, 132, 133, 134, 135; rsmp 0 | 7fdf0fc1, 7fd422a4, 7fbe5529, 7fab4493 |
| `wargame.iff` | BHAV 4100, 4101, 4102, 4105, 4113, 4118, 4120, 4123, 4125, 4126, 4129; STR# 258, 302, 303, 4096, 4097, 4098, 4099; TPRP 4100, 4101, 4102, 4105, 4113, 4118, 4120, 4123, 4125, 4126, 4129 | BCON 4098, 4099, 4101; BHAV 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145; TPRP 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145; TRCN 4098, 4099, 4101 | BHAV 4096, 4097, 4098, 4099, 4103, 4104, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4114, 4115, 4116, 4117, 4119, 4121, 4122, 4124, 4127, 4128; CTSS 2000; OBJD 16809, 16810, 16811, 16812, 16815; OBJf 16809, 16810, 16811, 16812; STR# 129, 256, 257, 301, 304; TPRP 4096, 4097, 4098, 4103, 4110, 4111, 4112, 4114, 4115, 4116, 4117, 4119, 4121, 4122, 4127, 4128; TTAB 129; TTAs 129; rsmp 0 | cca8accf, cc9781aa, ccab8368, cca9d3f5, ccbfcb62 |
| `watercooler.iff` |  |  | CTSS 2000; STR# 129, 130, 256, 257, 303; rsmp 0 |  |
| `wedcandelabra.iff` | STR# 258 |  | BHAV 4116; CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | 44deb9fc |
| `weddingarch.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 130, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 4ebd9bcd |
| `weddingballoons.iff` | BHAV 4101, 4102, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111; TPRP 4101, 4102, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111 | GLOB 1 | BHAV 4096, 4097, 4100, 4103, 4116; CTSS 2000; OBJf 16807; STR# 129, 130, 256, 257, 303, 304; TPRP 4097, 4103, 4116; TTAB 129; TTAs 129; rsmp 0 |  |
| `weddingcake.iff` | TRCN 4096, 4097, 4098, 4100 | BHAV 4120, 4148; GLOB 1; TPRP 4120, 4148 | BHAV 4097, 4111, 4141, 4151, 4152, 4172, 4173, 4175, 4178, 4182, 4195, 4210, 4212; CTSS 2000, 2001; OBJD 16812, 16817; OBJf 16812, 16817; STR# 129, 130, 256, 257, 258, 301, 302, 303, 304, 402; TPRP 4111, 4173, 4210; TTAB 129, 135; TTAs 128, 129, 130, 131, 132, 133, 134, 135, 136, 137; rsmp 0 | 36b5fd20, 3673d605 |
| `weddingchairfolding.iff` | TTAB 128, 129, 131, 132, 133 |  | BHAV 4098; CTSS 2000; OBJD 16809; STR# 129, 130, 256, 257; TPRP 4098; TTAB 130; TTAs 128, 129, 130, 131, 132, 133; rsmp 0 | 674b7edd |
| `weddingflowers.iff` | BHAV 4098, 4099, 4100, 4101, 4105, 4106, 4107; TPRP 4098, 4099, 4100, 4101, 4105, 4106, 4107 |  | BHAV 4096, 4097, 4102, 4104; CTSS 2000; OBJD 16815; STR# 129, 130, 256, 257, 301; TPRP 4096, 4097; TTAs 129, 130, 131, 132; rsmp 0 | 97fee127 |
| `weddingqueueropes.iff` |  | STR# 256 | CTSS 2000; OBJD 16807; STR# 129, 300, 303; rsmp 0 | 83684654 |
| `weddingrugrunner.iff` |  |  | CTSS 2000; OBJD 16820; OBJf 16827, 16839, 16851, 16855; STR# 130, 256, 257; TTAs 129; rsmp 0 | dad21316 |
| `weddingsign.iff` | STR# 258 |  | BHAV 4121, 4122; CTSS 2000; OBJD 16811; OBJf 16811; STR# 129, 256, 257; TTAs 129; rsmp 0 | a5fb7d34 |
| `weddingtrunk.iff` |  |  | CTSS 2000; OBJD 16808; STR# 129, 256, 257, 301; TTAs 129, 130, 131, 132; rsmp 0 | 3ebd3567 |
| `windows.iff` |  |  | BHAV 4103; CTSS 2000, 2001, 2002, 2010, 2011, 2012, 2013, 2014; TPRP 4103; rsmp 0 |  |
| `windows2.iff` |  |  | BHAV 4103; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008; TPRP 4103; rsmp 0 |  |
| `windows3.iff` |  |  | BHAV 4103; CTSS 2000; TPRP 4103; rsmp 0 |  |
| `windows4.iff` |  |  | BHAV 4103; CTSS 2000, 2001, 2002, 2003, 2004, 2005, 2006; rsmp 0 |  |
| `windows5.iff` |  |  | BHAV 4103; CTSS 2000, 2001; rsmp 0 |  |
| `windows6.iff` |  |  | BHAV 4103; CTSS 2000, 2001, 2002, 2003; rsmp 0 |  |
| `windowsbeach.iff` | BHAV 4097, 4100; TPRP 4097, 4100 | CTSS 2000, 2001; OBJf 16809, 16810, 16812, 16813 | BHAV 4096, 4105; OBJD 16808, 16809, 16810, 16811, 16812, 16813; TPRP 4096, 4105; rsmp 0 | 1ca3f4b8, 1cd9ae50, 1cf18335, 1c4dc9fd, 1c4781f7, 1c21d16a |
| `windowslodge.iff` | BHAV 4097, 4100, 4106, 4107; TPRP 4097, 4100, 4106, 4107 | CTSS 2000, 2001; OBJf 16812, 16813 | BHAV 4096, 4103, 4105; OBJD 16808, 16811, 16812, 16813; OBJf 16809, 16810, 16814, 16815; TPRP 4096, 4103, 4105; rsmp 0 | 2bf3bb70, 28fed160, 2b4eae5a, 2b70833f |
| `windowsunleashed.iff` | BHAV 4096, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114; TPRP 4096, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114 | OBJf 16831, 16851, 16854; STR# 2000, 2001, 2002 | BHAV 4097, 4103, 4104, 4105; OBJD 16829, 16831, 16849, 16851, 16852, 16854; TPRP 4097, 4103, 4104, 4105; rsmp 0 | 0aaed894, 0419c003, 07bde5d2, 06c8aa10, 077fbf3a, 014ab1ec |

#### `objectdata/objects/objotf.far`

FAR1, 421249 bytes in the older, 484868 in the newer.

Entries only in the older: 1, only in the newer: 60, changed: 217.

#### `objectdata/objects/objspf1.far`

FAR1, 53459952 bytes in the older, 53447519 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `awnings4.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `beds3.spf` | BMP_ 4001, 6001; rsmp 0 | XXXX 2001 | BMP_ 2000, 2001, 4000, 6000 |  |

#### `objectdata/objects/objspf2.far`

FAR1, 52639857 bytes in the older, 52484427 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `birthdaycake.spf` | BMP_ 2006, 4000, 4001, 6000, 6001; XXXX 31886 |  | BMP_ 2000, 2001; XXXX 0 |  |
| `cannon.spf` | BMP_ 2000, 4000, 6000; XXXX 0, 2000 |  | SPR2 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141; rsmp 0 |  |
| `cannonball.spf` | BMP_ 2000, 4000, 6000; DGRP 206, 207, 208, 209; SPR2 102, 103, 104, 105 |  | DGRP 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 200, 201, 202; PALT 0; SPR2 100, 101, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 300, 301, 302, 303; rsmp 0 |  |
| `chairsdiningunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `chairslr3.spf` | XXXX 2002, 2004, 2005, 2006, 2007, 4002, 4004, 4005, 4006, 4007, 6002, 6004, 6005, 6006, 6007 | BMP_ 2008; DGRP 900, 901; PALT 8; SPR2 108, 109; XXXX 8, 900; rsmp 0 | XXXX 0 |  |
| `chairslrunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `christmastree.spf` | BMP_ 2001, 2002, 2003, 2004, 4001, 4002, 4003, 4004, 6001, 6002, 6003, 6004; rsmp 0 | XXXX 0 | BMP_ 2000, 4000, 6000 |  |
| `columnarchcarnival.spf` | rsmp 0 |  | BMP_ 2000; XXXX 0 |  |
| `columnarchunleashed.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `computers.spf` | BMP_ 2001, 4000, 4001, 4002, 6000, 6001, 6002 |  | BMP_ 2000, 2002, 2003, 4003, 6003; XXXX 0 |  |
| `computerslaptop.spf` |  | whole entry |  |  |
| `counters4.spf` | BMP_ 4000, 4001, 4002, 4003, 4004, 4005, 6000, 6001, 6002, 6003, 6004, 6005; XXXX 2000, 2001, 2005, 4000, 4001, 4005, 6000, 6001, 6005 |  | BMP_ 2000, 2001, 2002, 2003, 2004, 2005; XXXX 0 |  |
| `counters5.spf` | BMP_ 4000, 4001, 4002, 4003, 6000, 6001, 6002, 6003; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002, 2003 |  |

#### `objectdata/objects/objspf3.far`

FAR1, 55045383 bytes in the older, 54922735 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `counters6.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002 |  |
| `curtainsunleashed.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `dancefloor.spf` |  | BMP_ 2001 |  |  |
| `deadmouse.spf` | rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `diningtablelodge.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `diningtablesbeach.spf` | BMP_ 4001, 6001; rsmp 0 | XXXX 0 | BMP_ 2001 |  |
| `djbooth.spf` |  | BMP_ 2001 |  |  |
| `doghouse.spf` | BMP_ 4000, 4001, 6000, 6001; DGRP 1100, 1101, 1102, 1103, 1300, 1301, 1302, 1303, 1400, 1401, 1402, 1403, 1600, 1601, 1602, 1603, 1700, 1701, 1702, 1703, 1800, 1801, 1802, 1803, 2100, 2101, 2102, 2103, 2300, 2301, 2302, 2303, 2700, 2701, 2702, 2703, 3100, 3101, 3102, 3103, 3300, 3301, 3302, 3303, 3700, 3701, 3702, 3703, 4100, 4101, 4102, 4103, 4300, 4301, 4302, 4303, 4400, 4401, 4402, 4403, 4600, 4601, 4602, 4603, 4700, 4701, 4702, 4703, 4800, 4801, 4802, 4803, 5100, 5101, 5102, 5103, 5300, 5301, 5302, 5303, 5400, 5401, 5402, 5403, 5600, 5601, 5602, 5603, 5700, 5701, 5702, 5703, 5800, 5801, 5802, 5803; PALT 2, 3, 4, 5, 6; rsmp 0 | XXXX 0 | BMP_ 2000, 2001; SPR2 100 |  |

#### `objectdata/objects/objspf4.far`

FAR1, 52434953 bytes in the older, 52527122 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `doorsunleashed.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002 |  |
| `fencecarnival.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `fenceparty.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `fencesunleashed.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002 |  |
| `fireplaces2.spf` | BMP_ 2002, 4000, 4001, 6000, 6001; rsmp 0 |  | BMP_ 2000, 2001; XXXX 0 |  |
| `flowersunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `gamerugbackwhite.spf` |  | whole entry |  |  |

#### `objectdata/objects/objspf5.far`

FAR1, 52632705 bytes in the older, 52576106 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `gamerugbackwhite.spf` | whole entry |  |  |  |
| `gardengnome.spf` | BMP_ 4000, 6000 |  | BMP_ 2000; XXXX 0 |  |
| `jackolantern.spf` | rsmp 0 | XXXX 0 | BMP_ 2000, 4000, 6000 |  |
| `lampceilingunleashed.spf` | BMP_ 2000, 2001, 2002, 4000, 4001, 4002, 6000, 6001, 6002 |  | rsmp 0 |  |
| `lampsunleashed.spf` | BMP_ 2003, 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `lampswall4.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `lampwallvictorian.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `mailboxvacation.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 2000 | BMP_ 2000 |  |
| `mice.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `mirrorvacation.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `newspaper.spf` | BMP_ 4000, 6000; XXXX 4000, 62688, 64732; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `npc_mcd.spf` |  | whole entry |  |  |
| `npc_mcd_dark.spf` |  | whole entry |  |  |
| `npc_mcd_fem.spf` |  | whole entry |  |  |
| `npc_mcd_fem_dark.spf` |  | whole entry |  |  |
| `npc_mcd_fem_med.spf` |  | whole entry |  |  |
| `npc_mcd_med.spf` |  | whole entry |  |  |
| `npccontroller.spf` | BMP_ 4000, 6000; DGRP 128; SPR2 105, 106, 107, 128; XXXX 6000 | BMP_ 2001; DGRP 200, 201, 202, 203, 204, 205, 206, 207; PALT 1, 2, 3, 4, 5, 6, 7; SPR2 110, 111, 120, 121, 122, 123, 124, 200, 201, 202, 203, 204, 210, 211, 220, 221, 222, 223, 224 | BMP_ 2000; DGRP 100, 101, 102, 103, 104, 105, 106, 107; PALT 0; SPR2 100, 101, 102, 103, 104; XXXX 0 |  |
| `oj-nc-portals.spf` |  | whole entry |  |  |
| `paintings7.spf` | BMP_ 2000, 2001, 2003, 2004, 4000, 4001, 4002, 4003, 6000, 6001, 6002, 6003; rsmp 0 | XXXX 2002 | BMP_ 2002, 4004, 6004 |  |
| `petbath.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `petbed.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002 |  |
| `petcatlitterbox.spf` |  | whole entry |  |  |
| `petcatsit.spf` |  | whole entry |  |  |

#### `objectdata/objects/objspf6.far`

FAR1, 54522708 bytes in the older, 54056388 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `pet_inventory_fish.spf` | PALT 1; rsmp 0 | XXXX 0 |  |  |
| `pet_inventory_iguana.spf` | PALT 1; rsmp 0 | XXXX 0 |  |  |
| `pet_inventory_turtle.spf` | PALT 1; rsmp 0 | XXXX 0 |  |  |
| `petcatlitterbox.spf` | whole entry |  |  |  |
| `petcatsit.spf` | whole entry |  |  |  |
| `petfishbowl.spf` | BMP_ 4000, 6000; DGRP 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124; PALT 1, 3; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `petfoodbowl.spf` | BMP_ 4000, 4001, 6000, 6001; DGRP 1000, 104, 105, 106, 107, 108, 109, 110, 1100, 111, 112, 113, 114, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 400, 500, 600, 700, 800, 900; rsmp 0 | BMP_ 2002; DGRP 301, 302, 303; SPR2 300, 301, 302, 303; XXXX 0 | BMP_ 2000, 2001; DGRP 300; PALT 2 |  |
| `petgym.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `pethouse.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `petiguana.spf` | BMP_ 4000, 6000; DGRP 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `petparrot.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `petpost.spf` | BMP_ 4000, 6000; DGRP 103, 104; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `petturtle.spf` | BMP_ 4000, 6000; DGRP 118, 119, 120, 121, 122, 123, 124, 125; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `plantboxfenceunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `poop.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `reclinerdoublevacation.spf` | rsmp 0 | XXXX 0 | BMP_ 4000, 6000 |  |
| `sculptures5.spf` | XXXX 8, 800 | BMP_ 2000, 2006 | XXXX 0 |  |
| `sculptures7.spf` | BMP_ 2000, 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2001, 2002 |  |
| `showertubunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `signs.spf` |  |  | rsmp 0 |  |

#### `objectdata/objects/objspf7.far`

FAR1, 53397728 bytes in the older, 53331779 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `sinkvacation.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `snowman.spf` | BMP_ 4000, 6000; rsmp 0 | BMP_ 2001, 2002, 2003, 2004, 2005; DGRP 103, 104, 105, 106, 107, 108; XXXX 0 | BMP_ 2000; PALT 0, 1, 2, 3; SPR2 100, 101, 102, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341 |  |
| `sofasunleashed.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `stairsspiral.spf` | BMP_ 2000, 2001, 2002, 4000, 4001, 4002, 6000, 6001, 6002 |  | rsmp 0 |  |
| `stereowallunleashed.spf` | BMP_ 2000; rsmp 0 | BMP_ 4000, 6000; XXXX 0 | BMP_ 2001 |  |
| `tablecoffee.spf` | BMP_ 4000, 4002, 6000, 6002; rsmp 0 | XXXX 0, 2001 | BMP_ 4001, 6001 |  |
| `tablecoffee2.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `tablecoffeeunleashed.spf` | BMP_ 4000, 6000 | XXXX 0 | BMP_ 2000; rsmp 0 |  |
| `tablediningunleashed.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `tablegiftshop.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `tablepicnic.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `tablepicnic2.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `tablesend5.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `toiletsunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `trashcanunleashed.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `trashcanvacation.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `trashpile.spf` | BMP_ 4000, 6000; XXXX 2000, 4000, 6000 | BMP_ 0; rsmp 0 | BMP_ 2000; XXXX 0 |  |
| `treesunleashed.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |

#### `objectdata/objects/objspf8.far`

FAR1, 19594488 bytes in the older, 19829922 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `turkey.spf` | BMP_ 4000, 4001, 6000, 6001; XXXX 43888 | XXXX 0 | BMP_ 2000, 2001 |  |
| `tvs.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002 | BMP_ 2003, 2004; DGRP 500, 501, 502, 503, 504, 505, 506, 507, 508, 600, 601, 602, 603, 604, 605, 606, 607, 608, 700, 701, 702, 703, 704, 705, 706, 707, 708, 800, 801, 802, 803, 804, 805, 806, 807, 808; PALT 19, 20, 22, 23, 24, 25, 26, 27; SPR2 2500, 2511, 2512, 2513, 2514, 2515, 2516, 2517, 2518, 2600, 2611, 2612, 2613, 2614, 2615, 2616, 2617, 2618, 2700, 2800 | BMP_ 2000, 2001, 2002; DGRP 100, 101, 102, 103, 104, 105, 106, 107, 108, 200, 201, 202, 203, 204, 205, 206, 207, 208, 300, 301, 302, 303, 304, 305, 306, 307, 308, 400, 401, 402, 403, 404, 405, 406, 407, 408; PALT 12, 18; SPR2 100, 1100, 1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 199, 200, 201, 202, 203, 204, 205, 206, 207, 2100, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2300, 2400, 2401, 2402, 2403, 2404, 2405, 2406, 2407, 2408; XXXX 0 |  |
| `vacationgrill.spf` | BMP_ 4000, 6000; rsmp 0 | XXXX 0 | BMP_ 2000 |  |
| `windowsbeach.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `windowslodge.spf` | BMP_ 4000, 4001, 6000, 6001; rsmp 0 | XXXX 0 | BMP_ 2000, 2001 |  |
| `windowsunleashed.spf` | BMP_ 4000, 4001, 4002, 6000, 6001, 6002; rsmp 0 | XXXX 0 | BMP_ 2000, 2001, 2002 |  |

#### `objectdata/objects/objspf9.far`

FAR1, 6743433 bytes in the older, 32239357 in the newer.

| Entry | Only in the older | Only in the newer | Changed | Object GUIDs |
| --- | --- | --- | --- | --- |
| `accessoryrack.spf` |  | whole entry |  |  |
| `anniversary.spf` |  | whole entry |  |  |
| `cartaxi.spf` |  | whole entry |  |  |
| `craftingcomponents.spf` |  | whole entry |  |  |
| `craftingworkbench.spf` |  | whole entry |  |  |
| `footmassager.spf` |  | whole entry |  |  |
| `jobobjband.spf` | BMP_ 2000 |  | rsmp 0 |  |
| `mystictree.spf` |  | whole entry |  |  |
| `newyears.spf` |  |  | DGRP 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111; PALT 1, 2; SPR2 200, 300; rsmp 0 |  |
| `npcportal.spf` |  | whole entry |  |  |
| `oj-conveyertiles.spf` |  | whole entry |  |  |
| `oj-doors.spf` |  | whole entry |  |  |
| `oj-obstacles.spf` |  | whole entry |  |  |
| `oj-platform.spf` |  | whole entry |  |  |
| `oj-rest-check.spf` |  | whole entry |  |  |
| `oj-rest-counters.spf` |  | whole entry |  |  |
| `oj-rest-food.spf` |  | whole entry |  |  |
| `oj-rest-npc-busboy.spf` |  | whole entry |  |  |
| `oj-rest-npc-chef.spf` |  | whole entry |  |  |
| `oj-rest-pickup-counters.spf` |  | whole entry |  |  |
| `oj-rest-tables1x1.spf` |  | whole entry |  |  |
| `oj-rest-tables2x1.spf` |  | whole entry |  |  |
| `oj-rest-tables2x2.spf` |  | whole entry |  |  |
| `oj-rest-ticketdisplay.spf` |  | whole entry |  |  |
| `oj-rest-ticketholder.spf` |  | whole entry |  |  |
| `oj-robots.spf` |  | whole entry |  |  |
| `oj-toolstations.spf` |  | whole entry |  |  |
| `oj-workstations.spf` |  | whole entry |  |  |
| `pestmotel.spf` |  | whole entry |  |  |
| `petcarrier.spf` |  | whole entry |  |  |
| `petcattemplate.spf` |  | whole entry |  |  |
| `petdogtemplate.spf` |  | whole entry |  |  |
| `petsocialscat.spf` |  | whole entry |  |  |
| `petsocialsdog.spf` |  | whole entry |  |  |
| `phones.spf` |  | whole entry |  |  |
| `planttrellisvine.spf` |  | whole entry |  |  |
| `skillcontroller.spf` |  | whole entry |  |  |
| `skilltrainer.spf` |  | whole entry |  |  |
| `snowman.spf` |  | whole entry |  |  |
| `social2.spf` |  | whole entry |  |  |
| `spotlight.spf` |  | whole entry |  |  |
| `sprinklercontrolpanel.spf` |  | whole entry |  |  |
| `sprinklers.spf` |  | whole entry |  |  |

#### `packingslips/accessorytable.xml`

57915 bytes in the older, 62106 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/animtable.xml`

536506 bytes in the older, 556964 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/catalog.xml`

107697 bytes in the older, 208740 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/objecttable.xml`

183844 bytes in the older, 292713 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `packingslips/packingslips.dat`

FAR3, 4984795 bytes in the older, 5250640 in the newer.

Entries only in the older: 4, only in the newer: 1783, changed: 14660.

#### `packingslips/textable.xml`

482261 bytes in the older, 502536 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `properties.txt`

85 bytes in the older, 85 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/eventlist.txt`

49091 bytes in the older, 48994 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsoep5.evt`

20823 bytes in the older, 20992 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsoep5.hit`

17535 bytes in the older, 17665 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsoep5.hot`

9386 bytes in the older, 9459 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsoep5.hsm`

46457 bytes in the older, 46819 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsov2.evt`

32552 bytes in the older, 32634 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sounddata/tsov2.hit`

27803 bytes in the older, 28253 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `Stings.dat`

DBPF, 35526176 bytes in the older, 34184188 in the newer.

Entries only in the older: 4, only in the newer: 0, changed: 0.

#### `sys/default.ini`

5585 bytes in the older, 6276 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/hintmanager.ini`

2099 bytes in the older, 2364 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/nametohostmap.ini`

4534 bytes in the older, 6783 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `sys/tsoaudio.ini`

6766 bytes in the older, 7247 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOAnimD.dll`

344064 bytes in the older, 405504 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOAudio.dat`

DBPF, 74598227 bytes in the older, 74913471 in the newer.

Entries only in the older: 5, only in the newer: 86, changed: 0.

#### `TSOAudioViewD.dll`

380928 bytes in the older, 397312 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOClient.exe`

307200 bytes in the older, 323584 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOData_datadefinition.dat`

6789 bytes in the older, 10003 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSODataServiceClientD.dll`

638976 bytes in the older, 733184 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOEdithPluginClientD.dll`

393216 bytes in the older, 630784 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOGimexD.dll`

368640 bytes in the older, 405504 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOGraphicD.dll`

765952 bytes in the older, 782336 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSONetServiceSimClientD.dll`

704512 bytes in the older, 753664 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOServiceClientD.dll`

569344 bytes in the older, 684032 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOSimulatorClientD.dll`

966656 bytes in the older, 1130496 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOViewerClientD.dll`

483328 bytes in the older, 520192 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOWinAppD.dll`

2138112 bytes in the older, 2420736 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `TSOWorldClientD.dll`

274432 bytes in the older, 319488 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `tuning.dat`

2361 bytes in the older, 7384 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `uigraphics/bookmarks/bookmarks.dat`

FAR3, 220871 bytes in the older, 220624 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 2.

#### `uigraphics/budget/budget.dat`

FAR3, 326492 bytes in the older, 326346 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 2.

#### `uigraphics/clubs-neighborhoods/clubs-neighborhoods.dat`

FAR3, 582780 bytes in the older, 582539 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `uigraphics/cpanel/cpanel.dat`

FAR3, 114004 bytes in the older, 114532 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 8.

#### `uigraphics/customcontent/cc_dropdownbtn.bmp`

2194 bytes in the older, 2128 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.

#### `uigraphics/dialogs/dialogs.dat`

FAR3, 82992 bytes in the older, 82928 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `uigraphics/eods/eods.dat`

FAR3, 2996200 bytes in the older, 3183939 in the newer.

Entries only in the older: 121, only in the newer: 176, changed: 32.

#### `uigraphics/gizmo/gizmo.dat`

FAR3, 367930 bytes in the older, 374408 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 4.

#### `uigraphics/housepage/housepage.dat`

FAR3, 504620 bytes in the older, 500214 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 6.

#### `uigraphics/matchmaker/matchmaker.dat`

FAR3, 44146 bytes in the older, 47856 in the newer.

Entries only in the older: 0, only in the newer: 2, changed: 0.

#### `uigraphics/messaging/messaging.dat`

FAR3, 768428 bytes in the older, 767161 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 12.

#### `uigraphics/other/other.dat`

FAR3, 1005614 bytes in the older, 1022822 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 1.

#### `uigraphics/personpage/personpage.dat`

FAR3, 704349 bytes in the older, 818219 in the newer.

Entries only in the older: 0, only in the newer: 40, changed: 9.

#### `uigraphics/personselection/personselection.dat`

FAR3, 1535651 bytes in the older, 1559878 in the newer.

Entries only in the older: 0, only in the newer: 4, changed: 3.

#### `uigraphics/shared/sys/sys.dat`

FAR3, 79218 bytes in the older, 79016 in the newer.

Entries only in the older: 0, only in the newer: 0, changed: 1.

#### `uigraphics/ucp/ucp.dat`

FAR3, 3981791 bytes in the older, 4024325 in the newer.

Entries only in the older: 0, only in the newer: 14, changed: 49.

#### `version`

9 bytes in the older, 10 in the newer.
Not compared entry by entry: it isn't a container in both, or doesn't open.
