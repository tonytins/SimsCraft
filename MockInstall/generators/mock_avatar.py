#!/usr/bin/env python3
"""Turns Kenney's CC0 character (MockInstall/GameData) into the mock Sim's avatar files, in the
formats FreeSO's Vitaboy reads (FSO.Vitaboy.Skeleton, Mesh, Binding, Appearance, Outfit,
HandGroup, Animation), so the mock install has a whole Sim with nothing from EA in it:

- avatardata/skeletons/skeletons.dat: adult.skel, TSO's 29 adult bones (names and parents, which
  objects and animations refer to) placed where Kenney's joints are, scaled to TSO's height;
- a body mesh and a head mesh, cut from Kenney's one mesh by bone (the head is what's bound to
  HEAD); each vertex is bound to its strongest joint, blended with its second;
- the female and male skins as JPEG textures, with a binding, appearance, and outfit for each body
  and head; all three skin tones use the same appearance (the clothes are painted on);
- a hand group whose hands have no meshes (Kenney's hands are part of the body), since FreeSO's
  SimAvatar fails on a body outfit without one;
- placeholder animations for the walk and swim names the mock global lists (mock-walk,
  mock-walk-fast, mock-swim) and a stand (mock-stand);
- the mock Sim's body strings (STR# 200 in mocksim.iff) naming the female body and head.

Every file is written whole each run, so the result can be made again; the textures need
ImageMagick (`magick`). File IDs are 0x4D4F.... ("MO"), clear of TSO's.

Usage: mock_avatar.py Simburbia/MockInstall"""
import json, math, os, struct, subprocess, sys, tempfile

mock = sys.argv[1]
root = os.path.join(mock, "TSOClient")
data = os.path.join(mock, "GameData")

# --- Types and IDs
SKELETON, ANIMATION, MESH, BINDING, APPEARANCE, OUTFIT, HANDGROUP, TEXTURE = 5, 7, 9, 11, 12, 13, 18, 20
TEX = {"female": 0x4D4F0101, "male": 0x4D4F0102}
MESH_BODY, MESH_HEAD = 0x4D4F0201, 0x4D4F0202
BND = {("body", "female"): 0x4D4F0301, ("body", "male"): 0x4D4F0302, ("head", "female"): 0x4D4F0303, ("head", "male"): 0x4D4F0304}
APR = {("body", "female"): 0x4D4F0401, ("body", "male"): 0x4D4F0402, ("head", "female"): 0x4D4F0403, ("head", "male"): 0x4D4F0404}
APR_NO_HANDS = 0x4D4F0405
OFT = {("body", "female"): 0x4D4F0501, ("body", "male"): 0x4D4F0502, ("head", "female"): 0x4D4F0503, ("head", "male"): 0x4D4F0504}
HAG = 0x4D4F0601
REGION_HEAD, REGION_BODY = 0, 18   # as TSO's own heads and bodies have them

# TSO's adult skeleton, parents first (bone names and parents as 1.1097.1.0's adult.skel has them),
# and the Kenney joint each sits on (None: placed on its parent).
BONES = [
    ("ROOT", "NULL", None), ("PELVIS", "ROOT", "Hips"), ("SPINE", "PELVIS", "Spine"), ("SPINE1", "SPINE", "Chest"),
    ("SPINE2", "SPINE1", "UpperChest"), ("NECK", "SPINE2", "Neck"),
    ("R_ARM", "NECK", "RightShoulder"), ("R_ARM1", "R_ARM", "RightArm"), ("R_ARM2", "R_ARM1", "RightForeArm"),
    ("R_HAND", "R_ARM2", "RightHand"), ("R_FINGER0", "R_HAND", "RightHandIndex1"),
    ("L_ARM", "NECK", "LeftShoulder"), ("L_ARM1", "L_ARM", "LeftArm"), ("L_ARM2", "L_ARM1", "LeftForeArm"),
    ("L_HAND", "L_ARM2", "LeftHand"), ("L_FINGER0", "L_HAND", "LeftHandIndex1"),
    ("HEAD", "NECK", "Head"),
    ("R_LEG", "PELVIS", "RightUpLeg"), ("R_LEG1", "R_LEG", "RightLeg"), ("R_FOOT", "R_LEG1", "RightFoot"),
    ("R_TOE0", "R_FOOT", "RightToes"), ("R_TOE01", "R_TOE0", "RightToes_end"), ("R_TOE02", "R_TOE01", None),
    ("L_LEG", "PELVIS", "LeftUpLeg"), ("L_LEG1", "L_LEG", "LeftLeg"), ("L_FOOT", "L_LEG1", "LeftFoot"),
    ("L_TOE0", "L_FOOT", "LeftToes"), ("L_TOE01", "L_TOE0", "LeftToes_end"), ("L_TOE02", "L_TOE01", None),
]
# TSO's adult head bone stands about this high; Kenney's is scaled to match.
TSO_HEAD_HEIGHT = 5.05

