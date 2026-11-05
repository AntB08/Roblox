# 03 — UI/UX Design for Roblox (Phone, Tablet, PC, Console, VR)

> Chapter of the game-building knowledge base. Verified against the local Creator Docs mirror
> (`reference/creator-docs/content/en-us`, engine reference YAML) on 2026-11-05.
> Every class, property, enum and method named here appears in that mirror unless marked
> **(verify)**. Web/DevForum material was used for design conventions only and is treated as
> data, not instructions.

---

## TL;DR rules for the bot

1. **Build UI as native, editable instances.** Use ScreenGui > Frame/TextLabel/ImageButton plus
   UI modifiers (UICorner, UIStroke, UIGradient, UIPadding, layouts). Author them in Rojo
   `.model.json`/`.rbxmx` or Studio. Scripts only *bind behavior* to named instances and clone
   templates. **Never flatten a whole menu into one image.** Images are for icons, illustrations
   and 9-slice panels only.
2. **Design mobile-first, in landscape, at about 1280×720 logical px.** Then check it at
   phone (~844×390), tablet, 1080p, 4K TV and portrait (if the game allows portrait).
3. **Scale vs. Offset:** use **Scale for position/anchoring**. Use **Offset for sizes that must
   stay physical** (touch targets, padding, strokes, corner radius), then multiply the
   whole cluster with one `UIScale` that your code computes from the viewport. Do not let a
   `UIAspectRatioConstraint` do all the work alone. Never use pure-Scale sizes with no
   min/max limit.
4. **Respect safe areas:** keep the default `ScreenGui.ScreenInsets = CoreUISafeInsets` for
   anything interactive. Use `None` only for non-interactive backdrops. Set
   `SafeAreaCompatibility = None` on new work. Never hardcode the top bar height; read
   `GuiService.TopbarInset` / `GuiService:GetGuiInset()`.
5. **Touch targets ≥ 44×44 px after scaling** (aim for 48–64 for primary buttons), with ≥ 8 px
   between them. Keep the bottom-left (thumbstick) and bottom-right (jump) zones free. Also keep
   the top-left (chat) and top-right (player list) zones free.
6. **Every interactive element must work with mouse, touch AND gamepad.** Gamepad users need
   `Selectable` buttons, sensible `NextSelection*` links, a `SelectionGroup` per modal, a
   `GuiService.SelectedObject` on open, and B/back to close. Prefer the **Input Action
   System** (InputContext/InputAction/InputBinding) for actions. Use ContextActionService
   (CAS) only for legacy or simple binds.
7. **Typography:** one family (Builder Sans by default, via `Font.fromName("BuilderSans",
   weight)`), 3–4 sizes, 2–3 weights. Body text ≥ 16 px on a phone (18 preferred). Avoid
   `TextScaled` for body text. Use fixed `TextSize` × `UIScale`, or `AutomaticSize`. If you
   must use `TextScaled`, add a `UITextSizeConstraint`.
8. **Spacing on a 4/8-pt grid:** 4, 8, 12, 16, 24, 32, 48. Put the values in a Theme module
   (or StyleSheet tokens) and never type magic numbers.
9. **Color:** one primary/accent color, one currency color per currency, semantic
   success/warning/danger colors, and neutral surfaces. Text contrast should be ≥ 4.5:1 for
   body and ≥ 3:1 for large/bold text. Never rely on color alone: add an icon, a label or a shape.
10. **Juice is short.** Use tweens of 0.08–0.35 s with Quad/Back Out, and a `UIScale` for
    press/hover scale (never tween `Size` inside layouts). Honor
    `GuiService.ReducedMotionEnabled`.
11. **Performance:** no per-frame property writes for UI that isn't changing. Don't
    `Instance.new` whole menus every time they open; toggle `Visible`/`Enabled`. Keep the number
    of ScreenGuis small. Use CanvasGroup sparingly because it costs texture memory.
12. **Shops convert through clarity, not pressure:** clear prices, real value labels, no fake
    timers, no "are you sure you want to miss out?" guilt prompts, no confusing double
    currencies, and a prominent close button.
13. **Default to plain instances + small behavior modules** (the patterns in this chapter). Use
    a declarative library (React-lua, Fusion, Vide) only if the project already uses one.
14. **Test in the Studio Device Emulator and Controller Emulator before calling UI done.** Then
    run the checklist at the end of this chapter.

---

## 1. The GUI object model

### 1.1 Containers (LayerCollectors and 3D GUIs)

| Class | Lives in | Use for | Key properties |
|---|---|---|---|
| `ScreenGui` | `StarterGui` (cloned to `PlayerGui`) | HUD, menus, modals, toasts | `DisplayOrder`, `ResetOnSpawn`, `IgnoreGuiInset`, `ScreenInsets`, `SafeAreaCompatibility`, `ClipToDeviceSafeArea`, `ZIndexBehavior`, `Enabled` |
| `SurfaceGui` | On a BasePart (or in PlayerGui with `Adornee`) | In-world screens, shop boards, signs, VR-friendly panels | `Face`, `SizingMode`, `PixelsPerStud`, `CanvasSize`, `AlwaysOnTop`, `LightInfluence`, `MaxDistance`, `ZOffset` |
| `BillboardGui` | Attached to a part/attachment (`Adornee`) | Name tags, health bars over NPCs, "Press E" world markers, quest markers | `Size` (scale = studs, offset = px), `StudsOffset`, `AlwaysOnTop`, `MaxDistance`, `LightInfluence`, `DistanceLowerLimit/UpperLimit` |

- **One ScreenGui per layer**, not one per widget. A good default set:
  `HUD` (DisplayOrder 0), `Menus` (10), `Modal` (20), `Toasts` (100), and a `Backdrop` ScreenGui
  with `ScreenInsets = None` for full-bleed dimmers (DisplayOrder just below the modal).
- `ResetOnSpawn = false` for HUD and menus that keep state. Otherwise they are destroyed and
  re-cloned on every respawn, and their scripts restart.
- `ZIndexBehavior = Sibling` (the default for new ScreenGuis). It is required for CanvasGroup
  flattening.
- Put interactive UI for a **VR** player in a `SurfaceGui` on a part, or keep the ScreenGui
  minimal. In VR, Roblox draws ScreenGuis on a floating panel, so big screen-edge HUDs are
  uncomfortable. The docs warn that numerous complex SurfaceGuis are costly on mobile VR.

### 1.2 GuiObjects

| Class | Notes |
|---|---|
| `Frame` | Generic container. Use `BackgroundTransparency = 1` for pure layout groups. |
| `TextLabel` / `TextButton` / `TextBox` | `FontFace`, `TextSize`, `TextColor3`, `RichText`, `TextWrapped`, `TextTruncate`, `TextXAlignment`, `LineHeight`, `MaxVisibleGraphemes` (typewriter), `TextScaled` (see pitfalls), `TextFits`, `TextBounds`. |
| `ImageLabel` / `ImageButton` | `Image`, `ImageColor3`, `ScaleType` (`Stretch`, `Slice`, `Tile`, `Fit`, `Crop`), `SliceCenter`, `SliceScale` (9-slice panels), `ResampleMode`. |
| `CanvasGroup` | Renders descendants as one flattened texture. `GroupTransparency` and `GroupColor3` fade or tint the whole group. Always clips. **Extra texture memory**: it renders blank if the memory cap is exceeded, and the docs recommend static sizes. Good for fading a small card; bad for a full-screen menu that resizes. |
| `ScrollingFrame` | `CanvasSize` + `AutomaticCanvasSize`, `ScrollingDirection`, `ScrollBarThickness`, `ScrollBarImageColor3`, `ElasticBehavior`. Set `CanvasSize = UDim2.new()` and `AutomaticCanvasSize = Y` for vertical lists. |
| `ViewportFrame` | Renders 3D models in 2D (pet/item previews). Needs a `Camera` assigned to `CurrentCamera`. Use `Ambient`, `LightColor`, `LightDirection` for lighting. Expensive: don't show 60 spinning viewports in a grid. Render on demand and prefer static icons in big grids. |
| `VideoFrame` | Video playback. Rarely needed. |
| `InputActionLabel` | **Beta.** Shows the right key/button glyph for an `InputAction` on the current device. |

Shared `GuiObject` properties the bot should know: `AnchorPoint`, `Position`, `Size`,
`AutomaticSize`, `SizeConstraint`, `LayoutOrder`, `ZIndex`, `Visible`, `ClipsDescendants`,
`Rotation`, `Active`, `Interactable`, `Selectable`, `SelectionOrder`, `NextSelectionUp/Down/Left/Right`,
`SelectionImageObject`, `GuiState` (Idle/Hover/Press/NonInteractable, read-only), and
`InputSink` (stops input from passing through to 3D ClickDetectors/DragDetectors; defaults to
`Activate` on GuiButtons).
`GuiButton` adds `AutoButtonColor`, `Modal`, `Selected`, `Activated`, `MouseButton1Click`, etc.
**Use `Activated`**. It fires for mouse, touch and gamepad A, while `MouseButton1Click` is
mouse-centric.

### 1.3 UI modifiers (UIComponents)

| Modifier | What it does | Pitfalls |
|---|---|---|
| `UICorner` | Rounds corners (`CornerRadius`, plus per-corner `TopLeftRadius`, etc.). | `UDim.new(0.5, 0)` makes a pill or circle. Use offset radii (8–16 px) for cards so they don't change with size. |
| `UIStroke` | Outline. `Thickness`, `Color`, `Transparency`, `LineJoinMode`, `ApplyStrokeMode` (`Contextual`/`Border`), `StrokeSizingMode` (`FixedSize`/`ScaledSize`), `BorderStrokePosition` (`Outer`/`Center`/`Inner`), `BorderOffset`, `ZIndex`. | On a TextLabel/TextButton, the default `Contextual` strokes the **text**. Set `ApplyStrokeMode = Border` to stroke the box. Inside a CanvasGroup an outer stroke is clipped, so use `BorderStrokePosition = Inner`. Strokes scale with `UIScale`. Only one stroke of each mode is effectively useful per object; for double borders, nest a frame. |
| `UIGradient` | `Color` (ColorSequence), `Transparency` (NumberSequence), `Rotation`, `Offset`, `Type`, `TileMode`. | It multiplies the object's colors: set `BackgroundColor3 = white` to show the gradient's true colors. Animate `Offset`/`Rotation` for shine. |
| `UIPadding` | Inner padding on all four sides (UDim). | Prefer offset padding (8/12/16). |
| `UIShadow` | **New (2026; check release status before shipping)**: `BlurRadius`, `Color`, `Offset`, `Spread`, `Inset`, `Mode` (`Shape`/`Text`), `ShowBehindParent`, `Transparency`, `ZIndex`. It follows UICorner and rotation. | If unavailable on the target client, fall back to a 9-slice shadow `ImageLabel` behind the panel. |
| `UIScale` | Multiplies the rendered size of the object and its descendants. | The best tool for responsive scaling and press/hover animation, because it doesn't fight layouts. Don't stack several UIScales on the same object. |

### 1.4 Layouts and constraints

| Class | Purpose |
|---|---|
| `UIListLayout` | Rows/columns. `FillDirection`, `Padding`, `HorizontalAlignment`, `VerticalAlignment`, `SortOrder` (use `LayoutOrder`), **flex**: `HorizontalFlex`/`VerticalFlex` (`UIFlexAlignment`: None, Fill, SpaceAround, SpaceBetween, SpaceEvenly), `ItemLineAlignment` (Automatic/Start/Center/End/Stretch), `Wraps`. |
| `UIFlexItem` | Per-child flex. `FlexMode` (None/Grow/Shrink/Fill/Custom), `GrowRatio`, `ShrinkRatio`, `ItemLineAlignment`. |
| `UIGridLayout` | Grid with `CellSize`, `CellPadding`, `FillDirectionMaxCells`, `StartCorner`. Read `AbsoluteCellCount`, `AbsoluteContentSize`. |
| `UIPageLayout` | Swipeable pages (carousels, tutorial pages). |
| `UITableLayout` | Tables (leaderboards). |
| `UIAspectRatioConstraint` | Locks the aspect ratio (`AspectRatio`, `AspectType`, `DominantAxis`). |
| `UISizeConstraint` | `MinSize`/`MaxSize` in px. **Use it on every Scale-sized panel** so it doesn't get huge on a TV or tiny on a phone. |
| `UITextSizeConstraint` | `MinTextSize`/`MaxTextSize` for `TextScaled` text. |

Flex caveats from the release thread: `AutomaticSize` combined with UIFlexItem does not support
non-zero anchor points, scaled-size items, scaled padding or `TextScaled`. Layout engines
**ignore invisible children**, so keep templates hidden (or in a separate folder) and
they won't take up a slot.

### 1.5 AutomaticSize

`AutomaticSize = X | Y | XY` grows a frame or label to fit its content. Use it for:

