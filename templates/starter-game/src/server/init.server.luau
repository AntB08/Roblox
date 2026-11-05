--!strict
-- Server bootstrap: the ONLY server Script. Everything else is a ModuleScript.
-- Order: create every remote (so clients can WaitForChild them), then load Services/*
-- (Init all in Priority order, then Start all).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage:WaitForChild("Shared").Loader)
local Net = require(script.Net)

Net.createAll()
Loader.load(script.Services)

print(`[Server] booted (place version {game.PlaceVersion})`)
