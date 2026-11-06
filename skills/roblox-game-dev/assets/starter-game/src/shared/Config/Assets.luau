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
		Collect = PLACEHOLDER, -- PLACEHOLDER: bright chime/pop, non-vocal
		Reward = PLACEHOLDER, -- PLACEHOLDER: small fanfare stinger, instrumental
		Error = PLACEHOLDER, -- PLACEHOLDER: soft low "bonk"
	},

	Music = {
		Main = { asset = PLACEHOLDER, volume = 1 } :: MusicTrack, -- PLACEHOLDER: instrumental loop
	},

	Images = {
		CoinIcon = PLACEHOLDER, -- PLACEHOLDER: original coin icon (used in HUD + particles)
	},
}

function Assets.isPlaceholder(asset: string?): boolean
	return asset == nil or asset == "" or asset == PLACEHOLDER
end

return table.freeze(Assets)