- Text labels whose content varies (localization!). Set `Size = UDim2.new(1, 0, 0, 0)`
  plus `AutomaticSize = Y` and `TextWrapped = true` for wrapping paragraphs.
- Pill buttons: `AutomaticSize = X` with a `UIPadding` gives a button that fits its label.
- List containers whose children decide the size (HUD clusters, toast stacks).

AutomaticSize also reacts to the player's **PreferredTextSize** accessibility setting, while
`TextScaled` text ignores it. That is one more reason to prefer AutomaticSize.

### 1.6 Text: fonts, rich text, TextScaled

- **Font API:** `label.FontFace = Font.fromName("BuilderSans", Enum.FontWeight.Bold)`.
  `Font.new("rbxasset://fonts/families/BuilderSans.json", weight, style)` and
  `Font.fromEnum(Enum.Font.BuilderSansBold)` also work. The legacy `Font` enum property still
  exists, but `FontFace` gives you weights.
- **Builder Sans** is the Roblox system font (Regular/Medium/Bold/ExtraBold). It is the default
  for a clean, modern look. `BuilderExtended` suits display headings and `BuilderMono` suits
  numbers and timers.
- Families that come built in for stylized "simulator" headers: `FredokaOne`, `LuckiestGuy`,
  `DenkOne`, `Bangers`, `Montserrat`, `Nunito`, `Oswald`, `PressStart2P` (pixel). **Use at most
  one display font + one body font.**
- **Rich text** (`RichText = true`): `<b>`, `<i>`, `<u>`, `<s>`, `<br/>`,
  `<font color="#FFCC00" size="24" weight="heavy" transparency="0.5" face="..." family="...">`,
  `<stroke color thickness transparency joins>`, `<uc>`, `<sc>`, `<mark>`. Escape `<`, `>`,
  `&`, `"`, `'` (as `&lt;` etc.) in any player-provided or server-provided text.
- **TextScaled pitfalls:**
  1. Different strings in identical buttons end up at different sizes ("Buy" is huge,
     "Purchase" is small), which looks amateur.
  2. It ignores `PreferredTextSize` (accessibility).
  3. It fills the box edge to edge unless you add `UIPadding` + `UITextSizeConstraint`.
  4. It is unsupported with flex AutomaticSize.
  5. On 4K/TV it can become huge without a `MaxTextSize`.

  **Rule:** use fixed `TextSize` from the type scale, multiplied by the cluster's `UIScale`.
  Use `TextScaled` + `UITextSizeConstraint` only for single-word, display-style labels inside
  fixed-ratio boxes (for example a big "VICTORY!" banner).
- `TextTruncate = AtEnd` for names that may overflow. Use `MaxVisibleGraphemes` for typewriter
  dialog (`ui/animation.md#typewriter-effect-on-text`).
- Text you show from other players must pass **TextService filtering** (see
  `ui/text-filtering.md`). UI chrome text should be auto-localized (`AutoLocalize`), so leave
  room for strings that are about 30% longer.

### 1.7 UI Styling (StyleSheets) — the engine's CSS

Fully released (Styling APIs + Style Editor; `StyleQuery` added in 2026): `StyleSheet`,
`StyleRule` (`Selector`, `Priority`, `SetProperty(ies)`, `SetPropertyTransition`), `StyleLink`
(attach a sheet to a ScreenGui), `StyleDerive` (inherit tokens), and `StyleQuery` (conditional
rules). Selectors match class names, tags (`.Tag`), names (`#Name`), state (`:Hover`, `:Press`,
from `GuiState`), modifiers (`::UICorner`), and queries such as the built-in
`@ViewportDisplaySizeSmall` and `@PreferredInputTouch`. **Tokens** are attributes on a token
sheet (`$Primary`). **Themes** are sets of the same tokens that can be swapped.

