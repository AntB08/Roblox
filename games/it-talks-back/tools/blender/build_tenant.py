"""Builds "The Tenant" (original design) as a realistic creature model in Blender, from code.

    blender -b -P tools/blender/build_tenant.py -- <out_dir>

Techniques (no primitive "ovals" glued together):
  * Skin modifier on a vertex skeleton -> one continuous body (torso, neck, arms, hands, fingers, legs,
    feet), Subdivision Surface for organic form.
  * Head sculpted by vertex deformation from a dense sphere: long skull, deep eye sockets with bony
    rims, cheekbones, hollow temples, a protruding muzzle. A BOOLEAN cut tears the mouth open wide.
  * Voxel REMESH fuses head and body into one watertight surface; then procedural sculpt passes push
    out ribs, sternum, collarbones, spine, shoulder blades, bony knees / elbows, a sunken belly, and
    wrinkle / sinew displacement (Voronoi + Clouds textures).
  * The torn mouth is painted on the body itself (throat inside the pocket, wet gums at the rim);
    curved, uneven fangs are rooted on the real mouth wall by RAYCASTING; a long tongue (tapered
    Bezier curve); small milky eyeballs deep in the sockets.
  * Skin shader: grey-mauve to raw red with ambient-occlusion grime, subsurface scattering, wet
    roughness variation, pore and wrinkle bump. Eyes milky with a faint glow.
Writes <out_dir>/tenant_hi.blend (for later baking / rigging) and renders: front, face, side, back.
Front of the creature faces -Y, up is +Z, units are Roblox studs.
"""
import bpy
import bmesh
import math
import random
import sys
from mathutils import Vector, Matrix, noise

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = argv[0] if argv else "/tmp/tenant"
RENDER = "--norender" not in argv
SAMPLES = int(next((a.split("=")[1] for a in argv if a.startswith("--samples=")), "96"))
random.seed(11)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene


def gauss(x, s):
    return math.exp(-(x * x) / (2 * s * s))


def apply_all(obj):
    bpy.context.view_layer.objects.active = obj
    for m in list(obj.modifiers):
        bpy.ops.object.modifier_apply(modifier=m.name)


def link(obj):
    bpy.context.collection.objects.link(obj)
    return obj


# ===== 1. Body: skin-modifier skeleton ===================================================================
# (name, position, radius x, radius y, parent)
J = {}
EDGES = []


def jp(name, pos, rx, ry=None, parent=None):
    J[name] = (Vector(pos), rx, ry if ry is not None else rx)
    if parent:
        EDGES.append((parent, name))


jp("pelvis", (0, 0.02, 3.85), 0.46, 0.34)
jp("waist1", (0, 0.06, 4.3), 0.27, 0.22, "pelvis")
jp("waist2", (0, 0.08, 4.72), 0.4, 0.28, "waist1")
jp("chest", (0, 0.08, 5.3), 0.7, 0.48, "waist2")
jp("upper", (0, 0.04, 5.82), 0.8, 0.44, "chest")
jp("neck1", (0, -0.1, 6.2), 0.25, 0.25, "upper")
jp("neck2", (0, -0.36, 6.5), 0.2, 0.2, "neck1")
jp("neck3", (0, -0.58, 6.66), 0.19, 0.19, "neck2")

