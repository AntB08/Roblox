--!strict
-- Client bootstrap: the ONLY LocalScript. Loads Controllers/* (Init all, then Start all).
-- UI/ and FX/ hold helper modules that controllers require directly.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Loader"))

Loader.load(script:WaitForChild("Controllers"))