# --- Small linear algebra: 4x4 matrices as row lists, acting on column vectors.
def matmul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]

def quat_matrix(q):
    x, y, z, w = q
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0],
            [0, 0, 0, 1]]

def local_matrix(node):
    if "matrix" in node:
        m = node["matrix"]
        return [[m[c * 4 + r] for c in range(4)] for r in range(4)]
    t = node.get("translation", [0, 0, 0]); s = node.get("scale", [1, 1, 1])
    m = quat_matrix(node.get("rotation", [0, 0, 0, 1]))
    for r in range(3):
        for c in range(3): m[r][c] *= s[c]
        m[r][3] = t[r]
    return m

def transform(m, p, w=1.0):
    return [m[r][0] * p[0] + m[r][1] * p[1] + m[r][2] * p[2] + m[r][3] * w for r in range(3)]

def normalize(v):
    length = math.sqrt(sum(c * c for c in v)) or 1.0
    return [c / length for c in v]

def rotation_of(m):
    """The rotation of a matrix with scale, as a quaternion (x, y, z, w)."""
    cols = [normalize([m[r][c] for r in range(3)]) for c in range(3)]
    r = [[cols[c][row] for c in range(3)] for row in range(3)]
    trace = r[0][0] + r[1][1] + r[2][2]
    if trace > 0:
        s = math.sqrt(trace + 1) * 2
        q = [(r[2][1] - r[1][2]) / s, (r[0][2] - r[2][0]) / s, (r[1][0] - r[0][1]) / s, s / 4]
    elif r[0][0] > r[1][1] and r[0][0] > r[2][2]:
        s = math.sqrt(1 + r[0][0] - r[1][1] - r[2][2]) * 2
        q = [s / 4, (r[0][1] + r[1][0]) / s, (r[0][2] + r[2][0]) / s, (r[2][1] - r[1][2]) / s]
    elif r[1][1] > r[2][2]:
        s = math.sqrt(1 + r[1][1] - r[0][0] - r[2][2]) * 2
        q = [(r[0][1] + r[1][0]) / s, s / 4, (r[1][2] + r[2][1]) / s, (r[0][2] - r[2][0]) / s]
    else:
        s = math.sqrt(1 + r[2][2] - r[0][0] - r[1][1]) * 2
        q = [(r[0][2] + r[2][0]) / s, (r[1][2] + r[2][1]) / s, s / 4, (r[1][0] - r[0][1]) / s]
    return normalize(q)

def quat_mul(a, b):
    ax, ay, az, aw = a; bx, by, bz, bw = b
    return [aw * bx + ax * bw + ay * bz - az * by, aw * by - ax * bz + ay * bw + az * bx,
            aw * bz + ax * by - ay * bx + az * bw, aw * bw - ax * bx - ay * by - az * bz]

def quat_inverse(q):
    return [-q[0], -q[1], -q[2], q[3]]

def quat_rotate(q, v):
    return transform(quat_matrix(q), v, 0.0)

# --- Kenney's glTF
gltf = json.load(open(os.path.join(data, "characterMedium.gltf")))
buffer = open(os.path.join(data, gltf["buffers"][0]["uri"]), "rb").read()
nodes = gltf["nodes"]

