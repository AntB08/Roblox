#!/usr/bin/env python3
"""Generates the high-detail monster meshes for "The Tenant" (original design).

    lune run lune/export-rig-spec          # writes build/rig_spec.json from MonsterRig.SPEC
    python3 tools/build_monster_mesh.py    # writes the files below

Outputs:
  assets/meshes/TheTenant.glb                one file to import with Studio's 3D Importer: one mesh per
                                             body part, named M_<PartName>, with flesh / bone / claw textures
  assets/meshes/textures/*.png               the textures (also embedded in the .glb)
  src/server/Config/MonsterMeshes.luau       per part: where the mesh's bounding box sits inside the part
                                             and its size, so the game can place each imported MeshPart
                                             exactly on the rig no matter how the importer recentres or
                                             scales it

Every mesh is built in its rig part's local space (same origin as the part, Y = the limb's long axis,
-Z = forward), sized from the rig spec so it fits the skeleton, with rounded overlapping ends so the
joints hide their seams. Shapes: striated muscle-fibre tubes for limbs and neck, a ribbed barrel chest,
a hunched shoulder hump, a long skull with deep sockets, cheekbones and brow, a hanging jaw, blade-
tipped fingers, tapering tendrils and wriggling mouth feelers. ~25k triangles in total.
"""
import json
import math
import pathlib
import sys

import numpy as np
from PIL import Image, ImageFilter
import trimesh

ROOT = pathlib.Path(__file__).resolve().parent.parent
SPEC_PATH = ROOT / "build" / "rig_spec.json"
OUT_DIR = ROOT / "assets" / "meshes"
TEX_DIR = OUT_DIR / "textures"
LUAU_OUT = ROOT / "src" / "server" / "Config" / "MonsterMeshes.luau"

rng = np.random.default_rng(7)


# ===== noise helpers ==================================================================================
def gauss(x, mu, sigma):
    return np.exp(-((x - mu) ** 2) / (2 * sigma * sigma))


def ang_dist(a, b):
    d = np.abs((a - b + np.pi) % (2 * np.pi) - np.pi)
    return d


# ===== generic sweep (tube along +Y, centred on the origin) =============================================
def sweep(length, radius_x, radius_z, profile, n_around=16, n_rings=14, detail=None, point_bottom=False,
          point_top=False, flatten=1.0):
    """profile(t) -> radius multiplier at height t (0 = bottom, 1 = top).
    detail(t, theta, r) -> radial offset (studs). Ends are domed (or pointed)."""
    verts, uvs = [], []
    ts = np.linspace(0, 1, n_rings)
    thetas = np.linspace(0, 2 * np.pi, n_around, endpoint=False)
    for t in ts:
        # rounded caps: radius goes to 0 at the very ends
        edge = min(t, 1 - t)
        cap = 1.0
        if not (point_bottom and t < 0.5) and not (point_top and t > 0.5):
            cap = math.sqrt(max(0.0, 1 - max(0.0, (0.08 - edge) / 0.08) ** 2)) if edge < 0.08 else 1.0
        else:
            cap = (edge / 0.5) ** 0.85  # long point
        m = profile(t) * cap
        y = (t - 0.5) * length
        for th in thetas:
            r = m
            off = detail(t, th, m) if detail else 0.0
            x = (radius_x * r + off * cap) * math.cos(th)
            z = (radius_z * r * flatten + off * cap) * math.sin(th)
            verts.append((x, y, z))
            uvs.append((th / (2 * math.pi), y / 2.0))
    faces = []
    for i in range(n_rings - 1):
        for j in range(n_around):
            a = i * n_around + j
            b = i * n_around + (j + 1) % n_around
            c = (i + 1) * n_around + (j + 1) % n_around
            d = (i + 1) * n_around + j
            faces.append((a, c, b))
            faces.append((a, d, c))
    # close the ends with a centre vertex
    bottom = len(verts)
    verts.append((0, -length / 2, 0))
    uvs.append((0.5, -length / 4))
    top = len(verts)
    verts.append((0, length / 2, 0))
    uvs.append((0.5, length / 4))
    for j in range(n_around):
        faces.append((bottom, j, (j + 1) % n_around))
        last = (n_rings - 1) * n_around
        faces.append((top, last + (j + 1) % n_around, last + j))
    return np.array(verts, float), np.array(faces, int), np.array(uvs, float)


