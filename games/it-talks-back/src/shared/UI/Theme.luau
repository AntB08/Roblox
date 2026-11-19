--!strict
-- Theme: the single source of truth for UI tokens (spacing on a 4/8 grid, radii, colors, fonts,
-- text sizes, motion). The authored HUD (src/gui/HUD.model.json) uses the same values; code that
-- creates small dynamic UI (toasts) reads them from here. Restyle a game by editing this file
-- and the .model.json together.

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
	TextOnAccent = Color3.fromRGB(16, 18, 24),
	Primary = Color3.fromRGB(64, 145, 255),
	PrimaryDark = Color3.fromRGB(34, 98, 196),
	Success = Color3.fromRGB(46, 204, 113),
	Warning = Color3.fromRGB(255, 176, 32),
	Danger = Color3.fromRGB(235, 72, 72),
	Coins = Color3.fromRGB(255, 200, 40),
}

Theme.Font = {
	Regular = Font.fromName("BuilderSans", Enum.FontWeight.Regular),
	Medium = Font.fromName("BuilderSans", Enum.FontWeight.Medium),
	Bold = Font.fromName("BuilderSans", Enum.FontWeight.Bold),
	Heavy = Font.fromName("BuilderSans", Enum.FontWeight.ExtraBold),
}

-- Logical px at the 1280x720 design canvas, before the responsive UIScale.
Theme.TextSize = { caption = 14, label = 16, body = 18, heading = 22, title = 28, display = 44 }

-- Seconds. Keep UI motion short; honor GuiService.ReducedMotionEnabled in every tween.
Theme.Motion = { Fast = 0.08, Normal = 0.18, Slow = 0.35 }

-- Minimum touch target after scaling (px).
Theme.MinTouchTarget = 44

return table.freeze(Theme)
