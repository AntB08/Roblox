---
title: "Input"
url: /docs/en-us/input
last_updated: 2026-11-05T19:15:54Z
description: "Summary of cross-platform input on Roblox and implementation guidelines."
---

# Input

Every game needs to receive user input for players to interact and view their environment. Roblox supports nearly all forms of input, including [mouse/keyboard](/docs/en-us/input/mouse-and-keyboard.md), [touch](/docs/en-us/input/mobile.md), [gamepads](/docs/en-us/input/gamepad.md), and VR.

## Cross-platform input

Roblox is inherently [cross‑platform](/docs/en-us/projects/cross-platform.md), as players can discover and join games on their phone or tablet, then later continue where they left off on their PC or console. Input is especially important as part of your cross‑platform development plan.

To simplify this process, Roblox provides the [Input Action System](/docs/en-us/input/input-action-system.md) to define **actions** such as "jump," "sprint," or "shoot" and set up **bindings** for multiple hardware inputs to drive those actions. This frees you from thinking of all the technical aspects of hardware inputs and allows you to simply define which inputs perform which actions.

## Input type detection

In cross‑platform development, it's important that you determine and respond to the **primary** input type a player is using, normally to ensure that [UI elements](/docs/en-us/ui.md#ui-objects) like on‑screen buttons and menus work elegantly across devices.

For example, a touch‑enabled device assumes touch is the default input and that touch buttons may appear for actions, but if a player connects an additional bluetooth keyboard/mouse or gamepad, you can assume they want to switch to that as the **primary** input type and possibly use touch as a backup input for on‑screen UI. The read‑only `Class.UserInputService.PreferredInput` property is a convenient way to test for and adapt to multiple input types across multiple device types, based on anticipated player behavior.

#### Behavior

The value of `Class.UserInputService.PreferredInput|PreferredInput` changes based on built‑in device inputs and the player's most recent interaction with a connected gamepad or keyboard/mouse. Examples include:

| Real-World Scenario | `PreferredInput` |
| --- | --- |
| Player is using a phone with no other connected input devices; no possibility of an input type change. | `Enum.PreferredInput\|Touch` |
| Player is using a mobile device with a bluetooth keyboard & mouse connected, but no gamepad is connected. | `Enum.PreferredInput\|KeyboardAndMouse` |
| Player is using a tablet with a bluetooth gamepad connected, but no keyboard or mouse is connected. | `Enum.PreferredInput\|Gamepad` |
| Player is using an Xbox or PlayStation with a bluetooth keyboard & mouse connected and has most recently interacted with the keyboard or mouse. | `Enum.PreferredInput\|KeyboardAndMouse` |
| Player is on a Windows or Mac PC with a gamepad connected and has most recently interacted with the gamepad. | `Enum.PreferredInput\|Gamepad` |

#### Benefits

Importantly, the `Class.UserInputService.PreferredInput|PreferredInput` property overcomes the following issues related to `Class.UserInputService.TouchEnabled` and `Class.UserInputService:GetLastInputType()`, both traditionally used to detect input types.

- `Class.UserInputService.TouchEnabled|TouchEnabled` is `true` on laptops with touch screens, so it is **not** a proper "is mobile" check.
- UI layouts for gamepad or keyboard/mouse may be more appropriate even if a device has touch capability, for example a mobile device with a bluetooth gamepad connected.
- Multiple `Class.UserInputService:GetLastInputType()|GetLastInputType()` values may represent the same input device, requiring compound `or` logic in scripts. For example, `Enum.UserInputType|MouseWheel`, `Enum.UserInputType|MouseMovement`, and `Enum.UserInputType|MouseButton1` all represent a mouse.
- `Class.UserInputService:GetLastInputType()|GetLastInputType()` frequently thrashes between `Enum.UserInputType|MouseMovement` and `Enum.UserInputType|Keyboard` which may cause code to run more often than expected. Similarly, thrashes between `Enum.UserInputType|Touch` and `Enum.UserInputType|Gamepad[]` may cause on‑screen UI to flicker between layouts.
- `Class.UserInputService:GetLastInputType()|GetLastInputType()` may return confusing values such as `Enum.UserInputType|TextInput`, `Enum.UserInputType|Focus`, and `Enum.UserInputType|InputMethod`.

> **Info:** For advanced workflows or control schemes that rely on detecting and responding to the player's **specific** most recent UserInputType, you can continue using UserInputService:GetLastInputType() and UserInputService.LastInputTypeChanged.

