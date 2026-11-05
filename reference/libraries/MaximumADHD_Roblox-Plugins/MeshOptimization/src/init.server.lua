----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @ MaximumADHD, 2016-2026
--   Mesh Optimization Tools
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")

local Studio = settings().Studio
local PhysicsSettings = settings().Physics
local RenderingSettings = settings().Rendering

local PLUGIN_PATCH_TITLE = "Mesh Patcher"
local PLUGIN_PATCH_SUMMARY = "Allows you to apply certain properties of each MeshPart in the Workspace with a select MeshId."
local PLUGIN_PATCH_ICON = "rbxassetid://6284437024"
local PLUGIN_TOOLBAR = "Mesh Optimization Tools"

if plugin.Name:find(".rbxm") then
	PLUGIN_TOOLBAR ..= " (LOCAL)"
end

local toolbar = plugin:CreateToolbar(PLUGIN_TOOLBAR)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Show Decomposition Geometry
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local decompOn = PhysicsSettings.ShowDecompositionGeometry
local updateSignal = PhysicsSettings:GetPropertyChangedSignal("ShowDecompositionGeometry")

local decompButton = toolbar:CreateButton(
	"Show Decomposition Geometry",
	"Toggles the visibility of Decomposition Geometry for TriangleMeshParts.",
	"rbxassetid://414888901"
)

local function onDecompClick()
	PhysicsSettings.ShowDecompositionGeometry = not PhysicsSettings.ShowDecompositionGeometry
end

local function updateGeometry(init: boolean?)
	decompOn = PhysicsSettings.ShowDecompositionGeometry
	decompButton:SetActive(decompOn)
end

updateGeometry(true)
updateSignal:Connect(updateGeometry)
decompButton.Click:Connect(onDecompClick)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mesh LOD Previewer
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Levels = {
	[0] = Enum.MeshPartDetailLevel.DistanceBased,
	[1] = Enum.MeshPartDetailLevel.Level00,
	[2] = Enum.MeshPartDetailLevel.Level01,
	[3] = Enum.MeshPartDetailLevel.Level02,
	[4] = Enum.MeshPartDetailLevel.Level03,
	[5] = Enum.MeshPartDetailLevel.Level04,
}

local Icons = {
	[0] = "rbxassetid://121685663861927", -- DISTANCE BASED
	[1] = "rbxassetid://81793100631219", -- LOD 00
	[2] = "rbxassetid://86385579484788", -- LOD 01
	[3] = "rbxassetid://134582475129399", -- LOD 02
	[4] = "rbxassetid://118710837638919", -- LOD 03
	[5] = "rbxassetid://85552618740314", -- LOD 04
}

local LODButton = toolbar:CreateButton(
	"Toggle LOD Level",
	"Jumps to the next LOD level ",
	"rbxassetid://100954789557055"
)

local function updateLODIcon()
	local currValue = RenderingSettings.MeshPartDetailLevel.Value
	LODButton.Icon = Icons[currValue] or Icons[0]

	LODButton.Enabled = false
	LODButton:SetActive(false)
	LODButton.Enabled = true
end

local function onLODClick()
	local currValue = RenderingSettings.MeshPartDetailLevel.Value
	local nextValue = currValue + 1

	if nextValue > #Levels then
		nextValue = 0
	end

	RenderingSettings.MeshPartDetailLevel = Levels[nextValue]
	updateLODIcon()
end

updateLODIcon()
LODButton.Click:Connect(onLODClick)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Transparent Boxes
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local boxButton = toolbar:CreateButton(
	"Transparent Boxes",
	"Renders nearby TriangleMeshParts (which have their CollisionFidelity set to 'Box') as mostly-transparent boxes.",
	"rbxassetid://5523395476"
)

local boxBin: Folder?
local boxOn = false

local boxes = {}
local boxThread

-- Capture regardless of CanQuery
local overlap = OverlapParams.new()
overlap.BruteForceAllSlow = true