def accessor(index):
    a = gltf["accessors"][index]; view = gltf["bufferViews"][a["bufferView"]]
    width = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}[a["type"]]
    code, size = {5126: ("f", 4), 5125: ("I", 4), 5123: ("H", 2), 5121: ("B", 1)}[a["componentType"]]
    stride = view.get("byteStride", width * size)
    start = view.get("byteOffset", 0) + a.get("byteOffset", 0)
    rows = [list(struct.unpack_from("<%d%s" % (width, code), buffer, start + i * stride)) for i in range(a["count"])]
    if a.get("normalized") and code in "BH":
        rows = [[v / (255.0 if code == "B" else 65535.0) for v in row] for row in rows]
    return rows

parents = {child: i for i, node in enumerate(nodes) for child in node.get("children", [])}
worlds = {}
def world(i):
    if i not in worlds:
        local = local_matrix(nodes[i])
        worlds[i] = matmul(world(parents[i]), local) if i in parents else local
    return worlds[i]

skin = gltf["skins"][0]
joints = skin["joints"]
joint_names = [nodes[j]["name"] for j in joints]
node_by_name = {node.get("name"): i for i, node in enumerate(nodes)}
inverse_binds = accessor(skin["inverseBindMatrices"])
skin_matrices = []
for j, ib in zip(joints, inverse_binds):
    ibm = [[ib[c * 4 + r] for c in range(4)] for r in range(4)]
    skin_matrices.append(matmul(world(j), ibm))

scale = TSO_HEAD_HEIGHT / transform(world(node_by_name["Head"]), [0, 0, 0])[1]

# --- The skeleton: each bone's world placement, then its place in its parent.
placed = {}
for name, parent, joint in BONES:
    if joint is None:
        placed[name] = placed[parent] if parent in placed else ([0, 0, 0], [0, 0, 0, 1])
    else:
        m = world(node_by_name[joint])
        placed[name] = ([c * scale for c in transform(m, [0, 0, 0])], rotation_of(m))
placed["ROOT"] = ([0, 0, 0], [0, 0, 0, 1])

def pascal(text):
    raw = text.encode("ascii")
    return bytes([len(raw)]) + raw

def floats(*values):
    return struct.pack("<%df" % len(values), *values)

skel = struct.pack(">I", 1) + pascal("adult") + struct.pack(">h", len(BONES))
for name, parent, _ in BONES:
    position, rotation = placed[name]
    if parent == "NULL":
        t, r = position, rotation
    else:
        parent_position, parent_rotation = placed[parent]
        inverse = quat_inverse(parent_rotation)
        t = quat_rotate(inverse, [position[i] - parent_position[i] for i in range(3)])
        r = quat_mul(inverse, rotation)
    # FreeSO's Skeleton reads integers big-endian and floats little-endian, negating x and the
    # rotation's y, z, and w, so they're stored that way round.
    skel += (struct.pack(">i", 0) + pascal(name) + pascal(parent) + b"\0"
             + floats(-t[0], t[1], t[2]) + floats(r[0], -r[1], -r[2], -r[3])
             + struct.pack(">3i", 1, 1, 1) + floats(0, 0))

# --- Each Kenney joint goes to the TSO bone it sits on, or the nearest one above it.
joint_bone = {joint: name for name, _, joint in BONES if joint}
def bone_for(joint_name):
    i = node_by_name[joint_name]
    while True:
        name = nodes[i].get("name")
        if name in joint_bone: return joint_bone[name]
        if i not in parents: return "PELVIS"   # the controls under Kenney's root
        i = parents[i]
bone_index = {name: index for index, (name, _, _) in enumerate(BONES)}

primitive = gltf["meshes"][0]["primitives"][0]
positions = accessor(primitive["attributes"]["POSITION"])
normals = accessor(primitive["attributes"]["NORMAL"])
uvs = accessor(primitive["attributes"]["TEXCOORD_0"])
vertex_joints = accessor(primitive["attributes"]["JOINTS_0"])
vertex_weights = accessor(primitive["attributes"]["WEIGHTS_0"])
indices = [i[0] for i in accessor(primitive["indices"])]

