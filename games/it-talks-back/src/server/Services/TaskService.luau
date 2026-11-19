--!strict
-- TaskService: tonight's checklist. Fuses are always on it; each night adds tasks from
-- HorrorConfig.Nights. The exit gate opens only when EVERY task is done.
--
--   Radio    a haunted radio is on in a random room. It makes noise every few seconds (pulling the
--            monster there) and the monster's voice also comes out of it. Hold to switch it off.
--   Candles  one candle per room. Hold to light. The monster snuffs lit candles it walks past.
--   Key      find the key, carry it to the exit gate and unlock it. Caught -> you drop it.
--
-- Replication (Workspace attributes): "TaskList" = "Fuses,Radio,..." (order shown in the HUD),
-- "Task_<Id>_Done" / "Task_<Id>_Goal" numbers, "ExitOpen" boolean. Player attribute "CarryingKey".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Signal = require(Shared.Packages.Signal)
local Rooms = require(Shared.Rooms)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local NoiseService = require(script.Parent.NoiseService)
local FuseService = require(script.Parent.FuseService)
local VoiceService = require(script.Parent.VoiceService)
local MonsterService = require(script.Parent.MonsterService)

local cfg = HorrorConfig.Tasks
local MAX_DISTANCE = 12
local FLAME = Color3.fromRGB(255, 170, 70)

local TaskService = {}
TaskService.Priority = 20

TaskService.AllDone = Signal.new()

type Progress = { done: number, goal: number }

local rng = Random.new()
local order: { string } = {}
local progress: { [string]: Progress } = {}
local spawned: { Instance } = {}
local candles: { BasePart } = {}
local radio: BasePart? = nil
local keyItem: BasePart? = nil
local keyCarrier: Player? = nil
local keyVisual: BasePart? = nil
local exitOpen = false

local function near(player: Player, position: Vector3): boolean
	local root = State.rootOf(player)
	return root ~= nil and (root.Position - position).Magnitude <= MAX_DISTANCE
end

local function prompt(parent: BasePart, action: string, object: string, hold: number, tag: string): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.ObjectText = object
	p.HoldDuration = hold
	p.MaxActivationDistance = 8
	p.RequiresLineOfSight = false
	p:AddTag(tag)
	p.Parent = parent
	return p
end

local function publish()
	Workspace:SetAttribute("TaskList", table.concat(order, ","))
	for id, p in progress do
		Workspace:SetAttribute(`Task_{id}_Done`, p.done)
		Workspace:SetAttribute(`Task_{id}_Goal`, p.goal)
	end
end

local function checkAllDone()
	if exitOpen or not State.isPlaying() then
		return
	end
	for _, p in progress do
		if p.done < p.goal then
			return
		end
	end
	exitOpen = true
	Workspace:SetAttribute("ExitOpen", true)
	FuseService.setGate(true)
	Net.fireAll("RoundMessage", "The exit is open!", "Get to the north gate. It's coming.", 4)
	TaskService.AllDone:Fire()
end

local function setProgress(id: string, done: number)
	local p = progress[id]
	if not p then
		return
	end
	p.done = math.clamp(done, 0, p.goal)
	publish()
	checkAllDone()
end

local function track(inst: Instance): Instance
	table.insert(spawned, inst)
	return inst
end

local function newPart(name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	return p
end

local function pick<T>(list: { T }): T?
	return if #list > 0 then list[rng:NextInteger(1, #list)] else nil
end

-- ===== Radio ======================================================================================

local function spawnRadio()
	local spot = pick(Map.parts("RadioSpawn"))
	if not spot then
		return
	end
	local body = newPart("Radio", Vector3.new(2, 1.2, 1), spot.CFrame, Color3.fromRGB(70, 45, 30), Enum.Material.Wood)
	local dial = newPart(
		"Dial",
		Vector3.new(0.6, 0.4, 0.05),
		spot.CFrame * CFrame.new(0.4, 0.1, -0.53),
		Color3.fromRGB(255, 190, 90),
		Enum.Material.Neon
	)
	dial.Parent = body
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 190, 90)
	glow.Range = 7
	glow.Brightness = 0.8
	glow.Parent = dial
	body:SetAttribute("On", true)
	body:SetAttribute("Room", spot:GetAttribute("Room"))
	body:AddTag("Radio")
	body.Parent = Workspace
	track(body)
	radio = body

	local p = prompt(body, "Turn Off", "Radio", cfg.RadioHoldSeconds, "RadioPrompt")
	p.Triggered:Connect(function(player: Player)
		if radio ~= body or body:GetAttribute("On") ~= true or not State.isFree(player) then
			return
		end
		if not near(player, body.Position) then
			return
		end
		body:SetAttribute("On", false)
		dial.Color = Color3.fromRGB(40, 40, 40)
		glow.Enabled = false
		p.Enabled = false
		NoiseService.emit(body.Position, HorrorConfig.Noise.Closet, "Radio", player)
		VoiceService.say("RadioOff", nil, true)
		setProgress("Radio", 1)
	end)