def blob(size, deform=None, n_lon=28, n_lat=20):
    """Ellipsoid of `size` (full extents), optionally deformed: deform(dir, pos) -> new pos."""
    rx, ry, rz = size[0] / 2, size[1] / 2, size[2] / 2
    verts, uvs = [], []
    for i in range(n_lat + 1):
        phi = math.pi * i / n_lat
        for j in range(n_lon):
            th = 2 * math.pi * j / n_lon
            n = np.array([math.sin(phi) * math.cos(th), math.cos(phi), math.sin(phi) * math.sin(th)])
            p = n * np.array([rx, ry, rz])
            if deform:
                p = deform(n, p)
            verts.append(p)
            uvs.append((j / n_lon, i / n_lat))
    faces = []
    for i in range(n_lat):
        for j in range(n_lon):
            a = i * n_lon + j
            b = i * n_lon + (j + 1) % n_lon
            c = (i + 1) * n_lon + (j + 1) % n_lon
            d = (i + 1) * n_lon + j
            if i > 0:
                faces.append((a, b, c))
            if i < n_lat - 1:
                faces.append((a, c, d))
    return np.array(verts, float), np.array(faces, int), np.array(uvs, float)


def fibres(strength, count=7, twist=0.35):
    """Muscle-fibre striations: shallow grooves running along the limb."""
    phase = rng.uniform(0, 6.28)

    def f(t, th, r):
        g = math.sin(count * th + twist * t * 6.28 + phase)
        g2 = math.sin((count * 2 + 1) * th - twist * t * 9 + phase * 1.7)
        return strength * r * (0.6 * g + 0.4 * g2) * (0.3 + 0.7 * math.sin(math.pi * t))

    return f


def rotate_to_axis(verts, axis):
    """Sweeps are built along Y; turn them to run along X or Z."""
    v = verts.copy()
    if axis == "x":
        v = v[:, [1, 0, 2]] * np.array([1, -1, 1])
    elif axis == "z":
        v = v[:, [0, 2, 1]] * np.array([1, 1, -1])
    return v


# ===== per-part shapes ===================================================================================
def limb(size, kind):
    L = size[1] + 0.35  # overlap the neighbours so elbows / knees / waist show no gaps
    rx, rz = size[0] / 2, size[2] / 2
    if kind == "upper":  # bicep / thigh bulge in the upper half, sinewy below
        prof = lambda t: 0.62 + 0.42 * gauss(t, 0.68, 0.2) + 0.08 * gauss(t, 0.15, 0.1)
        det = fibres(0.09, 7, 0.4)
    elif kind == "lower":  # forearm / calf: bulge high, long tendon taper to the wrist / ankle
        prof = lambda t: 0.5 + 0.5 * gauss(t, 0.74, 0.17)
        det = fibres(0.11, 6, 0.6)
    elif kind == "neck":  # stringy, corded
        prof = lambda t: 0.9 + 0.08 * math.sin(t * 6.28)
        det = fibres(0.16, 5, 0.9)
    elif kind == "waist":  # pinched, fibrous
        prof = lambda t: 0.82 + 0.2 * (2 * t - 1) ** 2
        det = fibres(0.14, 9, 0.2)
    else:
        prof = lambda t: 1.0
        det = fibres(0.06)
    return sweep(L, rx, rz, prof, 16, 14, det)


def finger(size, last):
    L = size[1]
    r = size[0] / 2
    prof = (lambda t: 0.55 + 0.45 * t) if last else (lambda t: 0.85 + 0.15 * math.sin(t * 3.14))
    det = fibres(0.06, 4, 0.2)
    # last segment: long flattened blade ending in a point
    return sweep(L * (1.35 if last else 1.0), r * (1.1 if last else 1), r, prof, 8, 7, det,
                 point_bottom=last, flatten=0.55 if last else 1)


def tendril(size, index, count):
    L = size[1]
    r = size[0] / 2
    tip = index == count
    prof = lambda t: 0.75 + 0.25 * t
    return sweep(L, r, r, prof, 9, 8, fibres(0.12, 4, 0.8), point_top=tip)


def feeler(size, second):
    L = size[1]
    r = size[0] / 2
    prof = (lambda t: 0.6 + 0.4 * t) if second else (lambda t: 0.9 + 0.1 * t)
    return sweep(L * (1.15 if second else 1), r, r * 0.85, prof, 8, 7, fibres(0.1, 3, 0.5), point_bottom=second)


