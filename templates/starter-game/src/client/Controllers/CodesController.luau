--!strict
-- CodesController: the authored CodesPanel (HUD). Opens from the Codes button, closes with the
-- × button or gamepad B. Input is pre-checked with the shared CodeFormat rules; the server
-- re-normalizes and decides. Result keys map to player-facing messages here (localize later).

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CodeFormat = require(Shared.Util.CodeFormat)
local NetClient = require(Shared.Net.Client)
local Assets = require(Shared.Config.Assets)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)
local AnimatedButton = require(Client.UI.AnimatedButton)
local Sfx = require(Client.FX.Sfx)

local CLOSE_ACTION = "CloseCodesPanel"

local MESSAGES: { [string]: { text: string, kind: Toast.Kind } } = {
	OK = { text = "Code redeemed!", kind = "success" },
	INVALID = { text = "That code isn't valid.", kind = "error" },
	EXPIRED = { text = "That code has expired.", kind = "warning" },
	ALREADY_REDEEMED = { text = "You already used that code.", kind = "warning" },
	SOLD_OUT = { text = "That code has run out.", kind = "warning" },
	ACCOUNT_TOO_NEW = { text = "Your account is too new for this code.", kind = "warning" },
	BUSY = { text = "One moment…", kind = "info" },
	NOT_LOADED = { text = "Loading your data…", kind = "info" },
	ERROR = { text = "Something went wrong. Try again.", kind = "error" },
}

local CodesController = {}

function CodesController:Start()
	local panel = Hud.find("CodesPanel") :: Frame
	local input = Hud.find("CodesPanel/Body/Input") :: TextBox
	local redeemButton = Hud.find("CodesPanel/Body/RedeemButton") :: GuiButton
	local closeButton = Hud.find("CodesPanel/CloseButton") :: GuiButton
	local openButton = Hud.find("LeftStack/Menu/CodesButton") :: GuiButton

	local busy = false

	local function close()
		panel.Visible = false
		ContextActionService:UnbindAction(CLOSE_ACTION)
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
			GuiService.SelectedObject = nil
		end
	end

	local function open()
		panel.Visible = true
		input.Text = ""
		GuiService.SelectedObject = redeemButton -- gamepad focus lands inside the modal
		ContextActionService:BindAction(CLOSE_ACTION, function(_, state: Enum.UserInputState)
			if state == Enum.UserInputState.Begin then
				close()
				return Enum.ContextActionResult.Sink
			end
			return Enum.ContextActionResult.Pass
		end, false, Enum.KeyCode.ButtonB)
	end

	local function redeem()
		if busy then
			return
		end
		local code = CodeFormat.normalize(input.Text)
		if not code then
			Sfx.play(Assets.Sounds.Error, 0.6)
			Toast.show("Codes use letters, numbers, - and _.", "error")
			return
		end
		busy = true
		local ok, result = NetClient.invoke("RedeemCode", code)
		busy = false
		local key = if ok and typeof(result) == "string" then result else "ERROR"
		local message = MESSAGES[key] or MESSAGES.ERROR
		Toast.show(message.text, message.kind)
		if key == "OK" then
			Sfx.play(Assets.Sounds.Reward, 0.8)
			close()
		else
			Sfx.play(Assets.Sounds.Error, 0.6)
		end
	end

	AnimatedButton.wrap(openButton, {
		onActivated = function()
			if panel.Visible then
				close()
			else
				open()
			end
		end,
	})
	AnimatedButton.wrap(closeButton, { onActivated = close })
	AnimatedButton.wrap(redeemButton, { onActivated = redeem })
	input.FocusLost:Connect(function(enterPressed: boolean)
		if enterPressed then
			redeem()
		end
	end)
end

return CodesController