end

-- ===== Candles ====================================================================================

local function setLit(candle: BasePart, lit: boolean)
	candle:SetAttribute("Lit", lit)
	local flame = candle:FindFirstChild("Flame")
	if flame and flame:IsA("BasePart") then
		flame.Transparency = if lit then 0 else 1
		local light = flame:FindFirstChildOfClass("PointLight")
		if light then
			light.Enabled = lit
		end
	end
	local p = candle:FindFirstChildOfClass("ProximityPrompt")
	if p then
		p.Enabled = not lit
	end
	local lit_count = 0
	for _, c in candles do
		if c:GetAttribute("Lit") == true then
			lit_count += 1
		end
	end
	setProgress("Candles", lit_count)
end

local function spawnCandles()
	for _, spot in Map.parts("CandleSpawn") do
		local candle = newPart(
			"Candle",
			Vector3.new(0.5, 1.4, 0.5),
			spot.CFrame,
			Color3.fromRGB(230, 222, 200),
			Enum.Material.SmoothPlastic
		)
		local flame = newPart(
			"Flame",
			Vector3.new(0.25, 0.45, 0.25),
			spot.CFrame * CFrame.new(0, 0.95, 0),
			FLAME,
			Enum.Material.Neon
		)
		flame.Transparency = 1
		flame.Parent = candle
		local light = Instance.new("PointLight")
		light.Color = FLAME
		light.Range = 14
		light.Brightness = 1.3
		light.Shadows = true
		light.Enabled = false
		light.Parent = flame
		candle:SetAttribute("Lit", false)
		candle:SetAttribute("Room", spot:GetAttribute("Room"))
		candle:AddTag("Candle")
		candle.Parent = Workspace
		track(candle)
		table.insert(candles, candle)

		local p = prompt(candle, "Light", "Candle", cfg.CandleHoldSeconds, "CandlePrompt")
		p.Triggered:Connect(function(player: Player)
			if candle:GetAttribute("Lit") == true or not State.isFree(player) or not State.isPlaying() then
				return
			end
			if near(player, candle.Position) then
				setLit(candle, true)
			end
		end)
	end
	progress.Candles.goal = #candles
end

-- ===== Key ========================================================================================

local function dropKey(at: Vector3?)
	local carrier = keyCarrier
	if not carrier then
		return
	end
	keyCarrier = nil
	carrier:SetAttribute("CarryingKey", false)
	local position = at or (if keyVisual then keyVisual.Position else nil)
	if keyVisual then
		keyVisual:Destroy()
		keyVisual = nil
	end
	if position and keyItem and State.isPlaying() then
		keyItem.CFrame = CFrame.new(position + Vector3.new(0, 0.5, 0))
		keyItem.Transparency = 0
		local p = keyItem:FindFirstChildOfClass("ProximityPrompt")
		if p then
			p.Enabled = true
		end
	end
end