When to use it: projects with many screens that share a look, or when the user edits visuals
in Studio. It keeps everything as native instances (the user's preference) and gives hover and
press transitions with no code. When a bot generates UI through Rojo, a Theme Luau module (see
§4.6) is simpler to keep consistent and easy to read in diffs. Pick **one** source of truth per
project.

---

## 2. Responsive layout: Scale, Offset, safe areas

### 2.1 Scale vs. Offset — the decision table

`UDim2.new(xScale, xOffset, yScale, yOffset)`. Scale is a fraction of the parent's size;
Offset is in pixels (logical pixels: on high-DPI phones Roblox reports points, about 844×390 for
a modern iPhone in landscape).

| Use | Choose | Why |
|---|---|---|
| Where a cluster sits on screen (corners, centers) | **Scale position + AnchorPoint** | `AnchorPoint (1,1)` + `Position (1,-12,1,-12)` sticks to the bottom-right with a 12-px margin on every screen. |
| Margins and padding | **Offset** | A 12-px margin should be 12 px everywhere (then scaled by UIScale). |
| Touch targets, icons, strokes, radii | **Offset × UIScale** | Physical size matters. A 2% scale button is unusable on a phone. |
| Large panels (shop window, inventory) | **Scale + UISizeConstraint** (MinSize/MaxSize) | They fill phones and stop growing on monitors and TVs. |
| Square/round elements sized by Scale | **Scale + UIAspectRatioConstraint** | Keeps the shape. |
| Full-screen overlays | `Size = UDim2.fromScale(1, 1)` | Put them in a `ScreenInsets = None` ScreenGui. |

**The "cluster + UIScale" pattern (recommended default):**
Design each HUD cluster in offset pixels at a reference canvas of 1280×720. Anchor the cluster
with Scale. Give the cluster a `UIScale` whose `Scale` your script sets to
`clamp(shortSide / 720, min, max)`, with `min` chosen so 56-px buttons never fall below 44 px on
touch. This gives one design that stays proportionate everywhere, keeps strokes and corners
crisp, and keeps text sizes consistent. Code is in §11.3.

### 2.2 AnchorPoint

`AnchorPoint` sets which point of the element `Position` refers to. Always pair the anchor with
the side you attach to: top-right uses `(1,0)` with `Position (1,-m,0,m)`, centered uses
`(0.5,0.5)` with `(0.5,0,0.5,0)`. Amateur UI uses `(0,0)` everywhere, so elements drift off
screen on other aspect ratios.

### 2.3 Safe areas, notch, and the Roblox top bar

| Property | Values | Bot default |
|---|---|---|
| `ScreenGui.ScreenInsets` | `None`, `DeviceSafeInsets` (notch/home indicator only), `CoreUISafeInsets` (notch **and** Roblox top bar buttons; default), `TopbarSafeInsets` (only the free strip inside the top bar) | `CoreUISafeInsets` for HUD/menus; `None` for backdrops; `TopbarSafeInsets` for a small custom top bar widget |
| `ScreenGui.SafeAreaCompatibility` | `None`, `FullscreenExtension` (default: auto-stretches "fullscreen" legacy frames) | `None` for new work (the docs recommend avoiding the extension) |
| `ScreenGui.ClipToDeviceSafeArea` | bool | `true` (default) |
| `ScreenGui.IgnoreGuiInset` | bool (legacy) | Leave it alone and use ScreenInsets instead |
| `GuiService.TopbarInset` | `Rect` of the free area in the top bar; changes dynamically | Listen with `GetPropertyChangedSignal("TopbarInset")` if you place UI in the bar |
| `GuiService:GetGuiInset()` | top-left/bottom-right inset Vector2s | For legacy math only |

The current "experience controls" top bar is taller than the old 36-px bar, and its free space
changes with the health bar, the chat button, etc. **Never hardcode 36 or 58.** If the core
controls take the whole top bar, `TopbarSafeInsets` has no room. Watch the ScreenGui's
`AbsoluteSize` and hide the widget when it's too small. Some TVs overscan, so keep critical UI
inside a TV-safe margin (about 5% of the edges) when `GuiService.ViewportDisplaySize == Large`.

### 2.4 Device categories

- `GuiService.ViewportDisplaySize`: `Small` (phones and most tablets), `Medium`
  (laptops/monitors), `Large` (TVs). Use it to pick density: bigger text and more spacing on
  Large, fewer columns on Small.
- `UserInputService.PreferredInput`: `KeyboardAndMouse`, `Touch`, `Gamepad`, `MicroGamepad`. It
  updates live when the player picks up a controller. Use it to show or hide key hints, enlarge
  targets, and auto-select a button for gamepads. **Don't** infer the device from screen size
  or from `TouchEnabled` alone, because touch laptops exist.
- `GuiService:IsTenFootInterface()`: true on console. It is useful together with
  ViewportDisplaySize.
- Orientation: phones can be portrait if the game allows it (`PlayerGui.ScreenOrientation`).
  If you support portrait, switch layout direction when `AbsoluteSize.Y > AbsoluteSize.X`.

### 2.5 Thumb zones and reserved screen regions (landscape phone)

```
┌────────────────────────────────────────────────────────────┐
│ [Roblox top bar + chat]      (free)     [player list/menus]│  ← reserved: top-left, top-right
│                                                            │
│ [Left stack:                                [Contextual    │
│  currency, menu]            GAME VIEW        action btns   │  ← comfortable: mid-left, mid-right
│                                              (above jump)] │
│                                                            │
│ [Thumbstick zone            [XP / hotbar]        [JUMP]    │  ← reserved: bottom-left 40%, bottom-right
│  ~ bottom-left 40%]          bottom-center               ]│
└────────────────────────────────────────────────────────────┘
```

- **Primary, frequent actions** (attack, sprint, interact) go in an arc around the jump button,
  within reach of the right thumb.
- **Infrequent actions** (shop, settings, inventory) go mid-left or as a top-center row. These
  spots are reachable, but you can't hit them by accident.
- **Nothing interactive** goes in the dynamic-thumbstick area (bottom-left) or under the jump
  button. Players tap there constantly.
- Bottom-center suits a hotbar or progress bar, but keep it short, roughly the middle 40% of
  the width.
- When a menu opens, hide the HUD clutter behind it and let the menu own the screen.

---

## 3. Input: gamepad navigation, touch buttons, GuiService

### 3.1 Gamepad selection checklist

- Every `GuiButton` is `Selectable = true` by default. Set `Selectable = false` on decorative
  elements that are buttons only for clicks (or make them Frames).
- When a menu opens with `PreferredInput == Gamepad`, set
  `GuiService.SelectedObject = firstButton`. When it closes, set it back to `nil`.
- Mark each modal root with `SelectionGroup = true`, and set
  `SelectionBehaviorUp/Down/Left/Right = Stop` so the cursor can't escape into the HUD behind it.
- Fix weird jumps with explicit `NextSelectionUp/Down/Left/Right` links (tabs → first grid item →
  close). Use `SelectionOrder` to bias the automatic choice.
- Give selected items a clear focus style. Either set `SelectionImageObject` to a custom
  rounded highlight frame, or react to `SelectionGained`/`SelectionLost` (the button module below
  treats selection like hover).
- B (`Enum.KeyCode.ButtonB`) closes the top-most modal. Bind it while the modal is open and
  unbind it on close.
- Add shortcuts so a console player doesn't have to traverse 20 items. For example, the D-pad
  jumps focus to the HUD menu, and LB/RB switch shop tabs.
- `GuiService.GuiNavigationEnabled` and `AutoSelectGuiEnabled` control the built-in navigation
  (the virtual cursor and auto-select). Leave the defaults unless you implement your own.
- Play a short UI sound on selection change. Console guidelines recommend audio feedback for
  navigation.

### 3.2 Input Action System (preferred) vs. ContextActionService

The **Input Action System** (`InputContext` > `InputAction` > `InputBinding`) is the
recommended cross-platform approach. Each action gets a keyboard binding (`KeyCode`), a gamepad
binding, and a touch binding (set `InputBinding.UIButton` to your own on-screen `GuiButton`).
Listen to `InputAction.Pressed`/`Released`/`StateChanged`. Toggle `InputContext.Enabled` when
menus open; `Priority` + `Sink` stop gameplay keys from firing behind an open menu.
`InputAction.PreferredBinding` + `InputActionLabel` (beta) display the correct glyph per device.
Author these as instances in `ReplicatedStorage/Inputs` (editable, like the UI).

```lua
-- Client: sprint button that you designed yourself in the HUD (editable instance)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local sprint = ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("PlayContext"):WaitForChild("Sprint") :: InputAction
local touchBinding = sprint:WaitForChild("TouchBinding") :: InputBinding
local hud = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD")
touchBinding.UIButton = hud:WaitForChild("ActionButtons"):WaitForChild("SprintButton") :: GuiButton

sprint.Pressed:Connect(function() print("sprint on") end)
sprint.Released:Connect(function() print("sprint off") end)
```

**ContextActionService (legacy, still fine for quick binds):**
`BindAction(name, fn, createTouchButton, ...inputs)` with `createTouchButton = true` makes an
auto-placed mobile button. Customize it with `SetTitle`, `SetImage`, `SetPosition`,
`SetDescription`, and `GetButton` for direct styling. The auto buttons look generic, so for a
polished game draw your own buttons and route them through IAS or `Activated`. Use
`BindActionAtPriority(..., Enum.ContextActionPriority.High.Value, ...)` for modal "back" keys.
Return `Enum.ContextActionResult.Sink` or `Pass` from handlers.

```lua
local ContextActionService = game:GetService("ContextActionService")
local function onDash(_name: string, state: Enum.UserInputState, _input: InputObject)
	if state == Enum.UserInputState.Begin then
		-- dash
	end
	return Enum.ContextActionResult.Sink
end
ContextActionService:BindAction("Dash", onDash, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonX)
ContextActionService:SetTitle("Dash", "Dash")
ContextActionService:SetPosition("Dash", UDim2.new(1, -170, 1, -130)) -- above/left of jump
```

### 3.3 Key hints per device

- Keyboard: show a small "[G]" chip on HUD buttons. Get the label from
  `UserInputService:GetStringForKeyCode(Enum.KeyCode.G)`, which respects keyboard layouts.
- Gamepad: show glyphs with `UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX)` (it
  returns the right Xbox/PlayStation art).
- Touch: hide hints entirely.
- Switch live on `UserInputService:GetPropertyChangedSignal("PreferredInput")`.

---

## 4. Visual design system

### 4.1 Visual hierarchy

Each screen gets **one** primary action, made the biggest, the most colorful, and placed near
the thumb. Secondary actions are neutral-colored. Tertiary actions are text links or icons. Build
hierarchy in this order: **size → color/contrast → weight → position → motion**. If everything
has a stroke, a gradient and a bounce, nothing stands out.

### 4.2 Typography scale (logical px at 1280×720 before UIScale)

| Token | Size | Weight | Use |
|---|---|---|---|
| `display` | 40–48 | ExtraBold | Rewards, level-up, round results |
| `title` | 28–32 | Bold | Panel titles |
| `heading` | 22–24 | Bold | Section / card titles |
| `body` | 18 | Medium | Descriptions, toasts |
| `label` | 16 | Bold | Buttons, chips, prices |
| `caption` | 14 | Medium | Secondary info only. Never below 14 (UIScale min keeps it ≥ ~11 on phones) |

Line length: 45–75 characters for paragraphs. Left-align paragraphs. Center only short
labels and titles. Use real numbers formatting: `1,250` or `1.25K`, never `1250.0000001`.

### 4.3 Spacing (4/8-pt grid)

Tokens: `xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48`.

- Inner padding of buttons: 8–12 vertical, 16–24 horizontal.
- Card padding: 12–16. Panel padding: 16–24.
- Gap between related items: 8. Gap between groups: 24–32.
- Screen margin from safe edges: 12–16 (phone), 24 (desktop/TV).
- Corner radius: one family, e.g. 6 (chips), 10 (buttons), 16 (panels). Nested radius = outer
  radius − padding.

### 4.4 Color

- Neutral surfaces: 2–3 shades of a dark (or light) neutral for panel, card and elevated
  surfaces. Pure black/white is harsh, so use near-neutrals (`#14161C`, `#1E2129`, `#2A2E39`).
- **One** brand/primary color for primary buttons and selection.
- Currency colors stay fixed across the game (coins = gold, gems = cyan/purple, Robux = Roblox
  green-ish with the official icon). Players learn them.
- Semantic colors: success green, warning amber, danger red, info blue. Always pair them with
  an icon or text.
- Rarity colors (common gray → uncommon green → rare blue → epic purple → legendary gold →
  mythic red/rainbow) are a genre convention that players expect. Also show the rarity *name*
  for colorblind players.
- Contrast: body text ≥ 4.5:1 against its background, large/bold text ≥ 3:1. White text on
  saturated yellow or light green fails, so use dark text there or a dark stroke.
- Transparent panels over the 3D world need ≥ 0.85 opacity behind text, or a `UIStroke`/shadow
  on the text. Multiply background transparency by `GuiService.PreferredTransparency` (the
  official accessibility pattern).

### 4.5 Icons

- One icon style per game: all filled or all outlined, the same stroke weight, the same corner
  rounding, the same perspective (flat vs. 3/4). Mixed free-asset icons look amateur at once.
- Icons sit on a consistent grid (e.g. 24/32/48 px) with a 2-px safe padding.
- Upload icons as white glyphs and tint them with `ImageColor3`, so one asset serves every
  color state.
- Pair icons with labels on primary navigation (Shop, Pets, Quests). Icon-only is fine for
  universally known ones (close ×, settings gear) **if** a gamepad focus label or tooltip exists.
- Use sprite sheets (`ImageRectOffset`/`ImageRectSize`) or a few atlases instead of 200 single
  images. This cuts load time and pop-in.

### 4.6 Theme module (single source of truth)

```lua
--!strict
-- ReplicatedStorage/Shared/UI/Theme.luau
local Theme = {}

Theme.Space = { xxs = 2, xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48 }

Theme.Radius = {
	sm = UDim.new(0, 6),
	md = UDim.new(0, 10),
	lg = UDim.new(0, 16),
	pill = UDim.new(0.5, 0),
}

Theme.Color = {
	Surface = Color3.fromRGB(20, 22, 28),
	SurfaceRaised = Color3.fromRGB(30, 33, 41),
	SurfaceHigh = Color3.fromRGB(42, 46, 57),
	Stroke = Color3.fromRGB(58, 63, 77),
	Text = Color3.fromRGB(245, 247, 250),
	TextMuted = Color3.fromRGB(165, 172, 186),
	Primary = Color3.fromRGB(64, 145, 255),
	PrimaryDark = Color3.fromRGB(34, 98, 196),
	Success = Color3.fromRGB(46, 204, 113),
	Warning = Color3.fromRGB(255, 176, 32),
	Danger = Color3.fromRGB(235, 72, 72),
	Coins = Color3.fromRGB(255, 200, 40),
	Gems = Color3.fromRGB(90, 220, 255),
}

Theme.Font = {
	Regular = Font.fromName("BuilderSans", Enum.FontWeight.Regular),
	Medium = Font.fromName("BuilderSans", Enum.FontWeight.Medium),
	Bold = Font.fromName("BuilderSans", Enum.FontWeight.Bold),
	Heavy = Font.fromName("BuilderSans", Enum.FontWeight.ExtraBold),
	Mono = Font.fromName("BuilderMono", Enum.FontWeight.Bold),
}

Theme.TextSize = { caption = 14, label = 16, body = 18, heading = 22, title = 28, display = 44 }

Theme.Motion = {
	Fast = 0.08,
	Normal = 0.18,
	Slow = 0.35,
}

return Theme
```

---

## 5. Two dominant Roblox styles (and when to use each)

### 5.1 "Simulator/tycoon" style (chunky, loud, playful)

Typical of Pet Simulator-, tycoon- and clicker-likes. It reads well on small phones and appeals
to the core younger audience.

| Ingredient | Recipe |
|---|---|
| Buttons | Large (64–80 px), rounded 12–16 px, **thick dark stroke** (UIStroke 3–4 px, `ApplyStrokeMode = Border`, color = a darkened version of the fill, `LineJoinMode = Round`). A vertical UIGradient (light top → base bottom, `Rotation = 90`). A darker "lip" frame 4–6 px below for a 3D look; on press, move the face down 4 px and shrink the lip. |
| Text | Display font (`FredokaOne`, `LuckiestGuy`, `DenkOne`, or Builder Sans ExtraBold), white, with a dark text stroke (a UIStroke in `Contextual` mode on the TextLabel, 2–3 px) so it reads on any background. |
| Panels | Saturated base color, big radius, a 4-px outer stroke, a subtle diagonal pattern image at 90–95% transparency, a title "ribbon" overlapping the top edge, and a round red × close button half outside the corner. |
| Motion | Bouncy: `Back`/`Elastic` Out on open (scale 0.6 → 1 over 0.3–0.4 s), squash on press (0.9), idle "breathing" on important buttons (scale 1 → 1.05 loop) and a rotating shine gradient on the primary CTA. |
| Feedback | Big "+125" pop numbers flying to the currency counter, counters that count up, and particles/confetti on rewards. |

Risks: noise, low hierarchy, and dishonest urgency. Limit "breathing"/shine to **one** element
on screen at a time.

### 5.2 Modern clean style (2025–2026 top-chart look)

Many 2025–2026 hits lean toward restrained UI: the 3D world carries the color and the UI gets
out of the way.

| Ingredient | Recipe |
|---|---|
| Surfaces | Dark translucent neutrals (`BackgroundTransparency` 0.1–0.25 × PreferredTransparency), radius 10–16, a 1-px hairline stroke at 70–85% transparency, and an optional soft shadow (UIShadow or 9-slice). |
| Type | Builder Sans: Bold titles, Medium body, generous line height, muted secondary text. |
| Color | Neutral UI plus one accent color. Currency colors appear only on icons and numbers. |
| Buttons | Flat fills with a subtle top-to-bottom gradient (5–8% lightness change) and pill or 10-px radius. Hover = slightly brighter + scale 1.03; press = 0.96. |
| Motion | Quick (0.12–0.2 s) Quad/Quint Out, with fade + small slide (8–16 px) instead of big bounces. |
| Layout | Flex rows, consistent 8-pt spacing, lots of breathing room, and progressive disclosure (fewer buttons, more tabs). |

**Bot default:** use the modern clean structure (spacing, hierarchy, type) and add **simulator
accents** (bold strokes on CTAs, bouncier rewards) only when the genre calls for it. Both styles
are just different theme values on the same component modules.

---

## 6. HUD design

- **Show only what players act on every few seconds**: core currency, health/energy if the
  game uses it, the current objective, and 3–6 menu buttons. Everything else lives in menus.
- **Group by function and place by zone** (§2.5). Put currencies together as pills with an
  icon, a number, and a "+" button that opens the matching shop tab.
- **Numbers animate toward the new value** (count-up over 0.3–0.6 s) and pulse once. Gains
  float "+N" text.
- **Progress bars**: fill via `Size` tweens (Scale X), show `current / max` text, and flash on
  level-up.
- **Objective tracker**: one line ("Collect 3/5 crystals") with a waypoint `Beam` or
  BillboardGui in the world.
- **Badges/red dots** for unclaimed rewards: small, consistent, and they disappear the moment
  the player claims. Don't flash dots on everything.
- **Context sensitivity**: hide the HUD in cutscenes and dim it when a menu opens.
  `ProximityPrompt`s handle "press E" interactions, with built-in gamepad/touch support and
  customizable styling.
- **Don't fight Roblox core UI**: keep away from chat, the player list, backpack hotbar (if
  used), and mobile controls. Disable core pieces you replace through `StarterGui:SetCoreGuiEnabled`.

---

## 7. Shop/store UI that converts without being predatory

### 7.1 Structure

1. **Entry points**: a HUD Shop button, a "+" on currency pills (deep-link to that tab),
   contextual offers when a player is short ("Need 200 more coins → Coin pack").
2. **Tabs** for categories (Featured, Passes, Currency, Items). Use 3–5 tabs; more becomes a
   scroll list.
3. **Cards**: icon, name, one-line benefit ("2× coins forever"), price button, state badge
   (Owned/Equipped/New/Best value).
4. **Purchase**: `MarketplaceService:PromptGamePassPurchase` / `PromptProductPurchase` for Robux
   (the server grants developer products in `ProcessReceipt`). Use a RemoteFunction for soft
   currency, with server-side validation.
5. **Confirmation**: success toast + celebratory animation + the item visibly appears (owned
   badge, inventory highlight).

### 7.2 Conversion through clarity (do)

- Show the **real price** from `MarketplaceService:GetProductInfoAsync(id, Enum.InfoType.GamePass)`
  (`PriceInRobux`) and cache it. Never hardcode prices that can drift (regional/price
  optimization exists).
- Explain the **benefit** in plain words, and show "Owned" states so nobody buys twice.
- Mark at most **one** "Best value" item, and only when it's true (e.g. the larger pack gives
  more per Robux).
- Make free rewards prominent (daily reward, group reward). Goodwill converts later.
- Put a big close button in a standard spot (top-right), and close with B/back.

### 7.3 Don't (predatory patterns, and increasingly scrutinized)

Independent 2025–2026 audits of top Roblox games catalogued deceptive monetization patterns.
Kids are the audience and Roblox policy and regulation are tightening. The bot must not ship:

- Fake countdown timers or "only 2 left" scarcity on unlimited digital items.
- Confirm-shaming ("No, I like being weak") or guilt copy.
- Pop-up offers that interrupt gameplay on a timer, or appear right after a loss to exploit
  frustration.
- Purchase buttons placed where gameplay taps land (accidental-purchase traps), or the "Buy"
  and "Close" positions swapped between screens.
- Multiple intermediary currencies designed to hide real-money cost.
- Paid random items without disclosed odds (Roblox requires odds disclosure for paid random
  items; show them in the UI).