local function createBox(part: BasePart)
	if boxes[part] then
		return boxes[part]
	end

	local sizeListener = part:GetPropertyChangedSignal("Size")
	boxBin = boxBin or CoreGui:QueryDescendants("Folder #CollisionProxies")[1]

	if boxBin == nil then
		local new = Instance.new("Folder")
		new.Name = "CollisionProxies"
		new.Parent = CoreGui
		
		boxBin = new
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Color3 = BrickColor.random().Color
	box.Transparency = 0.875
	box.Size = part.Size
	box.Adornee = part
	box.Parent = boxBin

	local signal = sizeListener:Connect(function ()
		box.Size = part.Size
	end)

	local data = {
		Adorn = box,
		Signal = signal,
		LastUpdate = 0,
	}

	boxes[part] = data
	part.LocalTransparencyModifier = 1

	return data
end

local function destroyBox(part)
	local box = boxes[part]

	if box then
		box.Adorn:Destroy()
		box.Signal:Disconnect()
	end

	boxes[part] = nil
	part.LocalTransparencyModifier = 0
end

local function updateBoxes()
	local now = os.clock()
	local camera = assert(workspace.CurrentCamera)

	local pos = camera.CFrame.Position
	local parts = workspace:GetPartBoundsInRadius(pos, 400, overlap)

	for i, part in pairs(parts) do
		if part:IsA("TriangleMeshPart") then
			local collision = part.CollisionFidelity.Name

			if collision == "Box" or (part.Anchored and not part.CanCollide and not part.CanQuery) then
				local box = createBox(part)
				box.LastUpdate = now
			end
		end
	end

	for part, box in boxes do
		if box.LastUpdate ~= now then
			destroyBox(part)
		end
	end
end

local function clearBoxes()
	while true do
		local part = next(boxes)

		if part then
			destroyBox(part)
		else
			break
		end
	end

	if boxBin then
		boxBin:Destroy()
		boxBin = nil
	end

	if boxThread then
		task.cancel(boxThread)
	end
end

local function onBoxClick()
	boxOn = not boxOn
	boxButton:SetActive(boxOn)

	if boxOn then
		boxThread = task.spawn(function()
			while boxOn do
				updateBoxes()
				task.wait(1)
			end
		end)
	else
		clearBoxes()
	end
end

boxButton.Click:Connect(onBoxClick)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mesh Patcher
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ui = script.UI
local patch = ui.Patch

local meshId = ui.MeshId
local otherTypes = ui.Other
local fluidTypes = ui.FluidFidelity
local collisionTypes = ui.CollisionFidelity
local renderingTypes = ui.RenderFidelity

local precisionFrame = ui.CollisionPrecision
local precisionEditor = precisionFrame.Editor
local precisionInput = precisionEditor.Input
local precisionBar = precisionEditor.Bar
local precisionSlider = precisionBar.Slider
local precisionDragger = precisionSlider.Dragger
local precisionFill = precisionBar.Fill

local input = meshId.Input
local autoCheck = meshId.AutoSet
local preserveOptionsCheck = meshId.PreserveOtherOptions

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false, -- Widget will be initially disabled
	false, -- Override the previous enabled state
	250, -- Default width of the floating window
	500 -- Default height of the floating window
)

local guiGuid = "MeshPatcher"
local themes = require(script.Themes)

if plugin.Name:find(".rbxm") then
	guiGuid ..= " (LOCAL)"
end

local pluginGui = plugin:CreateDockWidgetPluginGuiAsync(guiGuid, widgetInfo)
pluginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pluginGui.Title = "Mesh Patcher"
pluginGui.Name = guiGuid

local patcherButton = toolbar:CreateButton(PLUGIN_PATCH_TITLE, PLUGIN_PATCH_SUMMARY, PLUGIN_PATCH_ICON)
local enabledChanged = pluginGui:GetPropertyChangedSignal("Enabled")

