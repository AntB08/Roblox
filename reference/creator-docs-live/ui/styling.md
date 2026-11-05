---
title: "UI styling"
url: /docs/en-us/ui/styling
last_updated: 2026-11-05T19:16:10Z
description: "Explore how stylesheets let you declare and globally apply overrides to UI instance properties."
---

# UI styling

UI styling is a Roblox solution to stylesheets, [similar to CSS](/docs/en-us/ui/css-comparisons.md), that lets you declare and globally apply overrides to UI instance properties. This engine‑level support is the foundation for the [Style Editor](/docs/en-us/ui/editor.md) and the end‑to‑end token pipeline.

## Concepts

Style **rules** (part of a `Class.StyleSheet`) apply to every instance that matches the rule's `Class.StyleRule.Selector|Selector` definition to match characteristics such as class name, instance name, and hierarchy relationships. See the `Class.StyleRule.Selector|Selector` documentation for details.

Style **tokens**, defined through [attributes](/docs/en-us/studio/properties.md#instance-attributes) of a token `Class.StyleSheet`, represent UI property variables that can be used across styles and components, for example a common color for a `Class.Frame.BackgroundColor3`, `Class.TextLabel.TextColor3`, and `Class.UIStroke.Color`. Tokens are comparable to CSS [variables](/docs/en-us/ui/css-comparisons.md#variables).

Style **themes**, configured through [attributes](/docs/en-us/studio/properties.md#instance-attributes) of a theme `Class.StyleSheet`, consist of sets of specific tokens that can be swapped, for example color tokens that define a "light" and "dark" theme. Related themes must have the same set of tokens to work correctly.

Style **queries** allow you to apply styles conditionally based on the UI's context or environment. These are comparable to CSS [container queries and media queries](/docs/en-us/ui/css-comparisons.md#queries), enabling UI to adapt to screen size, input types, or user accessibility settings.

## Rule propagation

A `Class.StyleLink` instance links a `Class.StyleSheet` and its associated rules to a parent `Class.ScreenGui` and all of the `Class.GuiObject|GuiObjects` within it. Only one `Class.StyleSheet` can apply to a given tree.

## Selector definitions

At a high level, instance matching and modification via a rule's `Class.StyleRule.Selector|Selector` definition operates through:

- Roblox **class** selectors which target all instances of a given `Class.GuiObject` class, for example `Class.Frame`, `Class.ImageLabel`, `Class.TextButton`, etc.
- Instance [tags](/docs/en-us/studio/properties.md#instance-tags) applied to specific UI objects through `Class.CollectionService`.
- Instance **name** selection according to the value of the UI object's `Class.Instance.Name`.
- Instance **modifiers**, similar to [CSS pseudo-elements](/docs/en-us/ui/css-comparisons.md#pseudo-instances), applied through phantom `Class.UIComponent|UIComponents` such as `Class.UICorner` or `Class.UIStroke`.
- `Class.GuiObject` **state** selectors, similar to [CSS pseudo-class](/docs/en-us/ui/css-comparisons.md#pseudo-classes) selectors, which correspond to one of the four `Enum.GuiState|GuiState` enum values such as `Enum.GuiState|Hover`.
- Roblox **query** selectors, similar to [CSS container and media queries](/docs/en-us/ui/css-comparisons.md#queries), which use the `@` prefix to apply styles only while a `Class.StyleQuery` instance or pseudo‑instance with the same name is active.

#### Class Selector

The following setup shows how size and color tokens, a theme, and a class selector of `"Frame"` produce a magenta `Class.Frame` of size 200×200 pixels.

** Code Equivalent**

```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local screenGui = script.Parent

-- Tokens
local tokens = Instance.new("StyleSheet")
tokens.Name = "Tokens"
tokens.Parent = ReplicatedStorage
tokens:SetAttribute("SquareS", UDim2.fromOffset(50, 50))
tokens:SetAttribute("SquareM", UDim2.fromOffset(100, 100))
tokens:SetAttribute("SquareL", UDim2.fromOffset(200, 200))
tokens:SetAttribute("Fit", UDim2.fromScale(1, 1))
tokens:SetAttribute("Magenta", Color3.fromHex("FF0099"))
tokens:SetAttribute("Gold", Color3.fromHex("FFCC00"))
tokens:SetAttribute("Aqua", Color3.fromHex("0093F0"))

-- ThemeA
local themeA = Instance.new("StyleSheet")
themeA.Name = "ThemeA"
themeA.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeA
themeA:SetAttribute("FrameSize", "$SquareM")
themeA:SetAttribute("FrameColor", "$Aqua")

-- ThemeB
local themeB = Instance.new("StyleSheet")
themeB.Name = "ThemeB"
themeB.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeB
themeB:SetAttribute("FrameSize", "$SquareL")
themeB:SetAttribute("FrameColor", "$Magenta")

-- DesignSheet
local designSheet = Instance.new("StyleSheet")
designSheet.Name = "DesignSheet"
designSheet.Parent = ReplicatedStorage
local themeDerive = Instance.new("StyleDerive")
themeDerive.StyleSheet = themeB  -- Derive from ThemeB
themeDerive.Parent = designSheet

-- Link DesignSheet to ScreenGui
local styleLink = Instance.new("StyleLink")
styleLink.StyleSheet = designSheet
styleLink.Parent = screenGui

-- Configure rule
local rule = Instance.new("StyleRule")
rule.Selector = "Frame"  -- Class selector
rule.Parent = designSheet

-- Set rule properties
rule:SetProperties({
	["BackgroundColor3"] = "$FrameColor",
	["Size"] = "$FrameSize",
	["BorderSizePixel"] = 0
})

local frame = Instance.new("Frame")
frame.Parent = screenGui
```

#### Tag Selector

This setup shows how size/color/font tokens, a theme, and a tag selector of `".ButtonPrimary"` produces a gold button using the `Enum.Font|Oswald` font at `32` pixels.

** Code Equivalent**

```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local screenGui = script.Parent

-- Tokens
local tokens = Instance.new("StyleSheet")
tokens.Name = "Tokens"
tokens.Parent = ReplicatedStorage
tokens:SetAttribute("Text24", 24)
tokens:SetAttribute("Text32", 32)
tokens:SetAttribute("Magenta", Color3.fromHex("FF0099"))
tokens:SetAttribute("Gold", Color3.fromHex("FFCC00"))
tokens:SetAttribute("Aqua", Color3.fromHex("0093F0"))
tokens:SetAttribute("DenkOne", Enum.Font.DenkOne)
tokens:SetAttribute("Oswald", Enum.Font.Oswald)

-- ThemeA
local themeA = Instance.new("StyleSheet")
themeA.Name = "ThemeA"
themeA.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeA
themeA:SetAttribute("BackColor", "$Gold")
themeA:SetAttribute("TextSize", "$Text32")
themeA:SetAttribute("ButtonFont", "$Oswald")

-- ThemeB
local themeB = Instance.new("StyleSheet")
themeB.Name = "ThemeB"
themeB.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeB
themeB:SetAttribute("BackColor", "$Aqua")
themeB:SetAttribute("TextSize", "$Text24")
themeB:SetAttribute("ButtonFont", "$DenkOne")

-- DesignSheet
local designSheet = Instance.new("StyleSheet")
designSheet.Name = "DesignSheet"
designSheet.Parent = ReplicatedStorage
local themeDerive = Instance.new("StyleDerive")
themeDerive.StyleSheet = themeA  -- Derive from ThemeA
themeDerive.Parent = designSheet

-- Link DesignSheet to ScreenGui
local styleLink = Instance.new("StyleLink")
styleLink.StyleSheet = designSheet
styleLink.Parent = screenGui

-- Configure rule
local rule = Instance.new("StyleRule")
rule.Selector = ".ButtonPrimary"  -- Tag selector
rule.Parent = designSheet

-- Set rule properties
rule:SetProperties({
	["BackgroundColor3"] = "$BackColor",
	["TextSize"] = "$TextSize",
	["Font"] = "$ButtonFont",
	["BorderSizePixel"] = 0
})

local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.fromOffset(200, 44)
menuButton.Text = "Menu"
menuButton.Parent = screenGui
CollectionService:AddTag(menuButton, "ButtonPrimary")  -- Apply tag to button
```

#### UI Modifier Selector

This setup shows how tokens, a theme, a class selector of `"Frame"`, and a nested UI modifier selector of `"::UICorner"` produce a 300×160 orange `Class.Frame` with a `Class.UICorner` modifier of `20` pixels.

** Code Equivalent**

```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local screenGui = script.Parent

-- Tokens
local tokens = Instance.new("StyleSheet")
tokens.Name = "Tokens"
tokens.Parent = ReplicatedStorage
tokens:SetAttribute("RectS", UDim2.fromOffset(75, 40))
tokens:SetAttribute("RectM", UDim2.fromOffset(150, 80))
tokens:SetAttribute("RectL", UDim2.fromOffset(300, 160))
tokens:SetAttribute("Magenta", Color3.fromHex("FF0099"))
tokens:SetAttribute("Orange", Color3.fromHex("DD6030"))
tokens:SetAttribute("Radius20", UDim.new(0, 20))
tokens:SetAttribute("RadiusPill", UDim.new(0.5, 0))

-- ThemeA
local themeA = Instance.new("StyleSheet")
themeA.Name = "ThemeA"
themeA.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeA
themeA:SetAttribute("FrameSize", "$RectM")
themeA:SetAttribute("FrameColor", "$Magenta")
themeA:SetAttribute("CornerRad", "$Radius20")

-- ThemeB
local themeB = Instance.new("StyleSheet")
themeB.Name = "ThemeB"
themeB.Parent = ReplicatedStorage
local tokensDerive = Instance.new("StyleDerive")
tokensDerive.StyleSheet = tokens  -- Derive global tokens
tokensDerive.Parent = themeB
themeB:SetAttribute("FrameSize", "$RectL")
themeB:SetAttribute("FrameColor", "$Orange")
themeB:SetAttribute("CornerRad", "$Radius20")

-- DesignSheet
local designSheet = Instance.new("StyleSheet")
designSheet.Name = "DesignSheet"
designSheet.Parent = ReplicatedStorage
local themeDerive = Instance.new("StyleDerive")
themeDerive.StyleSheet = themeB  -- Derive from ThemeB
themeDerive.Parent = designSheet

-- Link DesignSheet to ScreenGui
local styleLink = Instance.new("StyleLink")
styleLink.StyleSheet = designSheet
styleLink.Parent = screenGui

-- Configure rules
local frameRule = Instance.new("StyleRule")
frameRule.Selector = "Frame"  -- Class selector
frameRule.Parent = designSheet
local modifierRule = Instance.new("StyleRule")
modifierRule.Selector = "::UICorner"  -- UI modifier selector
modifierRule.Parent = frameRule

-- Set rule properties
frameRule:SetProperties({
	["BackgroundColor3"] = "$FrameColor",
	["Size"] = "$FrameSize",
	["BorderSizePixel"] = 0
})
modifierRule:SetProperty("CornerRadius", "$CornerRad")

local frame = Instance.new("Frame")
frame.Parent = screenGui
```

## Modified properties

Instance properties affected by styling are flagged with a **⚠** in the **Properties** window, and hovering over an affected property shows which style is influencing it. For example, if a style rule tells a tagged `Class.Frame` to use an `Class.Frame.AnchorPoint|AnchorPoint` of

`0.5, 0.5`

, that object property will show the **default** value of

`0, 0`

 but its actual `Class.Frame.AnchorPoint|AnchorPoint` will use the rule's **styled** value.

When a default or styled property value is further modified for a specific UI object, it becomes **bold** to indicate an overridden value. For example — assuming a default `Class.Frame.AnchorPoint|AnchorPoint` of

`0, 0`

 — setting that property to

`1, 1`

 for a specific instance reveals an override in bold:

#### Default Property Value

#### Overridden Property Value

For any overridden property value, you can right-click it in the **Properties** window and select **Reset to Default** to revert it to the styled value, or to the default property value if it hasn't been styled.
</document>

<document url="/docs/en-us/ui/text-filtering.md" title="Text filtering">