def chest(size):
    rx, ry, rz = size[0] / 2, size[1] / 2, size[2] / 2

    def deform(n, p):
        x, y, z = p
        th = math.atan2(n[2], n[0])
        front = max(0.0, -n[2])  # -Z is the front
        side = abs(n[0])
        t = (n[1] + 1) / 2
        # ribs: sharp ridges with deep gaps, strongest on the front and flanks
        rib = max(0.0, math.sin(t * math.pi * 11)) ** 3
        bump = 0.07 * rib * (0.4 + 0.6 * max(front, side)) * (1 - abs(n[1]) ** 3)
        # sternum groove down the middle of the front
        groove = -0.08 * front * gauss(ang_dist(th, -math.pi / 2), 0, 0.12)
        # sunken belly at the bottom front (the waist pinches in)
        belly = -0.12 * front * gauss(t, 0.05, 0.14)
        # spine ridge on the back
        spine = 0.06 * max(0.0, n[2]) * gauss(ang_dist(th, math.pi / 2), 0, 0.1)
        k = 1 + (bump + groove + belly + spine) / max(0.2, math.sqrt((x / rx) ** 2 + (z / rz) ** 2) * min(rx, rz))
        return np.array([x * k, y, z * k])

    return blob(size, deform, 32, 24)


def hump(size):
    """Upper chest / shoulders: a hunched mass with two trapezius peaks rising beside the skull."""

    def deform(n, p):
        x, y, z = p
        peaks = 0.32 * gauss(abs(n[0]), 0.55, 0.22) * max(0.0, n[1]) * (1 - max(0.0, -n[2]) * 0.6)
        back = 0.1 * max(0.0, n[2]) * max(0.0, n[1])
        notch = -0.18 * gauss(n[0], 0, 0.25) * max(0.0, -n[2]) * max(0.0, n[1])  # hollow where the skull sits
        return p + n * np.array([0.6, 1, 0.6]) * (peaks + back + notch)

    return blob(size, deform, 30, 18)


def pelvis(size):
    def deform(n, p):
        hip = 0.1 * gauss(abs(n[0]), 0.8, 0.15) * max(0.0, n[1] + 0.2)  # hip bones
        return p + n * hip

    return blob(size, deform, 22, 14)


def skull(size):
    """Long skull: deep sockets, brow, cheekbones, nasal cavity, cranium bulge. -Z is the face."""
    rx, ry, rz = size[0] / 2, size[1] / 2, size[2] / 2
    eyes = [np.array([sx * 0.18 / rx, 0.08 / ry, -0.8]) for sx in (-1, 1)]
    eyes = [e / np.linalg.norm(e) for e in eyes]
    nose = np.array([0, -0.18 / ry, -1.0])
    nose /= np.linalg.norm(nose)

    def deform(n, p):
        d = 0.0
        for e in eyes:
            a = math.acos(max(-1, min(1, float(np.dot(n, e)))))
            d -= 0.17 * gauss(a, 0, 0.15)  # deep socket
            d += 0.05 * gauss(a, 0.3, 0.06)  # bony rim
        a = math.acos(max(-1, min(1, float(np.dot(n, nose)))))
        d -= 0.1 * gauss(a, 0, 0.09)  # nasal cavity
        front = max(0.0, -n[2])
        d += 0.07 * front * gauss(n[1], 0.32, 0.08)  # brow ridge
        d += 0.06 * front * gauss(abs(n[0]), 0.55, 0.12) * gauss(n[1], -0.15, 0.12)  # cheekbones
        d -= 0.06 * gauss(abs(n[0]), 0.75, 0.15) * gauss(n[1], -0.3, 0.2)  # temples hollow
        d += 0.12 * max(0.0, n[2]) * max(0.0, n[1])  # cranium bulge at the back
        d -= 0.08 * front * gauss(n[1], -0.6, 0.15)  # tuck under the face (mouth line)
        return p + n * d

    return blob(size, deform, 40, 30)


def jaw(size):
    def deform(n, p):
        chin = 0.06 * max(0.0, -n[2]) * max(0.0, -n[1])
        hollow = -0.05 * max(0.0, n[1])  # mouth floor
        return p + n * (chin + hollow)

    return blob(size, deform, 24, 14)


