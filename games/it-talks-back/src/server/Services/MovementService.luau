--!strict
-- MovementService: sprint, crouch and flashlight. Clients only send what they WANT
-- (SetSprint/SetCrouch/SetFlashlight); the server owns stamina, WalkSpeed and the light, and
-- mirrors them to player attributes for the HUD: "Stamina" (0..1), "Sprinting", "Crouched",
-- "Flashlight".

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Net = require(script.Parent.Parent.Net)
local State = require(script.Parent.Parent.Game.State)
local PlayerLifecycle = require(script.Parent.PlayerLifecycle)

type Intent = {
	sprint: boolean,
	crouch: boolean,
	light: boolean,
	stamina: number,
	exhausted: boolean,
	lastSentStamina: number,
}

local MovementService = {}
MovementService.Priority = 70

local intents: { [Player]: Intent } = {}

local function intentFor(player: Player): Intent
	local i = intents[player]
	if not i then
		i = {
			sprint = false,
			crouch = false,
			light = false,
			stamina = HorrorConfig.Player.StaminaMax,
			exhausted = false,
			lastSentStamina = -1,
		}
		intents[player] = i
	end
	return i
end

local function findLight(player: Player): SpotLight?
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local light = head and head:FindFirstChild("Flashlight")
	return if light and light:IsA("SpotLight") then light else nil
end

local function applyLight(player: Player)
	local on = intentFor(player).light and State.getStatus(player) ~= "Hidden"
	local light = findLight(player)
	if light then
		light.Enabled = on
	end
	player:SetAttribute("Flashlight", on)
end

-- Forget intent (used when a player is caged, hidden or the round resets).
function MovementService.reset(player: Player)
	local i = intentFor(player)
	i.sprint = false
	i.crouch = false
	i.light = false
	i.stamina = HorrorConfig.Player.StaminaMax
	i.exhausted = false
	player:SetAttribute("Crouched", false)
	player:SetAttribute("Sprinting", false)
	applyLight(player)
end

function MovementService.isLit(player: Player): boolean
	return player:GetAttribute("Flashlight") == true
end

function MovementService.isCrouched(player: Player): boolean
	return player:GetAttribute("Crouched") == true
end

local function step(dt: number)
	local cfg = HorrorConfig.Player
	for _, player in Players:GetPlayers() do
		local humanoid = State.humanoidOf(player)
		if not humanoid then
			continue
		end
		local i = intentFor(player)
		local status = State.getStatus(player)
		local speed = cfg.LobbySpeed
		local sprinting = false

		if status == "Alive" then
			local moving = humanoid.MoveDirection.Magnitude > 0.1
			if i.crouch then
				speed = cfg.CrouchSpeed
			elseif i.sprint and moving and not i.exhausted and i.stamina > 0 then
				speed = cfg.SprintSpeed
				sprinting = true
			else
				speed = cfg.WalkSpeed
			end
			if sprinting then
				i.stamina = math.max(0, i.stamina - dt)
				if i.stamina <= 0 then
					i.exhausted = true
				end
			else
				i.stamina = math.min(cfg.StaminaMax, i.stamina + cfg.StaminaRegen * dt)
				if i.exhausted and i.stamina >= cfg.StaminaResume then
					i.exhausted = false
				end
			end
		elseif status == "Hidden" or status == "Caged" then
			speed = if status == "Hidden" then 0 else cfg.CrouchSpeed
			i.stamina = math.min(cfg.StaminaMax, i.stamina + cfg.StaminaRegen * dt)
		end

		if humanoid.WalkSpeed ~= speed then
			humanoid.WalkSpeed = speed
		end
		if player:GetAttribute("Sprinting") ~= sprinting then
			player:SetAttribute("Sprinting", sprinting)
		end
		-- Replicate stamina in 5% steps only (no attribute spam every frame).
		local shown = math.floor(i.stamina / cfg.StaminaMax * 20 + 0.5) / 20
		if shown ~= i.lastSentStamina then
			i.lastSentStamina = shown
			player:SetAttribute("Stamina", shown)
		end
	end
end

function MovementService:Init()
	Net.handle("SetSprint", function(player: Player, on: boolean)
		intentFor(player).sprint = on
	end)
	Net.handle("SetCrouch", function(player: Player, on: boolean)
		local i = intentFor(player)
		i.crouch = on and State.getStatus(player) == "Alive"
		player:SetAttribute("Crouched", i.crouch)
	end)
	Net.handle("SetFlashlight", function(player: Player, on: boolean)
		intentFor(player).light = on
		applyLight(player)
	end)

	PlayerLifecycle.onCharacter(function(player: Player, character: Model)
		local head = character:WaitForChild("Head", 10)
		if not head then
			return
		end
		local light = Instance.new("SpotLight")
		light.Name = "Flashlight"
		light.Face = Enum.NormalId.Front
		light.Angle = 55
		light.Range = 42
		light.Brightness = 2.4
		light.Color = Color3.fromRGB(255, 244, 214)
		light.Shadows = true
		light.Enabled = false
		light.Parent = head
		MovementService.reset(player)
	end)

	State.StatusChanged:Connect(function(player: Player, status: string)
		if status ~= "Alive" then
			local i = intentFor(player)
			i.crouch = false
			player:SetAttribute("Crouched", false)
		end
		applyLight(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		intents[player] = nil
	end)

	RunService.Heartbeat:Connect(step)
end

return MovementService