ARMS = {  # the right arm is longer
    -1: dict(elbow=(-1.12, 0.18, 4.6), wrist=(-1.2, -0.08, 3.25)),
    1: dict(elbow=(1.18, 0.24, 4.38), wrist=(1.3, -0.12, 2.75)),
}
for s, a in ARMS.items():
    n = "L" if s < 0 else "R"
    jp(f"shoulder{n}", (0.92 * s, 0.06, 5.92), 0.25, 0.22, "upper")
    jp(f"bicep{n}", tuple((Vector((0.92 * s, 0.06, 5.92)) + Vector(a["elbow"])) / 2), 0.17, 0.16, f"shoulder{n}")
    jp(f"elbow{n}", a["elbow"], 0.13, 0.13, f"bicep{n}")
    fore = (Vector(a["elbow"]) * 0.7 + Vector(a["wrist"]) * 0.3)
    jp(f"fore{n}", tuple(fore), 0.14, 0.13, f"elbow{n}")
    jp(f"wrist{n}", a["wrist"], 0.08, 0.07, f"fore{n}")
    hand = Vector(a["wrist"]) + Vector((0.02 * s, -0.04, -0.32))
    jp(f"hand{n}", tuple(hand), 0.15, 0.06, f"wrist{n}")
    scale = 1.25 if s > 0 else 1.0
    for f in range(4):
        dx = (-0.11 + f * 0.075) * s
        base = hand + Vector((dx, -0.02, -0.12))
        prev = f"hand{n}"
        lengths = [0.36, 0.32, 0.28] if f in (1, 2) else [0.3, 0.27, 0.24]
        radii = [0.042, 0.034, 0.022]
        cur = base
        for k in range(3):
            cur = cur + Vector((dx * 0.15, -0.04 * k, -lengths[k] * scale))
            name = f"f{n}{f}{k}"
            jp(name, tuple(cur), radii[k], radii[k], prev)
            prev = name
        jp(f"tip{n}{f}", tuple(cur + Vector((0, -0.05, -0.12 * scale))), 0.006, 0.006, prev)  # claw point
    th = hand + Vector((-0.12 * s, -0.12, -0.02))
    jp(f"th{n}0", tuple(th), 0.045, 0.045, f"hand{n}")
    jp(f"th{n}1", tuple(th + Vector((-0.05 * s, -0.12, -0.2))), 0.03, 0.03, f"th{n}0")
    jp(f"th{n}2", tuple(th + Vector((-0.07 * s, -0.17, -0.36))), 0.006, 0.006, f"th{n}1")

for s in (-1, 1):
    n = "L" if s < 0 else "R"
    jp(f"hip{n}", (0.34 * s, 0.02, 3.68), 0.25, 0.24, "pelvis")
    jp(f"thigh{n}", (0.4 * s, -0.05, 2.95), 0.19, 0.18, f"hip{n}")
    jp(f"knee{n}", (0.42 * s, -0.12, 2.2), 0.13, 0.13, f"thigh{n}")
    jp(f"calf{n}", (0.42 * s, 0.02, 1.6), 0.15, 0.13, f"knee{n}")
    jp(f"ankle{n}", (0.4 * s, 0.06, 0.4), 0.07, 0.07, f"calf{n}")
    jp(f"heel{n}", (0.4 * s, 0.12, 0.13), 0.08, 0.07, f"ankle{n}")
    jp(f"ball{n}", (0.42 * s, -0.38, 0.1), 0.11, 0.05, f"ankle{n}")
    for t in range(3):
        jp(f"toe{n}{t}", (0.42 * s + (t - 1) * 0.1, -0.68, 0.06), 0.035, 0.025, f"ball{n}")
        jp(f"toetip{n}{t}", (0.42 * s + (t - 1) * 0.12, -0.85, 0.02), 0.006, 0.006, f"toe{n}{t}")

names = list(J.keys())
index = {n: i for i, n in enumerate(names)}
me = bpy.data.meshes.new("Body")
me.from_pydata([J[n][0] for n in names], [(index[a], index[b]) for a, b in EDGES], [])
body = link(bpy.data.objects.new("Body", me))
skin = body.modifiers.new("Skin", "SKIN")
skin.use_smooth_shade = True
for n, (pos, rx, ry) in J.items():
    sv = me.skin_vertices[0].data[index[n]]
    sv.radius = (rx, ry)
    sv.use_root = n == "pelvis"
sub = body.modifiers.new("Sub", "SUBSURF")
sub.levels = sub.render_levels = 2
apply_all(body)

