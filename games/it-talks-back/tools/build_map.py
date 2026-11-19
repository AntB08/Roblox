#!/usr/bin/env python3
"""Generates src/map/House.model.json: the grey-box house, lobby and every tagged gameplay marker.

Run from the game folder:  python3 tools/build_map.py
The output is a normal Rojo model, so you can also tweak it in Studio. Re-running this script
overwrites it, so either keep editing this script or stop using it once the map is hand-built.

Coordinates (studs, Y up). Ground-floor surface is y = 0, walls are 12 tall, doorways 6 x 9.
  Hallway  x  -8..8   z -40..20   (foyer at the south end, generator mid-way, exit gate north)
  Kitchen  x -40..-8  z -40..-10  (island in the middle = a chase loop)
  Stairs   x -40..-8  z -10..20   (ramp down to the basement on the west side)
  Study    x   8..40  z -40..20   (bookshelf aisles, two doors = another loop)
  Basement x -40..-8  z -40..20   y -14..-1 (one way in: the ramp. The cage is down here)
  Lobby    south of the house around z = 70
"""
import json
import math
import pathlib

OUT = pathlib.Path(__file__).resolve().parent.parent / "src" / "map" / "House.model.json"

# ---- palette (docs/STYLE.md) -----------------------------------------------------------------
WALLPAPER = [0.33, 0.36, 0.31]
WALL_BASEMENT = [0.27, 0.27, 0.29]
TRIM = [0.2, 0.14, 0.1]
FLOOR_WOOD = [0.33, 0.23, 0.16]
FLOOR_TILE = [0.5, 0.49, 0.45]
CONCRETE = [0.24, 0.24, 0.26]
CEILING = [0.18, 0.18, 0.17]
FURNITURE = [0.26, 0.18, 0.12]
FABRIC = [0.3, 0.12, 0.12]
METAL = [0.32, 0.3, 0.28]
GRASS = [0.12, 0.17, 0.11]
LAMP_WARM = [1.0, 0.78, 0.5]
LAMP_COLD = [0.75, 0.82, 1.0]

FLOOR_TOP = 0.0
WALL_H = 12.0
DOOR_W = 6.0
DOOR_H = 9.0
BASE_FLOOR = -14.0
BASE_CEIL = -1.0

_names: dict[str, int] = {}


def uniq(name: str) -> str:
    n = _names.get(name, 0) + 1
    _names[name] = n
    return name if n == 1 else f"{name}{n}"


def cframe(x, y, z, yaw_deg=0.0):
    a = math.radians(yaw_deg)
    c, s = round(math.cos(a), 6), round(math.sin(a), 6)
    return [x, y, z, c, 0, s, 0, 1, 0, -s, 0, c]


def part(name, size, pos, color, material="SmoothPlastic", yaw=0.0, cls="Part", tags=None,
         attrs=None, children=None, **props):
    p = {
        "Anchored": True,
        "Size": [round(v, 3) for v in size],
        "CFrame": cframe(*[round(v, 3) for v in pos], yaw),
        "Color": color,
        "Material": material,
        "TopSurface": "Smooth",
        "BottomSurface": "Smooth",
    }
    p.update(props)
    if tags:
        p["Tags"] = tags
    node = {"name": uniq(name), "className": cls, "properties": p}
    if attrs:
        node["attributes"] = attrs
    if children:
        node["children"] = children
    return node


def marker(name, pos, tag, attrs=None, size=(1, 1, 1), yaw=0.0):
    """Invisible, non-colliding, non-queryable gameplay marker."""
    return part(name, size, pos, [1, 0, 1], yaw=yaw, tags=[tag], attrs=attrs, Transparency=1,
                CanCollide=False, CanQuery=False, CanTouch=False, CastShadow=False)


def slab(name, x1, x2, z1, z2, top, color, material, thickness=1.0):
    return part(name, (x2 - x1, thickness, z2 - z1),
                ((x1 + x2) / 2, top - thickness / 2, (z1 + z2) / 2), color, material)