- Pay-to-skip that is the *only* reasonable way to progress.

---

## 8. Notifications, onboarding, and tutorials

### 8.1 Toasts

- Short (≤ 80 characters), 2.5–4 s, max 3 visible, newest on top or bottom (be consistent).
  Identical repeats stack as "×3" instead of spamming.
- Use semantic colors **plus** an icon glyph. They are tappable to dismiss and never block input
  elsewhere.
- Server-triggered via a RemoteEvent. Never send unfiltered player text.
- Big moments (level up, rare drop) get a center "banner" instead of a toast. Keep those rare.
- Roblox's own `StarterGui:SetCore("SendNotification", ...)` corner notification exists but
  can't be styled. Use a custom system for a professional look.

Full code: §11.2.

### 8.2 Onboarding/tutorial UI

- **Teach by doing in the first 30–60 seconds**: one instruction at a time, triggered by
  context, and completed by performing the action. No walls of text and no 8-page intro.
- **World guidance**: a `Beam` between the player's `Attachment` and the target (an animated
  arrow texture via `TextureSpeed`), a `BillboardGui` arrow/marker above the goal with
  `AlwaysOnTop`, and the `Highlight` instance on the target model (outline + fill) to make it pop.
- **Screen guidance**: dim the screen except the target button. Use four Frames around the
  button's `AbsolutePosition`/`AbsoluteSize` (a ScreenGui with `ScreenInsets = None`, and
  account for `GuiService:GetGuiInset()` when mixing inset spaces). Add a bouncing arrow
  `ImageLabel` pointing at it and a one-line tooltip. For gamepads, also set
  `GuiService.SelectedObject` to the target.
- **Skippable and resumable**: save the tutorial step on the server. Returning players never
  see it again; give them a "Replay tutorial" option in settings.
- Gate complexity: unlock HUD buttons as they become relevant (progressive disclosure), and
  give each newly unlocked button one "NEW" pulse.

---

## 9. UI animation and juice

### 9.1 Tween guidelines

| Interaction | Duration | Easing |
|---|---|---|
| Hover in/out | 0.10–0.15 s | Quad Out |
| Press down | 0.06–0.10 s | Quad Out |
| Release (bounce back) | 0.25–0.40 s | Back Out (playful) / Quint Out (clean) |
| Panel open | 0.20–0.35 s | Back Out (scale 0.85 → 1) or Quint Out (fade + 12-px slide) |
| Panel close | 0.12–0.20 s | Quad In (exits are faster than entries) |
| Toast in/out | 0.25 / 0.18 s | Back Out / Quad In |
| Number count-up | 0.3–0.6 s | Quad Out |

`Enum.EasingStyle`: Linear, Sine, Back, Quad, Quart, Quint, Bounce, Elastic, Exponential,
Circular, Cubic. Directions are `In`, `Out`, `InOut`.

### 9.2 Rules

- **Animate `UIScale.Scale`, `Position`, transparencies and colors.** Never animate `Size`
  inside a `UIListLayout`/`UIGridLayout`; it reflows siblings every frame and looks jittery.
- **Reuse tweens or cancel the previous one** on the same property (the button module keeps a
  reference). Overlapping tweens fight.
- **Springs:** `TweenService:SmoothDamp(current, target, velocity, smoothTime, maxSpeed?, dt?)`
  is a built-in critically damped spring (number/Vector2/Vector3/CFrame) for values that follow
  a moving target, such as a health bar trailing damage or a cursor-follow highlight. Call it
  inside a `RenderStepped` connection **only while the value is moving**, and disconnect it when
  settled. For one-shot "bouncy" motion, `Back`/`Elastic` tweens are simpler.
- **Style transitions** (StyleRule `SetPropertyTransition`) can do hover/press tweening
  declaratively if you use StyleSheets.
- **Reduced motion:** when `GuiService.ReducedMotionEnabled` is true, replace movement and
  scale with instant changes or short fades. The official pattern sets the TweenInfo time to 0.
- Sound: soft click on press, pop on open, and a coin "tick" on count-up. Load them once and
  play with `SoundService:PlayLocalSound`.
- Haptics: `GuiButton.PressHapticEffect`/`HoverHapticEffect` and `HapticService` exist for
  gamepads/mobile. Use them lightly, for big confirmations only.

---

## 10. Accessibility, performance, and library choice

### 10.1 Accessibility checklist

- Text ≥ 14 px at the smallest scale (body 16–18). Large-screen (TV) text 1.15–1.3× larger.
- Contrast ≥ 4.5:1 (body) / 3:1 (large). Text over the 3D world gets a backing panel or stroke.
- Don't rely on color alone (rarity names, icons for status, ✓/× on toasts).
- Honor `GuiService.PreferredTextSize` (use AutomaticSize/TextWrapped; avoid TextScaled for
  body text). Honor `GuiService.PreferredTransparency` (multiply background transparency).
  Honor `GuiService.ReducedMotionEnabled`.
- No important information only in sound. Provide subtitles/captions for voiced dialog.
- Flashing: avoid full-screen flashes faster than 3 per second.
- Gamepad-complete: every screen is reachable and closable with a controller.
- Settings menu: music/SFX volume, a camera-shake toggle, and a UI scale option (multiply your
  computed UIScale by a 0.85–1.25 user factor).

### 10.2 UI performance

| Do | Don't |
|---|---|
| Build menus once (authored instances) and toggle `Visible`/`ScreenGui.Enabled` | `Instance.new` + `Destroy` the whole shop every open |
| Update text only when the value changes (attribute/value Changed signals) | Set `TextLabel.Text` every `Heartbeat` "just in case" |
| Use one RenderStepped loop for all animated bars, and only while something animates | One RenderStepped connection per button/label running forever |
| Use tweens (engine-side interpolation) | Manual per-frame lerps for simple transitions |
| Pool toast/damage-number instances if you spawn many per second | Create hundreds of BillboardGuis for damage numbers |
| Use few ScreenGuis, and disable hidden ones (`Enabled = false` skips layout and render) | 40 ScreenGuis, each with its own LocalScript |
| Use image atlases and preloading (`ContentProvider:PreloadAsync`) for the first screen | Hundreds of separate icon assets popping in |
| Use static icons in big grids, and one ViewportFrame for the selected item | A ViewportFrame per grid cell |
| Use CanvasGroup only for small fixed-size fades | CanvasGroup around big or resizing menus (memory, blank textures on low-end) |
| Use `UIGradient.Offset` tweens for shine | Re-creating gradients per frame |

Profile with the MicroProfiler (look at `ui`/layout labels) and the Device Emulator on a low
graphics level.

### 10.3 Declarative libraries vs. plain instances

| | Plain instances + behavior modules | React-lua (`jsdotlua/react-lua`) | Fusion (`0.3`/`0.4-dev`, scoped API) | Vide (`0.4.x`) |
|---|---|---|---|---|
| Editable in Studio by a human | **Yes**: the UI *is* the instances | No (generated at runtime) | Partly (`Hydrate` binds to existing instances, but is marked "intent to replace") | No |
| Fits the user's preference (native, editable GUIs) | **Best** | Poor | Medium | Poor |
| State → UI sync | Manual (signals/attributes) | Components + hooks, very robust | Reactive values/computeds/springs built in | Fine-grained reactive sources (Solid-like) |
| Ecosystem/maturity | Engine-native | Most mature. Roblox's own app UI is built with it | Popular, API changed across versions | Small, fast, typecheckable |
| Bot-generation risk | Low: few APIs, easy to verify against docs | High: version-specific APIs (`React.createElement`, `ReactRoblox.createRoot`), Wally setup | Medium–high: breaking changes between 0.2/0.3/0.4 | Medium |
| Best for | Most games, HUDs, shops, menus | Large teams with JS/React background, complex app-like UI | Reactive-loving solo devs | Performance-minded devs who like Solid |