The following `Class.LocalScript` is a template for initially detecting the preferred input and responding to changes during gameplay.

```lua
local UserInputService = game:GetService("UserInputService")

local function preferredInputChanged()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		-- Player is on touch-enabled device with no other input types available/connected
		print("Touch")
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		-- Player has connected or most recently interacted with a gamepad
		print("Gamepad")
	elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		-- Player has connected or most recently interacted with a keyboard or mouse
		print("KeyboardAndMouse")
	end
end

preferredInputChanged()

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	preferredInputChanged()
end)
```

## Default bindings

Roblox provides default input bindings for movement, camera control, and basic environment interaction — Roblox players are familiar with these controls, so you should only override them in specific cases. Also note that the **reserved** inputs cannot be overridden and will always operate with their intended purpose.

#### Roblox Reserved

| Action | Mouse/Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Open Roblox menu | `Esc` | `Start` button (`Enum.KeyCode\|ButtonStart`) | N/A |
| [Developer Console](/docs/en-us/studio/developer-console.md) | `F9` | N/A | N/A |
| Fullscreen mode (Windows)<br>Show desktop (Mac) | `F11` | N/A | N/A |
| Record video (Windows) | `F12` | N/A | N/A |
| Take screenshot | `PrintScreen` | N/A | N/A |

#### Character

| Action | Mouse/Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Move forward | `W` `↑` | Press up on primary thumbstick | Press up on virtual thumbstick |
| Move backward | `S` `↓` | Press down on primary thumbstick | Press down on virtual thumbstick |
| Move left | `A` | Press left on primary thumbstick | Press left on virtual thumbstick |
| Move right | `D` | Press right on primary thumbstick | Press right on virtual thumbstick |
| Jump | `Space` |   | Tap virtual jump button |

#### Interface / Inventory

> **Info:** The following action inputs are reserved unless you [disable the respective feature](/docs/en-us/players/disable-ui.md).

| Action | Mouse/Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Open text chat | `/` | N/A | N/A |
| Show/hide players list | `Tab` | N/A | N/A |
| Toggle backpack | ``` | N/A | N/A |
| Equip/unequip tools | `0`-`9` | Swap between tools using front‑left and front‑right triggers (`Enum.KeyCode.ButtonL1\|ButtonL1` and `Enum.KeyCode.ButtonR1\|ButtonR1`) | Tap on-screen tool icons |
| Use equipped tool | Click left mouse button | Back‑right trigger (`Enum.KeyCode.ButtonR2\|ButtonR2`) | Tap on screen |
| Drop equipped tool | `Backspace` | N/A | N/A |
| Toggle **UI selection** mode¹ | `\` | `Select` button (`Enum.KeyCode.ButtonSelect\|ButtonSelect`) | N/A |
| Navigate among interactive UI elements while in **UI selection** mode | `↑` `↓` `←` `→`<br>`W` `S` `A` `D` | Primary thumbstick (`Enum.KeyCode.Thumbstick1\|Thumbstick1`) or D‑pad (`Enum.KeyCode.DPadUp\|DPadUp`; `Enum.KeyCode.DPadDown\|DPadDown`; `Enum.KeyCode.DPadLeft\|DPadLeft`; `Enum.KeyCode.DPadRight\|DPadRight`) | |
| Activate an interactive UI element while in **UI selection** mode | `Enter` | Back‑right trigger (`Enum.KeyCode.ButtonR2\|ButtonR2`) | |
| Scroll up/down/left/right in selected `Class.ScrollingFrame` while in **UI selection** mode | `PageUp`<br>`PageDown`<br>`Home`<br>`End` | Secondary thumbstick (`Enum.KeyCode.Thumbstick2\|Thumbstick2`) | |

_¹ If `Class.GuiService.GuiNavigationEnabled|GuiNavigationEnabled` is enabled (default)_

#### Camera

| Action | Mouse/Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Move camera view around | While holding right mouse button | Move secondary thumbstick | Touch-drag around screen |
| Zoom camera in/out | Mouse scroll wheel<br>`I`/`O` | Press secondary thumbstick | Pinch in/out on screen |
| Rotate camera left or right | `←` `→` | N/A | N/A |
| Toggle mouse lock² | `Shift` | N/A | N/A |

_² If `Class.StarterPlayer.EnableMouseLockOption|EnableMouseLockOption` is enabled (default)_
</document>

<document url="/docs/en-us/input/input-action-system.md" title="Input Action System">