def hand(size):
    def deform(n, p):
        knuckles = 0.035 * max(0.0, -n[1]) * (0.5 + 0.5 * math.cos(n[0] * 14))
        tendons = 0.02 * max(0.0, -n[2]) * math.cos(n[0] * 18)
        return p + n * (knuckles + tendons)

    return blob(size, deform, 20, 14)


def foot(size, toes=False):
    def deform(n, p):
        if toes:
            ridge = 0.04 * max(0.0, n[1]) * (0.5 + 0.5 * math.cos(n[0] * 16))
            return p + n * ridge
        ankle = 0.05 * gauss(n[2], 0.6, 0.25) * max(0.0, n[1])
        return p + n * ankle

    return blob(size, deform, 20, 12)


def flap(size):
    """Torn skin flap: flat strip with a ragged edge."""
    L = size[1]
    prof = lambda t: 0.8 + 0.25 * math.sin(t * 17) * (1 - t)
    return sweep(L, size[0] / 2, max(size[2], 0.04) / 2, prof, 8, 8, None)


def tongue(size, second):
    L = size[2]
    prof = (lambda t: 0.55 + 0.45 * t) if second else (lambda t: 0.9 + 0.1 * t)
    v, f, uv = sweep(L, size[0] / 2, size[1] / 2, prof, 10, 9, fibres(0.04), point_bottom=second, flatten=1)
    # sweep runs along Y; the tongue runs along Z (tip toward -Z)
    return rotate_to_axis(v, "z"), f, uv


def clavicle(size):
    L = size[0]
    v, f, uv = sweep(L, size[1] / 2, size[2] / 2, lambda t: 0.8 + 0.25 * gauss(t, 0.15, 0.15) + 0.25 * gauss(t, 0.85, 0.15),
                     12, 10, fibres(0.05, 5))
    return rotate_to_axis(v, "x"), f, uv


def build_part(name, size):
    if name in ("UpperChest",):
        return hump(size), "flesh"
    if name == "Chest":
        return chest(size), "flesh"
    if name == "Pelvis":
        return pelvis(size), "flesh"
    if name in ("Abdomen", "Waist"):
        return limb(size, "waist"), "flesh"
    if name.startswith("Neck"):
        return limb(size, "neck"), "flesh"
    if name == "Head":
        return skull(size), "bone"
    if name == "Jaw":
        return jaw(size), "bone"
    if name.startswith("Tongue"):
        return tongue(size, name.endswith("2")), "flesh"
    if name.endswith("Lid"):
        return blob(size, None, 12, 8), "flesh"
    if name.startswith("Feeler"):
        return feeler(size, name.endswith("_2")), "claw" if name.endswith("_2") else "flesh"
    if name.startswith("Rag"):
        return flap(size), "flesh"
    if name.endswith("Clavicle"):
        return clavicle(size), "flesh"
    if name.endswith("UpperArm") or name.endswith("UpperLeg"):
        return limb(size, "upper"), "flesh"
    if name.endswith("LowerArm") or name.endswith("LowerLeg"):
        return limb(size, "lower"), "flesh"
    if name.endswith("Hand"):
        return hand(size), "flesh"
    if "Finger" in name or "Thumb" in name:
        last = name.endswith("_3") or name.endswith("Thumb_2")
        return finger(size, last), "claw" if last else "flesh"
    if name.endswith("Toes"):
        return foot(size, True), "flesh"
    if name.endswith("Foot"):
        return foot(size), "flesh"
    if name.startswith("Tendril"):
        idx = int(name.split("_")[1])
        return tendril(size, idx, 5), "flesh"
    return blob(size, None, 12, 8), "flesh"