# ===== 2. Head: sculpted skull with a torn-open mouth ======================================================
HEAD_C = Vector((0, -0.86, 6.92))
HR = Vector((0.42, 0.56, 0.5))  # half extents: narrow, long front-to-back
bpy.ops.mesh.primitive_uv_sphere_add(segments=96, ring_count=64, radius=1, location=(0, 0, 0))
head = bpy.context.active_object
head.name = "Head"
EYES = [Vector((0.17 * s, -0.5, 0.08)).normalized() for s in (-1, 1)]
for v in head.data.vertices:
    n = v.co.normalized()
    p = Vector((n.x * HR.x, n.y * HR.y, n.z * HR.z))
    d = 0.0
    for e in EYES:
        a = n.angle(e)
        d -= 0.16 * gauss(a, 0.16)  # deep sockets
        d += 0.025 * gauss(a - 0.27, 0.05)  # bony rims
    front = max(0.0, -n.y)
    d += 0.05 * front * gauss(n.z - 0.3, 0.07) * gauss(abs(n.x) - 0.28, 0.2)  # brow ridge
    d += 0.06 * front * gauss(abs(n.x) - 0.6, 0.12) * gauss(n.z + 0.15, 0.12)  # cheekbones
    d -= 0.05 * gauss(abs(n.x) - 0.85, 0.12) * gauss(n.z - 0.15, 0.25)  # hollow temples
    d += 0.08 * max(0.0, n.y) * max(0.0, n.z)  # big cranium at the back
    p += n * d
    # muzzle: the lower front pulls down and forward (long jaw for a huge mouth)
    if n.z < 0.05 and n.y < 0.2:
        k = min(1.0, (0.05 - n.z) / 0.8) * min(1.0, (0.2 - n.y) / 0.8)
        p += Vector((0, -0.14 * k, -0.32 * k))
        p.x *= 1.0 - 0.25 * k  # narrower jaw
    v.co = p
head.location = HEAD_C
bpy.ops.object.transform_apply(location=True)

# Mouth: a boolean cut tears the face open from cheek to cheek.
CUT_C = Vector((0, -1.33, 6.6))
CUT_S = Vector((0.3, 0.42, 0.34))
CUT_R = Matrix.Rotation(math.radians(-18), 3, "X")
bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=32, radius=1, location=CUT_C)
cutter = bpy.context.active_object
cutter.scale = CUT_S
cutter.rotation_euler = (math.radians(-18), 0, 0)
bpy.ops.object.transform_apply(scale=True, rotation=True)
bh = head.modifiers.new("Mouth", "BOOLEAN")
bh.operation = "DIFFERENCE"
bh.object = cutter
bh.solver = "EXACT"
apply_all(head)
cutter.hide_render = True
cutter.hide_viewport = True

# ===== 3. Fuse + sculpt passes ===========================================================================
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
head.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.object.join()
rm = body.modifiers.new("Remesh", "REMESH")
rm.mode = "VOXEL"
rm.voxel_size = 0.028
rm.use_smooth_shade = True
apply_all(body)
sm = body.modifiers.new("Smooth", "LAPLACIANSMOOTH")
sm.lambda_factor = 0.4
sm.iterations = 2
apply_all(body)

bm = bmesh.new()
bm.from_mesh(body.data)
bm.normal_update()
for v in bm.verts:
    p = v.co
    nrm = v.normal
    d = 0.0
    # ribs: ridges with deep gaps over the chest front and flanks
    if 4.55 < p.z < 5.95 and abs(p.x) < 0.78:
        t = (p.z - 4.55) / 1.4
        front = max(0.0, -nrm.y) + 0.6 * abs(nrm.x)
        ribwave = math.sin(t * math.pi * 2 * 5.2 + abs(p.x) * 4.2)  # ribs sweep down toward the sides
        d += 0.032 * front * (max(0.0, ribwave) ** 2 - 0.45 * max(0.0, -ribwave)) * math.sin(math.pi * t)
        d -= 0.045 * max(0.0, -nrm.y) * gauss(p.x, 0.05) * math.sin(math.pi * t)  # sternum groove
    # sunken belly under the ribs
    if 4.0 < p.z < 4.65:
        d -= 0.05 * max(0.0, -nrm.y) * gauss(p.z - 4.35, 0.15)
    # collarbones
    if 5.75 < p.z < 6.05 and 0.08 < abs(p.x) < 0.9 and nrm.y < 0:
        d += 0.035 * gauss(p.z - (5.95 - abs(p.x) * 0.08), 0.03)
    # spine ridge and shoulder blades on the back
    if 4.0 < p.z < 6.2 and nrm.y > 0.2:
        d += 0.05 * gauss(p.x, 0.045) * (0.5 + 0.5 * math.sin(p.z * 22))
        for sx in (-0.42, 0.42):
            d += 0.04 * gauss(p.x - sx, 0.14) * gauss(p.z - 5.55, 0.22)
    # bony knees / elbows / knuckles
    for key in ("kneeL", "kneeR", "elbowL", "elbowR"):
        c = J[key][0]
        dist = (p - c).length
        d += 0.035 * gauss(dist, 0.09) * max(0.0, -nrm.y if "knee" in key else nrm.y)
    # sinew: long vertical striations on limbs and neck
    if p.z < 3.6 or abs(p.x) > 0.85 or 6.05 < p.z < 6.75:
        d += 0.006 * math.sin(math.atan2(nrm.x, nrm.y) * 9 + p.z * 1.7)
    v.co = p + nrm * d
