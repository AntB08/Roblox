#!/usr/bin/env python3
"""Generates the authored GUI: src/gui/HUD.model.json and src/gui/Overlay.model.json.

Native, editable GUI instances (no flattened images). Design canvas 1280x720; every anchored group
has a UIScale named "Responsive" that UIController scales to the screen. Touch targets are 72 px
(>= 44 px after the minimum touch scale of 0.8). Re-run after editing:  python3 tools/build_hud.py
Behavior lives in src/client/Controllers/* (found by name through Hud.find("Group/Name")).
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent / "src" / "gui"

SURFACE = [0.055, 0.05, 0.06]
TEXT = [0.93, 0.9, 0.85]
MUTED = [0.62, 0.6, 0.57]
BLOOD = [0.78, 0.12, 0.1]
AMBER = [1.0, 0.77, 0.25]
GREEN = [0.35, 0.85, 0.5]


def font(family="BuilderSans", weight="Bold"):
    return {"family": f"rbxasset://fonts/families/{family}.json", "weight": weight, "style": "Normal"}


def udim2(xs, xo, ys, yo):
    return {"UDim2": [[xs, xo], [ys, yo]]}


def node(cls, name, props=None, children=None, attrs=None):
    n = {"className": cls, "name": name, "properties": props or {}}
    if children:
        n["children"] = children
    if attrs:
        n["attributes"] = attrs
    return n


def corner(r):
    return node("UICorner", "UICorner", {"CornerRadius": {"UDim": [0, r] if r < 1 else [0, r]}})


def pill_corner():
    return node("UICorner", "UICorner", {"CornerRadius": {"UDim": [0.5, 0]}})


def stroke(color=(0, 0, 0), t=0.4, th=2):
    return node("UIStroke", "UIStroke", {"Color": list(color), "Thickness": th, "Transparency": t,
                                         "ApplyStrokeMode": "Border"})


def pad(px):
    return node("UIPadding", "UIPadding", {k: {"UDim": [0, px]} for k in
                                           ("PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight")})


def vlist(padding=8, halign="Center"):
    return node("UIListLayout", "UIListLayout", {"FillDirection": "Vertical", "Padding": {"UDim": [0, padding]},
                                                 "SortOrder": "LayoutOrder", "HorizontalAlignment": halign})


def responsive():
    return node("UIScale", "Responsive", {"Scale": 1})


def label(name, text, size, color=TEXT, fam="BuilderSans", weight="Bold", order=0, **extra):
    p = {"AutomaticSize": "XY", "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1, "Text": text,
         "TextColor3": color, "TextSize": size, "FontFace": font(fam, weight), "LayoutOrder": order,
         "RichText": False}
    p.update(extra)
    return node("TextLabel", name, p)


def action_button(name, text, key, order):
    return node("TextButton", name, {
        "Size": udim2(0, 72, 0, 72), "BackgroundColor3": SURFACE, "BackgroundTransparency": 0.25,
        "Text": text, "TextColor3": TEXT, "TextSize": 17, "FontFace": font(weight="ExtraBold"),
        "AutoButtonColor": False, "LayoutOrder": order, "Tags": ["AnimatedButton"], "Selectable": True,
    }, [pill_corner(), stroke(TEXT, 0.75, 2),
        label("KeyHint", key, 12, MUTED, AnchorPoint=[0.5, 1], Position=udim2(0.5, 0, 1, -6), Visible=False)],
        attrs={"Active": False})


def small_button(name, text, order, width=132, color=SURFACE, visible=True):
    return node("TextButton", name, {
        "Size": udim2(0, width, 0, 48), "BackgroundColor3": color, "BackgroundTransparency": 0.2,
        "Text": text, "TextColor3": TEXT, "TextSize": 18, "FontFace": font(weight="Bold"),
        "AutoButtonColor": False, "LayoutOrder": order, "Visible": visible, "Tags": ["AnimatedButton"],
        "Selectable": True,
    }, [corner(12), stroke(TEXT, 0.8, 1.5)])


def hud():
    top = node("Frame", "Top", {
        "AnchorPoint": [0.5, 0], "Position": udim2(0.5, 0, 0, 8), "AutomaticSize": "XY",
        "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1,
    }, [responsive(), vlist(6),
        node("Frame", "ObjectivePill", {
            "AutomaticSize": "XY", "Size": udim2(0, 0, 0, 0), "BackgroundColor3": SURFACE,
            "BackgroundTransparency": 0.2, "LayoutOrder": 1}, [
            pill_corner(), stroke(), node("UIPadding", "UIPadding", {
                "PaddingTop": {"UDim": [0, 8]}, "PaddingBottom": {"UDim": [0, 8]},
                "PaddingLeft": {"UDim": [0, 18]}, "PaddingRight": {"UDim": [0, 18]}}),
            node("UIListLayout", "UIListLayout", {"FillDirection": "Horizontal", "Padding": {"UDim": [0, 14]},
                                                  "SortOrder": "LayoutOrder", "VerticalAlignment": "Center"}),
            label("Objective", "Waiting for players...", 20, TEXT, order=1),
            label("Timer", "", 20, AMBER, order=2),
        ]),
        node("Frame", "StatusBanner", {
            "AutomaticSize": "XY", "Size": udim2(0, 0, 0, 0), "BackgroundColor3": BLOOD,
            "BackgroundTransparency": 0.15, "LayoutOrder": 2, "Visible": False}, [
            corner(12), pad(10),
            node("UIListLayout", "UIListLayout", {"FillDirection": "Horizontal", "Padding": {"UDim": [0, 12]},
                                                  "SortOrder": "LayoutOrder", "VerticalAlignment": "Center"}),
            label("Text", "", 18, TEXT, order=1),
            small_button("LeaveButton", "Leave", 2, 110, SURFACE, False),
        ]),
    ])

    center = node("Frame", "Center", {
        "AnchorPoint": [0.5, 0.5], "Position": udim2(0.5, 0, 0.34, 0), "AutomaticSize": "XY",
        "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1, "Visible": False,
    }, [responsive(), vlist(6),
        label("Title", "", 52, TEXT, "SpecialElite", "Regular", order=1,
              TextStrokeTransparency=0.4, TextStrokeColor3=[0, 0, 0]),
        label("Subtitle", "", 20, TEXT, order=2, TextWrapped=True, AutomaticSize="Y",
              Size=udim2(0, 560, 0, 0), TextStrokeTransparency=0.5, TextStrokeColor3=[0, 0, 0]),
    ])

    bottom = node("Frame", "Bottom", {
        "AnchorPoint": [0.5, 1], "Position": udim2(0.5, 0, 1, -18), "AutomaticSize": "XY",
        "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1,
    }, [responsive(), vlist(10),
        node("Frame", "Subtitle", {
            "AutomaticSize": "XY", "Size": udim2(0, 0, 0, 0), "BackgroundColor3": [0, 0, 0],
            "BackgroundTransparency": 0.35, "LayoutOrder": 1, "Visible": False}, [
            corner(10), pad(10), vlist(2),
            label("Speaker", "THE TENANT", 13, BLOOD, order=1),
            dict(label("Line", "", 22, TEXT, "SpecialElite", "Regular", order=2, TextWrapped=True,
                       AutomaticSize="XY", Size=udim2(0, 0, 0, 0)),
                 children=[node("UISizeConstraint", "MaxWidth", {"MaxSize": [600, 300]})]),
        ]),
        node("Frame", "Stamina", {
            "Size": udim2(0, 220, 0, 8), "BackgroundColor3": SURFACE, "BackgroundTransparency": 0.3,
            "LayoutOrder": 2, "Visible": False}, [
            pill_corner(),
            node("Frame", "Fill", {"Size": udim2(1, 0, 1, 0), "BackgroundColor3": TEXT,
                                   "BackgroundTransparency": 0.1}, [pill_corner()]),
        ]),
    ])

    # Right side: action buttons (shown on touch; keys shown as hints on keyboard/gamepad).
    actions = node("Frame", "Actions", {
        "AnchorPoint": [1, 1], "Position": udim2(1, -24, 1, -150), "AutomaticSize": "XY",
        "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1,
    }, [responsive(), vlist(12, "Right"),
        action_button("LightButton", "LIGHT", "F", 1),
        action_button("CrouchButton", "CROUCH", "C", 2),
        action_button("SprintButton", "RUN", "Shift", 3),
    ])

    callouts = [small_button("CalloutToggle", "Call out", 0, 132, BLOOD)]
    for i, room in enumerate(["Kitchen", "Study", "Basement", "Hallway"]):
        b = small_button(f"Callout{room}", room, i + 1, 132, SURFACE, False)
        b["attributes"] = {"Room": room}
        b["children"].append(label("KeyHint", str(i + 1), 12, MUTED, AnchorPoint=[1, 0.5],
                                   Position=udim2(1, -8, 0.5, 0), Visible=False))
        callouts.append(b)
    left = node("Frame", "Callouts", {
        "AnchorPoint": [0, 0.5], "Position": udim2(0, 12, 0.4, 0), "AutomaticSize": "XY",
        "Size": udim2(0, 0, 0, 0), "BackgroundTransparency": 1,
    }, [responsive(), vlist(8, "Left")] + callouts)

    return {
        "className": "ScreenGui",
        "properties": {"ResetOnSpawn": False, "DisplayOrder": 1, "ScreenInsets": "CoreUISafeInsets",
                       "SafeAreaCompatibility": "None", "ZIndexBehavior": "Sibling"},
        "children": [top, center, bottom, actions, left],
    }


def gradient(name, rotation):
    # Opaque at the edges, clear in the middle.
    return node("UIGradient", name, {
        "Rotation": rotation,
        "Transparency": {"NumberSequence": {"keypoints": [
            {"time": 0, "value": 0, "envelope": 0}, {"time": 0.28, "value": 1, "envelope": 0},
            {"time": 0.72, "value": 1, "envelope": 0}, {"time": 1, "value": 0, "envelope": 0}]}},
    })


def overlay():
    def edge_frame(name, color, rotation, visible=True):
        return node("Frame", name, {"Size": udim2(1, 0, 1, 0), "BackgroundColor3": color,
                                    "BackgroundTransparency": 1, "BorderSizePixel": 0, "Visible": visible},
                    [gradient("UIGradient", rotation)])

    return {
        "className": "ScreenGui",
        "properties": {"ResetOnSpawn": False, "DisplayOrder": 0, "ScreenInsets": "None",
                       "IgnoreGuiInset": True, "ZIndexBehavior": "Sibling"},
        "children": [
            # Danger: red edges that grow as the monster gets close (two gradients = vignette).
            edge_frame("DangerX", BLOOD, 0), edge_frame("DangerY", BLOOD, 90),
            # Hiding: dark edges (you're peeking through the slats).
            edge_frame("HideX", [0, 0, 0], 0), edge_frame("HideY", [0, 0, 0], 90),
            node("Frame", "Flash", {"Size": udim2(1, 0, 1, 0), "BackgroundColor3": BLOOD,
                                    "BackgroundTransparency": 1, "BorderSizePixel": 0}),
        ],
    }


if __name__ == "__main__":
    ROOT.mkdir(parents=True, exist_ok=True)
    (ROOT / "HUD.model.json").write_text(json.dumps(hud(), indent=1) + "\n")
    (ROOT / "Overlay.model.json").write_text(json.dumps(overlay(), indent=1) + "\n")
    print("wrote HUD.model.json and Overlay.model.json")
