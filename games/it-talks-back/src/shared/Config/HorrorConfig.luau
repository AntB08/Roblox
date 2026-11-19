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

	-- Nights: survive a night (at least one escape) and the next round is the next night.
	-- Lose and you replay it. After the last entry, the last night repeats and the monster keeps
	-- getting a little faster (ExtraSpeedPerNight).
	-- Tasks: "Radio" (switch off the haunted radio), "Candles" (light every candle), "Key"
	-- (find the key, unlock the exit gate). Fuses are always a task.
	Nights = {
		{ fuses = 2, tasks = { "Key" }, monsterSpeed = 1 },
		{ fuses = 3, tasks = { "Radio", "Candles" }, monsterSpeed = 1.04 },
		{ fuses = 3, tasks = { "Radio", "Candles", "Key" }, monsterSpeed = 1.08 },
	},
	ExtraSpeedPerNight = 0.03,
	MaxMonsterSpeed = 1.25,

	-- The director: what changes every night so a replayed night still plays differently.
	Variety = {
		-- Monster personalities (one per night, random). Multipliers on the Monster values above.
		Personalities = {
			Stalker = {
				view = 1.25,
				hear = 0.9,
				speed = 0.95,
				talk = 0.4,
				memory = 1.4,
				hintTruth = 0.5,
				blurb = "It's quiet tonight. Too quiet.",
			},
			Chatty = {
				view = 1,
				hear = 1,
				speed = 1,
				talk = 2,
				memory = 1,
				hintTruth = 0.3,
				blurb = "It won't stop talking tonight.",
			},
			Hunter = {
				view = 1,
				hear = 1,
				speed = 1.1,
				talk = 1,
				memory = 0.6,
				hintTruth = 0.5,
				blurb = "It's fast tonight... but forgetful.",
			},
			Listener = {
				view = 0.7,
				hear = 1.5,
				speed = 1,
				talk = 1,
				memory = 1,
				hintTruth = 0.5,
				blurb = "It can barely see tonight. It hears everything.",
			},
		},
		-- Night twists: weight = how often. "None" keeps a normal night in the mix.
		Twists = {
			{ id = "None", weight = 3 },
			{ id = "Barricades", weight = 3, blurb = "Some doors are boarded up." },
			{ id = "Blackout", weight = 2, blurb = "The lamps are dead. Use your light... carefully." },
			{ id = "Fog", weight = 2, blurb = "A cold fog fills the house." },
			{ id = "JammedClosets", weight = 2, blurb = "Some closets are jammed shut." },
		},
		MaxBarricades = 2,
		JammedClosets = 2,
		FogDensity = 0.62,
		-- Surprise events during the round (one every EventEvery seconds, random).
		EventEvery = NumberRange.new(55, 95),
		SurgeSeconds = 8,
		VanishQuietSeconds = 15,
	},

	Tasks = {
		RadioNoiseRadius = 55, -- the radio is loud: it keeps pulling the monster to its room
		RadioNoiseEvery = 6, -- seconds
		RadioHoldSeconds = 2.5,
		CandleHoldSeconds = 1.2,
		CandleBlowOutDistance = 6, -- the monster snuffs lit candles it walks past
		CandleBlowOutChance = 0.5, -- per candle it passes
		KeyUnlockHold = 1.5,
	},

	Voice = {
		HearRange = 80, -- subtitles show for players within this distance of the monster
		AmbientMin = 25,
		AmbientMax = 45,
		GlobalCooldown = 3.5,
		-- "Hybrid": recorded clip when a line has one (Shared/Config/VoiceLines.luau), otherwise the
		--           processed live voice (new AI lines possible).
		-- "RecordedOnly": only lines you recorded; GPT picks the best-fitting recording for replies.
		Mode = "Hybrid",
		VoiceId = "1", -- base text-to-speech voice under the effects
		Pitch = -7, -- semitones, main layer
		LowPitch = -12, -- semitones, the second "demon" layer under it
		LowLayerVolume = 0.7,
		Speed = 0.8,
		Volume = 2.5,
		-- Effects chain on the live voice (all on the monster, so it stays 3D):
		-- EQ -> Distortion -> Chorus -> Tremolo -> Reverb. Tune by ear in Studio.
		Effects = {
			LowGain = 5, -- dB
			MidGain = 0,
			HighGain = -8,
			Distortion = 0.18, -- 0..1
			ChorusMix = 0.35,
			ChorusRate = 0.6,
			ChorusDepth = 0.4,
			TremoloDepth = 0.18, -- a slight shake in the voice
			TremoloFrequency = 7,
			ReverbDecay = 2.4, -- seconds (old house)
			ReverbWet = -6, -- dB
			ReverbDry = 0,
		},
		-- Unpredictable pitch (applies to live AND recorded voice, through an AudioPitchShifter):
		Warp = {
			LinePitchRange = 2.5, -- each line starts up to +/- this many semitones off
			LineSpeedRange = 0.08, -- and up to +/- 8% faster/slower
			DriftDepth = 0.07, -- slow wander while speaking (ratio: 0.07 = about +/- 1.2 semitones)
			DriftSpeed = 0.9, -- how fast it wanders
			GlitchesPerSecond = 0.7, -- sudden short pitch jumps
			GlitchMin = 0.7, -- glitch pitch ratio range (0.7 = much lower, 1.3 = higher)
			GlitchMax = 1.3,
			GlitchSeconds = NumberRange.new(0.06, 0.22),
		},
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