bm.to_mesh(body.data)
bm.free()

# wrinkles and pores
tex1 = bpy.data.textures.new("Wrinkles", "VORONOI")
tex1.noise_scale = 0.09
tex1.distance_metric = "DISTANCE"
dm = body.modifiers.new("Wrinkles", "DISPLACE")
dm.texture = tex1
dm.strength = -0.012
dm.mid_level = 0.5
tex2 = bpy.data.textures.new("Lumps", "CLOUDS")
tex2.noise_scale = 0.35
dm2 = body.modifiers.new("Lumps", "DISPLACE")
dm2.texture = tex2
dm2.strength = 0.03
apply_all(body)
for poly in body.data.polygons:
    poly.use_smooth = True

# ===== 4. Mouth parts, teeth, tongue, eyes ================================================================
from mathutils.bvhtree import BVHTree


def sphere(name, loc, scale, seg=32, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings, radius=1, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.object.shade_smooth()
    return o


CUT_INV = (CUT_R @ Matrix.Diagonal(CUT_S)).inverted()


def cut_space(p):
    return CUT_INV @ (p - CUT_C)


# Paint the torn mouth on the body mesh itself: throat inside the pocket, wet gums / lips at the rim.
for poly in body.data.polygons:
    q = cut_space(poly.center)
    dist = q.length
    inward = poly.normal.dot((CUT_C - poly.center).normalized()) > 0.2
    if dist < 1.08 and inward:
        poly.material_index = 1  # throat
    elif dist < 1.16:
        poly.material_index = 2  # gums / lips

# Fangs: rooted on the actual mouth wall (raycast), crowded and uneven, pointing across the gap.
bvh = BVHTree.FromObject(body, bpy.context.evaluated_depsgraph_get())
teeth = []
for row, (lo, hi, count, point) in enumerate([(20, 160, 12, -1), (200, 340, 11, 1)]):
    for i in range(count):
        th = math.radians(lo + (hi - lo) * (i + random.uniform(-0.25, 0.25)) / (count - 1))
        # Sweep from the opening inward until the ray meets the mouth wall just inside the lips.
        hit = None
        for deg in range(62, 120, 3):
            phi = math.radians(deg + random.uniform(-2, 2))
            local = Vector((math.sin(phi) * math.cos(th), -math.cos(phi), math.sin(phi) * math.sin(th)))
            target = CUT_C + CUT_R @ Vector((local.x * CUT_S.x, local.y * CUT_S.y, local.z * CUT_S.z))
            hit, nrm, _, _ = bvh.ray_cast(CUT_C, (target - CUT_C).normalized(), 1.5)
            if hit is not None:
                break
        if hit is None:
            continue
        mid = abs(i - (count - 1) / 2) / ((count - 1) / 2)
        length = (0.1 + 0.13 * (1 - mid) + random.uniform(-0.02, 0.05)) * (1.2 if row == 0 else 0.85)
        radius = 0.018 + 0.01 * (1 - mid) + random.uniform(-0.003, 0.003)
        # direction: vertical across the gap, leaning in toward the mouth's axis
        axis = Vector((0, 0, point)) * 0.75 + (CUT_C + Vector((0, -0.25, 0)) - hit).normalized() * 0.35
        axis.normalize()
        bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=radius, radius2=0.001, depth=length, location=(0, 0, 0))
        t = bpy.context.active_object
        t.name = f"Tooth{row}_{i}"
        bend = t.modifiers.new("Bend", "SIMPLE_DEFORM")
        bend.deform_method = "BEND"
        bend.angle = math.radians(random.uniform(12, 30))
        bend.deform_axis = "X"
        apply_all(t)
        # cone axis is +Z: aim it along `axis`, base buried slightly in the gum
        t.rotation_mode = "QUATERNION"
        t.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(axis)
        t.location = hit + axis * (length / 2 - 0.02)
        bpy.ops.object.shade_smooth()
        teeth.append(t)