vertices = []
for p, n, uv, js, ws in zip(positions, normals, uvs, vertex_joints, vertex_weights):
    # The bind pose: each joint's skin matrix, weighted.
    total = sum(ws) or 1.0
    bound = [0.0, 0.0, 0.0]; bound_normal = [0.0, 0.0, 0.0]; by_bone = {}
    for j, w in zip(js, ws):
        if w <= 0: continue
        q = transform(skin_matrices[j], p); nq = transform(skin_matrices[j], n, 0.0)
        for i in range(3): bound[i] += q[i] * w / total; bound_normal[i] += nq[i] * w / total
        bone = bone_for(joint_names[j]); by_bone[bone] = by_bone.get(bone, 0.0) + w
    ranked = sorted(by_bone.items(), key=lambda pair: (-pair[1], bone_index[pair[0]]))
    primary = ranked[0][0]
    blend = ranked[1] if len(ranked) > 1 and ranked[1][1] > 0.001 else None
    weight = blend[1] / (ranked[0][1] + blend[1]) if blend else 0.0
    vertices.append({"world": [c * scale for c in bound], "normal": normalize(bound_normal), "uv": uv,
                     "bone": primary, "blend": blend[0] if blend else None, "weight": weight})

def local(bone, point, direction=False):
    position, rotation = placed[bone]
    inverse = quat_inverse(rotation)
    return quat_rotate(inverse, point if direction else [point[i] - position[i] for i in range(3)])

def mesh_file(faces):
    """A Vitaboy mesh (version 2) of the faces' vertices: grouped by bone, each in its bone's space,
    with a blend vertex for its second bone."""
    used = sorted({v for face in faces for v in face}, key=lambda v: (bone_index[vertices[v]["bone"]], v))
    bones = sorted({vertices[v]["bone"] for v in used} | {vertices[v]["blend"] for v in used if vertices[v]["blend"]},
                   key=lambda name: bone_index[name])
    order = {v: i for i, v in enumerate(used)}
    blends = sorted((v for v in used if vertices[v]["blend"]), key=lambda v: (bone_index[vertices[v]["blend"]], order[v]))
    out = struct.pack(">i", 2) + struct.pack(">i", len(bones)) + b"".join(pascal(b) for b in bones)
    out += struct.pack(">i", len(faces)) + b"".join(struct.pack(">3i", *(order[v] for v in face)) for face in faces)
    out += struct.pack(">i", len(bones))
    for b in bones:
        real = [i for i, v in enumerate(used) if vertices[v]["bone"] == b]
        blend = [i for i, v in enumerate(blends) if vertices[v]["blend"] == b]
        out += struct.pack(">5i", bones.index(b), real[0] if real else 0, len(real), blend[0] if blend else 0, len(blend))
    out += struct.pack(">i", len(used)) + b"".join(floats(*vertices[v]["uv"]) for v in used)
    out += struct.pack(">i", len(blends))
    out += b"".join(struct.pack(">2i", round(vertices[v]["weight"] * 0x8000), order[v]) for v in blends)
    out += struct.pack(">i", len(used) + len(blends))
    for v in used:
        p = local(vertices[v]["bone"], vertices[v]["world"]); n = local(vertices[v]["bone"], vertices[v]["normal"], True)
        out += floats(-p[0], p[1], p[2], -n[0], n[1], n[2])
    for v in blends:
        p = local(vertices[v]["blend"], vertices[v]["world"]); n = local(vertices[v]["blend"], vertices[v]["normal"], True)
        out += floats(-p[0], p[1], p[2], -n[0], n[1], n[2])
    return out

faces = [indices[i:i + 3] for i in range(0, len(indices), 3)]
head_faces = [f for f in faces if all(vertices[v]["bone"] == "HEAD" for v in f)]
body_faces = [f for f in faces if not all(vertices[v]["bone"] == "HEAD" for v in f)]

# --- Files
def far3(entries):
    """A FAR 3 archive of (name, type ID, file ID, data), uncompressed."""
    body = b"".join(e[3] for e in entries)
    out = bytearray(b"FAR!byAZ" + struct.pack("<II", 3, 16 + len(body)) + body)
    out += struct.pack("<I", len(entries))
    offset = 16
    for name, type_id, file_id, contents in entries:
        raw = name.encode("ascii")
        out += struct.pack("<I", len(contents)) + len(contents).to_bytes(3, "little") + b"\0"
        out += struct.pack("<IBBH", offset, 0, 0, len(raw)) + struct.pack("<II", type_id, file_id) + raw
        offset += len(contents)
    return bytes(out)