def wall_x(name, z, x1, x2, y0, h, color, material="SmoothPlastic", doors=(), t=1.0):
    """Wall along X at fixed z, with doorway gaps [(center_x, width)] and lintels above them."""
    out, cursor = [], x1
    for cx, w in sorted(doors):
        a, b = cx - w / 2, cx + w / 2
        if a > cursor:
            out.append(part(name, (a - cursor, h, t), ((cursor + a) / 2, y0 + h / 2, z), color, material))
        lintel = h - DOOR_H
        out.append(part(name + "Lintel", (w, lintel, t), (cx, y0 + DOOR_H + lintel / 2, z), color, material))
        cursor = b
    if x2 > cursor:
        out.append(part(name, (x2 - cursor, h, t), ((cursor + x2) / 2, y0 + h / 2, z), color, material))
    return out


def wall_z(name, x, z1, z2, y0, h, color, material="SmoothPlastic", doors=(), t=1.0):
    out, cursor = [], z1
    for cz, w in sorted(doors):
        a, b = cz - w / 2, cz + w / 2
        if a > cursor:
            out.append(part(name, (t, h, a - cursor), (x, y0 + h / 2, (cursor + a) / 2), color, material))
        lintel = h - DOOR_H
        out.append(part(name + "Lintel", (t, lintel, w), (x, y0 + DOOR_H + lintel / 2, cz), color, material))
        cursor = b
    if z2 > cursor:
        out.append(part(name, (t, h, z2 - cursor), (x, y0 + h / 2, (cursor + z2) / 2), color, material))
    return out


def lamp(room, x, y, z, color=LAMP_WARM, rng=24.0, brightness=0.9):
    light = {"name": "Light", "className": "PointLight",
             "properties": {"Brightness": brightness, "Range": rng, "Color": color, "Shadows": True}}
    return part("Lamp", (1.2, 0.6, 1.2), (x, y, z), color, "Neon", tags=["HouseLight"],
                attrs={"Room": room, "BaseBrightness": brightness}, children=[light],
                CanCollide=False, CanQuery=False, CastShadow=False)


def closet(room, x, floor, z, yaw):
    """A hiding closet: 4 wide, 8 tall, 3 deep. Local -Z is the open front (door side)."""
    a = math.radians(yaw)

    def world(lx, ly, lz):
        # Roblox yaw rotation about +Y: x' = x cos + z sin, z' = -x sin + z cos
        return (x + lx * math.cos(a) + lz * math.sin(a), floor + ly, z - lx * math.sin(a) + lz * math.cos(a))

    kids = [
        part("Back", (4, 8, 0.4), world(0, 4, 1.3), FURNITURE, "Wood", yaw),
        part("Left", (0.4, 8, 3), world(-1.8, 4, 0), FURNITURE, "Wood", yaw),
        part("Right", (0.4, 8, 3), world(1.8, 4, 0), FURNITURE, "Wood", yaw),
        part("Top", (4, 0.4, 3), world(0, 7.8, 0), FURNITURE, "Wood", yaw),
        part("Bottom", (4, 0.3, 3), world(0, 0.15, 0), FURNITURE, "Wood", yaw),
        # Slatted door: two panels with a dark gap between so a hider can peek out.
        part("DoorLow", (3.2, 4.6, 0.25), world(0, 2.6, -1.4), TRIM, "Wood", yaw),
        part("DoorHigh", (3.2, 2.2, 0.25), world(0, 6.6, -1.4), TRIM, "Wood", yaw),
        part("Inside", (1, 1, 1), world(0, 3.2, 0.1), [1, 0, 1], yaw=yaw, Transparency=1, CanCollide=False,
             CanQuery=False, CanTouch=False),
        part("Front", (3, 5, 0.5), world(0, 3, -2.6), [1, 0, 1], yaw=yaw, Transparency=1, CanCollide=False,
             CanQuery=False, CanTouch=False),
    ]
    return {"name": uniq("Closet"), "className": "Model", "properties": {"Tags": ["Closet"]},
            "attributes": {"Room": room}, "children": kids}


