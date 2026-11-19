--!strict
-- VoiceLines: recorded voice clips for the monster, keyed by the EXACT line text in
-- src/server/Config/Lines.luau. When a line has a real asset id, clients play your recording
-- (through a light room reverb) instead of the processed text-to-speech voice.
--
-- How to make the voice:
--   1. Record or generate each line below in your horror voice (your own voice, a voice actor, or
--      an AI voice tool whose license allows commercial use in games; never clone a real person).
--   2. Export each as .ogg or .mp3 (mono is fine), trim the silence, keep it under ~6 s.
--   3. Upload in Creator Hub > Development Items > Audio, wait for moderation, then paste the id
--      here as "rbxassetid://<id>". Record each one in assets/ASSETS.md.
-- Lines with {name}/{room} placeholders can't be pre-recorded, so they're not listed. In
-- HorrorConfig.Voice.Mode = "RecordedOnly" the monster only says lines that have a recording.
-- To add a recording-only line, add it to Lines.luau first, then here.

local P = "rbxassetid://0" -- PLACEHOLDER: not recorded yet

local VoiceLines: { [string]: string } = {
	-- RoundStart
	["Somebody is in my house."] = P,
	["Oh, guests. I do love guests."] = P,
	["Lights out. Let's play a game."] = P,
	["I've been waiting so long for company."] = P,
	-- Ambient
	["I can hear you breathing."] = P,
	["This house remembers everyone who came in."] = P,
	["Come out, come out, wherever you are."] = P,
	["I know every floorboard in this place."] = P,
	["Don't you want to stay forever?"] = P,
	["I'm not angry. Not yet."] = P,
	["Tick, tock. The clock is on my side."] = P,
	-- Heard
	["What was that?"] = P,
	["I heard that."] = P,
	["You're not as quiet as you think."] = P,
	-- CalloutEmpty
	["Nobody here... were you lying to me?"] = P,
	["Empty. Hmm."] = P,
	-- ChaseStart
	["There you are."] = P,
	["Found you."] = P,
	["Don't run. It only makes it fun."] = P,
	-- Lost
	["You can't hide forever."] = P,
	["Where did you go?"] = P,
	["I'll find you. I always do."] = P,
	["Hiding? How cute."] = P,
	-- PullOut
	["I saw you go in there."] = P,
	["Knock knock."] = P,
	-- Caught
	["Into the cage you go."] = P,
	["One less guest wandering around."] = P,
	-- Rescued
	["Who let them out?!"] = P,
	["My cage! Someone opened my cage!"] = P,
	-- FuseInserted
	["Stop touching my things."] = P,
	["That generator stays OFF."] = P,
	-- PowerRestored
	["No. NO. Nobody leaves!"] = P,
	["The lights won't save you!"] = P,
}

return table.freeze(VoiceLines)