# tongue: tapered curve lolling out of the mouth
cu = bpy.data.curves.new("TongueCurve", "CURVE")
cu.dimensions = "3D"
cu.bevel_depth = 0.06
cu.bevel_resolution = 6
cu.resolution_u = 24
sp = cu.splines.new("BEZIER")
pts = [(0, -1.12, 6.5), (0.02, -1.5, 6.42), (-0.04, -1.64, 6.05), (0.05, -1.6, 5.6), (0.0, -1.68, 5.25)]
radii = [1.0, 1.0, 0.85, 0.65, 0.25]
sp.bezier_points.add(len(pts) - 1)
for bp, p, rr in zip(sp.bezier_points, pts, radii):
    bp.co = p
    bp.handle_left_type = bp.handle_right_type = "AUTO"
    bp.radius = rr
tongue = link(bpy.data.objects.new("Tongue", cu))
tongue.scale = (1.0, 1.0, 1.0)
bpy.context.view_layer.objects.active = tongue
tongue.select_set(True)
bpy.ops.object.convert(target="MESH")
tongue = bpy.context.active_object
tongue.scale.x = 1.5  # flat and wide
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.shade_smooth()

eyes = []
for s in (-1, 1):
    e = sphere(f"Eye{'L' if s < 0 else 'R'}", HEAD_C + Vector((0.15 * s, -0.36, 0.07)), (0.052, 0.052, 0.052), 32, 16)
    eyes.append(e)


# ===== 5. Materials ======================================================================================
def principled(name):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    return m, m.node_tree.nodes, m.node_tree.links, m.node_tree.nodes["Principled BSDF"]


def skin_material(name="Skin", dark=(0.045, 0.038, 0.042), red=(0.11, 0.045, 0.045)):
    m, N, L, b = principled(name)
    coord = N.new("ShaderNodeTexCoord")
    n1 = N.new("ShaderNodeTexNoise")
    n1.inputs["Scale"].default_value = 1.6
    n1.inputs["Detail"].default_value = 8
    L.new(coord.outputs["Object"], n1.inputs["Vector"])
    ramp = N.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (*dark, 1)  # dark grey-mauve
    ramp.color_ramp.elements[1].color = (*red, 1)  # bruised red
    ramp.color_ramp.elements[0].position = 0.4
    ramp.color_ramp.elements[1].position = 0.72
    L.new(n1.outputs["Fac"], ramp.inputs["Fac"])
    ao = N.new("ShaderNodeAmbientOcclusion")
    ao.inputs["Distance"].default_value = 0.12
    grime = N.new("ShaderNodeMix")
    grime.data_type = "RGBA"
    grime.blend_type = "MULTIPLY"
    grime.inputs["Factor"].default_value = 1.0
    L.new(ramp.outputs["Color"], grime.inputs[6])
    L.new(ao.outputs["AO"], grime.inputs[7])
    L.new(grime.outputs[2], b.inputs["Base Color"])
    b.inputs["Subsurface Weight"].default_value = 0.06
    b.inputs["Subsurface Radius"].default_value = (0.25, 0.05, 0.04)
    b.inputs["Subsurface Scale"].default_value = 0.08
    # wet: low roughness with patches of drier skin
    n2 = N.new("ShaderNodeTexNoise")
    n2.inputs["Scale"].default_value = 6
    L.new(coord.outputs["Object"], n2.inputs["Vector"])
    rr = N.new("ShaderNodeMapRange")
    rr.inputs["To Min"].default_value = 0.22
    rr.inputs["To Max"].default_value = 0.6
    L.new(n2.outputs["Fac"], rr.inputs["Value"])
    L.new(rr.outputs["Result"], b.inputs["Roughness"])
    # bump: pores + wrinkles
    pores = N.new("ShaderNodeTexNoise")
    pores.inputs["Scale"].default_value = 140
    vor = N.new("ShaderNodeTexVoronoi")
    vor.inputs["Scale"].default_value = 22
    vor.feature = "DISTANCE_TO_EDGE"
    L.new(coord.outputs["Object"], pores.inputs["Vector"])
    L.new(coord.outputs["Object"], vor.inputs["Vector"])
    mixb = N.new("ShaderNodeMath")
    mixb.operation = "ADD"
    L.new(pores.outputs["Fac"], mixb.inputs[0])
    L.new(vor.outputs["Distance"], mixb.inputs[1])
    bump = N.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.35
    bump.inputs["Distance"].default_value = 0.02
    L.new(mixb.outputs[0], bump.inputs["Height"])
    L.new(bump.outputs["Normal"], b.inputs["Normal"])
    return m


