--!strict
-- ErrorReporterClient: forwards unhandled client errors to the server (ClientError remote), which
-- validates, dedupes and records them. Throttled on the client too. No PII is sent.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
local UserInputService = game:GetService("UserInputService")

local NetClient = require(ReplicatedStorage:WaitForChild("Shared").Net.Client)

local MIN_INTERVAL = 2

local ErrorReporterClient = {}
ErrorReporterClient.Priority = 200 -- start listening as early as possible

function ErrorReporterClient:Start()
	local remote = NetClient.event("ClientError")
	local lastSent = 0
	ScriptContext.Error:Connect(function(message: string, stackTrace: string)
		local now = os.clock()
		if now - lastSent < MIN_INTERVAL then
			return
		end
		lastSent = now
		local platform = UserInputService.PreferredInput.Name
		remote:FireServer(string.sub(message, 1, 500), string.sub(stackTrace or "", 1, 2000), platform)
	end)
end

return ErrorReporterClient