local autoSet = true
local preserveOriginalOptions = false

local props = {} :: {
	[string]: any
}

local setters = {} :: {
	[string]: (boolean) -> ()
}

local groupSetters = {} :: {
	[string]: {
		[string]: (boolean) -> ()
	}
}

local function onPatcherButtonClick()
	pluginGui.Enabled = not pluginGui.Enabled
end

local function onEnabledChanged()
	patcherButton:SetActive(pluginGui.Enabled)
end

local function applyTheme()
	local theme = Studio.Theme

	for _, element in pairs(pluginGui:GetDescendants()) do
		local themeType = element:GetAttribute("Theme") :: string
		local config = themes[themeType]

		if not config then
			continue
		end

		for prop, style in pairs(config) do
			local color = theme:GetColor(style);
			(element :: any)[prop] = color
		end
	end
end

local precision = tonumber(precisionInput.Text) or 0.5

local function updateTunable()
	local tunable = (props.CollisionFidelity == "Tunable")
	precisionFrame.Visible = tunable

	if tunable then
		props.CollisionPrecision = precision
	else
		props.CollisionPrecision = nil
	end
end

local function setPrecision(value: number)
	precision = math.clamp(value, 0, 1)
	precisionInput.Text = string.format("%.3f", precision)
	precisionFill.Size = UDim2.fromScale(precision, 1)
	precisionSlider.Position = UDim2.new(precision, -2, 0.5, 0)

	if props.CollisionFidelity == "Tunable" then
		props.CollisionPrecision = precision
	end
end

local function onDrag(inputPosition: Vector2)
	local barPos = precisionBar.AbsolutePosition.X
	local barSize = precisionBar.AbsoluteSize.X

	if barSize > 0 then
		setPrecision((inputPosition.X - barPos) / barSize)
	end
end

local function onPrecisionFocusLost()
	local value = tonumber(precisionInput.Text)

	if value then
		setPrecision(value)
	else
		precisionInput.Text = string.format("%.3f", precision)
	end
end

local CHECKED = "☑"
local UNCHECKED = "☐"