# ===== textures ===========================================================================================
def make_texture(kind, size=512):
    h = w = size
    yy, xx = np.mgrid[0:h, 0:w] / size

    def fnoise(fx, fy, octaves=4, seed=0):
        r = np.random.default_rng(seed)
        out = np.zeros((h, w))
        amp = 1.0
        for o in range(octaves):
            nx, ny = int(fx * 2 ** o) + 1, int(fy * 2 ** o) + 1
            grid = r.random((ny + 1, nx + 1))
            grid[:, -1] = grid[:, 0]
            grid[-1, :] = grid[0, :]  # tile seamlessly
            img = Image.fromarray((grid * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
            out += amp * (np.asarray(img) / 255.0 - 0.5)
            amp *= 0.5
        return out

    if kind == "flesh":
        # Long fibres running along V (the limb axis): stretched noise, high frequency across.
        fib = fnoise(48, 3, 3, 1)
        blotch = fnoise(4, 4, 3, 2)
        base = np.stack([0.50, 0.33, 0.24])
        dark = np.stack([0.30, 0.13, 0.10])
        k = np.clip(0.5 + fib * 1.6 + blotch * 0.6, 0, 1)[..., None]
        col = dark + (base - dark) * k
        sinew = np.clip(fnoise(90, 2, 2, 3) * 3, 0, 1)[..., None]  # pale tendon strands
        col = col + sinew * np.stack([0.12, 0.09, 0.07]) * 0.6
    elif kind == "bone":
        stain = fnoise(6, 6, 4, 4)
        crack = np.clip(-fnoise(20, 20, 2, 5) * 4 - 0.6, 0, 1)
        base = np.stack([0.70, 0.60, 0.46])
        col = base[None, None, :] * (0.85 + stain[..., None] * 0.5) - crack[..., None] * 0.25
    else:  # claw: dark, glossy-looking keratin
        n = fnoise(30, 2, 3, 6)
        col = np.stack([0.16, 0.10, 0.08])[None, None, :] * (0.8 + n[..., None] * 0.8)
    img = Image.fromarray((np.clip(col, 0, 1) * 255).astype(np.uint8))
    return img.filter(ImageFilter.SMOOTH)


# ===== main ================================================================================================
def main():
    if not SPEC_PATH.exists():
        sys.exit("build/rig_spec.json missing: run `lune run lune/export-rig-spec` first")
    spec = json.loads(SPEC_PATH.read_text())
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    TEX_DIR.mkdir(parents=True, exist_ok=True)

    textures = {k: make_texture(k) for k in ("flesh", "bone", "claw")}
    materials = {}
    for k, img in textures.items():
        img.save(TEX_DIR / f"{k}.png")
        materials[k] = trimesh.visual.material.PBRMaterial(
            name=k, baseColorTexture=img, metallicFactor=0.0, roughnessFactor=0.55 if k == "claw" else 0.8
        )

    scene = trimesh.Scene()
    info = {}
    tris = 0
    for part in spec["parts"]:
        name, size = part["name"], part["size"]
        (verts, faces, uvs), mat = build_part(name, size)
        mesh = trimesh.Trimesh(vertices=verts, faces=faces, process=False)
        mesh.fix_normals()  # consistent outward winding (vertices are shared, so shading is smooth)
        mesh.visual = trimesh.visual.TextureVisuals(uv=uvs, material=materials[mat])
        lo, hi = mesh.bounds
        info[name] = {"center": ((lo + hi) / 2).tolist(), "size": (hi - lo).tolist()}
        tris += len(mesh.faces)
        scene.add_geometry(mesh, node_name=f"M_{name}", geom_name=f"M_{name}")
    scene.export(OUT_DIR / "TheTenant.glb")

    lines = [
        "--!strict",
        "-- GENERATED by tools/build_monster_mesh.py. Do not edit by hand.",
        "-- For each rig part: where its imported mesh's bounding box sits in the part's local space",
        "-- (center) and the box's size. MonsterRig uses this to place the MeshParts from",
        "-- ServerStorage.TenantMeshes exactly on the rig, whatever the importer did to them.",
        "",
        "export type MeshInfo = { center: Vector3, size: Vector3 }",
        "",
        "local MonsterMeshes: { [string]: MeshInfo } = {",
    ]
    for name, d in info.items():
        c, s = d["center"], d["size"]
        lines.append(
            f"\t{name} = {{ center = Vector3.new({c[0]:.4f}, {c[1]:.4f}, {c[2]:.4f}), "
            f"size = Vector3.new({s[0]:.4f}, {s[1]:.4f}, {s[2]:.4f}) }},"
        )
    lines += ["}", "", "return table.freeze(MonsterMeshes)", ""]
    LUAU_OUT.write_text("\n".join(lines))
    print(f"wrote {OUT_DIR / 'TheTenant.glb'} ({len(info)} meshes, {tris} triangles) and {LUAU_OUT}")


if __name__ == "__main__":
    main()
