--!strict
-- Hud: access to the AUTHORED HUD ScreenGui (src/gui/HUD.model.json, cloned from StarterGui into
-- PlayerGui). Controllers find named instances here and only bind behavior; they never build the
-- HUD in code, so it stays editable in Studio / JSON.
--
--   local hud = Hud.get()                         -- yields (timeout) until the HUD exists
--   local button = Hud.find("BottomCenter/CollectButton") :: TextButton

local Players = game:GetService("Players")

local TIMEOUT = 60

local Hud = {}

local cached: ScreenGui? = nil

function Hud.get(): ScreenGui
	if cached and cached.Parent then
		return cached
	end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:WaitForChild("HUD", TIMEOUT)
	assert(gui and gui:IsA("ScreenGui"), "[Hud] PlayerGui.HUD not found (is StarterGui.HUD in the project?)")
	cached = gui
	return gui
end

-- Finds a descendant by slash-separated path, e.g. "LeftStack/Menu/DailyButton". Errors with the
-- full path if a piece is missing, so renamed instances fail loudly instead of silently.
function Hud.find(path: string): Instance
	local node: Instance = Hud.get()
	for _, part in string.split(path, "/") do
		local child = node:WaitForChild(part, 10)
		assert(child, `[Hud] missing "{part}" in HUD path "{path}"`)
		node = child
	end
	return node
end

return Hud