def build():
    house, markers, lights, furniture = [], [], [], []

    # ---- floors and ceilings ------------------------------------------------------------------
    house += [
        slab("HallFloor", -8, 8, -40, 20, FLOOR_TOP, FLOOR_WOOD, "WoodPlanks"),
        slab("KitchenFloor", -40, -8, -40, -10, FLOOR_TOP, FLOOR_TILE, "Slate"),
        slab("StairsFloor", -32, -8, -10, 20, FLOOR_TOP, FLOOR_WOOD, "WoodPlanks"),
        slab("StairsFloorTop", -40, -32, 16, 20, FLOOR_TOP, FLOOR_WOOD, "WoodPlanks"),
        slab("StudyFloor", 8, 40, -40, 20, FLOOR_TOP, FLOOR_WOOD, "WoodPlanks"),
        slab("Ceiling", -40.5, 40.5, -40.5, 20.5, WALL_H + 1, CEILING, "SmoothPlastic"),
        slab("BasementFloor", -40, -8, -40, 20, BASE_FLOOR, CONCRETE, "Concrete"),
    ]

    # ---- ground-floor walls ---------------------------------------------------------------------
    house += wall_x("OuterSouth", 20, -40.5, 40.5, 0, WALL_H, WALLPAPER)
    house += wall_x("OuterNorth", -40, -40.5, 40.5, 0, WALL_H, WALLPAPER, doors=[(0, 8)])
    house += wall_z("OuterWest", -40, -40, 20, 0, WALL_H, WALLPAPER)
    house += wall_z("OuterEast", 40, -40, 20, 0, WALL_H, WALLPAPER)
    house += wall_z("HallWest", -8, -40, 20, 0, WALL_H, WALLPAPER, doors=[(-25, DOOR_W), (5, DOOR_W)])
    house += wall_z("HallEast", 8, -40, 20, 0, WALL_H, WALLPAPER, doors=[(-25, DOOR_W), (5, DOOR_W)])
    house += wall_x("KitchenStairs", -10, -40, -8, 0, WALL_H, WALLPAPER, doors=[(-20, DOOR_W)])
    # Study: half-height divider makes two aisles and blocks the long sight line.
    house += wall_x("StudyDivider", -10, 8, 28, 0, WALL_H, WALLPAPER)

    # ---- basement walls ---------------------------------------------------------------------------
    bh = BASE_CEIL - BASE_FLOOR
    house += wall_x("BaseSouth", 20, -40.5, -7.5, BASE_FLOOR, bh, WALL_BASEMENT, "Concrete")
    house += wall_x("BaseNorth", -40, -40.5, -7.5, BASE_FLOOR, bh, WALL_BASEMENT, "Concrete")
    house += wall_z("BaseWest", -40, -40, 20, BASE_FLOOR, bh, WALL_BASEMENT, "Concrete")
    house += wall_z("BaseEast", -8, -40, 20, BASE_FLOOR, bh, WALL_BASEMENT, "Concrete")

    # ---- stairs: a ramp from (z=16, y=0) down to (z=-12, y=-14), with a railing --------------------
    house.append(part("Ramp", (8, 14, 28), (-36, -7, 2), FLOOR_WOOD, "WoodPlanks", cls="WedgePart"))
    house.append(part("Railing", (0.5, 3, 26), (-32, 1.5, 3), TRIM, "Wood"))
    house.append(part("RailingPost", (0.8, 3.6, 0.8), (-32, 1.8, 16), TRIM, "Wood"))

    # ---- exit gate (north wall gap) and exit zone outside -----------------------------------------------
    house.append(part("ExitGate", (8, DOOR_H, 1), (0, DOOR_H / 2, -40), METAL, "DiamondPlate",
                      tags=["ExitGate"]))
    house.append(part("ExitSign", (3, 0.8, 0.3), (0, 10.2, -39.3), [0.9, 0.1, 0.08], "Neon",
                      tags=["ExitSign"], CanCollide=False, CastShadow=False))
    markers.append(marker("ExitZone", (0, 5, -48), "ExitZone", size=(14, 10, 10)))

    # ---- generator (hallway, east wall) ---------------------------------------------------------------
    gen_kids = [
        part("Body", (3, 5, 4), (6, 2.5, -12), METAL, "CorrodedMetal", tags=["Generator"]),
        part("Pipe", (0.6, 6, 0.6), (7, 8, -13.2), METAL, "Metal"),
    ]
    for i, dz in enumerate((-1.2, 0, 1.2)):
        gen_kids.append(part("Slot", (0.2, 0.9, 0.6), (4.45, 3.6, -12 + dz), [0.15, 0.15, 0.15], "Neon",
                             tags=["FuseSlot"], attrs={"Index": i + 1}, CanCollide=False, CastShadow=False))
    house.append({"name": "Generator", "className": "Model", "children": gen_kids})

    # ---- cage (basement, north-west corner) ------------------------------------------------------------
    cx, cz, cs = -34.0, -34.0, 8.0
    cage = [part("CageFloor", (cs, 0.4, cs), (cx, BASE_FLOOR + 0.2, cz), METAL, "DiamondPlate"),
            part("CageTop", (cs, 0.4, cs), (cx, BASE_FLOOR + 9.2, cz), METAL, "DiamondPlate")]
    n = 6
    for i in range(n):
        off = -cs / 2 + (i + 0.5) * cs / n
        for (bx, bz) in ((cx + off, cz - cs / 2), (cx + off, cz + cs / 2), (cx - cs / 2, cz + off),
                         (cx + cs / 2, cz + off)):
            cage.append(part("Bar", (0.3, 9, 0.3), (bx, BASE_FLOOR + 4.5, bz), METAL, "Metal"))
    cage.append(part("CageDoor", (0.5, 6, 3), (cx + cs / 2 + 0.6, BASE_FLOOR + 3, cz), [0.4, 0.05, 0.05],
                     "Metal", tags=["CageDoor"], Transparency=0.6, CanCollide=False))
    cage.append(marker("CageInside", (cx, BASE_FLOOR + 3.2, cz), "CageInside"))
    cage.append(marker("CageOutside", (cx + cs / 2 + 3.5, BASE_FLOOR + 3.2, cz), "CageOutside"))
    house.append({"name": "Cage", "className": "Model", "children": cage})

    # ---- furniture (also the chase obstacles) -----------------------------------------------------------
    F = furniture
    # Kitchen
    F.append(part("Counter", (24, 3.5, 2.5), (-26, 1.75, -38.25), FURNITURE, "Wood"))
    F.append(part("CounterTop", (24, 0.3, 2.7), (-26, 3.65, -38.25), FLOOR_TILE, "Marble"))
    F.append(part("Island", (10, 3.5, 4), (-24, 1.75, -25), FURNITURE, "Wood"))
    F.append(part("IslandTop", (10.4, 0.3, 4.4), (-24, 3.65, -25), FLOOR_TILE, "Marble"))
    F.append(part("Fridge", (3, 7, 3), (-37.5, 3.5, -16), [0.55, 0.56, 0.52], "SmoothPlastic"))
    F.append(part("Stove", (3, 3.5, 2.5), (-12.5, 1.75, -38.25), METAL, "Metal"))
    # Stairs room
    F.append(part("Couch", (8, 2.5, 3), (-12.5, 1.25, -7.5), FABRIC, "Fabric"))
    F.append(part("CouchBack", (8, 2, 0.8), (-12.5, 3.5, -8.6), FABRIC, "Fabric"))
    F.append(part("SideTable", (3, 2.6, 3), (-24, 1.3, 8), FURNITURE, "Wood"))
    F.append(part("Grandfather", (2, 8, 1.5), (-9.5, 4, 16), TRIM, "Wood"))
    # Hallway
    F.append(part("HallTable", (2, 3, 4), (-6, 1.5, -2), FURNITURE, "Wood"))
    F.append(part("HallTable", (2, 3, 4), (6, 1.5, 12), FURNITURE, "Wood"))
    F.append(part("Rug", (6, 0.1, 30), (0, 0.05, -2), [0.25, 0.08, 0.08], "Fabric", CanCollide=False))
    # Study
    F.append(part("Shelf", (18, 8, 2), (24, 4, -28), TRIM, "Wood"))
    F.append(part("Shelf", (2, 8, 14), (31, 4, 4), TRIM, "Wood"))
    F.append(part("Shelf", (10, 8, 2), (18, 4, -36.5), TRIM, "Wood"))
    F.append(part("Desk", (6, 3, 3), (16, 1.5, 12), FURNITURE, "Wood"))
    F.append(part("Armchair", (3, 3, 3), (20, 1.5, 15), FABRIC, "Fabric"))
    # Basement
    F.append(part("Pillar", (2, 13, 2), (-24, -7.5, -24), CONCRETE, "Concrete"))
    F.append(part("Pillar", (2, 13, 2), (-24, -7.5, 4), CONCRETE, "Concrete"))
    F.append(part("Boiler", (5, 8, 5), (-12, -10, -36), METAL, "CorrodedMetal"))
    F.append(part("Crates", (4, 4, 4), (-16, -12, -6), FURNITURE, "WoodPlanks"))
    F.append(part("Crates", (4, 3, 4), (-12, -12.5, -2), FURNITURE, "WoodPlanks"))
    F.append(part("BaseShelf", (2, 7, 10), (-9.5, -10.5, 8), TRIM, "Wood"))

    # ---- closets ---------------------------------------------------------------------------------------
    # yaw: local -Z (front) points into the room. yaw 0 -> front faces -Z, 90 -> -X, 180 -> +Z, -90 -> +X
    closets = [
        closet("Kitchen", -38, FLOOR_TOP, -30, -90),
        closet("Study", 38, FLOOR_TOP, -36, 90),
        closet("Study", 34, FLOOR_TOP, 18, 0),
        closet("Stairs", -20, FLOOR_TOP, 18, 0),
        closet("Basement", -9.6, BASE_FLOOR, -20, 90),
        closet("Basement", -20, BASE_FLOOR, 18.4, 0),
    ]

    # ---- lights ------------------------------------------------------------------------------------------
    for (room, x, y, z, color, rng) in [
        ("Hallway", 0, 11.6, -30, LAMP_WARM, 24), ("Hallway", 0, 11.6, -6, LAMP_WARM, 24),
        ("Hallway", 0, 11.6, 14, LAMP_WARM, 24), ("Kitchen", -24, 11.6, -25, LAMP_WARM, 28),
        ("Kitchen", -34, 11.6, -16, LAMP_WARM, 18), ("Stairs", -18, 11.6, 4, LAMP_WARM, 26),
        ("Study", 18, 11.6, -20, LAMP_WARM, 24), ("Study", 30, 11.6, -34, LAMP_WARM, 20),
        ("Study", 22, 11.6, 6, LAMP_WARM, 24), ("Basement", -30, -1.6, -26, LAMP_COLD, 22),
        ("Basement", -18, -1.6, -12, LAMP_COLD, 22), ("Basement", -18, -1.6, 12, LAMP_COLD, 20),
    ]:
        lights.append(lamp(room, x, y, z, color, rng))

    # ---- markers -----------------------------------------------------------------------------------------
    for room, (x1, x2, y1, y2, z1, z2) in {
        "Hallway": (-8, 8, 0, 12, -40, 20), "Kitchen": (-40, -8, 0, 12, -40, -10),
        "Stairs": (-40, -8, -1, 12, -10, 20), "Study": (8, 40, 0, 12, -40, 20),
        "Basement": (-40, -8, -14, -1, -40, 20),
    }.items():
        markers.append(marker("Room" + room, ((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2), "RoomVolume",
                              attrs={"RoomName": room}, size=(x2 - x1, y2 - y1, z2 - z1)))

    for room, x, y, z in [
        ("Kitchen", -30, 3.8, -38.2), ("Kitchen", -24, 3.8, -25), ("Kitchen", -12, 0, -14),
        ("Study", 16, 3, 12), ("Study", 36, 0, -20), ("Study", 20, 0, -21),
        ("Stairs", -24, 2.6, 8), ("Stairs", -12, 0, 12),
        ("Basement", -14, BASE_FLOOR, -24), ("Basement", -36, BASE_FLOOR, -20), ("Basement", -12, BASE_FLOOR, 14),
        ("Hallway", -6, 3, -2),
    ]:
        markers.append(marker("FuseSpawn", (x, y + 0.9, z), "FuseSpawn", attrs={"Room": room}))

    for room, x, y, z in [
        ("Hallway", 0, 0, -30), ("Hallway", 0, 0, 0), ("Hallway", 0, 0, 14),
        ("Kitchen", -16, 0, -30), ("Kitchen", -32, 0, -22), ("Kitchen", -24, 0, -16),
        ("Study", 20, 0, -34), ("Study", 18, 0, -4), ("Study", 34, 0, 10), ("Study", 36, 0, -16),
        ("Stairs", -24, 0, 0), ("Stairs", -14, 0, 14),
        ("Basement", -16, BASE_FLOOR, -32), ("Basement", -20, BASE_FLOOR, 6), ("Basement", -28, BASE_FLOOR, -20),
    ]:
        markers.append(marker("PatrolPoint", (x, y + 0.5, z), "PatrolPoint", attrs={"Room": room}))

    for i, (x, z) in enumerate([(-3, 14), (3, 14), (-3, 17), (3, 17), (0, 11), (-5, 11), (5, 11), (0, 17)]):
        markers.append(marker("PlayerStart", (x, 3.5, z), "PlayerStart", attrs={"Index": i + 1}))
    markers.append(marker("MonsterSpawn", (-16, BASE_FLOOR + 4.2, -32), "MonsterSpawn"))

    house_model = {
        "name": "House", "className": "Model",
        "properties": {"ModelStreamingMode": "Persistent"},
        "children": [
            {"name": "Structure", "className": "Folder", "children": house},
            {"name": "Furniture", "className": "Folder", "children": furniture},
            {"name": "Closets", "className": "Folder", "children": closets},
            {"name": "Lights", "className": "Folder", "children": lights},
            {"name": "Markers", "className": "Folder", "children": markers},
        ],
    }

    # ---- outside: ground (with the house footprint left open), lobby, bounds --------------------------
    outside = [
        slab("GroundSouth", -120, 120, 20.5, 120, 0, GRASS, "Grass", 4),
        slab("GroundNorth", -120, 120, -120, -40.5, 0, GRASS, "Grass", 4),
        slab("GroundWest", -120, -40.5, -40.5, 20.5, 0, GRASS, "Grass", 4),
        slab("GroundEast", 40.5, 120, -40.5, 20.5, 0, GRASS, "Grass", 4),
        part("Path", (8, 0.2, 40), (0, 0.1, 40), [0.25, 0.24, 0.22], "Cobblestone"),
        part("LobbyPad", (30, 0.4, 24), (0, 0.2, 70), [0.2, 0.2, 0.22], "Cobblestone"),
        part("SpawnLocation", (10, 1, 10), (0, 0.5, 72), [0.3, 0.3, 0.32], "Slate", cls="SpawnLocation",
             Duration=0, Neutral=True, AllowTeamChangeOnTouch=False),
        part("LobbyLamp", (1, 10, 1), (-12, 5, 62), TRIM, "Metal"),
        part("LobbyLampBulb", (1.6, 1.6, 1.6), (-12, 10.5, 62), LAMP_WARM, "Neon", children=[
            {"name": "Light", "className": "PointLight",
             "properties": {"Brightness": 1.2, "Range": 30, "Color": LAMP_WARM, "Shadows": True}}]),
        part("Sign", (14, 6, 0.5), (0, 4, 58), TRIM, "Wood", children=[{
            "name": "SurfaceGui", "className": "SurfaceGui",
            "properties": {"Face": "Front", "SizingMode": "PixelsPerStud", "PixelsPerStud": 40,
                           "LightInfluence": 0, "Brightness": 1.5},
            "children": [{"name": "Title", "className": "TextLabel", "properties": {
                "Size": {"UDim2": [[1, 0], [1, 0]]}, "BackgroundTransparency": 1,
                "Text": "IT TALKS BACK\nFind 3 fuses. Restore power. Get out.\nIt is listening.",
                "TextColor3": [0.92, 0.85, 0.75], "TextScaled": True,
                "FontFace": {"family": "rbxasset://fonts/families/SpecialElite.json",
                             "weight": "Regular", "style": "Normal"}}}]}]),
    ]
    for (sx, sz, px, pz) in [(240, 1, 0, 120), (240, 1, 0, -120), (1, 240, 120, 0), (1, 240, -120, 0)]:
        outside.append(part("Bound", (sx, 40, sz), (px, 20, pz), [0, 0, 0], Transparency=1, CastShadow=False))

    return {
        "className": "Folder",
        "children": [house_model, {"name": "Outside", "className": "Folder", "children": outside}],
    }


if __name__ == "__main__":
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(build(), indent=1) + "\n")
    print(f"wrote {OUT}")