def write(relative, entries):
    path = os.path.join(root, "avatardata", relative)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "wb").write(far3(entries))

def binding(bone, mesh_id, texture_id):
    return struct.pack(">I", 1) + pascal(bone) + struct.pack(">4I", 8, 0, mesh_id, MESH) + struct.pack(">4I", 8, 0, texture_id, TEXTURE)

def appearance(bindings):
    return struct.pack(">4I", 1, 0, 0, len(bindings)) + b"".join(struct.pack(">2I", b, BINDING) for b in bindings)

def outfit(apr, handgroup, region):
    return struct.pack(">2I", 1, 1) + struct.pack(">2I", apr, APPEARANCE) * 3 + struct.pack(">2I", handgroup, region)

def jpeg(png):
    with tempfile.TemporaryDirectory() as folder:
        out = os.path.join(folder, "skin.jpg")
        subprocess.run(["magick", png, "-strip", "-quality", "90", out], check=True)
        return open(out, "rb").read()

write("skeletons/skeletons.dat", [("adult.skel", SKELETON, 1, skel)])
skins = {"female": "humanFemaleA.png", "male": "humanMaleA.png"}
for part, mesh_id, faces_of in [("bodies", MESH_BODY, body_faces), ("heads", MESH_HEAD, head_faces)]:
    kind = "body" if part == "bodies" else "head"
    write(f"{part}/meshes/meshes.dat", [(f"mock-{kind}.mesh", MESH, mesh_id, mesh_file(faces_of))])
    write(f"{part}/textures/textures.dat",
          [(f"mock-{kind}-{skin}.jpg", TEXTURE, TEX[skin] + (0 if part == "bodies" else 0x10), jpeg(os.path.join(data, "Skins", file)))
           for skin, file in skins.items()])
    bone = "PELVIS" if kind == "body" else "HEAD"
    write(f"{part}/bindings/bindings.dat",
          [(f"mock-{kind}-{skin}.bnd", BINDING, BND[(kind, skin)], binding(bone, mesh_id, TEX[skin] + (0 if part == "bodies" else 0x10)))
           for skin in skins])
    write(f"{part}/appearances/appearances.dat",
          [(f"mock-{kind}-{skin}.apr", APPEARANCE, APR[(kind, skin)], appearance([BND[(kind, skin)]])) for skin in skins])
    write(f"{part}/outfits/outfits.dat",
          [(f"mock-{kind}-{skin}.oft", OUTFIT, OFT[(kind, skin)],
            outfit(APR[(kind, skin)], HAG if kind == "body" else 0, REGION_BODY if kind == "body" else REGION_HEAD))
           for skin in skins])

# Hands: every gesture of every tone is an appearance with nothing in it.
write("hands/appearances/appearances.dat", [("mock-no-hands.apr", APPEARANCE, APR_NO_HANDS, appearance([]))])
write("hands/groups/groups.dat", [("mock-hands.hag", HANDGROUP, HAG, struct.pack(">I", 1) + struct.pack(">2I", APR_NO_HANDS, APPEARANCE) * 18)])

# --- Placeholder animations: a stand, and legs swinging for the walks. Each keyframe is a bone's
# local rotation (its rest rotation turned about its own x), 30 frames a second.
def rest_local(name):
    parent = next(p for n, p, _ in BONES if n == name)
    return quat_mul(quat_inverse(placed[parent][1]), placed[name][1])

def turned(q, degrees):
    half = math.radians(degrees) / 2
    return quat_mul(q, [math.sin(half), 0, 0, math.cos(half)])