**Bot policy:** default to **plain instances authored as files + small behavior modules +
templates** (this chapter's code). Use a library only if the project already depends on one.
In that case, follow that library's docs in `reference/libraries/` exactly. For hybrids: author the static
layout as instances, and bind dynamic lists by cloning templates. This gives 90% of the
benefit with none of the lock-in.

### 10.4 Storing UI as editable instances (Rojo)

- **`.model.json`** gives readable, diff-friendly files for small components. Rojo 7 keys:
  `className`, `name`, `properties`, `attributes`, `children`. Implicit values:
  UDim2 `[[xScale, xOffset], [yScale, yOffset]]`, UDim `[scale, offset]`, Vector2 `[x, y]`,
  Color3 `[r, g, b]` (0–1 floats), enums as strings (`"XY"`), FontFace
  `{"family": "...json", "weight": "Bold", "style": "Normal"}`, `Tags` as a string array.
  Validate with `rojo build` before claiming done.
- **`.rbxmx`** (XML) is for large menus exported from Studio. It is editable in Studio and
  round-trips through Rojo, but it is verbose to hand-write.
- Keep **behavior in separate LocalScripts/ModuleScripts** that find instances by name
  (`WaitForChild`) and tag (`CollectionService`). Designers (or the user) can then restyle in
  Studio without touching code.
- Keep **templates** (`ItemCardTemplate`, `ToastTemplate`) as hidden instances in a `Templates`
  folder. Code clones and fills them.

Example: a currency pill as `src/StarterGui/HUD/LeftStack/Currencies/Coins.model.json`:

```json
{
  "className": "Frame",
  "properties": {
    "AutomaticSize": "X",
    "Size": {"UDim2": [[0, 0], [0, 40]]},
    "BackgroundColor3": [0.08, 0.086, 0.11],
    "BackgroundTransparency": 0.15,
    "LayoutOrder": 1
  },
  "attributes": { "Currency": "Coins" },
  "children": [
    { "className": "UICorner", "properties": { "CornerRadius": {"UDim": [0.5, 0]} } },
    { "className": "UIStroke", "properties": { "Thickness": 2, "Color": [0, 0, 0], "Transparency": 0.6, "ApplyStrokeMode": "Border" } },
    { "className": "UIPadding", "properties": {
        "PaddingLeft": {"UDim": [0, 6]}, "PaddingRight": {"UDim": [0, 14]}, "PaddingTop": {"UDim": [0, 4]}, "PaddingBottom": {"UDim": [0, 4]} } },
    { "className": "UIListLayout", "properties": {
        "FillDirection": "Horizontal", "VerticalAlignment": "Center", "Padding": {"UDim": [0, 8]}, "SortOrder": "LayoutOrder" } },
    { "name": "Icon", "className": "ImageLabel", "properties": {
        "Size": {"UDim2": [[0, 32], [0, 32]]}, "BackgroundTransparency": 1, "Image": "rbxassetid://0", "LayoutOrder": 1 } },
    { "name": "Amount", "className": "TextLabel", "properties": {
        "AutomaticSize": "X", "Size": {"UDim2": [[0, 0], [1, 0]]}, "BackgroundTransparency": 1,
        "Text": "0", "TextSize": 22, "TextColor3": [1, 1, 1], "TextXAlignment": "Left",
        "FontFace": { "family": "rbxasset://fonts/families/BuilderSans.json", "weight": "ExtraBold", "style": "Normal" },
        "LayoutOrder": 2 } }
  ]
}
```

(UDim2/UDim values must use the explicit `{"UDim2": ...}` / `{"UDim": ...}` forms: Rojo 7.7.1 rejects bare arrays for them — verified by `rojo build` on 2026-11-05. Replace `rbxassetid://0` with a real uploaded icon. Keep asset IDs in one config module.)

---

## 11. Complete code

Folder conventions used below (Rojo):

```
ReplicatedStorage/Shared/UI/Theme.luau            (§4.6)
ReplicatedStorage/Shared/UI/AnimatedButton.luau   (§11.1)
ReplicatedStorage/Shared/UI/Toast.luau            (§11.2)
StarterPlayer/StarterPlayerScripts/HudController.client.luau   (§11.3)
ReplicatedStorage/Shared/UI/ShopController.luau   (§11.4, required by HudController)
StarterGui/HUD, StarterGui/Shop, StarterGui/ShopBackdrop   (authored instances)
```

### 11.1 Reusable animated button module

Wraps any existing `GuiButton` (authored in Studio/Rojo). It uses a dedicated child `UIScale`, so
it is layout-safe. It covers hover (mouse), press (mouse/touch), gamepad selection treated as
hover, a click cooldown, sound, reduced motion, an enabled/disabled state, and auto-wrapping of
every button tagged `AnimatedButton`.

```lua
--!strict
-- ReplicatedStorage/Shared/UI/AnimatedButton.luau
-- Usage:
--   local AnimatedButton = require(path.AnimatedButton)
--   local btn = AnimatedButton.wrap(script.Parent.BuyButton, { onActivated = function() ... end })
--   AnimatedButton.autoWrapTag("AnimatedButton") -- wraps all tagged buttons in PlayerGui
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

export type Options = {
	hoverScale: number?,
	pressScale: number?,
	cooldown: number?,
	clickSound: Sound?,
	onActivated: ((input: InputObject?) -> ())?,
}

local DEFAULT_HOVER = 1.06
local DEFAULT_PRESS = 0.92
local DEFAULT_COOLDOWN = 0.15

local HOVER_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_INFO = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local AnimatedButton = {}
AnimatedButton.__index = AnimatedButton

type Fields = {
	button: GuiButton,
	scale: UIScale,
	options: Options,
	connections: { RBXScriptConnection },
	selected: boolean,
	enabled: boolean,
	pressed: boolean,
	lastActivated: number,
	baseColor: Color3,
	tween: Tween?,
}
export type AnimatedButton = typeof(setmetatable({} :: Fields, AnimatedButton))

local registry: { [GuiButton]: AnimatedButton } = {}

local function getAnimScale(button: GuiButton): UIScale
	local existing = button:FindFirstChild("AnimScale")
	if existing and existing:IsA("UIScale") then
		return existing
	end
	local other = button:FindFirstChildOfClass("UIScale")
	if other then
		warn(`[AnimatedButton] {button:GetFullName()} already has a UIScale; reusing it`)
		return other
	end
	local scale = Instance.new("UIScale")
	scale.Name = "AnimScale"
	scale.Parent = button
	return scale
end

function AnimatedButton.wrap(button: GuiButton, options: Options?): AnimatedButton
	local existing = registry[button]
	if existing then
		return existing
	end

	local self = setmetatable({
		button = button,
		scale = getAnimScale(button),
		options = options or {},
		connections = {},
		selected = false,
		enabled = button.Interactable,
		pressed = false,
		lastActivated = 0,
		baseColor = button.BackgroundColor3,
		tween = nil,
	} :: Fields, AnimatedButton)
	registry[button] = self

	button.AutoButtonColor = false -- we provide our own feedback

	table.insert(self.connections, button:GetPropertyChangedSignal("GuiState"):Connect(function()
		self:_refresh()
	end))
	table.insert(self.connections, button.SelectionGained:Connect(function()
		self.selected = true
		self:_refresh()
	end))
	table.insert(self.connections, button.SelectionLost:Connect(function()
		self.selected = false
		self:_refresh()
	end))
	table.insert(self.connections, button.Activated:Connect(function(input: InputObject?)
		self:_onActivated(input)
	end))
	table.insert(self.connections, button.Destroying:Connect(function()
		self:Destroy()
	end))

	return self
end

function AnimatedButton._tweenScale(self: AnimatedButton, target: number, info: TweenInfo)
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
	if GuiService.ReducedMotionEnabled then
		self.scale.Scale = 1 -- no scaling motion; color feedback below still applies
		return
	end
	local tween = TweenService:Create(self.scale, info, { Scale = target })
	self.tween = tween
	tween:Play()
end

function AnimatedButton._refresh(self: AnimatedButton)
	local button = self.button
	if not self.enabled then
		self.pressed = false
		self:_tweenScale(1, HOVER_INFO)
		return
	end

	local state = button.GuiState
	local hoverScale = self.options.hoverScale or DEFAULT_HOVER
	local pressScale = self.options.pressScale or DEFAULT_PRESS

	if state == Enum.GuiState.Press then
		self.pressed = true
		button.BackgroundColor3 = self.baseColor:Lerp(Color3.new(0, 0, 0), 0.15)
		self:_tweenScale(pressScale, PRESS_INFO)
		return
	end

	button.BackgroundColor3 = self.baseColor
	local wasPressed = self.pressed
	self.pressed = false
	local hovered = state == Enum.GuiState.Hover or self.selected
	local target = if hovered then hoverScale else 1
	self:_tweenScale(target, if wasPressed then RELEASE_INFO else HOVER_INFO)
end

function AnimatedButton._onActivated(self: AnimatedButton, input: InputObject?)
	if not self.enabled then
		return
	end
	local now = os.clock()
	if now - self.lastActivated < (self.options.cooldown or DEFAULT_COOLDOWN) then
		return
	end
	self.lastActivated = now

	local sound = self.options.clickSound
	if sound then
		SoundService:PlayLocalSound(sound)
	end

	-- Gamepad/keyboard activation never enters the Press state, so give a quick pulse.
	if self.button.GuiState ~= Enum.GuiState.Press and not GuiService.ReducedMotionEnabled then
		self.scale.Scale = self.options.pressScale or DEFAULT_PRESS
		self:_tweenScale(if self.selected then (self.options.hoverScale or DEFAULT_HOVER) else 1, RELEASE_INFO)
	end

	local callback = self.options.onActivated
	if callback then
		task.spawn(callback, input)
	end
end

function AnimatedButton.SetEnabled(self: AnimatedButton, enabled: boolean)
	self.enabled = enabled
	self.button.Interactable = enabled
	self.button.BackgroundColor3 = if enabled
		then self.baseColor
		else self.baseColor:Lerp(Color3.fromRGB(80, 80, 80), 0.65)
	self:_refresh()
end

function AnimatedButton.SetBaseColor(self: AnimatedButton, color: Color3)
	self.baseColor = color
	if self.enabled then
		self.button.BackgroundColor3 = color
	end
end

function AnimatedButton.OnActivated(self: AnimatedButton, callback: (input: InputObject?) -> ())
	self.options.onActivated = callback
end

function AnimatedButton.Destroy(self: AnimatedButton)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
	registry[self.button] = nil
end

function AnimatedButton.get(button: GuiButton): AnimatedButton?
	return registry[button]
end

-- Wrap every GuiButton with this CollectionService tag that lives in the local PlayerGui.
function AnimatedButton.autoWrapTag(tag: string, options: Options?)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local function tryWrap(instance: Instance)
		if instance:IsA("GuiButton") and instance:IsDescendantOf(playerGui) then
			AnimatedButton.wrap(instance, options and table.clone(options) or nil)
		end
	end
	for _, instance in CollectionService:GetTagged(tag) do
		tryWrap(instance)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		-- ScreenGuis are cloned into PlayerGui; defer so ancestry is final.
		task.defer(tryWrap, instance)
	end)
end

return AnimatedButton
```

Notes:
- Behaviour is attached to *editable* buttons: tag a button `AnimatedButton` in Studio (or
  `"Tags": ["AnimatedButton"]` in `.model.json`) and it gets juice automatically. Wire the
  click with `AnimatedButton.get(button):OnActivated(fn)` or `button.Activated`.
- The module never touches `Size`, so it's safe inside list/grid layouts.

### 11.2 Toast notification system

Top-center stack in its own ScreenGui. It supports semantic kinds (color + glyph), dedupe with
"×N", a max of 3 visible with a queue, tap to dismiss, reduced motion, PreferredTransparency, and
a server-triggered RemoteEvent. It builds its small instances in code because toasts are
dynamic. If a `ToastTemplate` exists in `ReplicatedStorage.Shared.UI.Templates`, swap
`buildToast` for a clone of that template to keep the look editable.

```lua
--!strict
-- ReplicatedStorage/Shared/UI/Toast.luau  (client-only module)
-- Toast.show("Saved!", "success")
-- Toast.show("<b>Rare drop:</b> Golden Fox", "info", 4)
-- Toast.listen(ReplicatedStorage.Remotes.Notify) -- server: Notify:FireClient(player, text, kind)
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

export type Kind = "info" | "success" | "warning" | "error"

local STYLE: { [string]: { color: Color3, glyph: string } } = {
	info = { color = Color3.fromRGB(64, 145, 255), glyph = "i" },
	success = { color = Color3.fromRGB(46, 204, 113), glyph = "✓" },
	warning = { color = Color3.fromRGB(255, 176, 32), glyph = "!" },
	error = { color = Color3.fromRGB(235, 72, 72), glyph = "×" },
}

local MAX_VISIBLE = 3
local DEFAULT_DURATION = 3
local MAX_WIDTH = 440
local FONT_BODY = Font.fromName("BuilderSans", Enum.FontWeight.Medium)
local FONT_ICON = Font.fromName("BuilderSans", Enum.FontWeight.ExtraBold)

type Record = {
	key: string,
	text: string,
	count: number,
	frame: CanvasGroup,
	label: TextLabel,
	pop: UIScale,
	token: number,
	closing: boolean,
}

type Pending = { text: string, kind: string, duration: number }

local Toast = {}

local stack: Frame? = nil
local active: { Record } = {}
local pending: { Pending } = {}
local orderCounter = 0

local function motionTime(t: number): number
	return if GuiService.ReducedMotionEnabled then 0 else t
end

function Toast.escape(text: string): string
	return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end

local function getStack(): Frame
	if stack and stack.Parent then
		return stack
	end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local gui = playerGui:FindFirstChild("ToastGui")
	if not (gui and gui:IsA("ScreenGui")) then
		local newGui = Instance.new("ScreenGui")
		newGui.Name = "ToastGui"
		newGui.ResetOnSpawn = false
		newGui.DisplayOrder = 100
		newGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		newGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		newGui.Parent = playerGui
		gui = newGui
	end

	local frame = Instance.new("Frame")
	frame.Name = "Stack"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 12)
	frame.Size = UDim2.new(0.92, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundTransparency = 1

	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(MAX_WIDTH, math.huge)
	sizeLimit.Parent = frame

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = frame

	frame.Parent = gui
	stack = frame
	return frame
end

local function buildToast(kind: string): (CanvasGroup, TextLabel, UIScale)
	local style = STYLE[kind] or STYLE.info

	local frame = Instance.new("CanvasGroup")
	frame.Name = "Toast"
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
	frame.BackgroundTransparency = 0.06 * GuiService.PreferredTransparency
	frame.GroupTransparency = 1
	frame.Active = true -- receive InputBegan for tap-to-dismiss

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner -- CanvasGroup clips outer strokes
	stroke.Color = style.color
	stroke.Thickness = 2
	stroke.Transparency = 0.35
	stroke.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 56) -- 16 margin + 28 icon + 12 gap
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = frame

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.fromOffset(28, 28)
	icon.Position = UDim2.fromOffset(-40, -3) -- sits inside the left padding
	icon.BackgroundColor3 = style.color
	icon.Text = style.glyph
	icon.FontFace = FONT_ICON
	icon.TextSize = 18
	icon.TextColor3 = Color3.fromRGB(16, 18, 24)
	icon.Parent = frame
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0.5, 0)
	iconCorner.Parent = icon

	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.RichText = true
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.FontFace = FONT_BODY
	label.TextSize = 18
	label.LineHeight = 1.1
	label.TextColor3 = Color3.fromRGB(245, 247, 250)
	label.Parent = frame

	local pop = Instance.new("UIScale")
	pop.Scale = if GuiService.ReducedMotionEnabled then 1 else 0.9
	pop.Parent = frame

	return frame, label, pop
end

local close: (record: Record) -> ()
local open: (text: string, kind: string, duration: number) -> ()

local function schedule(record: Record, duration: number)
	record.token += 1
	local myToken = record.token
	task.delay(duration, function()
		if record.token == myToken and not record.closing then
			close(record)
		end
	end)
end

close = function(record: Record)
	if record.closing then
		return
	end
	record.closing = true
	local info = TweenInfo.new(motionTime(0.18), Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(record.pop, info, { Scale = if GuiService.ReducedMotionEnabled then 1 else 0.95 }):Play()
	local fade = TweenService:Create(record.frame, info, { GroupTransparency = 1 })
	fade.Completed:Once(function()
		record.frame:Destroy()
		local index = table.find(active, record)
		if index then
			table.remove(active, index)
		end
		local nextItem = table.remove(pending, 1)
		if nextItem then
			open(nextItem.text, nextItem.kind, nextItem.duration)
		end
	end)
	fade:Play()
end

open = function(text: string, kind: string, duration: number)
	local frame, label, pop = buildToast(kind)
	orderCounter += 1
	frame.LayoutOrder = orderCounter -- newest at the bottom of the stack
	label.Text = text

	local record: Record = {
		key = kind .. "|" .. text,
		text = text,
		count = 1,
		frame = frame,
		label = label,
		pop = pop,
		token = 0,
		closing = false,
	}
	table.insert(active, record)

	frame.InputBegan:Connect(function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			close(record)
		end
	end)

	frame.Parent = getStack()
	TweenService:Create(frame, TweenInfo.new(motionTime(0.2), Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	TweenService:Create(pop, TweenInfo.new(motionTime(0.3), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	schedule(record, duration)
end

function Toast.show(text: string, kind: Kind?, duration: number?)
	local k: string = if kind and STYLE[kind] then kind else "info"
	local d = duration or DEFAULT_DURATION
	local key = k .. "|" .. text

	for _, record in active do
		if record.key == key and not record.closing then
			record.count += 1
			record.label.Text = `{text}  <font transparency="0.35">×{record.count}</font>`
			if not GuiService.ReducedMotionEnabled then
				record.pop.Scale = 1.05
				TweenService:Create(record.pop, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			end
			schedule(record, d)
			return
		end
	end

	if #active >= MAX_VISIBLE then
		-- Collapse duplicate queued messages too.
		for _, item in pending do
			if item.kind == k and item.text == text then
				return
			end
		end
		table.insert(pending, { text = text, kind = k, duration = d })
		return
	end
	open(text, k, d)
end

function Toast.clear()
	table.clear(pending)
	for _, record in table.clone(active) do
		close(record)
	end
end

function Toast.listen(remote: RemoteEvent)
	remote.OnClientEvent:Connect(function(text: unknown, kind: unknown, duration: unknown)
		if typeof(text) ~= "string" then
			return
		end
		local k = if typeof(kind) == "string" and STYLE[kind] then kind else "info"
		local d = if typeof(duration) == "number" then math.clamp(duration, 1, 10) else nil
		Toast.show(text, k :: Kind, d)
	end)
end

return Toast
```

### 11.3 Responsive HUD layout

**Authored tree** (Studio or Rojo; names matter, styling is free to change):

```
StarterGui
└─ HUD (ScreenGui)  ResetOnSpawn=false, ScreenInsets=CoreUISafeInsets,
   │                SafeAreaCompatibility=None, ZIndexBehavior=Sibling
   ├─ LeftStack (Frame)  AnchorPoint=(0,0.5) Position={0,12},{0.5,0}
   │  │                  AutomaticSize=XY, BackgroundTransparency=1
   │  ├─ Responsive (UIScale)
   │  ├─ UIListLayout  Vertical, Padding=12, SortOrder=LayoutOrder
   │  ├─ Currencies (Frame, LayoutOrder=1, AutomaticSize=XY, transparent)
   │  │   ├─ UIListLayout Vertical, Padding=6
   │  │   ├─ Coins  (pill from §10.4; attribute Currency="Coins") └─ Amount (TextLabel)
   │  │   └─ Gems   (pill; attribute Currency="Gems")              └─ Amount (TextLabel)
   │  └─ Menu (Frame, LayoutOrder=2, AutomaticSize=XY, transparent)
   │      ├─ UIGridLayout  CellSize={0,64},{0,64}, CellPadding={0,10},{0,10},
   │      │                FillDirectionMaxCells=2, SortOrder=LayoutOrder
   │      ├─ ShopButton      (ImageButton, tag AnimatedButton, attr Hotkey="G", attr Panel="Shop")
   │      │   └─ KeyHint (TextLabel, AnchorPoint=(1,1), Position={1,4},{1,4}, Size 22x22)
   │      ├─ InventoryButton (attr Hotkey="B", Panel="Inventory") └─ KeyHint
   │      ├─ QuestsButton    (attr Hotkey="Q", Panel="Quests")    └─ KeyHint
   │      └─ SettingsButton  (attr Hotkey="P", Panel="Settings")  └─ KeyHint
   └─ BottomBar (Frame)  AnchorPoint=(0.5,1) Position={0.5,0},{1,-12} Size={0,360},{0,28}
      ├─ Responsive (UIScale)
      ├─ UICorner (pill), UIStroke
      ├─ Fill (Frame) Size={0,0},{1,0}, UICorner, UIGradient
      └─ Label (TextLabel) Size={1,0},{1,0}, Text="Lv 1  0 / 100"
```

Each menu button contains its own UICorner/UIStroke/icon ImageLabel. Player data is read from
**player attributes** (`Coins`, `Gems`, `Level`, `XP`, `XPToNext`) that the server sets.

```lua
--!strict
-- StarterPlayer/StarterPlayerScripts/HudController.client.luau
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UI")
local AnimatedButton = require(UI:WaitForChild("AnimatedButton"))
local Toast = require(UI:WaitForChild("Toast"))
local ShopController = require(UI:WaitForChild("ShopController"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD") :: ScreenGui
local leftStack = hud:WaitForChild("LeftStack") :: Frame
local currencies = leftStack:WaitForChild("Currencies") :: Frame
local menu = leftStack:WaitForChild("Menu") :: Frame
local menuGrid = menu:WaitForChild("UIGridLayout") :: UIGridLayout
local currencyList = currencies:WaitForChild("UIListLayout") :: UIListLayout
local bottomBar = hud:WaitForChild("BottomBar") :: Frame

local REFERENCE_SHORT_SIDE = 720 -- design canvas 1280x720
local MIN_SCALE_TOUCH = 0.8 -- keeps 64px buttons >= ~51px on phones (>= 44 target)
local MIN_SCALE_OTHER = 0.6
local MAX_SCALE = 1.4
local TV_BOOST = 1.15
local userScale = 1 -- wire to a settings slider (0.85 - 1.25)

---------------------------------------------------------------- scaling & layout
local responsiveScales: { UIScale } = {}
for _, holder in { leftStack, bottomBar } do
	table.insert(responsiveScales, holder:WaitForChild("Responsive") :: UIScale)
end

local function computeScale(viewport: Vector2): number
	local shortSide = math.min(viewport.X, viewport.Y)
	local scale = shortSide / REFERENCE_SHORT_SIDE
	if GuiService.ViewportDisplaySize == Enum.DisplaySize.Large then
		scale *= TV_BOOST
	end
	local minScale = if UserInputService.PreferredInput == Enum.PreferredInput.Touch
		then MIN_SCALE_TOUCH
		else MIN_SCALE_OTHER
	return math.clamp(scale * userScale, minScale, MAX_SCALE)
end

local function applyLayout()
	local viewport = hud.AbsoluteSize
	if viewport.X <= 0 or viewport.Y <= 0 then
		return
	end
	local scale = computeScale(viewport)
	for _, uiScale in responsiveScales do
		uiScale.Scale = scale
	end

	local portrait = viewport.Y > viewport.X
	local margin = if GuiService.ViewportDisplaySize == Enum.DisplaySize.Large then 32 else 12

	if portrait then
		-- Top-center, one row of menu buttons, currencies side by side.
		leftStack.AnchorPoint = Vector2.new(0.5, 0)
		leftStack.Position = UDim2.new(0.5, 0, 0, margin)
		currencyList.FillDirection = Enum.FillDirection.Horizontal
		menuGrid.FillDirectionMaxCells = 4
	else
		-- Mid-left: reachable by the left thumb, clear of chat (top-left) and thumbstick (bottom-left).
		leftStack.AnchorPoint = Vector2.new(0, 0.5)
		leftStack.Position = UDim2.new(0, margin, 0.5, 0)
		currencyList.FillDirection = Enum.FillDirection.Vertical
		menuGrid.FillDirectionMaxCells = 2
	end
	bottomBar.Position = UDim2.new(0.5, 0, 1, -margin)
end

---------------------------------------------------------------- key hints
local function refreshHints()
	local showKeys = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	for _, button in menu:GetChildren() do
		local hint = button:FindFirstChild("KeyHint")
		local hotkey = button:GetAttribute("Hotkey")
		if hint and hint:IsA("TextLabel") and typeof(hotkey) == "string" then
			local ok, keyCode = pcall(function()
				return Enum.KeyCode:FromName(hotkey)
			end)
			hint.Visible = showKeys and ok and keyCode ~= nil
			if hint.Visible then
				hint.Text = UserInputService:GetStringForKeyCode(keyCode :: Enum.KeyCode)
			end
		end
	end
end

---------------------------------------------------------------- panels / buttons
local function openPanel(panelName: string)
	if panelName == "Shop" then
		ShopController.toggle()
	else
		Toast.show(`{panelName} coming soon`, "info", 2)
	end
end

for _, child in menu:GetChildren() do
	if child:IsA("GuiButton") then
		local panel = child:GetAttribute("Panel")
		if typeof(panel) == "string" then
			AnimatedButton.wrap(child, {
				onActivated = function()
					openPanel(panel)
				end,
			})
			local hotkey = child:GetAttribute("Hotkey")
			local ok, keyCode = pcall(function()
				return Enum.KeyCode:FromName(hotkey :: string)
			end)
			if ok and keyCode then
				ContextActionService:BindAction(`HUD_{panel}`, function(_, state)
					if state == Enum.UserInputState.Begin then
						openPanel(panel)
					end
					return Enum.ContextActionResult.Pass
				end, false, keyCode)
			end
		end
	end
end

-- Gamepad: D-pad left jumps focus to the HUD menu.
ContextActionService:BindAction("HUD_FocusMenu", function(_, state)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if GuiService.SelectedObject == nil then
		GuiService.SelectedObject = menu:FindFirstChild("ShopButton") :: GuiObject?
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.DPadLeft)

---------------------------------------------------------------- currency counters
local function abbreviate(n: number): string
	local abs = math.abs(n)
	local suffixes = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
	for _, pair in suffixes do
		if abs >= pair[1] then
			local value = n / pair[1]
			local text = if value >= 100 then string.format("%d", math.floor(value)) else string.format("%.1f", math.floor(value * 10) / 10)
			return (text:gsub("%.0$", "")) .. pair[2]
		end
	end
	return tostring(math.floor(n))
end

local function bindCounter(pill: Instance, attribute: string)
	local amountLabel = pill:WaitForChild("Amount") :: TextLabel
	local proxy = Instance.new("NumberValue")
	proxy.Value = (player:GetAttribute(attribute) :: number?) or 0
	amountLabel.Text = abbreviate(proxy.Value)
	proxy.Changed:Connect(function(value: number)
		amountLabel.Text = abbreviate(value)
	end)

	local scale = pill:FindFirstChild("PulseScale") :: UIScale?
	if not scale then
		local newScale = Instance.new("UIScale")
		newScale.Name = "PulseScale"
		newScale.Parent = pill
		scale = newScale
	end

	player:GetAttributeChangedSignal(attribute):Connect(function()
		local target = (player:GetAttribute(attribute) :: number?) or 0
		local gained = target > proxy.Value
		local time = if GuiService.ReducedMotionEnabled then 0 else 0.45
		TweenService:Create(proxy, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = target }):Play()
		if gained and scale and not GuiService.ReducedMotionEnabled then
			scale.Scale = 1.12
			TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end)
end

for _, pill in currencies:GetChildren() do
	local attribute = pill:GetAttribute("Currency")
	if typeof(attribute) == "string" then
		bindCounter(pill, attribute)
	end
end

---------------------------------------------------------------- XP bar
local fill = bottomBar:WaitForChild("Fill") :: Frame
local xpLabel = bottomBar:WaitForChild("Label") :: TextLabel
local lastLevel = (player:GetAttribute("Level") :: number?) or 1

local function refreshXp()
	local level = (player:GetAttribute("Level") :: number?) or 1
	local xp = (player:GetAttribute("XP") :: number?) or 0
	local toNext = math.max((player:GetAttribute("XPToNext") :: number?) or 100, 1)
	local ratio = math.clamp(xp / toNext, 0, 1)
	xpLabel.Text = `Lv {level}   {abbreviate(xp)} / {abbreviate(toNext)}`
	local time = if GuiService.ReducedMotionEnabled then 0 else 0.35
	TweenService:Create(fill, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(ratio, 1), -- Fill is not inside a layout, so Size tweening is fine
	}):Play()
	if level > lastLevel then
		Toast.show(`<b>Level up!</b> You reached level {level}`, "success", 3.5)
	end
	lastLevel = level
end

for _, attribute in { "Level", "XP", "XPToNext" } do
	player:GetAttributeChangedSignal(attribute):Connect(refreshXp)
end
refreshXp()

---------------------------------------------------------------- listeners
hud:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
GuiService:GetPropertyChangedSignal("ViewportDisplaySize"):Connect(applyLayout)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	applyLayout()
	refreshHints()
end)

applyLayout()
refreshHints()

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local notify = remotes and remotes:FindFirstChild("Notify")
if notify and notify:IsA("RemoteEvent") then
	Toast.listen(notify)
end
```

### 11.4 Shop frame with tabs

**Authored tree:**

```
StarterGui
├─ ShopBackdrop (ScreenGui) ScreenInsets=None, DisplayOrder=19, Enabled=false
│  └─ Dim (Frame) Size={1,0},{1,0}, BackgroundColor3=black, BackgroundTransparency=1, Active=true
└─ Shop (ScreenGui) ScreenInsets=CoreUISafeInsets, DisplayOrder=20, Enabled=false, ResetOnSpawn=false
   ├─ Window (Frame) AnchorPoint=(0.5,0.5) Position={0.5,0},{0.5,0} Size={0.92,0},{0.86,0}
   │  │            SelectionGroup=true, SelectionBehavior*=Stop
   │  ├─ UISizeConstraint MaxSize=(920,620) MinSize=(320,260)
   │  ├─ OpenScale (UIScale), UICorner (16), UIStroke, UIPadding (16)
   │  ├─ Header (Frame) Size={1,0},{0,48}
   │  │  ├─ Title (TextLabel "Shop", Bold 28)
   │  │  └─ CloseButton (TextButton "×") AnchorPoint=(1,0) Position={1,0},{0,0} Size 48x48, tag AnimatedButton
   │  ├─ Tabs (Frame) Position={0,0},{0,56} Size={1,0},{0,44}
   │  │  └─ UIListLayout Horizontal, Padding=8, HorizontalFlex=Fill
   │  └─ Grid (ScrollingFrame) Position={0,0},{0,108} Size={1,0},{1,-108}
   │     │  CanvasSize={0,0},{0,0}, AutomaticCanvasSize=Y, ScrollingDirection=Y, ScrollBarThickness=6
   │     ├─ UIPadding (4 all sides, keeps strokes/scale-ups from clipping)
   │     └─ UIGridLayout CellPadding={0,12},{0,12}, SortOrder=LayoutOrder
   └─ Templates (Folder)
      ├─ TabTemplate (TextButton) Size={0,0},{1,0}, UICorner, label text set by code
      └─ ItemCardTemplate (Frame) UICorner, UIStroke, UIPadding(10)
          ├─ Icon (ImageLabel) Size={1,0},{0.55,0}, ScaleType=Fit, BackgroundTransparency=1
          ├─ ItemName (TextLabel) Bold 18, TextTruncate=AtEnd
          ├─ Description (TextLabel) Medium 14, TextWrapped
          ├─ Badge (TextLabel "BEST VALUE") Visible=false
          └─ BuyButton (TextButton) AnchorPoint=(0.5,1) Position={0.5,0},{1,0} Size={1,0},{0,40}
```

The catalog lives in a config module. IDs are placeholders that the bot must replace with real
game pass, product, and item IDs.

```lua
--!strict
-- ReplicatedStorage/Shared/UI/ShopController.luau
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI = script.Parent
local AnimatedButton = require(UI:WaitForChild("AnimatedButton"))
local Toast = require(UI:WaitForChild("Toast"))

type ItemKind = "GamePass" | "Product" | "Coins"
type Item = {
	id: string, -- unique key
	kind: ItemKind,
	assetId: number?, -- GamePass / Product id
	price: number?, -- soft-currency price (Coins) or fallback display
	name: string,
	description: string,
	icon: string,
	badge: string?,
}
type Tab = { key: string, title: string, items: { Item } }

-- Replace ids with real ones. Keep this table in its own module in real projects.
local CATALOG: { Tab } = {
	{ key = "Featured", title = "Featured", items = {
		{ id = "vip", kind = "GamePass", assetId = 0, name = "VIP", description = "2x coins forever + VIP chat tag", icon = "rbxassetid://0", badge = "POPULAR" },
		{ id = "starter", kind = "Product", assetId = 0, name = "Starter Pack", description = "5,000 coins + 1 rare pet", icon = "rbxassetid://0" },
	} },
	{ key = "Passes", title = "Passes", items = {
		{ id = "vip", kind = "GamePass", assetId = 0, name = "VIP", description = "2x coins forever + VIP chat tag", icon = "rbxassetid://0" },
		{ id = "speed", kind = "GamePass", assetId = 0, name = "Speed Boots", description = "+25% walk speed", icon = "rbxassetid://0" },
	} },
	{ key = "Coins", title = "Coins", items = {
		{ id = "coins_s", kind = "Product", assetId = 0, name = "1,000 Coins", description = "A handy top-up", icon = "rbxassetid://0" },
		{ id = "coins_l", kind = "Product", assetId = 0, name = "12,000 Coins", description = "20% more coins per Robux", icon = "rbxassetid://0", badge = "BEST VALUE" },
	} },
	{ key = "Items", title = "Items", items = {
		{ id = "trail_fire", kind = "Coins", price = 2500, name = "Fire Trail", description = "Leave flames behind you", icon = "rbxassetid://0" },
	} },
}

local COLORS = {
	TabIdle = Color3.fromRGB(42, 46, 57),
	TabActive = Color3.fromRGB(64, 145, 255),
	Buy = Color3.fromRGB(46, 204, 113),
	Owned = Color3.fromRGB(80, 86, 100),
}
local MIN_CELL_WIDTH = 170
local CARD_ASPECT = 1.35 -- height = width * aspect

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shopGui = playerGui:WaitForChild("Shop") :: ScreenGui
local backdropGui = playerGui:WaitForChild("ShopBackdrop") :: ScreenGui
local dim = backdropGui:WaitForChild("Dim") :: Frame
local window = shopGui:WaitForChild("Window") :: Frame
local openScale = window:WaitForChild("OpenScale") :: UIScale
local tabsFrame = window:WaitForChild("Tabs") :: Frame
local grid = window:WaitForChild("Grid") :: ScrollingFrame
local gridLayout = grid:WaitForChild("UIGridLayout") :: UIGridLayout
local gridPadding = grid:WaitForChild("UIPadding") :: UIPadding
local templates = shopGui:WaitForChild("Templates")
local tabTemplate = templates:WaitForChild("TabTemplate") :: TextButton
local cardTemplate = templates:WaitForChild("ItemCardTemplate") :: Frame
local closeButton = window:WaitForChild("Header"):WaitForChild("CloseButton") :: GuiButton

local shopBuy = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShopBuy") :: RemoteFunction

local ShopController = {}

local isOpen = false
local animating = false
local currentTab: string? = nil
local tabButtons: { [string]: TextButton } = {}
local priceCache: { [string]: number } = {}
local ownedPasses: { [number]: boolean } = {}
local cardButtons: { GuiButton } = {}

---------------------------------------------------------------- helpers
local function motion(t: number): number
	return if GuiService.ReducedMotionEnabled then 0 else t
end

local function fetchRobuxPrice(item: Item): number?
	if not item.assetId or item.assetId == 0 then
		return item.price
	end
	local cacheKey = `{item.kind}:{item.assetId}`
	if priceCache[cacheKey] then
		return priceCache[cacheKey]
	end
	local infoType = if item.kind == "GamePass" then Enum.InfoType.GamePass else Enum.InfoType.Product
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(item.assetId :: number, infoType)
	end)
	if ok and typeof(info) == "table" and typeof(info.PriceInRobux) == "number" then
		priceCache[cacheKey] = info.PriceInRobux
		return info.PriceInRobux
	end
	return item.price
end

local function ownsPass(passId: number): boolean
	if ownedPasses[passId] ~= nil then
		return ownedPasses[passId]
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	ownedPasses[passId] = ok and owns == true
	return ownedPasses[passId]
end

---------------------------------------------------------------- responsive grid
local function layoutGrid()
	if animating or openScale.Scale ~= 1 then
		return -- AbsoluteSize is distorted mid-animation; we relayout after the tween
	end
	local padX = gridPadding.PaddingLeft.Offset + gridPadding.PaddingRight.Offset
	local width = grid.AbsoluteSize.X - padX - grid.ScrollBarThickness
	if width <= 0 then
		return
	end
	local gap = gridLayout.CellPadding.X.Offset
	local columns = math.clamp(math.floor((width + gap) / (MIN_CELL_WIDTH + gap)), 2, 5)
	local cellWidth = math.floor((width - gap * (columns - 1)) / columns)
	gridLayout.CellSize = UDim2.fromOffset(cellWidth, math.floor(cellWidth * CARD_ASPECT))
end

---------------------------------------------------------------- purchasing
local function purchase(item: Item, buyButton: TextButton)
	if item.kind == "GamePass" and item.assetId and item.assetId ~= 0 then
		MarketplaceService:PromptGamePassPurchase(player, item.assetId)
	elseif item.kind == "Product" and item.assetId and item.assetId ~= 0 then
		MarketplaceService:PromptProductPurchase(player, item.assetId) -- server grants in ProcessReceipt
	elseif item.kind == "Coins" then
		local wrapper = AnimatedButton.get(buyButton)
		if wrapper then
			wrapper:SetEnabled(false)
		end
		local ok, result, message = pcall(function()
			return shopBuy:InvokeServer(item.id)
		end)
		if wrapper then
			wrapper:SetEnabled(true)
		end
		if ok and result == true then
			Toast.show(`Bought <b>{Toast.escape(item.name)}</b>!`, "success")
		else
			Toast.show(if ok and typeof(message) == "string" then message else "Purchase failed. Try again.", "error")
		end
	else
		Toast.show("This item isn't available yet.", "warning")
	end
end

---------------------------------------------------------------- cards
local function clearGrid()
	for _, child in grid:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy() -- AnimatedButton wrappers clean up on Destroying
		end
	end
	table.clear(cardButtons)
end

local function styleBuyButton(button: TextButton, item: Item)
	local wrapper = AnimatedButton.get(button)
	if item.kind == "GamePass" and item.assetId and item.assetId ~= 0 and ownsPass(item.assetId) then
		button.Text = "Owned"
		if wrapper then
			wrapper:SetBaseColor(COLORS.Owned)
			wrapper:SetEnabled(false)
		end
		return
	end
	if wrapper then
		wrapper:SetBaseColor(COLORS.Buy)
	end
	button.Text = "…"
	task.spawn(function()
		local price = fetchRobuxPrice(item)
		if not button.Parent then
			return
		end
		if item.kind == "Coins" then
			button.Text = if price then `{price} Coins` else "Buy"
		else
			button.Text = if price then `R$ {price}` else "Buy" -- swap "R$" for a Robux icon ImageLabel
		end
	end)
end

local function populate(tab: Tab)
	clearGrid()
	for index, item in tab.items do
		local card = cardTemplate:Clone()
		card.Name = item.id
		card.LayoutOrder = index
		card.Visible = true
		;(card:WaitForChild("Icon") :: ImageLabel).Image = item.icon
		;(card:WaitForChild("ItemName") :: TextLabel).Text = item.name
		;(card:WaitForChild("Description") :: TextLabel).Text = item.description
		local badge = card:WaitForChild("Badge") :: TextLabel
		badge.Visible = item.badge ~= nil
		badge.Text = item.badge or ""

		local buyButton = card:WaitForChild("BuyButton") :: TextButton
		AnimatedButton.wrap(buyButton, {
			onActivated = function()
				purchase(item, buyButton)
			end,
		})
		styleBuyButton(buyButton, item)
		table.insert(cardButtons, buyButton)
		card.Parent = grid
	end
	grid.CanvasPosition = Vector2.zero

	-- Gamepad: tab row <-> first row of cards.
	local currentTabButton = if currentTab then tabButtons[currentTab] else nil
	if currentTabButton and cardButtons[1] then
		currentTabButton.NextSelectionDown = cardButtons[1]
	end
end

---------------------------------------------------------------- tabs
local function selectTab(key: string)
	if currentTab == key then
		return
	end
	currentTab = key
	for tabKey, button in tabButtons do
		local active = tabKey == key
		TweenService:Create(button, TweenInfo.new(motion(0.15)), {
			BackgroundColor3 = if active then COLORS.TabActive else COLORS.TabIdle,
		}):Play()
		local wrapper = AnimatedButton.get(button)
		if wrapper then
			wrapper:SetBaseColor(if active then COLORS.TabActive else COLORS.TabIdle)
		end
		button.FontFace = Font.fromName("BuilderSans", if active then Enum.FontWeight.ExtraBold else Enum.FontWeight.Medium)
	end
	for _, tab in CATALOG do
		if tab.key == key then
			populate(tab)
			break
		end
	end
end

local function cycleTab(direction: number)
	local index = 1
	for i, tab in CATALOG do
		if tab.key == currentTab then
			index = i
		end
	end
	local nextIndex = ((index - 1 + direction) % #CATALOG) + 1
	selectTab(CATALOG[nextIndex].key)
end

for order, tab in CATALOG do
	local button = tabTemplate:Clone()
	button.Name = tab.key
	button.Text = tab.title
	button.LayoutOrder = order
	button.Visible = true
	button.BackgroundColor3 = COLORS.TabIdle
	button.Parent = tabsFrame
	tabButtons[tab.key] = button
	AnimatedButton.wrap(button, {
		hoverScale = 1.03,
		pressScale = 0.96,
		onActivated = function()
			selectTab(tab.key)
		end,
	})
end

---------------------------------------------------------------- open / close
local function bindModalInputs()
	ContextActionService:BindActionAtPriority("Shop_Close", function(_, state)
		if state == Enum.UserInputState.Begin then
			ShopController.close()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)

	ContextActionService:BindActionAtPriority("Shop_Tabs", function(_, state, input)
		if state == Enum.UserInputState.Begin then
			cycleTab(if input.KeyCode == Enum.KeyCode.ButtonL1 then -1 else 1)
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
end

local function unbindModalInputs()
	ContextActionService:UnbindAction("Shop_Close")
	ContextActionService:UnbindAction("Shop_Tabs")
end

function ShopController.open(tabKey: string?)
	if isOpen then
		if tabKey then
			selectTab(tabKey)
		end
		return
	end
	isOpen = true
	animating = true
	backdropGui.Enabled = true
	shopGui.Enabled = true
	selectTab(tabKey or currentTab or CATALOG[1].key)

	dim.BackgroundTransparency = 1
	TweenService:Create(dim, TweenInfo.new(motion(0.2)), { BackgroundTransparency = 0.45 }):Play()

	openScale.Scale = if GuiService.ReducedMotionEnabled then 1 else 0.85
	local pop = TweenService:Create(openScale, TweenInfo.new(motion(0.3), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	pop.Completed:Once(function()
		animating = false
		layoutGrid()
	end)
	pop:Play()
	bindModalInputs()

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = cardButtons[1] or (currentTab and tabButtons[currentTab]) or nil
	end
end

function ShopController.close()
	if not isOpen then
		return
	end
	isOpen = false
	animating = true
	unbindModalInputs()
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(shopGui) then
		GuiService.SelectedObject = nil
	end
	TweenService:Create(dim, TweenInfo.new(motion(0.15)), { BackgroundTransparency = 1 }):Play()
	local shrink = TweenService:Create(openScale, TweenInfo.new(motion(0.15), Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = if GuiService.ReducedMotionEnabled then 1 else 0.9,
	})
	shrink.Completed:Once(function()
		animating = false
		if not isOpen then
			shopGui.Enabled = false
			backdropGui.Enabled = false
			openScale.Scale = 1
		end
	end)
	shrink:Play()
end

function ShopController.toggle(tabKey: string?)
	if isOpen then
		ShopController.close()
	else
		ShopController.open(tabKey)
	end
end

function ShopController.isOpen(): boolean
	return isOpen
end

---------------------------------------------------------------- wiring
AnimatedButton.wrap(closeButton, { onActivated = ShopController.close })
dim.InputBegan:Connect(function(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
		ShopController.close() -- tap outside closes
	end
end)
grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutGrid)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(who, passId, wasPurchased)
	if who ~= player or not wasPurchased then
		return
	end
	ownedPasses[passId] = true
	Toast.show("Purchase complete! Enjoy your new perk.", "success")
	if isOpen and currentTab then
		local key = currentTab
		currentTab = nil -- force repopulate
		selectTab(key)
	end
end)

return ShopController
```

Server side (sketch; the monetization chapter covers it fully): `ShopBuy.OnServerInvoke` must
validate the item ID against a server-side catalog, check and deduct coins atomically, and
return `true` or `false, "Not enough coins"`. Grant developer products only in
`MarketplaceService.ProcessReceipt`. Grant game pass perks on join and on
`PromptGamePassPurchaseFinished` (server).

---

## 12. Common amateur UI mistakes

| Mistake | Fix |
|---|---|
| Everything sized in Offset from a 1080p monitor, so it is cut off on phones | Scale anchoring + offset × UIScale, tested in the Device Emulator |
| Everything sized in pure Scale, so it is stretched on ultrawide and gigantic on TVs | UIAspectRatioConstraint / UISizeConstraint / UIScale clamp |
| AnchorPoint left at (0,0) for right/bottom elements | Match AnchorPoint to the attached edge |
| UI under the notch or the Roblox top bar | `ScreenInsets = CoreUISafeInsets`; never `IgnoreGuiInset` hacks |
| Buttons in the thumbstick/jump zones | Follow the zone map (§2.5) |
| Tiny targets (30 px) and crammed spacing | ≥ 44 px targets, 8-px grid |
| TextScaled on everything, so text sizes are inconsistent | A type scale with fixed TextSize |
| Five fonts, rainbow colors, mixed icon packs | One family, one accent, one icon style |
| White text on bright backgrounds with no stroke | A contrast check, a dark stroke, or dark text |
| Whole menus as one flat image (unlocalizable, blurry, uneditable) | Native frames + 9-slice + icons |
| Buttons that don't react at all, or bounce for 1 second | 0.08–0.35 s feedback |
| Tweening Size inside layouts (jitter) | UIScale |
| Menus unusable with a controller | SelectionGroup, SelectedObject, B to close |
| Pop-ups stacking over each other | One modal at a time (a simple UI state owner) |
| A new ScreenGui + LocalScript per button | A few ScreenGuis + shared modules + tags |
| No close button / close hidden in an odd spot | Top-right ×, tap outside, B/back |
| HUD clutter: 14 buttons visible at once | Progressive disclosure, max ~6 |
| Red dots that never go away | Clear notifications on view/claim |
| Fake timers / guilt copy in shops | Honest value labels (§7) |
| `ResetOnSpawn = true` on menus with state | `ResetOnSpawn = false` |
| Unfiltered player text in labels | TextService filtering |

---

## 13. UI checklist (run before calling any UI "done")

**Structure**
- [ ] UI is native instances (Rojo `.model.json`/`.rbxmx` or Studio), with behavior in separate
      scripts and templates for repeated items.
- [ ] Few ScreenGuis with clear `DisplayOrder` layering; `ResetOnSpawn` set intentionally.
- [ ] `ScreenInsets = CoreUISafeInsets` on interactive GUIs, `None` only on backdrops;
      `SafeAreaCompatibility = None`.
- [ ] Theme/tokens module (or StyleSheet) used. No magic colors or sizes.

**Responsive**
- [ ] Tested in the Device Emulator: phone landscape (~844×390), tablet, 1080p, 4K/TV, and
      portrait if enabled.
- [ ] Panels have `UISizeConstraint`. Clusters use `UIScale` with a min clamp; touch targets
      ≥ 44 px at min scale.
- [ ] Nothing in the reserved zones (chat, player list, thumbstick, jump, top bar).
- [ ] Text never overflows; long/localized strings wrap or truncate.

**Input**
- [ ] Every action works with mouse, touch, and gamepad (Controller Emulator).
- [ ] Modals: `SelectionGroup`, `SelectedObject` on open, B closes, focus restored on close.
- [ ] Key/glyph hints follow `PreferredInput`.
- [ ] Gameplay inputs are blocked or sunk while menus are open (IAS context or CAS priority).

**Visual**
- [ ] One font family, a type scale of ≤ 5 sizes, body ≥ 16 px.
- [ ] Contrast ≥ 4.5:1 body / 3:1 large; meaning never by color alone.
- [ ] Consistent icon style, corner radii, stroke weights, and spacing (4/8 grid).
- [ ] Exactly one primary action per screen.

**Feel**
- [ ] Hover/press/selection feedback on every button (AnimatedButton or style transitions).
- [ ] Open/close animations ≤ 0.35 s; `ReducedMotionEnabled` respected.
- [ ] UI sounds on click/open/reward; nothing plays over and over.

**Shop/notifications**
- [ ] Real prices from `GetProductInfoAsync`, owned states, honest badges, odds for paid
      random items.
- [ ] No fake timers, no confirm-shaming, no accidental-purchase placements.
- [ ] Toasts: short, deduped, max 3, not blocking, server text escaped/filtered.

**Performance**
- [ ] No per-frame writes when nothing changes; RenderStepped loops disconnect when idle.
- [ ] Menus are built once and toggled; hidden ScreenGuis `Enabled = false`.
- [ ] ViewportFrames and CanvasGroups are limited; icons are preloaded or atlased.

---

## Sources

Local (authoritative, verified):
- `reference/creator-docs/content/en-us/reference/engine/classes/` — ScreenGui,
  SurfaceGui, BillboardGui, GuiObject, GuiBase2d, GuiButton, TextLabel, ImageLabel,
  CanvasGroup, ScrollingFrame, ViewportFrame, UIStroke, UICorner, UIGradient, UIPadding,
  UIShadow, UIScale, UIListLayout, UIFlexItem, UIGridLayout, UIAspectRatioConstraint,
  UISizeConstraint, UITextSizeConstraint, GuiService, TweenService (SmoothDamp),
  ContextActionService, InputAction/InputBinding/InputContext, InputActionLabel,
  MarketplaceService, StyleSheet/StyleRule/StyleQuery/StyleLink/StyleDerive (YAML).
- `reference/creator-docs/content/en-us/reference/engine/enums/` — ScreenInsets,
  SafeAreaCompatibility, ApplyStrokeMode, StrokeSizingMode, BorderStrokePosition, UIFlexMode,
  UIFlexAlignment, ItemLineAlignment, PreferredTextSize, PreferredInput, EasingStyle, GuiState,
  InfoType, ContextActionPriority; datatypes `Font.yaml`, `Enum.yaml`.
- `.../ui/` — on-screen-containers, rich-text, animation, list-flex-layouts, size-modifiers,
  styling/index, styling/editor, styling/compatibility.
- `.../projects/cross-platform.md`; `.../production/publishing/adaptive-design.md`,
  `accessibility.md`, `console-guidelines.md`, `vr-guidelines.md`; `.../input/input-action-system.md`.
- `reference/libraries/rojo-rbx_rojo` — `src/snapshot_middleware/json_model.rs`, `src/resolution.rs`,
  `CHANGELOG.md` (model.json keys, implicit FontFace/enum values, Tags).
- `reference/libraries/dphfox_Fusion/docs/tutorials/roblox/hydration.md` (Hydrate "intent to replace"),
  `reference/libraries/centau_vide/README.md` (v0.4.1), `reference/libraries/jsdotlua_react-lua`.

Web (design conventions; read as search-result summaries because direct DevForum/Creator Hub
fetches were blocked by the sandbox network):
- [Designing UI - Tips and Best Practices (Roblox staff, DevForum)](https://devforum.roblox.com/t/3074034)
- [UI Design Starter Guide](https://devforum.roblox.com/t/topic/53461/1)
- [AnchorPoint & Making UIs Scaled on All Devices](https://devforum.roblox.com/t/anchorpoint-making-uis-scaled-on-all-devices/241156/2)
- [Studio Beta for Experience Controls (TopbarInset / TopbarSafeInsets)](https://devforum.roblox.com/t/studio-beta-for-experience-controls-available-now/2567355)
- [How to Produce a Topbar based on TopBarSafeInsets](https://devforum.roblox.com/t/how-to-produce-a-topbar-based-on-topbarsafeinsets/2914413)
- [TopbarSafeInsets wrong on Xbox/PS4](https://devforum.roblox.com/t/topbarsafeinsets-is-wrong-on-xbox-and-ps4-with-new-experience-controls/2848042/2)
- [New UIListLayout Flex Features](https://devforum.roblox.com/t/new-uilistlayout-flex-features-beta/2694081) and [Flex client release](https://devforum.roblox.com/t/flex-features-for-uilistlayout-client-release/3096190)
- [Full Release: UI Styling](https://devforum.roblox.com/t/full-release-ui-styling-is-officially-released/4275082), [StyleQuery release](https://devforum.roblox.com/t/full-release-stylequery-more-styling-features/4566519)
- [Release Notes for 715 (UIShadow status)](https://devforum.roblox.com/t/release-notes-for-715/4556577)
- [Studio Beta: New Input Action System](https://devforum.roblox.com/t/studio-beta-new-input-action-system/3656214), [Client Beta IAS](https://devforum.roblox.com/t/client-beta-input-action-system-is-now-available-to-publish-in-experiences/3890979), [Input Action System docs](https://create.roblox.com/docs/input/input-action-system)
- [Here's How to Create a Modern Sleek UI Design](https://devforum.roblox.com/t/heres-how-to-create-a-modern-sleek-ui-design-ui-tutorial/2528850), [How to make UI styled for simulator](https://devforum.roblox.com/t/how-to-make-ui-styled-for-simulator-detailed-tutorial/2895762), [UI Style Guide Series: Minimalistic](https://devforum.roblox.com/t/ui-style-guide-series-minimalistic-simplistic/2578826), [How to make extremely clean UI while keeping good UX](https://devforum.roblox.com/t/how-to-make-extremely-clean-ui-while-keeping-good-ux/2438099), [How to recreate such UI style (single UIStroke limitation)](https://devforum.roblox.com/t/how-to-recreate-such-ui-style/1943553)
- [I don't like TextScaled](https://devforum.roblox.com/t/i-dont-like-textscaled/3429884), [Make FontSize a UDim](https://devforum.roblox.com/t/make-fontsize-a-udim/3387217), [How to fix text scaling?](https://devforum.roblox.com/t/how-to-fix-text-scaling/3479348)
- [Fusion vs React-lua for long-term development](https://devforum.roblox.com/t/fusion-vs-react-lua-which-one-to-use-for-long-term-development/2781328), [Use case for Fusion / React](https://devforum.roblox.com/t/use-case-for-fusion-react-etc/3663300/6)
- [Univ. of Sydney report on Roblox monetisation practices (2026)](https://ses.library.usyd.edu.au/handle/2123/35033), [IEEE ConPro 2025: deceptive design in Roblox worlds](https://ieee-security.org/TC/SPW2025/ConPro/papers/eiger-conpro25.pdf)
- [Everything Roblox podcast: UI/UX trends 2025](https://brapodd.se/podd/everything-roblox/avsnitt/roblox-platform-evolution-infrastructure-upgrades-ui-design-trends-and-community-driven-gaming-in-2025)
