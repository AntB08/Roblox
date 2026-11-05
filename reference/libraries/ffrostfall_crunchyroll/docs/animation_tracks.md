---
sidebar_position: 5
---

# Animation Tracks

So far, we've covered rigs & animation assets. The last piece of the equation is the Crunchyroll equivalent of Roblox's `AnimationTrack`s. We actually do not change the name here. Crunchyroll's equivalent is straight up called AnimationTrack.

An animation track is actually just a table like so:

```lua
{
	stop_fade_time = 0.5,
	start_fade_time = 0.5,
	alpha = 0.5,

	weight = 1
}
```

That's it.

## Details

The "weight" field is the track's contribution to the weighted average which will decide the final coordinate frames of the animation.

The alpha is the "percent complete" of the animation. It is a number between 0 and 1.

### Stop & Start Fade Time

You can see the math for stop fade time & start fade time [here](https://www.desmos.com/calculator/9wt45xeilg).
The end "influence" which fade time has is done by multiplying the weight of the track by a modifier between 0 and 1.