def simple(name, color, rough, sss=0.0, emit=0.0, coat=0.0):
    m, N, L, b = principled(name)
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Subsurface Weight"].default_value = sss
    b.inputs["Coat Weight"].default_value = coat
    if emit:
        b.inputs["Emission Color"].default_value = (*color, 1)
        b.inputs["Emission Strength"].default_value = emit
    return m


SKIN = skin_material()
body.data.materials.append(SKIN)
body.data.materials.append(simple("Throat", (0.02, 0.002, 0.003), 0.25, coat=0.5))
body.data.materials.append(skin_material("Gums", (0.06, 0.012, 0.014), (0.13, 0.02, 0.025)))
TOOTH = simple("Teeth", (0.42, 0.34, 0.22), 0.4, coat=0.4)
for t in teeth:
    t.data.materials.append(TOOTH)
tongue.data.materials.append(skin_material("Tongue", (0.07, 0.012, 0.015), (0.16, 0.025, 0.03)))
EYE = simple("Eyes", (0.5, 0.53, 0.55), 0.05, coat=1.0, emit=0.12)
for e in eyes:
    e.data.materials.append(EYE)

bpy.ops.wm.save_as_mainfile(filepath=f"{OUT}/tenant_hi.blend")
tri = sum(len(p.vertices) - 2 for o in scene.objects if o.type == "MESH" and not o.hide_render for p in o.data.polygons)
print(f"TRIANGLES {tri}")

if not RENDER:
    sys.exit(0)

# ===== 6. Studio render ====================================================================================
bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, 0))
floor = bpy.context.active_object
floor.data.materials.append(simple("Floor", (0.03, 0.025, 0.022), 0.75))
w = bpy.data.worlds.new("World")
scene.world = w
w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (0.005, 0.006, 0.008, 1)


def light(kind, loc, target, energy, color, size=0.3, spot=None):
    d = bpy.data.lights.new(f"{kind}{loc}", kind)
    d.energy = energy
    d.color = color
    d.shadow_soft_size = size
    if spot:
        d.spot_size = math.radians(spot)
        d.spot_blend = 0.5
    if kind == "AREA":
        d.size = size
    o = link(bpy.data.objects.new(d.name, d))
    o.location = loc
    o.rotation_euler = (Vector(target) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()


light("SPOT", (2.5, -8, 7.5), (0, -0.6, 5.8), 3500, (1.0, 0.88, 0.72), 0.2, 34)  # flashlight key
light("AREA", (-4, 5, 8), (0, 0, 5.5), 900, (0.72, 0.78, 0.95), 3)  # cold rim
light("AREA", (-6, -4, 3), (0, -0.5, 5), 160, (0.8, 0.45, 0.4), 4)  # faint warm fill

cam_data = bpy.data.cameras.new("Cam")
cam = link(bpy.data.objects.new("Cam", cam_data))
scene.camera = cam
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.use_denoising = False
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.view_settings.view_transform = "Filmic"
scene.view_settings.exposure = -0.1

SHOTS = {
    "front": ((4.5, -13.5, 6.0), (0, -0.4, 4.4), 38, SAMPLES),
    "face": ((1.3, -4.2, 7.1), (0, -1.1, 6.6), 55, SAMPLES + 32),
    "side": ((13.5, -1.5, 5.8), (0, -0.3, 4.4), 38, SAMPLES),
    "back": ((-6, 10.5, 6.6), (0, 0, 4.5), 38, SAMPLES),
}
ONLY = next((a.split("=")[1].split(",") for a in argv if a.startswith("--only=")), list(SHOTS))
print(f"TEETH {len(teeth)}")
for name, (loc, tgt, lens, samples) in SHOTS.items():
    if name not in ONLY:
        continue
    cam.location = loc
    cam.rotation_euler = (Vector(tgt) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
    cam_data.lens = lens
    scene.cycles.samples = samples
    scene.render.filepath = f"{OUT}/render_{name}.png"
    bpy.ops.render.render(write_still=True)
    print(f"RENDERED {name}")
