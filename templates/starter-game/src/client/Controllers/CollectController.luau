--!strict
-- CollectController: the EXAMPLE VERTICAL SLICE (client half). See Server/Services/CollectService.
--   * tracks parts tagged "CollectNode" (CollectionService; works with StreamingEnabled)
--   * shows the authored HUD CollectButton when a ready node is within range
--   * button / E key / gamepad X -> Remotes.Collect:FireServer(node)   (intent only)
--   * CollectResult -> RewardBurst (particles + light + sound) + toast + coin pop (UIController)
--     + tiny camera shake; the node dims locally until its cooldown ends
-- The client's range/cooldown checks are only for UI; the server re-checks everything.

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)
local Assets = require(Shared.Config.Assets)
local NetClient = require(Shared.Net.Client)
local Types = require(Shared.Types)
local Trove = require(Shared.Packages.Trove)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)
local AnimatedButton = require(Client.UI.AnimatedButton)
local RewardBurst = require(Client.FX.RewardBurst)
local CameraShaker = require(Client.FX.CameraShaker)
local Sfx = require(Client.FX.Sfx)

local CONFIG = GameConfig.Collect
local SCAN_INTERVAL = 0.15
local PENDING_TIMEOUT = 2
local DIMMED = 0.7
local ACTION = "CollectNearest"

local CollectController = {}

local trove = Trove.new()
local nodes: { [BasePart]: boolean } = {}
local readyAt: { [BasePart]: number } = {} -- client-side display cooldown only
local nearest: BasePart? = nil
local pendingNode: BasePart? = nil
local pendingSince = 0

local function addNode(instance: Instance)
	if instance:IsA("BasePart") then
		nodes[instance] = true
	end
end

local function removeNode(instance: Instance)
	if instance:IsA("BasePart") then
		nodes[instance] = nil
		readyAt[instance] = nil
	end
end

local function surfaceDistance(root: BasePart, node: BasePart): number
	local radius = math.max(node.Size.X, node.Size.Y, node.Size.Z) / 2
	return (root.Position - node.Position).Magnitude - radius
end

local function findNearest(): BasePart?
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (root and root:IsA("BasePart")) then
		return nil
	end
	local now = os.clock()
	local best: BasePart? = nil
	local bestDistance = CONFIG.MaxDistance
	for node in nodes do
		if node.Parent and (readyAt[node] or 0) <= now then
			local d = surfaceDistance(root, node)
			if d <= bestDistance then
				best, bestDistance = node, d
			end
		end
	end
	return best
end

local function dim(node: BasePart, seconds: number)
	readyAt[node] = os.clock() + seconds
	node.LocalTransparencyModifier = DIMMED -- local only, never replicates
	task.delay(seconds, function()
		if node.Parent and (readyAt[node] or 0) <= os.clock() then
			node.LocalTransparencyModifier = 0
		end
	end)
end

local function requestCollect()
	local node = nearest
	if not node or pendingNode then
		return
	end
	pendingNode, pendingSince = node, os.clock()
	NetClient.event("Collect"):FireServer(node)
end

local function onResult(result: Types.CollectResult)
	local node = pendingNode
	pendingNode = nil
	if typeof(result) ~= "table" then
		return
	end
	if result.ok then
		if node then
			dim(node, result.cooldown or CONFIG.CooldownSeconds)
		end
		local position = result.position or (node and node.Position)
		if typeof(position) == "Vector3" then
			RewardBurst.Play(position, { count = 24, sound = Assets.Sounds.Collect })
		end
		CameraShaker.AddTrauma(0.15)
		Toast.show(`+{result.amount or 0} {GameConfig.Currency}`, "success", 1.5)
	else
		Sfx.play(Assets.Sounds.Error, 0.6)
		if result.reason == "Cooldown" then
			if node and result.cooldown then
				dim(node, result.cooldown)
			end
			Toast.show("Recharging…", "warning", 1.5)
		elseif result.reason == "NotLoaded" then
			Toast.show("Loading your data…", "info", 2)
		elseif result.reason == "TooFar" then
			Toast.show("Move closer", "warning", 1.5)
		end
	end
end

function CollectController:Start()
	local button = Hud.find("BottomCenter/CollectButton") :: TextButton
	local keyHint = button:FindFirstChild("KeyHint") :: TextLabel?

	AnimatedButton.wrap(button, {
		onActivated = function()
			requestCollect()
		end,
	})

	trove:Connect(NetClient.event("CollectResult").OnClientEvent, onResult)

	-- Nodes: current + streamed in/out later.
	for _, instance in CollectionService:GetTagged(CONFIG.Tag) do
		addNode(instance)
	end
	trove:Connect(CollectionService:GetInstanceAddedSignal(CONFIG.Tag), addNode)
	trove:Connect(CollectionService:GetInstanceRemovedSignal(CONFIG.Tag), removeNode)

	-- Keyboard E / gamepad X (touch uses the big HUD button, so no extra touch button).
	ContextActionService:BindAction(ACTION, function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin and nearest then
			requestCollect()
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
	trove:Add(function()
		ContextActionService:UnbindAction(ACTION)
	end)

	local function refreshHint()
		if keyHint then
			keyHint.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
		end
	end
	trove:Connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), refreshHint)
	refreshHint()

	-- One coarse loop (not per-frame): find the nearest ready node and toggle the button.
	trove:Add(task.spawn(function()
		while true do
			if pendingNode and os.clock() - pendingSince > PENDING_TIMEOUT then
				pendingNode = nil -- result lost (e.g. server rejected silently); allow retry
			end
			nearest = findNearest()
			button.Visible = nearest ~= nil
			task.wait(SCAN_INTERVAL)
		end
	end))
end

return CollectController
