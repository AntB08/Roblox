--!strict
-- LeaderstatsService: mirrors selected profile values into player.leaderstats (the default
-- player list). Display only: DataService is the source of truth.

local DataService = require(script.Parent.DataService)

local SHOWN = { "Coins" } -- column order; each must be a top-level number in the profile

local LeaderstatsService = {}
LeaderstatsService.Priority = 90 -- after DataService; connects in Init, before DataService:Start

function LeaderstatsService:Init()
	DataService.Loaded:Connect(function(player: Player, data: DataService.Data)
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		for _, key in SHOWN do
			local value = Instance.new("IntValue")
			value.Name = key
			value.Value = (data :: any)[key]
			value.Parent = folder
		end
		folder.Parent = player -- parent last: one replication packet, no partial state
	end)

	DataService.Changed:Connect(function(player: Player, key: string, newValue: any)
		local folder = player:FindFirstChild("leaderstats")
		local stat = folder and folder:FindFirstChild(key)
		if stat and stat:IsA("IntValue") and typeof(newValue) == "number" then
			stat.Value = newValue
		end
	end)
end

return LeaderstatsService