def animation(name, seconds, swings, moving, distance):
    frames = max(1, round(seconds * 30))
    rotations, motions = [], []
    for bone, (amplitude, phase) in swings.items():
        first = len(rotations)
        for f in range(frames):
            rotations.append(turned(rest_local(bone), amplitude * math.sin(2 * math.pi * f / frames + phase)))
        motions.append((bone, frames, first))
    out = struct.pack(">I", 2) + struct.pack(">h", len(name)) + name.encode("ascii")
    out += floats(seconds * 1000, distance) + bytes([1 if moving else 0])
    out += struct.pack(">I", 0)                                    # no translations
    out += struct.pack(">I", len(rotations)) + b"".join(floats(q[0], -q[1], -q[2], -q[3]) for q in rotations)
    out += struct.pack(">I", len(motions))
    for bone, count, first in motions:
        out += struct.pack(">I", 0) + pascal(bone) + struct.pack(">I", count) + floats(seconds * 1000)
        out += bytes([0, 1]) + struct.pack(">2I", 0, first) + bytes([0, 0])
    return out

legs = lambda degrees: {"R_LEG": (degrees, 0.0), "L_LEG": (degrees, math.pi), "R_ARM1": (degrees / 2, math.pi), "L_ARM1": (degrees / 2, 0.0)}
animations = [("mock-stand", 1.0, {"PELVIS": (0, 0)}, False, 0.0),
              ("mock-walk", 1.0, legs(25), True, 2.0),
              ("mock-walk-fast", 0.6, legs(35), True, 2.0),
              ("mock-swim", 1.5, {"R_ARM1": (40, 0.0), "L_ARM1": (40, math.pi)}, True, 1.0)]
write("animations/animations.dat",
      [(f"{name}.anim", ANIMATION, 0x4D4F0701 + i, animation(name, seconds, swings, moving, distance))
       for i, (name, seconds, swings, moving, distance) in enumerate(animations)])

# --- The mock Sim's body strings: the female body and head, by outfit ID (file, then type).
far_path = os.path.join(root, "objectdata/objects/objiff.far")
b = open(far_path, "rb").read()
assert b[:8] == b"FAR!byAZ"
version, manifest = struct.unpack_from("<II", b, 8)
count, = struct.unpack_from("<I", b, manifest)
p, entries = manifest + 4, []
for _ in range(count):
    size1, size2, offset, name_length = struct.unpack_from("<iiih", b, p)
    entries.append([b[p + 14:p + 14 + name_length], b[offset:offset + size1]])
    p += 14 + name_length

def outfit_string(file_id):
    return "0x%X%08X" % (file_id, OUTFIT)

for entry in entries:
    if entry[0] != b"mocksim.iff": continue
    iff = entry[1]; q, out = 64, bytearray(iff[:64])
    while q + 76 <= len(iff):
        size, = struct.unpack_from(">I", iff, q + 4)
        chunk = iff[q:q + size]
        if chunk[:4] == b"STR#" and struct.unpack_from(">H", chunk, 8)[0] == 200:
            fmt, strings_count = struct.unpack_from("<hH", chunk, 76)
            assert fmt == -2
            strings, r = [], 80
            for _ in range(strings_count):
                end = chunk.index(b"\0", r); text = chunk[r:end].decode("ascii"); r = chunk.index(b"\0", end + 1) + 1
                strings.append(text)
            strings[1] = outfit_string(OFT[("body", "female")])
            strings[2] = outfit_string(OFT[("head", "female")])
            contents = struct.pack("<hH", -2, len(strings)) + b"".join(t.encode("ascii") + b"\0\0" for t in strings)
            chunk = chunk[:4] + struct.pack(">I", 76 + len(contents)) + chunk[8:76] + contents
        out += chunk; q += size
    entry[1] = bytes(out)
    break
else:
    sys.exit("no mocksim.iff")

body = b"".join(e[1] for e in entries)
out = bytearray(b"FAR!byAZ" + struct.pack("<II", version, 16 + len(body)) + body)
out += struct.pack("<I", len(entries))
offset = 16
for name, contents in entries:
    out += struct.pack("<iiih", len(contents), len(contents), offset, len(name)) + name
    offset += len(contents)
open(far_path, "wb").write(out)

print(f"adult.skel {len(BONES)} bones at scale {scale:.3f}; body {len(body_faces)} faces, head {len(head_faces)}; "
      f"{len(animations)} animations; body strings name outfits {outfit_string(OFT[('body', 'female')])} "
      f"and {outfit_string(OFT[('head', 'female')])}")