local function getLabel(button: TextButton): (string, boolean)
	local title = button.Text
	local display = button:GetAttribute("DisplayName")

	local glyph = title:sub(1, #CHECKED)
	local isValid = glyph == CHECKED or glyph == UNCHECKED
	local isChecked = isValid and glyph == CHECKED

	if isValid then
		title = title:sub(#glyph + 1):gsub("^%s+", "")
	end

	if typeof(display) == "string" then
		title = display
	end

	return title, isChecked
end

local function registerCheckBox(
	button: TextButton,
	title: string,
	callback: (boolean, string, string?) -> (),
	group: string?
)
	local label, init = getLabel(button)
	local checked: boolean?

	local function setChecked(value: boolean)
		if typeof(value) ~= "boolean" then
			value = not not value
		end

		if checked == value then
			return
		end

		checked = value
		button.Text = `{checked and CHECKED or UNCHECKED} {label}`

		if callback then
			callback(value, title, group)
		end
	end

	local function onActivated()
		setChecked(not checked)
	end

	if group then
		local groupSet = groupSetters[group] or {}
		groupSet[title] = setChecked
		groupSetters[group] = groupSet
	else
		setters[title] = setChecked
	end

	setChecked(init)
	button.Activated:Connect(onActivated)
end

local function registerCheckBoxes(bin: GuiObject, callback: (boolean, string, string?) -> (), group: string?)
	for _, check in pairs(bin:GetChildren()) do
		if check:IsA("TextButton") then
			registerCheckBox(check, check.Name, callback, group)
		end
	end
end

local function onMultiToggle(checked, propName)
	props[propName] = checked
end

local function onSingleToggle(checked: boolean, option: string, group: string?)
	if not group then
		return
	end

	if checked then
		local oldValue = props[group]
		local groupSet = groupSetters[group]

		if groupSet and oldValue and oldValue ~= option then
			local setOld = groupSet[oldValue]

			if setOld then
				setOld(false)
			end
		end

		props[group] = option
	elseif props[group] == option then
		props[group] = nil
	end

	if group == "CollisionFidelity" then
		updateTunable()
	end
end

local function setGroupOption(group: string, option: string)
	local groupSet = groupSetters[group]
	local setOption = groupSet and groupSet[option]

	if setOption then
		setOption(true)
	end
end

local function onSelectionChanged()
	if not autoSet then
		return
	end

	if not pluginGui.Enabled then
		return
	end

	local selected = Selection:Get()
	local target

	for i = #selected, 1, -1 do
		local object = selected[i]

		if object:IsA("MeshPart") then
			target = object
			break
		end
	end

	if not target then
		return
	end

	local meshId = target.MeshId
	input.Text = meshId

	setPrecision(target.CollisionPrecision)
	setGroupOption("FluidFidelity", target.FluidFidelity.Name)
	setGroupOption("RenderFidelity", target.RenderFidelity.Name)
	setGroupOption("CollisionFidelity", target.CollisionFidelity.Name)

	for prop, set in pairs(props) do
		local value = target[prop]
		local valueType = typeof(value)

		if valueType == "boolean" then
			setters[prop](value)
		end
	end
end

local function onPatch()
	local targetId = input.Text

	if targetId:gsub(" ", "") == "" then
		warn("No Target MeshId provided?")
		return
	end

	local targets = {}

	for _, desc in pairs(workspace:GetDescendants()) do
		if desc:IsA("MeshPart") and desc.MeshId == targetId then
			targets[desc] = true
		end
	end

	if not next(targets) then
		warn("No MeshParts found with Target MeshId:", targetId)
		return
	end

	
	local typesToSkip = {}
	ChangeHistoryService:SetWaypoint("Before Mesh Patch")

	if preserveOriginalOptions then
		for _, type in otherTypes:GetChildren() do
			if type:IsA("GuiButton") then
				table.insert(typesToSkip, type.Name)
			end
		end

		warn(`The following properties will be preserved: {table.concat(typesToSkip, ", ")}`)
	end

	for meshPart in pairs(targets) do
		for prop, value in pairs(props) do
			if table.find(typesToSkip, prop) then
				continue
			end

			(meshPart :: any)[prop] = value
		end
	end

	ChangeHistoryService:SetWaypoint("After Mesh Patch")
end

ui.Parent = pluginGui
applyTheme()

registerCheckBoxes(collisionTypes, onSingleToggle, "CollisionFidelity")
registerCheckBoxes(renderingTypes, onSingleToggle, "RenderFidelity")
registerCheckBoxes(fluidTypes, onSingleToggle, "FluidFidelity")
registerCheckBoxes(otherTypes, onMultiToggle)

registerCheckBox(autoCheck, "Auto-set options from selected MeshPart", function (checked)
	autoSet = checked

	if autoSet then
		onSelectionChanged()
	end
end)

registerCheckBox(preserveOptionsCheck, "Enable 'Other Flags'", function (checked)
	preserveOriginalOptions = not checked
	otherTypes.Visible = checked
end)

updateTunable()
setPrecision(precision)

-- The knob is positioned by setPrecision; CustomScale keeps the
-- drag detector from also moving it on its own.
precisionDragger.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale
patcherButton:SetActive(pluginGui.Enabled)

patch.Activated:Connect(onPatch)
precisionDragger.DragStart:Connect(onDrag)
precisionDragger.DragContinue:Connect(onDrag)
precisionDragger.DragEnd:Connect(onDrag)
precisionInput.FocusLost:Connect(onPrecisionFocusLost)
Studio.ThemeChanged:Connect(applyTheme)
enabledChanged:Connect(onEnabledChanged)
patcherButton.Click:Connect(onPatcherButtonClick)
Selection.SelectionChanged:Connect(onSelectionChanged)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
