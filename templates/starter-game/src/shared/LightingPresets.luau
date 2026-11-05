--!strict
-- LightingPresets: tuned mood presets (knowledge/02 section 6), applied at runtime.
--   LightingPresets.apply("Neutral")          -- instant
--   LightingPresets.apply("CozySunset", 2)    -- tween numbers/Color3 over 2 s
--
-- The BASE look is authored in default.project.json (Lighting node) and matches "Neutral".
-- Lighting.LightingStyle and Lighting.PrioritizeLightingQuality are writable only by plugins /
-- Open Cloud (API dump: PluginOrOpenCloud), so scripts cannot change them: set them in
-- default.project.json. The `style` field below documents what each preset expects.
--
-- Server: apply for everyone. Client: apply for one player (e.g. underwater, menus).

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local rgb = Color3.fromRGB

type Props = { [string]: any }
type Preset = {
	style: "Soft" | "Realistic", -- expected Lighting.LightingStyle (set in default.project.json)
	lighting: Props,
	atmosphere: Props,
	colorCorrection: Props,
	bloom: Props,
	sunRays: Props?, -- nil => disabled
}

local PRESETS: { [string]: Preset } = {
	-- Matches default.project.json. Neutral daylight, slightly cool shadows, warm sun.
	Neutral = {
		style = "Soft",
		lighting = {
			Brightness = 2.5,
			ExposureCompensation = 0,
			ClockTime = 14,
			GeographicLatitude = 35,
			Ambient = rgb(70, 74, 86),
			OutdoorAmbient = rgb(135, 140, 155),
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 0.5,
			GlobalShadows = true,
			ShadowSoftness = 0.25,
			ColorShift_Top = rgb(255, 248, 235),
			ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = {
			Density = 0.28,
			Offset = 0.2,
			Haze = 1,
			Glare = 0.2,
			Color = rgb(205, 215, 230),
			Decay = rgb(120, 130, 150),
		},
		colorCorrection = { Brightness = 0, Contrast = 0.05, Saturation = 0.08, TintColor = rgb(255, 252, 246) },
		bloom = { Intensity = 0.35, Size = 24, Threshold = 1.2 },
	},
	CartoonSimulator = {
		style = "Soft",
		lighting = {
			Brightness = 3,
			ExposureCompensation = 0.1,
			ClockTime = 13.5,
			GeographicLatitude = 30,
			Ambient = rgb(95, 100, 120),
			OutdoorAmbient = rgb(165, 165, 180),
			EnvironmentDiffuseScale = 0.4,
			EnvironmentSpecularScale = 0.2,
			GlobalShadows = true,
			ColorShift_Top = rgb(255, 245, 225),
			ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = {
			Density = 0.25,
			Offset = 0.2,
			Haze = 0.5,
			Glare = 0,
			Color = rgb(200, 225, 255),
			Decay = rgb(150, 180, 230),
		},
		colorCorrection = { Brightness = 0.02, Contrast = 0.1, Saturation = 0.25, TintColor = rgb(255, 252, 245) },
		bloom = { Intensity = 0.4, Size = 24, Threshold = 1.2 },
		sunRays = { Intensity = 0.05, Spread = 0.4 },
	},
	CozySunset = {
		style = "Realistic",
		lighting = {
			Brightness = 2,
			ExposureCompensation = 0,
			ClockTime = 17.7,
			GeographicLatitude = 40,
			Ambient = rgb(60, 45, 55),
			OutdoorAmbient = rgb(150, 110, 105),
			EnvironmentDiffuseScale = 1,
			EnvironmentSpecularScale = 1,
			GlobalShadows = true,
			ShadowSoftness = 0.3,
			ColorShift_Top = rgb(255, 200, 150),
			ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = {
			Density = 0.35,
			Offset = 0.15,
			Haze = 1.8,
			Glare = 1.5,
			Color = rgb(255, 190, 150),
			Decay = rgb(120, 80, 120),
		},
		colorCorrection = { Brightness = 0, Contrast = 0.08, Saturation = 0.15, TintColor = rgb(255, 240, 225) },
		bloom = { Intensity = 0.6, Size = 30, Threshold = 1.0 },
		sunRays = { Intensity = 0.12, Spread = 0.6 },
	},
	FoggyHorror = {
		style = "Realistic",
		lighting = {
			Brightness = 0.6,
			ExposureCompensation = -0.4,
			ClockTime = 0.5,
			GeographicLatitude = 41.7,
			Ambient = rgb(12, 12, 16),
			OutdoorAmbient = rgb(38, 42, 52),
			EnvironmentDiffuseScale = 0.3,
			EnvironmentSpecularScale = 0.6,
			GlobalShadows = true,
			ShadowSoftness = 0.15,
			ColorShift_Top = rgb(0, 0, 0),
			ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = {
			Density = 0.7,
			Offset = 0,
			Haze = 2.5,
			Glare = 0,
			Color = rgb(90, 95, 100),
			Decay = rgb(40, 40, 50),
		},
		colorCorrection = { Brightness = -0.05, Contrast = 0.15, Saturation = -0.4, TintColor = rgb(220, 230, 255) },
		bloom = { Intensity = 0.3, Size = 20, Threshold = 1.5 },
	},
	NightCity = {
		style = "Realistic",
		lighting = {
			Brightness = 0.7,
			ExposureCompensation = 0.2,
			ClockTime = 21.5,
			GeographicLatitude = 35,
			Ambient = rgb(22, 22, 38),
			OutdoorAmbient = rgb(55, 55, 85),
			EnvironmentDiffuseScale = 0.5,
			EnvironmentSpecularScale = 1,
			GlobalShadows = true,
			ShadowSoftness = 0.2,
			ColorShift_Top = rgb(0, 0, 0),
			ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = {
			Density = 0.35,
			Offset = 0.2,
			Haze = 1.2,
			Glare = 0,
			Color = rgb(90, 100, 140),
			Decay = rgb(50, 40, 80),
		},
		colorCorrection = { Brightness = 0, Contrast = 0.12, Saturation = 0.1, TintColor = rgb(225, 230, 255) },
		bloom = { Intensity = 0.8, Size = 28, Threshold = 1.0 },
	},
}

local function isTweenable(v: any): boolean
	local t = typeof(v)
	return t == "number" or t == "Color3"
end

-- Reuses the instances authored in default.project.json (same names) instead of stacking copies.
local function getOrCreate(className: string, name: string): Instance
	local existing = Lighting:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = Lighting
	return inst
end

local function applyProps(inst: Instance, props: Props, duration: number?)
	local goals: Props = {}
	for key, value in props do
		if duration and duration > 0 and isTweenable(value) then
			goals[key] = value
		else
			(inst :: any)[key] = value
		end
	end
	if duration and duration > 0 and next(goals) then
		TweenService:Create(inst, TweenInfo.new(duration, Enum.EasingStyle.Sine), goals):Play()
	end
end

local LightingPresets = {}

function LightingPresets.names(): { string }
	local names = {}
	for name in PRESETS do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function LightingPresets.apply(name: string, duration: number?)
	local preset = PRESETS[name]
	assert(preset, `Unknown lighting preset "{name}"`)
	if Lighting.LightingStyle.Name ~= preset.style then
		warn(`[LightingPresets] "{name}" expects LightingStyle {preset.style}; set it in default.project.json`)
	end
	applyProps(Lighting, preset.lighting, duration)
	applyProps(getOrCreate("Atmosphere", "Atmosphere"), preset.atmosphere, duration)
	applyProps(getOrCreate("ColorCorrectionEffect", "ColorCorrection"), preset.colorCorrection, duration)
	applyProps(getOrCreate("BloomEffect", "Bloom"), preset.bloom, duration)
	if preset.sunRays then
		local rays = getOrCreate("SunRaysEffect", "SunRays") :: SunRaysEffect
		rays.Enabled = true
		applyProps(rays, preset.sunRays, duration)
	else
		local rays = Lighting:FindFirstChild("SunRays")
		if rays and rays:IsA("SunRaysEffect") then
			rays.Enabled = false
		end
	end
end

return table.freeze(LightingPresets)
