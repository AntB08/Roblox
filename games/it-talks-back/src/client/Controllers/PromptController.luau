--!strict
-- PromptController: hides prompts that can't apply to the local player. Cosmetic only: the
-- server re-checks every trigger.
--   * fuses hide while you carry one; the generator prompt shows only while you carry one
--   * caged / lobby / escaped players see no house prompts
-- It hides a prompt by setting its MaxActivationDistance to 0 LOCALLY (the server never changes
-- that property, while it does toggle Enabled, e.g. on the cage door), so the two never fight.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local PROMPT_TAGS = { "GeneratorPrompt", "HidePrompt", "RescuePrompt", "FusePrompt" }

local PromptController = {}

local original: { [ProximityPrompt]: number } = {}

local function allowed(prompt: ProximityPrompt): boolean
	local status = player:GetAttribute("Status")
	local carrying = player:GetAttribute("CarryingFuse") == true
	if prompt:HasTag("HidePrompt") then
		return status == "Alive" or status == "Hidden"
	end
	if status ~= "Alive" then
		return false
	end
	if prompt:HasTag("GeneratorPrompt") then
		return carrying
	end
	if prompt:HasTag("FusePrompt") then
		return not carrying
	end
	return true
end

local function apply(prompt: ProximityPrompt)
	if original[prompt] == nil then
		original[prompt] = prompt.MaxActivationDistance
		prompt.Destroying:Connect(function()
			original[prompt] = nil
		end)
	end
	prompt.MaxActivationDistance = if allowed(prompt) then original[prompt] else 0
end

local function refresh()
	for _, tag in PROMPT_TAGS do
		for _, inst in CollectionService:GetTagged(tag) do
			if inst:IsA("ProximityPrompt") then
				apply(inst)
			end
		end
	end
end

function PromptController:Start()
	player:GetAttributeChangedSignal("Status"):Connect(refresh)
	player:GetAttributeChangedSignal("CarryingFuse"):Connect(refresh)
	for _, tag in PROMPT_TAGS do
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
			if inst:IsA("ProximityPrompt") then
				apply(inst)
			end
		end)
	end
	refresh()
end

return PromptController