local function spawnKey()
	local spot = pick(Map.parts("KeySpawn"))
	if not spot then
		return
	end
	local key =
		newPart("Key", Vector3.new(1.2, 0.2, 0.5), spot.CFrame, Color3.fromRGB(205, 170, 80), Enum.Material.Metal)
	local glint = Instance.new("PointLight")
	glint.Color = Color3.fromRGB(255, 220, 140)
	glint.Range = 5
	glint.Brightness = 0.7
	glint.Parent = key
	key:AddTag("KeyItem")
	key.Parent = Workspace
	track(key)
	keyItem = key

	local p = prompt(key, "Take Key", "Old Key", 0.3, "KeyPrompt")
	p.Triggered:Connect(function(player: Player)
		if keyCarrier or not State.isFree(player) or not near(player, key.Position) then
			return
		end
		keyCarrier = player
		player:SetAttribute("CarryingKey", true)
		key.Transparency = 1
		p.Enabled = false
		-- Visual in hand.
		local character = player.Character
		local hand = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
		if hand and hand:IsA("BasePart") then
			local v = newPart("CarriedKey", key.Size, hand.CFrame * CFrame.new(0, -0.6, -0.2), key.Color, key.Material)
			v.Anchored = false
			v.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hand
			weld.Part1 = v
			weld.Parent = v
			v.Parent = character
			keyVisual = v
		end
		NoiseService.emit(key.Position, HorrorConfig.Noise.FusePickup, "KeyPickup", player)
		VoiceService.say("KeyTaken")
	end)

	local gate = Map.one("ExitGate")
	local unlock = prompt(gate, "Unlock", "Exit Gate", cfg.KeyUnlockHold, "GatePrompt")
	track(unlock)
	unlock.Triggered:Connect(function(player: Player)
		if keyCarrier ~= player or not State.isFree(player) or not near(player, gate.Position) then
			return
		end
		keyCarrier = nil
		player:SetAttribute("CarryingKey", false)
		if keyVisual then
			keyVisual:Destroy()
			keyVisual = nil
		end
		unlock.Enabled = false
		NoiseService.emit(gate.Position, HorrorConfig.Noise.Rescue, "Unlock", player)
		Net.notify(player, "Gate unlocked!", "success")
		setProgress("Key", 1)
	end)
end

-- ===== Lifecycle (RoundService) ===================================================================

function TaskService.reset()
	dropKey()
	for _, inst in spawned do
		inst:Destroy()
	end
	table.clear(spawned)
	table.clear(candles)
	table.clear(order)
	for id in progress do
		Workspace:SetAttribute(`Task_{id}_Done`, nil)
		Workspace:SetAttribute(`Task_{id}_Goal`, nil)
	end
	table.clear(progress)
	radio = nil
	keyItem = nil
	exitOpen = false
	Workspace:SetAttribute("ExitOpen", false)
	Workspace:SetAttribute("TaskList", "")
end

export type Night = { fuses: number, tasks: { string }, monsterSpeed: number }

function TaskService.begin(night: Night)
	TaskService.reset()
	order = { "Fuses" }
	progress.Fuses = { done = 0, goal = night.fuses }
	FuseService.spawnRound(night.fuses)
	for _, id in night.tasks do
		table.insert(order, id)
		progress[id] = { done = 0, goal = 1 }
		if id == "Radio" then
			spawnRadio()
		elseif id == "Candles" then
			spawnCandles()
		elseif id == "Key" then
			spawnKey()
		end
	end
	publish()
end

function TaskService.isExitOpen(): boolean
	return exitOpen
end

-- Every few seconds: the radio makes noise; the monster snuffs candles it walks past.
local function loop()
	local nextRadio = 0
	local snuffChecked: { [BasePart]: boolean } = {}
	while true do
		task.wait(0.25)
		if not State.isPlaying() then
			continue
		end
		local now = os.clock()
		local r = radio
		if r and r.Parent and r:GetAttribute("On") == true and now >= nextRadio then
			nextRadio = now + cfg.RadioNoiseEvery
			NoiseService.emit(r.Position, cfg.RadioNoiseRadius, "Radio", nil)
		end
		local monster = MonsterService.position()
		if monster then
			for _, candle in candles do
				local close = (candle.Position - monster).Magnitude <= cfg.CandleBlowOutDistance
				if close and not snuffChecked[candle] then
					snuffChecked[candle] = true
					if candle:GetAttribute("Lit") == true and rng:NextNumber() < cfg.CandleBlowOutChance then
						setLit(candle, false)
						MonsterService.act("Snuff", 1)
						VoiceService.say("CandleOut", { room = Rooms.at(candle.Position) })
					end
				elseif not close then
					snuffChecked[candle] = nil
				end
			end
		end
	end
end

function TaskService:Init()
	FuseService.Inserted:Connect(function(_player: Player, count: number)
		setProgress("Fuses", count)
	end)
	State.StatusChanged:Connect(function(player: Player, status: string)
		if player == keyCarrier and status ~= "Alive" and status ~= "Hidden" then
			local root = State.rootOf(player)
			dropKey(if root then root.Position else nil)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		if player == keyCarrier then
			dropKey()
		end
	end)
end

function TaskService:Start()
	Workspace:SetAttribute("ExitOpen", false)
	task.spawn(loop)
end

return TaskService
