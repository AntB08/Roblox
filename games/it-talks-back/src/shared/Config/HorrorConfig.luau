--!strict
-- HorrorConfig: every tuning number for the round, the players and the monster in one place.
-- The SERVER is authoritative; clients read this only for display (stamina bar, prompts).
-- Speeds are studs/second. Player walk 14 < monster chase 16.5 < player sprint 22, so a chase is
-- "sprint to break line of sight, then hide or loop around furniture".

local HorrorConfig = {
	Round = {
		Intermission = 15, -- seconds in the lobby before a round (needs MinPlayers)
		MinPlayers = 1, -- 1 so a solo tester can play; 2+ is where the game shines
		Duration = 420, -- seconds; anyone still inside at the end is lost
		StartGrace = 12, -- the monster stays dormant this long after players arrive
		ResultsTime = 8,
		EscapeCoins = 25,
		RescueCoins = 5,
	},

	Player = {
		WalkSpeed = 14,
		SprintSpeed = 22,
		CrouchSpeed = 7,
		LobbySpeed = 16,
		StaminaMax = 5, -- seconds of sprint
		StaminaRegen = 0.6, -- per second while not sprinting
		StaminaResume = 1, -- seconds of stamina needed to start sprinting again after running dry
	},

	Monster = {
		Name = "The Tenant",
		PatrolSpeed = 9,
		InvestigateSpeed = 13,
		ChaseSpeed = 16.5,
		RageChaseSpeed = 18.5, -- after the power is back on
		CatchDistance = 4.5,
		ViewDistance = 70,
		CrouchViewDistance = 24, -- crouching players are only spotted this close
		FlashlightViewDistance = 95, -- a lit flashlight is visible from far away
		FovDot = 0.4, -- ~66 degrees each side of where it faces
		CloseSense = 9, -- always notices anyone this close (unless hidden)
		LoseSightSeconds = 3.5, -- out of sight this long -> it searches the last known spot
		SearchSeconds = 6,
		SawHideWindow = 1.5, -- hid within this many seconds of being seen -> it pulls you out
		PostCatchCooldown = 6, -- walks away after a catch, ignoring players (no cage camping)
		OtherFloorHearing = 0.55, -- noise radius multiplier when the noise is on another floor
		HintIntervalMin = 50,
		HintIntervalMax = 80,
		HintTruthChance = 0.5,
		LiesBeforeGrudge = 2, -- this many false callouts from one player -> it ignores them a while
		GrudgeSeconds = 60,
	},

	-- Noise radii (studs). The monster investigates the loudest recent noise it can hear.
	Noise = {
		Sprint = 34,
		Walk = 9,
		FusePickup = 26,
		FuseInsert = 400, -- house-wide
		Closet = 16,
		Rescue = 45,
		Callout = 400, -- it hears every callout (that's the point)
		Voice = 45, -- talking out loud (voice chat or text chat) is heard this far from you
	},

	Fuses = {
		Count = 3,
		MaxPerRoom = 2,
	},

	Voice = {
		HearRange = 80, -- subtitles show for players within this distance of the monster
		AmbientMin = 25,
		AmbientMax = 45,
		GlobalCooldown = 3.5,
		VoiceId = "1",
		Pitch = -6, -- semitones
		Speed = 0.85,
		Volume = 2.5,
		UseAI = true, -- try TextGenerator for flavor lines; canned lines are always the fallback
		AITimeout = 4, -- seconds to wait for a fresh line before speaking the canned one
		-- GPT writes the lines (Roblox text-to-speech still speaks them). Needs the API key in the
		-- game's Secrets store under SecretName and "Allow HTTP Requests" on. Falls back to Roblox's
		-- TextGenerator, then canned lines. Set Model to any chat model your key can use.
		OpenAI = {
			Enabled = true,
			SecretName = "openai_api_key",
			Model = "gpt-4o-mini",
		},
		AIMaxFailures = 3, -- after this many failures in a row, this server stops trying
	},

	Speech = {
		ReplyRange = 70, -- it answers what you said if it is this close to you
		ReplyChance = 0.7,
		ReplyCooldown = 8,
		-- Words that count as naming a room (lowercase). Saying one lures it there, true or not.
		RoomWords = {
			kitchen = "Kitchen",
			study = "Study",
			library = "Study",
			office = "Study",
			basement = "Basement",
			cellar = "Basement",
			downstairs = "Basement",
			cage = "Basement",
			hallway = "Hallway",
			hall = "Hallway",
			generator = "Hallway",
			stairs = "Stairs",
			staircase = "Stairs",
		},
	},

	Callouts = { "Kitchen", "Study", "Basement", "Hallway" },
	CalloutCooldown = 8,

	Rooms = { "Hallway", "Kitchen", "Stairs", "Study", "Basement" },
}

return table.freeze(HorrorConfig)
