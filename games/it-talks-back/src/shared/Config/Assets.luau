--!strict
-- Assets: every asset id the game uses, in one place. Mirror each entry in assets/ASSETS.md
-- (owner + license). Only use assets the game's owner uploaded or that are licensed for use
-- (Creator Store audio library). Never paste ids of commercial songs.
--
-- "rbxassetid://0" is a PLACEHOLDER: code that plays sounds/music skips placeholders, so the
-- template runs silently until real ids are filled in. Music must be INSTRUMENTAL (no vocals,
-- choir or humming) and authored to loop seamlessly; SFX must be non-vocal.

local PLACEHOLDER = "rbxassetid://0"

export type MusicTrack = {
	asset: string,
	loopRegion: NumberRange?, -- seconds; set when the file has an intro/outro to skip
	volume: number?,
}

local Assets = {
	PLACEHOLDER = PLACEHOLDER,

	Sounds = {
		Click = PLACEHOLDER, -- PLACEHOLDER: short soft UI click
		Error = PLACEHOLDER, -- PLACEHOLDER: soft low "bonk"
		-- Built-in engine sounds (ship with every Roblox client, no upload needed). Swap for your own
		-- uploads when you have them.
		MonsterStep = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Thud = "rbxasset://sounds/action_jump_land.mp3",
	},

	Music = {
		Ambient = { asset = PLACEHOLDER, volume = 0.6 } :: MusicTrack, -- PLACEHOLDER: low instrumental drone loop
		Chase = { asset = PLACEHOLDER, volume = 0.8 } :: MusicTrack, -- PLACEHOLDER: tense instrumental chase loop
	},

	-- Published animation ids. Leave PLACEHOLDER to keep the built-in procedural animation.
	-- Make them from assets/animations/*.rbxm (see assets/animations/README.md).
	Animations = {
		Monster = {
			Idle = PLACEHOLDER,
			Walk = PLACEHOLDER,
			Run = PLACEHOLDER,
			Listen = PLACEHOLDER,
			Speak = PLACEHOLDER,
			Dormant = PLACEHOLDER,
			Grab = PLACEHOLDER,
			Snuff = PLACEHOLDER,
			Look = PLACEHOLDER,
			Vanish = PLACEHOLDER,
			Emerge = PLACEHOLDER,
		} :: { [string]: string },
		Player = {
			CrouchIdle = PLACEHOLDER,
			CrouchWalk = PLACEHOLDER,
		} :: { [string]: string },
	},

	Images = {
		CoinIcon = PLACEHOLDER, -- PLACEHOLDER: original coin icon
	},
}

function Assets.isPlaceholder(asset: string?): boolean
	return asset == nil or asset == "" or asset == PLACEHOLDER
end

return table.freeze(Assets)
