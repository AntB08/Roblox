---
sidebar_position: 4
---

# Animation Assets

Animation assets in Crunchyroll are the equivalent of `Animation` instances in Roblox. They are not involved when it comes to _playing_ an animation, they are involved in loading the asset & storing data.

It is important to note, however, that you need `KeyframeSequence`s, not `Animation`s. This is because Crunchyroll parses keyframe sequences. There may be additional support for processing animation instances too, but that is not the case right now.

You can load a keyframe sequence into a Crunchyroll animation like so:

```lua
local crunchyroll = require(path.to.crunchyroll)

local keyframe_sequence = ReplicatedStorage.assets.walking_keyframe_sequence

crunchyroll.load_keyframe_sequence(keyframe_sequence)
```
