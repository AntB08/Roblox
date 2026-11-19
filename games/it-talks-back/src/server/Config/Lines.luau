--!strict
-- Lines: everything the monster can say without AI. These are always the fallback, and the only
-- source for lines whose CONTENT matters (hints, catches), so gameplay never depends on the LLM.
-- Placeholders: {name} = a player's DisplayName, {room} = a room name, {count}/{total} = fuses.
-- Keep it creepy, not gory: no threats of real violence, no swearing. Under 120 characters.

local Lines: { [string]: { string } } = {
	RoundStart = {
		"Somebody is in my house.",
		"Oh, guests. I do love guests.",
		"Lights out. Let's play a game.",
		"I've been waiting so long for company.",
	},
	Ambient = {
		"I can hear you breathing.",
		"This house remembers everyone who came in.",
		"Come out, come out, wherever you are.",
		"{name}... what a nice name.",
		"I know every floorboard in this place.",
		"Don't you want to stay forever?",
		"I'm not angry. Not yet.",
		"Tick, tock. The clock is on my side.",
	},
	Heard = {
		"What was that?",
		"I heard that.",
		"Someone's in the {room}.",
		"Footsteps... in the {room}.",
		"You're not as quiet as you think.",
	},
	HeardCallout = {
		"The {room}, you said? Thank you, {name}.",
		"I heard you, {name}. The {room}. On my way.",
		"Shouting in my house? The {room} it is.",
	},
	CalloutEmpty = {
		"Nobody here... were you lying to me?",
		"Empty. Hmm.",
	},
	Grudge = {
		"You lied to me, {name}. I won't listen to you anymore.",
		"Liar, liar. I'm done listening to you, {name}.",
	},
	ChaseStart = {
		"There you are.",
		"Found you.",
		"I see you, {name}.",
		"Don't run. It only makes it fun.",
	},
	Lost = {
		"You can't hide forever.",
		"Where did you go?",
		"I'll find you. I always do.",
		"Hiding? How cute.",
	},
	PullOut = {
		"I saw you go in there.",
		"Knock knock.",
	},
	Caught = {
		"Got you, {name}.",
		"Into the cage you go.",
		"One less guest wandering around.",
	},
	Rescued = {
		"Who let them out?!",
		"My cage! Someone opened my cage!",
	},
	FuseInserted = {
		"Stop touching my things.",
		"{count} of {total}... you're making me angry.",
		"That generator stays OFF.",
	},
	PowerRestored = {
		"No. NO. Nobody leaves!",
		"The lights won't save you!",
	},
	Escaped = {
		"{name} got away... no matter. Plenty more.",
		"Run home, {name}. I'll be here.",
	},
	CandleOut = {
		"Lights out.",
		"Too bright in here.",
		"No candles in my house.",
	},
	RadioOff = {
		"Hey. I was listening to that.",
		"Turn it back on. I like the static.",
	},
	KeyTaken = {
		"Put that key back.",
		"That key isn't yours.",
	},
	NightStart = {
		"Night {count}. Let's see how long you last.",
		"Back again? Night {count}, then.",
	},
	Reply = {
		"I heard that, {name}.",
		"Talking to me, {name}? Come closer, I can't hear you.",
		"Shh. I'm listening, {name}.",
		"Say it again, {name}. I'm right here.",
	},
	-- Hints: one may be true, one may be a lie. Players have to decide.
	Hint = {
		"Psst. There's a fuse in the {room}.",
		"Looking for fuses? Try the {room}.",
		"I left something shiny in the {room}.",
	},
}

return table.freeze(Lines)
