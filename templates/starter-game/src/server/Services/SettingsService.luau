--!strict
-- SettingsService: persists player settings sent with the SetSetting remote.
-- Net validates (key must be in GameConfig.Settings, value a finite number in 0..1) and
-- rate-limits; DataService clamps, saves, and mirrors to player attribute Setting_<Key>.

local Net = require(script.Parent.Parent.Net)
local DataService = require(script.Parent.DataService)

local SettingsService = {}

function SettingsService:Init()
	Net.handle("SetSetting", function(player: Player, key: string, value: number)
		DataService.setSetting(player, key, value)
	end)
end

return SettingsService
