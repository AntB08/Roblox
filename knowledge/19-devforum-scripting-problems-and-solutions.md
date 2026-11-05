# 19 — DevForum Scripting Problems and Solutions (symptom → cause → fix)

> Audience: a Claude Code bot that writes Roblox Luau and has to diagnose broken Roblox code.
> Accurate as of 2026-11-05. Sources: the local mirror of the most-liked DevForum threads in Scripting Support (`.sources/devforum/scripting/`, about 5,000 threads), Code Review (`.sources/devforum/code-review/`, about 1,200), and scripting threads in `tutorials/` and `resources/`. Every API named below was checked against `reference/api/API-Dump.txt` and `reference/creator-docs-live/deprecated-api-inventory.md`.
> This chapter **extends** [04-luau-engineering.md](04-luau-engineering.md). 04 explains how to build things correctly: architecture, ProfileStore, the remote validation wrapper, Trove cleanup, and its table of 30 common bugs. This chapter is the diagnostic side. It lists what developers actually report, why it happens, and the fix. Where 04 already has the full pattern, this chapter links to it instead of repeating it.

Many accepted answers on the forum date from 2018–2021 and use APIs that are now deprecated. Every fix below is rewritten in current Luau. Where the accepted answer used something deprecated, the entry says **(modernized)**.

---

## TL;DR rules for the bot

1. **Find out where the code runs before anything else.** About a third of all Scripting Support threads come down to "this ran on the wrong side". `Players.LocalPlayer` is `nil` on the server. DataStores, `SetNetworkOwner` and `BanAsync` are server-only. `UserInputService`, `Camera` and `PlayerGui` edits are client-only. A client change to a value doesn't replicate.
2. **Never index `player.Character` without handling nil.** Connect `CharacterAdded`, also handle a character that already exists, and rebind everything on every respawn. The Humanoid, Animator, Backpack and character parts are **new instances** after each respawn.
3. **Edit `PlayerGui`, not `StarterGui`.** StarterGui is only a template. Changing it at runtime changes nothing on anyone's screen.
4. **Get the player from trusted engine sources only:** `PlayerAdded`, the first argument of `OnServerEvent`, `Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))`, `ClickDetector.MouseClick(player)`, or `ProximityPrompt.Triggered(player)`.
5. **Save on the server, from server-held data, in `PlayerRemoving` and `BindToClose`.** The client can't send anything once it has left. `BindToClose` must yield until every save has finished; it has about 30 seconds. From **2026-11-11**, `PlayerCharacterDestroyBehavior` destroys Player objects 5 seconds after `PlayerRemoving`. Read the values you need before your handler yields.
6. **A BindableEvent never crosses the client/server boundary.** Use a RemoteEvent for that.
7. **Rate-limit remotes with a token bucket per player.** Validate intent ("swing", "buy item X"), never results ("deal 50 damage", "set coins to 1e9"). Remote "passwords" and obfuscation don't stop anyone.
8. **Connect client listeners before anything yields,** and make the client ask for initial state with a ready handshake. Events fired before a listener connects are queued for the first connection only, and later listeners miss them.
9. **Server-own important physics.** Unanchored NPCs, projectiles and enemies that stutter or pause near players are being handed to a client. Call `SetNetworkOwner(nil)` after checking `CanSetNetworkOwnership()`.
10. **Use constraint movers, not BodyMovers.** `BodyVelocity`, `BodyGyro` and `BodyPosition` are deprecated. Use `LinearVelocity`, `AlignOrientation`, `AlignPosition`, `AngularVelocity` or `BasePart:ApplyImpulse`.
11. **Move models with `PivotTo` / `GetPivot`.** `SetPrimaryPartCFrame` and `GetPrimaryPartCFrame` are deprecated, and the old method drifted from floating-point error.
12. **Tween a CFrame by more than 180° through a NumberValue angle.** A CFrame tween takes the shortest rotation, so a 360° goal produces no motion at all.
13. **Load animations with `Animator:LoadAnimation`** on a Humanoid that is inside `workspace` or a `WorldModel`. Keep the returned track, because loading again gives you a new track you can't stop the old one with. The animation asset must be owned by the experience's owner (user or group), or it fails in live games with "sanitized ID".
14. **Use `task.*` only.** Use `task.wait`, `task.spawn`, `task.defer`, `task.delay` and `task.cancel`. A `wait()` inside a `for` loop over players runs the loop one player at a time.
15. **Give `WaitForChild` a timeout for anything optional,** and for anything in `workspace` when StreamingEnabled is on (it's on by default for new places). Prefer CollectionService tag signals for streamed content.
16. **Disconnect what you connect.** A connection whose callback captures an Instance keeps that Instance alive. Tables keyed by Player leak unless you clear them on `PlayerRemoving`.
17. **A client-side anticheat is cosmetic.** Exploiters delete LocalScripts. Detect speed, teleport and fly on the server from position deltas, and accept that anything replicated to the client (map, LocalScripts, ReplicatedStorage) can be copied.
18. **"Works in Studio, not live" usually means one of these:** a timing race that Studio hides, unpublished drafts or an unpublished place, asset ownership, Studio API access settings, or DataStores not being saved on shutdown.
19. **Detect input type, not device.** Use `UserInputService.PreferredInput` and its changed signal. Use `GuiButton.Activated`, not `MouseButton1Click`. Use `GuiService.SelectedObject` for gamepads.
20. **Read the first error, not the last.** "Requested module experienced an error while loading" and "Infinite yield possible" are symptoms of another problem. Scroll up to the first red line.

---

## 0. Modernization key (old accepted answer → what to write now)

| Old code seen in accepted answers | Write instead | Status (API dump / deprecation inventory) |
|---|---|---|
| `wait(n)`, `spawn(f)`, `delay(n, f)` | `task.wait(n)`, `task.spawn(f)`, `task.delay(n, f)` | globals superseded by `task.*` |
| `Humanoid:LoadAnimation(anim)` | `Animator:LoadAnimation(anim)` | `Humanoid:LoadAnimation` is `[Deprecated]` |
| `BodyVelocity` / `BodyGyro` / `BodyPosition` | `LinearVelocity` / `AlignOrientation` / `AlignPosition` (+ `Attachment`) | BodyMovers are `[Deprecated]` |
| `model:SetPrimaryPartCFrame(cf)` / `GetPrimaryPartCFrame()` | `model:PivotTo(cf)` / `model:GetPivot()` | `[Deprecated]` |
| `player:LoadCharacter()` | `player:LoadCharacterAsync()` | superseded |
| `Players:CreateHumanoidModelFromUserId` | `CreateHumanoidModelFromUserIdAsync` | `[Deprecated]` |
| `Enum.RaycastFilterType.Blacklist` / `Whitelist` | `Exclude` / `Include` | the old items are gone from the enum |
| `Sound.EmitterSize` / `MinDistance` | `Sound.RollOffMinDistance` / `RollOffMaxDistance` | deprecated |
| `UserInputService.ModalEnabled` (to hide touch controls) | `GuiService.TouchControlsEnabled = false` | `ModalEnabled` is `[Deprecated]` |
| `Instance.new("Part", parent)` then set properties | set properties, then set `.Parent` last | allowed, but it costs replication work |
| `game.Workspace`, `game.Players` | `workspace`, `game:GetService("Players")` | style |
| `for i, v in pairs(arr)` | `for i, v in arr` (generalized iteration) | style; `ipairs` is fine when you need to stop at the first nil |
| `settings().Studio.ScriptTimeoutLength = -1` | batch the work with a time budget (§12.4) | Studio-only workaround |
| `RunService.Heartbeat`/`Stepped`/`RenderStepped` | still valid; `PostSimulation`/`PreSimulation`/`PreRender` are the newer equivalents | **not** deprecated in the current dump (see §12.6) |

---

## 1. Player and character lifecycle

### 1.1 "attempt to index nil with 'leaderstats'" / LocalPlayer is nil
- **Symptom:** A server Script uses `game.Players.LocalPlayer.leaderstats...` and errors with "attempt to index nil".
- **Cause:** `LocalPlayer` exists only in LocalScripts, and in Scripts with `RunContext = Client`. On the server there are many players, so there's no "local" one. Changing leaderstats from a LocalScript instead looks as if it works for that player, but it never replicates or saves.
- **Fix:** Get the player from an event that supplies it.

```lua
local Players = game:GetService("Players")

-- From a tool's server Script: the tool's parent is the character while it's equipped.
local tool = script.Parent :: Tool
tool.Activated:Connect(function()
	local character = tool.Parent
	local player = if character and character:IsA("Model") then Players:GetPlayerFromCharacter(character) else nil
	if not player then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	local xp = leaderstats and leaderstats:FindFirstChild("XP")
	if xp and xp:IsA("IntValue") then
		xp.Value += 10
	end
end)
```
- **Sources:** https://devforum.roblox.com/t/attempt-to-index-nil-with-leaderstats/530935 ; https://devforum.roblox.com/t/how-to-get-the-player-from-a-server-script-solved/639085 (191 likes; the OP's own answer lists PlayerAdded, remote arguments and Touched)

### 1.2 "attempt to index nil with 'WaitForChild'" on `player.Character`
- **Symptom:** `player.Character:WaitForChild("Humanoid")` errors on join, after a respawn, or at random.
- **Cause:** `player.Character` is `nil` until the first spawn, and `nil` again briefly between death and respawn. `WaitForChild` can't be called on nil.
- **Fix:** The accepted one-liner is `local character = player.Character or player.CharacterAdded:Wait()`. That's fine for a single read in a LocalScript. Anything that must survive respawns needs the full pattern below (04 §6.2 has the version with a Trove).

```lua
local Players = game:GetService("Players")

local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end
	humanoid.Died:Connect(function()
		-- runs once per life; it reconnects automatically because onCharacterAdded runs again on respawn
	end)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end
```
- **Sources:** https://devforum.roblox.com/t/attempt-to-index-nil-with-waitforchild/629126 (accepted answer, 43 likes) ; https://devforum.roblox.com/t/best-way-to-wait-for-character/996825 (code review: "don't forget to call the function if the Character already exists")

### 1.3 Getting the Player from a `Touched` event (and Touched firing many times)
- **Symptom:** "How do I get the player from Touched?", or "my kill brick / coin awards 20 times per step."
- **Cause:** `Touched` gives you a BasePart. For an accessory handle, `hit.Parent` is the Accessory, not the character. `Touched` also fires once per touching part, repeatedly while the player walks on the part, so 15+ hits per contact is normal.
- **Fix:** Resolve the character with `FindFirstAncestorOfClass("Model")`, then add a per-player cooldown. A single global debounce blocks every other player as well.

```lua
local Players = game:GetService("Players")
local part = script.Parent :: BasePart
local nextAllowed: { [Player]: number } = {}

part.Touched:Connect(function(hit: BasePart)
	local model = hit:FindFirstAncestorOfClass("Model")
	local player = if model then Players:GetPlayerFromCharacter(model) else nil
	if not player then
		return
	end
	local now = os.clock()
	if (nextAllowed[player] or 0) > now then
		return
	end
	nextAllowed[player] = now + 1
	-- award / damage here
end)

Players.PlayerRemoving:Connect(function(player)
	nextAllowed[player] = nil
end)
```
- **Sources:** https://devforum.roblox.com/t/how-to-get-player-from-touched-event/260923 (accepted, 169 likes) ; https://devforum.roblox.com/t/how-can-i-make-a-touched-event-fire-only-once/1600637

### 1.4 "My script stops working after I respawn"
- **Symptom:** Sprint, abilities, tool scripts or a custom backpack UI work on the first life and do nothing after a reset. Sometimes it's "works in Studio, breaks in the real game".
- **Cause:** The script cached `character`, `humanoid`, `animator` or `player.Backpack` once. A respawn creates new instances, including a **new Backpack**, so the cached references point at destroyed objects. A LocalScript in `StarterPlayerScripts` runs once per session. One in `StarterCharacterScripts`, or in a `ResetOnSpawn` ScreenGui, runs again every life. Live servers add latency, so races that Studio hides start to show up.
- **Fix:** Pick one of two approaches. (a) Put per-life logic in `StarterCharacterScripts` and read `script.Parent` as the character. (b) Keep the script in `StarterPlayerScripts` and rebind on `CharacterAdded`, reading `player:WaitForChild("Backpack")` again each time.
- **Sources:** https://devforum.roblox.com/t/sprint-local-script-not-working-in-starter-gui-after-respawn/2772465 ; https://devforum.roblox.com/t/roblox-player-has-bug-studio-does-not/3305455 (accepted: "the backpack is destroyed each time the character respawns … Roblox Player has more delay")

### 1.5 GUI resets on respawn even with `ResetOnSpawn = false`
- **Symptom:** A ScreenGui with `ResetOnSpawn = false` still resets. The OP had grouped ScreenGuis into Folders under StarterGui.
- **Cause:** `ResetOnSpawn` belongs to `LayerCollector`, which includes ScreenGui. Children of StarterGui are copied into PlayerGui, and the copy is redone on spawn for any container that doesn't opt out. A Folder has no `ResetOnSpawn` property.
- **Fix:** Don't group ScreenGuis in Folders. Use a top-level ScreenGui with `ResetOnSpawn = false`, or set the property on each ScreenGui at the top level. The same mechanism re-runs LocalScripts inside resetting GUIs, which is a common cause of duplicated connections (§2.6). Old answers mention `StarterGui.ResetPlayerGuiOnSpawn`; it's deprecated in favor of `LayerCollector.ResetOnSpawn`.
- **Source:** https://devforum.roblox.com/t/screenguis-in-startergui-folder-resets-on-respawn/1125765

### 1.6 What exists when `PlayerRemoving` fires (and the 2026-11-11 change)
- **Symptom:** "Is the player still in `GetPlayers()` during PlayerRemoving?" or "My save code can't find leaderstats any more."
- **Cause:** When `PlayerRemoving` fires, the Player has already been parented to nil and isn't returned by `GetPlayers()`. Lua references still work for now. **From November 11, 2026**, `Workspace.PlayerCharacterDestroyBehavior = Default` behaves like `Enabled`. The engine then calls `Destroy` on the Player **5 seconds after** the `PlayerRemoving` handlers run, and on Characters right after the `CharacterRemoving` handlers. A handler that yields (for example `task.wait(10)` or a slow DataStore read) and only then reads `player.leaderstats` finds nothing.
- **Fix:** Key session data by Player or UserId in a server-side table. Read everything you need **before the first yield**, then save.

```lua
local Players = game:GetService("Players")

type Session = { coins: number, inventory: { string } }
local sessions: { [Player]: Session } = {}

local function saveAsync(userId: number, data: Session)
	-- UpdateAsync with retries; see 04 §5.2
end

Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId -- read synchronously, before anything yields
	local data = sessions[player]
	sessions[player] = nil -- prevents the table leak from 04 §6.3
	if data then
		saveAsync(userId, data)
	end
end)
```
- **Sources:** https://devforum.roblox.com/t/is-a-player-already-removed-when-playerremoving-fires/122798 ; https://devforum.roblox.com/t/playercharacterdestroybehavior-will-be-default-on-november-11/4975616 (announcement, 2026-11-04)

### 1.7 Firing a remote from the client when the player leaves never arrives
- **Symptom:** A LocalScript's `PlayerRemoving` (or `player:GetPropertyChangedSignal("Parent")`) fires `save:FireServer(data)`, and the server never receives it.
- **Cause:** The client has disconnected and can't send anything. This design also lets the client write its own save data, which is an exploit.
- **Fix:** Keep the authoritative data on the server and save in the server's `PlayerRemoving`. To tell other clients that someone left, fire `FireAllClients` from the server's `PlayerRemoving`.
- **Sources:** https://devforum.roblox.com/t/player-removing-event-doesnt-have-enough-time-to-complete-please-help/252778 (reply: "push ALL datastore related code to the server") ; https://devforum.roblox.com/t/player-left-game-detection-not-working/2511322

### 1.8 Data doesn't save when the last player leaves, or when you press Stop in Studio
- **Symptom:** Saving works while another player is still in the server, but not for the last player out. In Studio, `print("before")` prints and `print("after")` never does.
- **Cause:** When the last player leaves, the server starts shutting down. `PlayerRemoving` handlers that yield on DataStore calls get killed unless `game:BindToClose` keeps the process alive. A second trap: the BindToClose callback must *itself* yield until the saves finish. Threads started with `task.spawn` inside it aren't waited for.
- **Fix (modernized):** Old accepted answers used `while true do wait() end` or `player:Kick()` loops. Use a counter instead.

```lua
local Players = game:GetService("Players")

local function savePlayer(player: Player)
	-- must be idempotent: PlayerRemoving can fire for the same player during shutdown
end

Players.PlayerRemoving:Connect(savePlayer)

game:BindToClose(function()
	local pending = 0
	for _, player in Players:GetPlayers() do
		pending += 1
		task.spawn(function()
			local ok, err = pcall(savePlayer, player)
			if not ok then
				warn("save failed", player.UserId, err)
			end
			pending -= 1
		end)
	end
	local deadline = os.clock() + 25 -- stay under the ~30 s limit
	while pending > 0 and os.clock() < deadline do
		task.wait()
	end
end)
```
If you use ProfileStore, it handles this for you (04 §5.4). Also check whether your "save" function wraps the DataStore call in `task.spawn`. If it does, the callback returns at once and nothing gets written.
- **Sources:** https://devforum.roblox.com/t/datastore-not-working-when-last-player-leaves-the-game-in-private-servers/3342715 (257 likes) ; https://devforum.roblox.com/t/datastore-not-saving-in-playerremoving/879024 ; https://devforum.roblox.com/t/data-store-is-not-saving-because-of-the-server-fast-shutdown/3263432 (reply: "BindToClose … doesn't take into account any spawned threads") ; https://devforum.roblox.com/t/how-should-i-be-using-bindtoclose/969161 ; https://devforum.roblox.com/t/playerremoving-and-bindtoclose-datastore-redundancy/281994

### 1.9 "Loop over GetPlayers only works for one person"
- **Symptom:** A round-start loop teleports or initializes one player, then seems to hang.
- **Cause:** A `wait(1)` inside the loop body makes the loop handle players one at a time. The OP's code also looped over every map's spawn and overwrote the character CFrame for each one. It used `Character.Torso`, which doesn't exist on R15, and wrote into `PlayerGui` from the server.
- **Fix:** Don't yield per player. Use `task.spawn` per player if per-player work has to yield. Teleport with `character:PivotTo(cf)`. Send UI changes to the client with a RemoteEvent.

```lua
local Players = game:GetService("Players")

local function startRound(spawnCFrame: CFrame, inRound: { [Player]: boolean })
	for _, player in Players:GetPlayers() do
		if inRound[player] and player.Character then
			player.Character:PivotTo(spawnCFrame + Vector3.new(math.random(-4, 4), 3, math.random(-4, 4)))
		end
	end
end
```
- **Source:** https://devforum.roblox.com/t/for-i-v-in-pairsgameplayersgetplayers-only-works-for-one-person/441407

### 1.10 `GetPlayers()` returns nothing in an NPC script
- **Symptom:** An NPC AI script calls `Players:GetPlayers()` once at the top and gets an empty table.
- **Cause:** Server scripts start before any client joins. In Studio's Play Solo the player arrives a moment later; on a live server, minutes later. A read at startup is always empty.
- **Fix:** Query inside the AI's update loop, or keep a set maintained by `PlayerAdded` and `PlayerRemoving`.
- **Source:** https://devforum.roblox.com/t/playersgetplayers-not-working-in-my-script/3619344

---

## 2. Remotes and replication

### 2.1 BindableEvent fired from a LocalScript never reaches the server
- **Symptom:** "Moving script not working when an event is received": a server Script listens to `ReplicatedStorage.GetEm.Event` and a LocalScript fires it. Nothing happens and there's no error.
- **Cause:** BindableEvents and BindableFunctions only work within one side: server to server, or client to client.
- **Fix:** Use a `RemoteEvent` (`FireServer` with `OnServerEvent`), or fire the bindable from server code.
- **Source:** https://devforum.roblox.com/t/moving-script-not-working-when-a-event-is-received/670130 (119 likes, 227 replies)

### 2.2 Detecting remote spam: use a leaky/token bucket, not a reset counter
- **Symptom:** "How do I check whether a player is firing my sword remote too fast?" A naive counter that resets every second gives false positives, because network jitter bunches up legitimate events.
- **Cause:** Events don't arrive at the same intervals at which they were sent.
- **Fix:** Use a per-player token bucket. It refills at the allowed rate and allows a small burst. The accepted answer describes the leaky-bucket version. 04 §4.2 has a full wrapper that includes type checks.

```lua
local Players = game:GetService("Players")

type Bucket = { tokens: number, last: number }
local RATE = 3 -- allowed actions per second
local BURST = 5 -- tolerated bunching
local buckets: { [Player]: Bucket } = {}

local function allow(player: Player): boolean
	local now = os.clock()
	local bucket = buckets[player]
	if not bucket then
		bucket = { tokens = BURST, last = now }
		buckets[player] = bucket
	end
	bucket.tokens = math.min(BURST, bucket.tokens + (now - bucket.last) * RATE)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
end)
```
- **Source:** https://devforum.roblox.com/t/how-to-check-if-a-player-is-spamming-a-remote-too-fast/245991 (accepted, 85 likes)

### 2.3 "God remotes" such as `Damage(player, amount)` or `GiveCoins(amount)`
- **Symptom:** A combat game has a `damage(target, amount)` remote, and an exploiter kills everyone.
- **Cause:** Anyone can fire any remote with any arguments. Remotes that carry *results* hand the server's authority to the client.
- **Fix:** Send intent ("I swung", "I want to buy item id X"). The server checks cooldown, range, line of sight, ownership and price from its own config, and works out the result itself. One reply in the thread says they "kick people when the input parameters are malformed in the slightest way… you don't want to know how many".
- **Source:** https://devforum.roblox.com/t/how-safe-are-remotefunctions/63336

### 2.4 Remote "passwords", random keys and obfuscators
- **Symptom:** "Can I generate a per-session password so only my scripts can fire remotes?"
- **Cause:** The key has to reach the client, so the client can read it. "They can ALWAYS find it out."
- **Fix:** Spend the effort on server-side checks: does the player own the item, are they in placement mode, is the target in range. Don't ship obfuscators, anti-RemoteSpy or anti-Dex code.
- **Sources:** https://devforum.roblox.com/t/how-could-i-go-about-making-a-random-password-for-remote-events-for-security-against-exploiters/113386 ; https://devforum.roblox.com/t/anti-remotespy-and-anti-dex/1309047

### 2.5 "How many RemoteEvents is too many?"
- **Symptom:** A framework has 40+ RemoteEvents, and the developer worries about cost.
- **Cause:** Each remote is an Instance, which is cheap. What costs something is the **traffic**: how often you fire and how big the payloads are.
- **Fix:** Group remotes by feature (one remote per system with an action enum, or one per clear purpose). Validate the action argument against a fixed set. Batch messages that are always sent together. Use `UnreliableRemoteEvent` for high-frequency cosmetic updates (04 §4.1).
- **Source:** https://devforum.roblox.com/t/how-many-remoteevents-is-too-much/1486049

### 2.6 `OnClientEvent` / `OnServerEvent` handler runs several times per fire
- **Symptom:** "RemoteEvent being fired multiple times when it is only supposed to be fired once." The suggested fix is a debounce.
- **Cause:** One `FireClient` call reached **several connected handlers**. Usually `:Connect` sits inside another event handler (each click adds another listener), inside a LocalScript that re-runs on respawn (a `ResetOnSpawn` GUI or StarterCharacterScripts), or inside a loop. A debounce only hides the leak.
- **Fix:** Connect once at the top level of a script that runs once (StarterPlayerScripts), or store the connection and disconnect it when the owner is cleaned up. To check: put `print("connected")` next to `:Connect` and count how often it prints.
- **Source:** https://devforum.roblox.com/t/remoteevent-being-fired-multiple-times-when-it-is-only-supposed-to-be-fired-once/1730923

### 2.7 Only one of two LocalScripts receives a remote event (or the first event is lost)
- **Symptom:** Two LocalScripts both listen to the same RemoteEvent and only one reacts, or the client misses the initial state the server sent on join.
- **Cause:** The listener wasn't connected yet when the server fired, often because the script yielded on `WaitForChild` chains first. A remote with no connections queues incoming events and delivers them to the **first** handler that connects. Handlers that connect later never see those events.
- **Fix:** Connect handlers before any yields. Use one client module that owns each remote and dispatches to subscribers. For initial state, use a handshake.

```lua
-- LocalScript (StarterPlayerScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateChanged = remotes:WaitForChild("StateChanged") :: RemoteEvent
local clientReady = remotes:WaitForChild("ClientReady") :: RemoteEvent

stateChanged.OnClientEvent:Connect(function(state: { [string]: any })
	-- render the state
end)
clientReady:FireServer() -- only after the listener exists
```
```lua
-- Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateChanged = remotes:WaitForChild("StateChanged") :: RemoteEvent
local clientReady = remotes:WaitForChild("ClientReady") :: RemoteEvent
local readyPlayers: { [Player]: boolean } = {}

clientReady.OnServerEvent:Connect(function(player)
	if readyPlayers[player] then
		return -- ignore repeats
	end
	readyPlayers[player] = true
	stateChanged:FireClient(player, { phase = "Lobby" })
end)
```
- **Source:** https://devforum.roblox.com/t/solved-why-is-only-one-local-script-receiving-remote-event-but-not-the-other/3357571 (accepted: "either script is yielding long enough that the event is missed")

### 2.8 Set properties before parenting (the `Instance.new` second argument)
- **Symptom:** "Is the parent argument of `Instance.new` deprecated?" or "Spawning many parts lags."
- **Cause:** Parenting first replicates the instance and then sends one property-change message per property you set afterwards. Parenting last sends one message.
- **Fix:** `local p = Instance.new("Part")`, set the properties, then `p.Parent = workspace` as the last line. For bulk spawns, build the parts under a parent that isn't in the DataModel, then parent the whole model once.
- **Source:** https://devforum.roblox.com/t/so-i-just-found-out-that-the-second-parameter-of-instancenew-is-deprecated/516408

### 2.9 Animations played by a LocalScript aren't visible to others
- **Symptom:** A LocalScript plays animations and other players don't see them, usually on a custom character or an NPC.
- **Cause:** The client's own character replicates animations through its Animator, but only if the **Animator was created by the server**. The default Humanoid does this; a hand-built custom character may not. Animations a client plays on parts it doesn't own (NPCs, other players) are local only.
- **Fix:** Make sure the character's Humanoid has an `Animator` created on the server (`Instance.new("Animator")` parented by a server Script when you build custom rigs). Play NPC animations on the server, or on every client after a remote broadcast.
- **Source:** https://devforum.roblox.com/t/animations-not-being-visible-to-other-players-through-local-scripts/775727

---

## 3. DataStores

For limits, `UpdateAsync`, session locking and ProfileStore, see 04 §5. The entries below are the confusions that bring people to the forum.

### 3.1 "Can I save a table?" Yes, but only JSON-shaped data
- **Symptom:** "How do I save my inventory?" Or tables save but come back as `nil` or with missing fields.
- **Cause:** DataStores store JSON. Tables of strings, numbers, booleans and nested tables work. Instances, Vector3, CFrame, Color3, functions, mixed array/dictionary tables, sparse arrays and non-string dictionary keys don't survive the round trip.
- **Fix:** Serialize to plain data (`{x, y, z}`, item IDs, `Color3:ToHex()`), and save one table per player under `tostring(userId)`. The accepted answer's sample calls `SetAsync` in `PlayerRemoving` without a session lock. Replace that with ProfileStore or `UpdateAsync` (04 §5.2–5.4).
- **Source:** https://devforum.roblox.com/t/how-do-you-save-tables-to-datastore/350773

### 3.2 Saving built models or parts (tycoon or sandbox bases)
- **Symptom:** "How do I save every model in a player's plot, like Theme Park Tycoon?"
- **Cause:** Instances can't be stored, and storing every property of every part wastes the 4 MB budget.
- **Fix:** Keep templates in ServerStorage. For each placed item, save `{id = "Bench01", cf = {x, y, z, rx, ry, rz}}` relative to the plot's origin CFrame (`plot:GetPivot():ToObjectSpace(model:GetPivot())`). On load, clone the template and call `PivotTo(plotOrigin * savedRelative)`.
- **Source:** https://devforum.roblox.com/t/saving-partsmodels-via-datastore/151616

### 3.3 "My save is 10 MB": size limits
- **Symptom:** The developer plans multi-megabyte saves for an MMO.
- **Cause:** The value limit is now **4,194,304 characters per key** (it was 260 KB in 2018, when the thread was written). Saves that big usually come from storing derived data such as weapon stats or textures.
- **Fix:** Store IDs and deltas, and look up static data from a server module. If you really need more, split the data across keys under one session lock, or compress it into a `buffer`.
- **Source:** https://devforum.roblox.com/t/datastore-limits/116953

### 3.4 Which library: DataStore2, ProfileService, raw, or ProfileStore?
- **Symptom:** "Should I use ProfileService, DataStore2 or DataStoreService?"
- **Cause:** The real difference is session locking. Without it, joining a new server while the old one is still saving causes rollbacks and duplicated items.
- **Fix:** Use **ProfileStore** (the successor to ProfileService, by the same author) for new projects. DataStore2 and the "Berezaa method" (an OrderedDataStore of timestamps that point at versioned keys) are legacy. Native DataStore versioning (`ListVersionsAsync`, `GetVersionAsync`) now covers the backup use case. Don't build ordered-backup schemes.
- **Sources:** https://devforum.roblox.com/t/should-i-use-profileservice-datastore2-or-datastoreservice/1611913 ; https://devforum.roblox.com/t/concerns-about-berezaas-datastore-saving-method/161480 ; https://devforum.roblox.com/t/how-to-use-datastore2-data-store-caching-and-data-loss-prevention/136317 ; https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543

### 3.5 Beginner DataStore script reviewed: the usual five defects
- **Symptom:** "Is there anything I can improve in my simple DataStore?" or "DataStore not working, the game is published."
- **Cause / fix list (from the reviews):**
  1. `LocalPlayer` used in a server DataStore script. It's nil (§1.1).
  2. Typos such as `SetAsnyc`. Use `--!strict` with luau-lsp so the editor catches unknown methods.
  3. No `pcall` around `GetAsync` / `SetAsync`. Every web call can fail (04 TL;DR #9).
  4. Saving on join right after loading. That wastes budget and, if the load failed, overwrites real data with defaults. Only write after a **successful** load, and never write defaults over a failed load.
  5. `leaderstats` read without `WaitForChild` from another script.
- Also, in Studio, turn on *Game Settings → Security → Enable Studio Access to API Services*, or every call errors.
- **Sources:** https://devforum.roblox.com/t/is-there-any-improvements-i-can-do-to-my-simple-datastore/2524948 ; https://devforum.roblox.com/t/datastore-not-working/490557 ; https://devforum.roblox.com/t/setting-up-a-datastore/295343

### 3.6 OrderedDataStore can't hold numbers above about 9.22e18
- **Symptom:** A simulator leaderboard breaks once values exceed 2^63, the largest integer an OrderedDataStore accepts.
- **Cause:** OrderedDataStore stores 64-bit integers only.
- **Fix:** Store a monotonic, log-scaled integer for ranking, and keep the exact value in the main profile.

```lua
local SCALE = 1e13 -- keeps ~13 significant digits of log10, well inside 2^63 for values up to 1e308

local function encode(value: number): number
	return math.floor(math.log10(math.max(value, 0) + 1) * SCALE)
end

local function decode(stored: number): number
	return 10 ^ (stored / SCALE) - 1
end
```
- **Source:** https://devforum.roblox.com/t/how-to-save-numbers-over-9223-quintillion-to-ordereddatastore/397438

### 3.7 Sharing data between places
- **Symptom:** "Data saves in place 1, but place 2 starts fresh."
- **Cause:** DataStores are per **experience (universe)**. Places in the same experience share them. A separate game is a separate universe and can't read them.
- **Fix:** Add the second place to the same experience (Asset Manager → Places) and use the same store name and key format in both. Use the same data module in both places so the schemas can't drift apart.
- **Source:** https://devforum.roblox.com/t/how-to-overwrite-values-in-datastore/2703017

---

## 4. Physics and network ownership

### 4.1 NPCs, enemies or projectiles stutter, pause or "lag behind" near players
- **Symptom:** Tower-defense enemies "lag behind and teleport", an NPC pauses for a beat before it starts walking, or a pathfinding NPC stutter-steps.
- **Cause:** The engine automatically gives network ownership of unanchored assemblies to the nearest player. Each handoff between server and client causes a hitch, and client ownership is also an exploit vector, since that client controls the physics.
- **Fix:** Claim ownership for the server once the model is in `workspace`, and do it again if the assembly changes (welds added or removed). For dozens of enemies, the alternative in the accepted answer is better: keep an anchored or abstract simulation on the server and render movement on each client from remote updates or attributes.

```lua
local function claimForServer(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and not descendant.Anchored then
			local canSet = descendant:CanSetNetworkOwnership()
			if canSet then
				descendant:SetNetworkOwner(nil) -- applies to the whole assembly
			end
		end
	end
end
```
- **Sources:** https://devforum.roblox.com/t/tower-defence-enemies-lagging-behind/2738378 ; https://devforum.roblox.com/t/enemy-npc-delay-when-walking/3370739 (98 likes) ; https://devforum.roblox.com/t/pathfinding-npc-stuttering/1739208

### 4.2 Pathfinding NPC "walks, stops, walks"
- **Symptom:** The NPC moves in bursts, especially after its target dies.
- **Cause:** `Path:ComputeAsync` is called every step or every frame, so each recompute stalls the NPC. Waiting on `MoveToFinished` for every waypoint also stalls it, because `MoveTo` times out after 8 seconds and ownership changes add hitches.
- **Fix:** From the second answer in the thread: recompute only when the target has moved a meaningful distance or the path is blocked (`Path.Blocked`). Use a direct `Humanoid:MoveTo(target)` when there's line of sight. Keep server ownership (§4.1). Keep moving while the path computes, and run animations on the client.
- **Source:** https://devforum.roblox.com/t/pathfinding-npc-stuttering/1739208

### 4.3 Two welded characters both die (handcuffs, carry, grab)
- **Symptom:** A WeldConstraint attaches a detained player to the officer, and when one dies, both die.
- **Cause:** Welded parts become one assembly. Breaking joints or killing one Humanoid propagates across the welded rig, and network ownership is also merged.
- **Fix:** From the accepted answer: use `AlignPosition` + `AlignOrientation` (attachment-based, so not one rigid assembly) instead of a weld, or destroy or disable the weld (`weld.Enabled = false`) before applying damage. Set `Massless = true` on the carried character's parts so the carrier isn't dragged down.
- **Source:** https://devforum.roblox.com/t/both-players-die-when-welded/998621

### 4.4 `Touched` doesn't fire on anchored or CFramed parts
- **Symptom:** A black hole or zone made of anchored parts never gets `Touched` events.
- **Cause:** `Touched` is produced by the physics solver when at least one of the two parts is simulated. Two anchored parts, or parts moved by setting their CFrame, don't generate contacts.
- **Fix:** For zones, hitboxes and areas of effect, use spatial queries: `workspace:GetPartsInPart(zone, params)`, `GetPartBoundsInBox` or `GetPartBoundsInRadius`, on a timer or on Heartbeat. Use `Touched` only when real physics is involved. Unanchoring parts just to get the event (the accepted answer) is a hack that changes behavior.
- **Source:** https://devforum.roblox.com/t/touched-event-not-working-on-anchored-parts/846239

### 4.5 BodyVelocity "doesn't work", or "how do I use LinearVelocity?" (modernized)
- **Symptom:** A fireball or dash made with `BodyVelocity` behaves oddly, or the LinearVelocity version does nothing.
- **Cause:** BodyMovers are deprecated. `LinearVelocity` needs an `Attachment0`, and it applies no force if `MaxForce` is left low.
- **Fix:**

```lua
local function launch(part: BasePart, direction: Vector3, speed: number): LinearVelocity
	local attachment = Instance.new("Attachment")
	attachment.Parent = part

	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	velocity.VectorVelocity = direction.Unit * speed
	velocity.MaxForce = math.huge
	velocity.Parent = part
	return velocity
end
```
For a one-off knockback, `part:ApplyImpulse(direction.Unit * part.AssemblyMass * speed)` is simpler. On a character, apply it on the side that owns the character (the owning client), or briefly take ownership away.
- **Sources:** https://devforum.roblox.com/t/how-to-use-bodyvelocity/1166176 (accepted answer recommends LinearVelocity) ; https://devforum.roblox.com/t/how-do-you-use-linear-velocity/1988812

### 4.6 Moving or rotating a model (modernized)
- **Symptom:** "Models have no Position property, so how do I move one?"
- **Cause:** Old answers use `SetPrimaryPartCFrame`, which is deprecated and drifted from floating-point error. Both accepted answers were later edited to say so.
- **Fix:** `model:PivotTo(model:GetPivot() * CFrame.Angles(0, math.rad(90), 0))`, or `model:PivotTo(CFrame.new(0, 20, 0))`. Set `Model.WorldPivot` or `PrimaryPart` in Studio so the pivot is meaningful. `Model:MoveTo(position)` also works, but it moves the model up to avoid collisions.
- **Sources:** https://devforum.roblox.com/t/how-can-i-move-a-models-position-with-code/610386 ; https://devforum.roblox.com/t/how-to-rotate-a-model-using-scripts/1398023

### 4.7 Smooth camera follow on a physics vehicle stutters
- **Symptom:** A hover car's lagging camera jitters.
- **Cause:** Investigation in the thread found that binding at exactly `RenderPriority.Camera` races the default camera script, and that some frames render twice per physics step.
- **Fix:** Bind with `RunService:BindToRenderStep("CarCam", Enum.RenderPriority.Camera.Value + 1, fn)`, or set `Camera.CameraType = Enum.CameraType.Scriptable` and own the camera fully. Read the vehicle's interpolated CFrame each render frame. Use a frame-rate-independent lerp (§5.4).
- **Source:** https://devforum.roblox.com/t/hover-car-physics-stuttering/60801

### 4.8 Parts vanish in chunks, or lighting goes crazy: NaN in physics
- **Symptom:** A seated vehicle's parts disappear at random, and the lighting glitches.
- **Cause:** A `NaN` or `inf` reached a CFrame, a velocity or a force. Typical sources are `.Unit` of a zero vector, dividing by a zero `dt` or distance, and `math.acos` of a value slightly above 1.
- **Fix:** Guard vector math: `if v.Magnitude > 1e-6 then dir = v.Unit end`, and `math.acos(math.clamp(dot, -1, 1))`. Check for NaN with `x ~= x`, and validate every number that comes from a client (04 §4.3).
- **Source:** https://devforum.roblox.com/t/terrible-game-breaking-physics-glitch-urgent/3164927

### 4.9 Attaching a model to a hand
- **Symptom:** Touch-to-equip scripts weld props at awkward offsets.
- **Cause:** Hand-coded offsets ignore the rig's attachments.
- **Fix:** From the accepted "no-code accessory method": make the prop an `Accessory` whose handle has an Attachment named to match the rig (for example `RightGripAttachment`), and call `humanoid:AddAccessory(accessory)`. Or use a `Tool`. Or weld with `RigidConstraint`/`WeldConstraint` after aligning the attachments. Set `Massless = true` and `CanCollide = false` on held props.
- **Source:** https://devforum.roblox.com/t/whats-the-most-efficient-way-to-attach-model-to-players-handanything-else/334624

---

## 5. CFrame and math

### 5.1 Tweening a 360° rotation does nothing
- **Symptom:** A tween to `CFrame * CFrame.Angles(0, math.rad(360), 0)` doesn't move, and a 270° goal rotates 90° the other way.
- **Cause:** CFrames store orientation, not how many turns were made. 360° equals 0°, and the tween takes the shortest path.
- **Fix:** Tween a number and apply it yourself. The accepted answer chains three 120° tweens, which works but is clumsy.

```lua
local TweenService = game:GetService("TweenService")

local function spinOnce(model: Model, seconds: number): Tween
	local base = model:GetPivot()
	local angle = Instance.new("NumberValue")
	angle.Changed:Connect(function(degrees: number)
		model:PivotTo(base * CFrame.Angles(0, math.rad(degrees), 0))
	end)
	local tween = TweenService:Create(angle, TweenInfo.new(seconds, Enum.EasingStyle.Linear), { Value = 360 })
	tween.Completed:Once(function()
		angle:Destroy()
	end)
	tween:Play()
	return tween
end
```
For continuous decorative spinning, rotate on the client in `RunService.PreRender` with `dt`, or use a `HingeConstraint` motor or `AngularVelocity` for physical parts. Don't run a server loop that sets CFrames every frame.
- **Source:** https://devforum.roblox.com/t/how-to-make-tween-service-rotate-my-part-by-360-degrees/533558 (144 likes)

### 5.2 Getting only the rotation of a CFrame
- **Symptom:** "How do I get the angles of a CFrame?"
- **Fix:** `cf.Rotation` (or `cf - cf.Position`) gives the rotation with zero translation. `cf:ToEulerAnglesYXZ()` returns radians, and `cf:ToOrientation()` matches the `Orientation` property. Compose rotations with `*`. Don't add Euler angles together, because of gimbal problems.
- **Source:** https://devforum.roblox.com/t/how-to-get-a-cframes-angles/238958

### 5.3 "attempt to call a table value" on `Vector3(1, 2, 3)`, and exact float comparisons
- **Symptom:** `if mesh.Scale == Vector3(1.25, 1.25, 1.25)` errors.
- **Cause:** `Vector3` is a library table. Its constructor is `Vector3.new`. Exact `==` on computed floats also fails after any arithmetic.
- **Fix:** `Vector3.new(...)`, and compare with `a:FuzzyEq(b, 1e-4)` or `(a - b).Magnitude < epsilon`.
- **Source:** https://devforum.roblox.com/t/attempt-to-call-a-table-value/542038

### 5.4 Frame-rate-independent smoothing
- **Symptom:** `x = x:Lerp(target, 0.1)` every frame feels different at 30, 60 and 240 FPS.
- **Cause:** A fixed alpha per frame means more smoothing per second at higher frame rates.
- **Fix:** From the accepted answer: `alpha = 1 - f ^ dt`, where `f` is the fraction of the distance left after one second.

```lua
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local REMAINING_PER_SECOND = 0.001 -- 99.9% of the gap is closed each second

local function follow(getTarget: () -> CFrame)
	return RunService.PreRender:Connect(function(dt: number)
		local alpha = 1 - REMAINING_PER_SECOND ^ dt
		camera.CFrame = camera.CFrame:Lerp(getTarget(), alpha)
	end)
end
```
- **Source:** https://devforum.roblox.com/t/frame-rate-independent-lerp/352375 (code review, 99 likes)

### 5.5 Randomness: `math.randomseed(tick())` repeats, and `math.random` vs `Random.new`
- **Symptom:** "randomseed seemingly broken": the same sequence repeats across restarts.
- **Cause:** In the old answer, `math.randomseed` used only the integer part of its argument, so restarts within the same second gave the same seed. `math.random` is one global stream shared by every script.
- **Fix:** Don't seed manually at all. Create `local rng = Random.new()` per system and call `rng:NextInteger(a, b)` and `rng:NextNumber()`. Use `Random.new(seed)` for reproducible procedural generation. To pick from a folder: `local list = folder:GetChildren(); local pick = list[rng:NextInteger(1, #list)]`, after checking that `#list > 0`.
- **Sources:** https://devforum.roblox.com/t/mathrandomseed-seemingly-broken/96945 ; https://devforum.roblox.com/t/randomnew-or-mathrandom/530582

---

## 6. UI and input

### 6.1 "GUI not updating": the script edits StarterGui
- **Symptom:** A script sets `game.StarterGui.ScreenGui.TextLabel.Text = ...`. No error, nothing changes.
- **Cause:** StarterGui is a template. Each player gets a **copy** in `Player.PlayerGui` at spawn.
- **Fix:** In a LocalScript, use `Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")`. Or, simplest, put the LocalScript inside the ScreenGui and use `script.Parent`. Don't edit another player's PlayerGui from the server. Send the data and let their client render it.
- **Source:** https://devforum.roblox.com/t/gui-not-updating/468533

### 6.2 Money label shows the starting value and never updates
- **Symptom:** The label reads `$0` forever.
- **Cause:** The text was set once at startup, with no listener.
- **Fix:** From the accepted answer: render once, then on every change. `ValueBase.Changed` fires with the new value. For attributes, use `GetAttributeChangedSignal`.

```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local label = script.Parent :: TextLabel
local money = player:WaitForChild("leaderstats"):WaitForChild("Money") :: IntValue

local function render()
	label.Text = "$" .. money.Value
end
render()
money.Changed:Connect(render)
```
- **Source:** https://devforum.roblox.com/t/money-gui-not-updating-need-help/1197988

### 6.3 BillboardGui grows or shrinks when zooming
- **Symptom:** An NPC nameplate looks huge when you zoom out.
- **Cause:** A BillboardGui `Size` in **offset** keeps a constant number of pixels, while **scale** (studs) shrinks with distance. People usually want studs.
- **Fix:** Size the BillboardGui in scale (`UDim2.fromScale(4, 1)` means 4×1 studs). Size its children with `UDim2.fromScale(1, 1)`. Set `MaxDistance` to cull it. Use `TextScaled` or a `UITextSizeConstraint`.
- **Source:** https://devforum.roblox.com/t/how-do-i-make-the-billboardgui-not-change-its-size-while-zooming-outin/234443 (541 likes, the most-liked UI thread)

### 6.4 Converting offset to scale
- **Fix:** Divide by the **parent's** `AbsoluteSize` (the accepted answer used `Camera.ViewportSize`, which is right only for direct children of a full-screen ScreenGui): `UDim2.fromScale(offset.X / parent.AbsoluteSize.X, offset.Y / parent.AbsoluteSize.Y)`. For text that should fit its content, use `AutomaticSize` instead of computing sizes.
- **Source:** https://devforum.roblox.com/t/how-can-you-convert-offset-size-to-scale-size/793784

### 6.5 Setting `ImageLabel.Image` from a user-typed ID shows nothing
- **Symptom:** Pasting a decal ID into Properties works, but setting it from a script fails with an assetdelivery error.
- **Cause:** A **Decal** asset ID isn't the **Image** asset ID. Studio converts it when you paste, and scripts don't.
- **Fix:** Use the image ID, or load through the thumbnail endpoint: `label.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420"`. Validate that `id` is digits only.
- **Source:** https://devforum.roblox.com/t/setting-imagelabel-image-not-working/1638919

### 6.6 Buttons inside a BillboardGui (or SurfaceGui) don't respond
- **Symptom:** A TextButton in a BillboardGui on a part never fires on touch or click.
- **Cause:** A BillboardGui in workspace is visible but doesn't take input. Interactive world GUIs must live in `PlayerGui` with `Adornee` pointing at the part. SurfaceGuis also need `Active` buttons, and nothing transparent in front of them.
- **Fix:** Clone the GUI into `PlayerGui`, set `Adornee = part`, and use `button.Activated`.
- **Source:** https://devforum.roblox.com/t/billboardgui-textbutton-touch-pressed-event/81276

### 6.7 ClickDetector works from far away but not up close, or not on cloned models
- **Cause:** (a) An invisible or transparent part (a roof, a hitbox) is in front of the detector's part and catches the mouse ray. (b) The player is beyond `MaxActivationDistance` (32 studs by default) from the part the detector is parented to. On cloned shop models, the detector is often under a tiny part instead of the visible one.
- **Fix:** Set `CanQuery = false` on decorative blockers, parent the detector to the main visible part or the Model, and adjust `MaxActivationDistance`. For new interactions, prefer `ProximityPrompt`, which works on all platforms.
- **Sources:** https://devforum.roblox.com/t/click-detector-not-working/1691822 ; https://devforum.roblox.com/t/why-click-detector-dont-work-on-models-cloned/914575

### 6.8 Disabling the reset button reliably
- **Symptom:** `SetCore("ResetButtonCallback", false)` errors with "SetCore: ResetButtonCallback has not been registered by the CoreScripts".
- **Cause:** The LocalScript ran before the CoreScripts registered the callback.
- **Fix:** Retry inside `pcall`.

```lua
local StarterGui = game:GetService("StarterGui")

for _ = 1, 20 do
	local ok = pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", false)
	if ok then
		break
	end
	task.wait(0.25)
end
```
To run your own logic instead of disabling reset, pass a `BindableEvent` as the value and handle its `Event`.
- **Source:** https://devforum.roblox.com/t/how-can-i-disable-reset-button/1969975 (177 likes)

### 6.9 Freezing player movement (cutscenes, menus, stuns)
- **Symptom:** Setting `WalkSpeed = 0` still allows jumping and turning, and anchoring looks wrong and fights replication.
- **Fix:** Pick the approach that matches the need.
  - Client controls: `require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Disable()` and `:Enable()`.
  - Sink input with `ContextActionService:BindActionAtPriority("Freeze", function() return Enum.ContextActionResult.Sink end, false, Enum.ContextActionPriority.High.Value + 1, unpack(Enum.PlayerActions:GetEnumItems()))` and unbind it afterwards.
  - On the server (authoritative stun): `humanoid.WalkSpeed = 0`, `humanoid.JumpHeight = 0` (or `JumpPower`, depending on `UseJumpPower`). Restore the saved values afterwards.
- **Sources:** https://devforum.roblox.com/t/how-to-disable-player-movement/235833 ; https://devforum.roblox.com/t/how-to-temporarily-disable-all-character-input/178365

### 6.10 Forcing shift lock / over-the-shoulder camera
- **Symptom:** The developer wants forced shift lock for a third-person game.
- **Cause:** The accepted answer edits the forked `CameraModule`, which breaks every time Roblox updates PlayerModule.
- **Fix:** Without forking: on the client, set `UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter` each `PreRender`. Set `humanoid.AutoRotate = false`, rotate the root to the camera's yaw, and set `humanoid.CameraOffset = Vector3.new(1.75, 0, 0)` for the shoulder offset. Restore everything when it's turned off. Players can also toggle shift lock themselves when `StarterPlayer.EnableMouseLockOption` is true.
- **Source:** https://devforum.roblox.com/t/how-can-i-force-shift-lock/239206

### 6.11 Tween errors: "Unable to cast to Dictionary" and "Can only tween objects in workspace"
- **Cause:** (a) The arguments to `TweenService:Create(instance, tweenInfo, goals)` were passed in the wrong order or shape. The goals must be a dictionary of property names. (b) The instance isn't in the DataModel yet, for example a GUI created but not parented under PlayerGui.
- **Fix:** Parent first, then tween: `TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()`.
- **Sources:** https://devforum.roblox.com/t/receiving-unable-to-cast-to-dictionary-error-for-tween/406928 ; https://devforum.roblox.com/t/tweening-error-can-only-tween-objects-in-workspace/163436

---

## 7. Tweens and animation

### 7.1 Tweening a whole model (modernized)
- **Symptom:** "TweenService works on parts, but not on models."
- **Cause:** `Model` has no tweenable CFrame property.
- **Fix:** The current accepted answer replaces `SetPrimaryPartCFrame` with `PivotTo`. Alternatives: weld all parts to an anchored root and tween only the root's `CFrame`. Or, for many objects, tween on the client and keep the server state abstract.

```lua
local TweenService = game:GetService("TweenService")

local function tweenModel(model: Model, info: TweenInfo, target: CFrame): Tween
	local driver = Instance.new("CFrameValue")
	driver.Value = model:GetPivot()
	local connection = driver.Changed:Connect(function(cf: CFrame)
		model:PivotTo(cf)
	end)
	local tween = TweenService:Create(driver, info, { Value = target })
	tween.Completed:Once(function()
		connection:Disconnect()
		driver:Destroy()
	end)
	tween:Play()
	return tween
end
```
- **Sources:** https://devforum.roblox.com/t/tweening-models/60545 (accepted answer updated for PivotTo) ; https://devforum.roblox.com/t/introduction-to-tweening-models/315253

### 7.2 Animation works in Studio but not in game, or "Failed to load animation — sanitized ID"
- **Symptom:** The animation plays in Studio and fails live. The output shows "Failed to load animation - sanitized ID", even when "I OWN ALL MY ANIMATIONS".
- **Cause:** Live games only load animations owned by the **experience owner**. If the experience belongs to a group, the animation must be published to that group, and the other way round. A wrong or non-animation ID gives the same error.
- **Fix:** Re-publish the animation under the same owner as the experience (in the Animation Editor, choose the group as creator), then update the IDs. Also check that the rig has no anchored parts and has an Animator.
- **Sources:** https://devforum.roblox.com/t/animation-only-works-in-studio-not-ingame/565465 ; https://devforum.roblox.com/t/animation-works-in-studio-yet-not-in-game/575473 ; https://devforum.roblox.com/t/failed-to-load-animation-sanitized-id/2652038 ; https://devforum.roblox.com/t/failed-to-load-animation-sanitized-id/2556354

### 7.3 "Cannot load the AnimationClipProvider service"
- **Symptom:** `LoadAnimation` errors with this message, typically on a ViewportFrame dummy or right after a character dies.
- **Cause:** From the thread's resolution: the Humanoid or Animator **isn't in workspace** (or a `WorldModel`) when `LoadAnimation` is called. A dead character that was removed has the same problem.
- **Fix (modernized from `Humanoid:LoadAnimation`):**

```lua
local function loadTrack(rig: Model, animationId: string): AnimationTrack?
	if not (rig:IsDescendantOf(workspace) or rig:FindFirstAncestorOfClass("WorldModel")) then
		return nil
	end
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return nil
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animator:LoadAnimation(animation)
end
```
In a ViewportFrame, put the dummy inside a `WorldModel` that's a child of the ViewportFrame, and parent the GUI under PlayerGui before loading. After a respawn, load again on the new character's Animator.
- **Source:** https://devforum.roblox.com/t/error-cannot-load-the-animationclipprovider-service/1639315 (441 likes)

### 7.4 `AdjustSpeed` "doesn't work", and `Stop` doesn't stop
- **Symptom:** Speed resets to 1 on every play, or `track:Stop()` leaves the animation running.
- **Cause:** (a) `AdjustSpeed` was called before `Play`, and `Play` resets the speed. (b) The code called `LoadAnimation` again and stopped the *new* track, while the old track kept playing.
- **Fix:** Use `track:Play(fadeTime, weight, speed)`, or call `AdjustSpeed` after `Play`. Load each animation **once** per Animator, cache the track, and reuse it. To stop everything: `for _, t in animator:GetPlayingAnimationTracks() do t:Stop() end`.
- **Sources:** https://devforum.roblox.com/t/animationtrackadjustspeed-not-working/1182750 ; https://devforum.roblox.com/t/cant-stop-animation/661170

### 7.5 Output spam: "Property Animator.EvaluationThrottled is not currently enabled"
- **Cause:** An engine-side property that wasn't enabled yet; it came from Roblox, not from your code. It shows up when printing or inspecting models.
- **Fix:** Ignore it, and don't change your code. In the current API dump, `Animator.EvaluationThrottled` is a normal read-only property.
- **Source:** https://devforum.roblox.com/t/what-is-property-animatorevaluationthrottled-is-not-currently-enabled/2448273

### 7.6 Fading things in and out
- **Fix:** Tween `Volume`, `Transparency`, `BackgroundTransparency` or `TextTransparency`. Don't write `for i = 0, 1, 0.1 do ... wait(0.1) end` loops, as the accepted answer for fading music points out: `TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Linear), { Volume = 0 }):Play()`. Trigger it from an event, such as `GetPropertyChangedSignal("Visible")`, rather than a polling loop.
- **Source:** https://devforum.roblox.com/t/is-there-a-way-to-make-music-fade-inout/793863

---

## 8. Sound

### 8.1 "Failed to load sound rbxassetid://… Unable to download sound data"
- **Cause:** Audio privacy. Since 2022, most audio is private to its owner, and an experience can only play audio it owns or has been granted permission to use. Typos and moderated assets cause the same error, and occasionally it's a Roblox outage, as in the original thread.
- **Fix:** Upload the audio under the experience owner (or grant it permission in the asset's settings). Use Creator Store tracks that Roblox licenses for use in experiences. Check `Sound.IsLoaded` and `Loaded` before relying on `TimeLength`.
- **Source:** https://devforum.roblox.com/t/failed-to-load-sound-rbxassetid-id-unable-to-download-sound-data/874349

### 8.2 3D sound range is wrong after `EmitterSize` was deprecated
- **Symptom:** A sound gets louder as you walk away, or plays at full volume everywhere.
- **Cause:** `EmitterSize` and `MinDistance` are deprecated, and the replacements are `RollOffMinDistance`, `RollOffMaxDistance` and `RollOffMode`. A Sound parented to SoundService, a Folder or the GUI is **2D**. Only a Sound under a BasePart or Attachment is positional.
- **Fix:**

```lua
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://0" -- your owned asset id
sound.RollOffMode = Enum.RollOffMode.InverseTapered
sound.RollOffMinDistance = 10
sound.RollOffMaxDistance = 80
sound.Looped = true
sound.Parent = workspace:WaitForChild("Radio") -- a BasePart, so the sound is positional
sound:Play()
```
For new audio work, the Audio API (`AudioPlayer`, `AudioEmitter`, `AudioListener`) is the current system. `Sound` is tagged as legacy in the API dump, but it still works.
- **Source:** https://devforum.roblox.com/t/how-to-properly-set-the-range-of-a-sound-that-can-be-heard/883232

### 8.3 Removing or replacing default footstep sounds
- **Symptom:** Setting `HumanoidRootPart.Running.Volume = 0` on the server does nothing.
- **Cause:** From the accepted answer: character sounds are created **per client** by the `RbxCharacterSounds` PlayerScript. The server has no role in them.
- **Fix:** Fork the script by putting a LocalScript named `RbxCharacterSounds` in `StarterPlayer.StarterPlayerScripts`, which replaces the default. Or mute the sounds on the client.

```lua
local Players = game:GetService("Players")

local function muteFootsteps(character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local running = root and root:WaitForChild("Running", 10)
	if running and running:IsA("Sound") then
		running.Volume = 0
	end
end

local function watch(player: Player)
	player.CharacterAdded:Connect(muteFootsteps)
	if player.Character then
		task.spawn(muteFootsteps, player.Character)
	end
end

Players.PlayerAdded:Connect(watch)
for _, player in Players:GetPlayers() do
	watch(player)
end
```
- **Source:** https://devforum.roblox.com/t/how-do-i-make-roblox-footsteps-sound-go-away/420413 (198 likes)

### 8.4 Exploiters playing music for everyone
- **Cause:** A radio remote that plays any ID the client sends, or `SoundService.RespectFilteringEnabled = false`, which lets client-played sounds replicate.
- **Fix:** Keep `RespectFilteringEnabled = true`. Radio remotes should accept only IDs from a server whitelist, be rate-limited (§2.2), and check permissions (for example a gamepass).
- **Source:** https://devforum.roblox.com/t/music-exploits-on-filtering-enabled/234314

---

## 9. Performance and memory leaks

### 9.1 Connections keep Instances alive
- **Symptom:** Server memory grows every round, or effects fire twice on the second round.
- **Cause:** From the PSA: a connection whose callback references the Instance it's connected to (directly or through a captured table) keeps that Instance alive until it's disconnected **or the Instance is destroyed**. `:Destroy()` disconnects everything. Setting `Parent = nil` doesn't.
- **Fix:** Call `:Destroy()` on instances you're finished with, never just reparent them to nil. Use one cleanup owner per lifetime (a Trove per player, character and round; 04 §6.2). Use `Signal:Once` for one-shot listeners. Clear Player-keyed tables in `PlayerRemoving`. The 2026-11-11 `PlayerCharacterDestroyBehavior` default (§1.6) now destroys old characters and players automatically, which fixes the most common leak at engine level. Don't rely on it for your own tables.
- **Sources:** https://devforum.roblox.com/t/psa-connections-can-memory-leak-instances/90082 (623 likes) ; https://devforum.roblox.com/t/garbage-collection-and-memory-leaks-in-roblox-what-you-should-know/374954

### 9.2 Polling loops instead of events
- **Symptom:** Code review of a health bar or flickering light: "Should I even be using a loop?"
- **Cause:** `while true do wait() ... end` per object costs script time on every frame, and multiplies with the number of objects.
- **Fix:** Use events (`Humanoid.HealthChanged`, `.Changed`, `GetAttributeChangedSignal`). For many similar objects (lights, coins, doors), use **one** script that drives every tagged instance through CollectionService, not one script per object.
- **Sources:** https://devforum.roblox.com/t/feedback-on-health-bar-gui/238919 ; https://devforum.roblox.com/t/flickering-light-script/578006

### 9.3 "Script timeout: exhausted allowed execution time"
- **Symptom:** A long computation (minimax, terrain generation, a big sort) gets killed after the timeout.
- **Cause:** Luau runs one thread at a time. A thread that never yields blocks the frame, and the watchdog kills it.
- **Fix:** Do the work in time-budgeted slices. Don't raise the Studio timeout (`settings().Studio.ScriptTimeoutLength`); that only hides the freeze locally. For CPU-heavy, parallelizable work, use Actors and Parallel Luau (04 §13).

```lua
local BUDGET = 1 / 240 -- seconds of work per frame

local function processAll<T>(items: { T }, process: (T) -> ())
	local deadline = os.clock() + BUDGET
	for _, item in items do
		process(item)
		if os.clock() >= deadline then
			task.wait()
			deadline = os.clock() + BUDGET
		end
	end
end
```
- **Source:** https://devforum.roblox.com/t/how-to-handle-script-timeout-exhausted-allowed-execution-time/533353 (173 likes)

### 9.4 "My game lags": diagnose before optimizing
- **Symptom:** Low FPS even on a strong PC, or "I already used the MicroProfiler and can't find it."
- **Cause:** Developers optimize the wrong thing (part count) while the real cost is somewhere else: unbounded connections, many Humanoids, per-frame server loops, physics ownership churn, huge textures.
- **Fix:** Follow the playbook in §17. The usual wins from these threads: disconnect unused connections and use `:Once`; destroy finished tweens and effects; turn on StreamingEnabled for big maps; reduce Humanoid count (or use `AnimationController` for NPCs that don't need Humanoid physics); move cosmetic animation to the client; run one central update loop instead of hundreds.
- **Sources:** https://devforum.roblox.com/t/help-needed-to-remove-lag-from-my-game/2924694 ; https://devforum.roblox.com/t/how-to-reduce-lag-on-a-game/285814 ; https://devforum.roblox.com/t/how-to-measure-how-expensive-code-is/238408 ; https://devforum.roblox.com/t/improved-how-to-actually-improve-performance-in-your-games/1221842

### 9.5 Hundreds or thousands of NPCs
- **Symptom:** With 1,500 NPCs, ping hits 300–500 ms even though script activity is low.
- **Cause:** Replication and physics cost, not Lua: every Humanoid NPC replicates its parts' CFrames and runs a Humanoid state machine.
- **Fix:** Simulate NPCs as data on the server (position, path progress) and replicate compact state with buffers or unreliable remotes at a low rate. Each client renders and interpolates the models locally. Anchor server-side proxies or don't create them at all.
- **Sources:** https://devforum.roblox.com/t/optimization-tips-on-npcs-managed-to-get-1500-npcs-300-500-ping-about-3-5-script-activity-but-rate-is-over-20-30k/2511448 ; https://devforum.roblox.com/t/tower-defence-enemies-lagging-behind/2738378

### 9.6 Player data stored as hundreds of Value objects
- **Symptom:** Code review: "I use Values to store all player information. Is that outdated?"
- **Fix:** From the accepted answer: keep the authoritative data in a server ModuleScript table keyed by Player, and remove the entry on leave. Expose only what the UI needs, through attributes or a replication remote. Keep `leaderstats` Values only for the default player list.
- **Source:** https://devforum.roblox.com/t/storing-player-data-in-game/250801

---

## 10. StreamingEnabled

StreamingEnabled is on by default in new places, so the bot should assume it's on unless the place says otherwise.

### 10.1 Random "Infinite yield possible on Workspace.X:WaitForChild('Y')"
- **Symptom:** Sometimes it works and sometimes LocalScripts hang on workspace objects. The OP in the thread had inherited a project with streaming turned on.
- **Cause:** With streaming, distant parts of workspace aren't on the client, and they stream in and out at any time.
- **Fix:** For client code that touches workspace:
  - Call `WaitForChild(name, timeout)` and handle `nil`.
  - Drive behavior from CollectionService signals, which also fire on stream-in and stream-out.
  - Set `Model.ModelStreamingMode = Atomic` for models whose parts must arrive together, and `Persistent` (sparingly) for things that must always exist on the client.
  - Keep client-required assets in ReplicatedStorage.

```lua
local CollectionService = game:GetService("CollectionService")

local active: { [Instance]: RBXScriptConnection } = {}

local function onDoorAdded(door: Instance)
	local prompt = door:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		active[door] = prompt.Triggered:Connect(function() end)
	end
end

local function onDoorRemoved(door: Instance)
	local connection = active[door]
	if connection then
		connection:Disconnect()
		active[door] = nil
	end
end

CollectionService:GetInstanceAddedSignal("Door"):Connect(onDoorAdded)
CollectionService:GetInstanceRemovedSignal("Door"):Connect(onDoorRemoved)
for _, door in CollectionService:GetTagged("Door") do
	task.spawn(onDoorAdded, door)
end
```
- **Sources:** https://devforum.roblox.com/t/how-to-get-localscripts-to-wait-for-workspace-to-completely-load/277160 ; https://devforum.roblox.com/t/how-useful-is-it-to-have-streaming-enabled/260694

### 10.2 What happens to streamed-out instances
- **Answer (per updated docs quoted in the thread):** When an instance streams out on the client, it's **parented to nil**, so existing Luau references reconnect if it streams back in. Don't keep long-lived references and assume the instance is still in workspace. Check `inst:IsDescendantOf(workspace)` or use the tag signals above.
- **Source:** https://devforum.roblox.com/t/when-parts-are-streamed-out-are-they-parented-to-nil-or-destroyed/672658

### 10.3 Effects silently don't play (`ParticleEmitter:Emit` does nothing)
- **Symptom:** `emitter:Emit(20)` works with streaming off and does nothing with it on. Adding `wait()` "fixes" it.
- **Cause:** The emitter's part hadn't streamed in yet, or had just streamed in, when the server or client called `Emit`. On the server, the client may not have the part at all.
- **Fix:** Play VFX on the client: the server fires a remote with a position or tag, and the client clones the effect from ReplicatedStorage and emits it after parenting. Don't rely on yields to fix this.
- **Source:** https://devforum.roblox.com/t/particleemitteremit-doesnt-work/758953

### 10.4 Teleporting a player to a far location lands them in the void, or the client can't find the target
- **Fix:** On the server, before moving them: `player:RequestStreamAroundAsync(targetPosition, 5)` (it yields; wrap it in `pcall`), then `character:PivotTo(targetCFrame)`. For a client-side camera focus somewhere else, set `Player.ReplicationFocus`.
- **Source (related):** https://devforum.roblox.com/t/how-to-get-localscripts-to-wait-for-workspace-to-completely-load/277160

### 10.5 "How do I make an ACTUAL loading screen?"
- **Fix:** In ReplicatedFirst, remove the default with `ReplicatedFirst:RemoveDefaultLoadingScreen()`. Show your GUI. Wait for `game:IsLoaded()` (or `game.Loaded:Wait()`). Then `ContentProvider:PreloadAsync({ ...assets you need on screen first })` with a progress callback. With streaming on, "loaded" doesn't mean the whole map is present, so preload only UI and the first view.
- **Source:** https://devforum.roblox.com/t/how-do-i-make-a-actual-loading-screen/1751134

---

## 11. OOP, ModuleScripts and require

### 11.1 "Requested module experienced an error while loading"
- **Cause:** The ModuleScript threw while it ran, or returned nothing. This message only reports that the require failed. The real error is printed **above** it, with the module's own line number.
- **Fix:** Scroll up to the first red line and fix that. Common culprits: the module indexes something that doesn't exist yet at require time, yields forever on `WaitForChild`, or doesn't end with exactly one `return`. Keep module bodies side-effect free (declare things, don't start them). 04 §3.2 has the Init/Start loader.
- **Source:** https://devforum.roblox.com/t/requested-module-experienced-an-error-while-loading/524297

### 11.2 Circular requires: two modules that need each other
- **Symptom:** A loop of modules requiring a "Main" module that requires them back. It stalls, errors, or produces nil fields.
- **Cause:** Module A requires B while A is still loading, and B requires A.
- **Fix:** The pattern from the thread: a framework module that requires everything inside an `Initialize()` called once by the bootstrap script, so the modules don't require each other at load time. Other options: pass dependencies into `Init(deps)`, require lazily inside the function that needs the module, or move the shared piece into a third module. See 04 table rows 23–24.
- **Source:** https://devforum.roblox.com/t/help-with-modularization/170723

### 11.3 Requiring a module many times
- **Answer:** That's fine. `require` runs a module **once per Luau VM** and caches the returned value, so every caller gets the same table. The server and each client are separate VMs, so a module in ReplicatedStorage has one copy on the server and one per client. State doesn't sync between them. Actors (Parallel Luau) also get their own copies.
- **Source:** https://devforum.roblox.com/t/requiring-module-more-than-once/223496

### 11.4 Single-script architecture, or many small scripts?
- **Symptom:** "Is running the whole game on 2 scripts good or bad?" Answers are split.
- **Resolution:** "Single script" really means one bootstrap Script and one bootstrap LocalScript that require ModuleScripts, plus optionally one in ReplicatedFirst for loading. The code is still split into many files. The argument that "one error kills everything" goes away once each module's `Init` and `Start` is wrapped in `xpcall` by the loader (04 §3.2).
- **Sources:** https://devforum.roblox.com/t/questions-regarding-single-script-architecture-module-loaders/327169 ; https://devforum.roblox.com/t/scripting-with-module-scripts-or-one-big-script/138469

### 11.5 `self` is nil, or "attempt to index nil with ..." inside a method
- **Cause:** A method defined with `:` (`function Class:Method()`) was called with `.` (`obj.Method()`), so `self` received the first argument or nil. The reverse mistake shifts all the parameters by one. It also happens when you pass `obj.Method` as a callback, which loses `self`.
- **Fix:** Define and call consistently: `obj:Method(x)` is shorthand for `obj.Method(obj, x)`. For callbacks, wrap the call: `signal:Connect(function(...) obj:Method(...) end)`. 04 §7.1 has the full typed class pattern.
- **Source:** https://devforum.roblox.com/t/what-is-self-and-how-can-i-use-it/368697 (772 likes)

### 11.6 `_G` / `shared` for sharing between scripts
- **Cause:** `_G` works, but it's untyped and has ordering races: a reader can run before the writer.
- **Fix:** Use a ModuleScript that returns the shared table. It's typed, it's explicit, and `require` handles the ordering. Never put secrets in `_G` on the client.
- **Source:** https://devforum.roblox.com/t/what-is-g-and-for-what-i-can-use-it/322199 (746 likes)

---

## 12. Task scheduling and yielding

### 12.1 `wait()` vs `task.wait()`
- **Answer:** Always use `task.wait`. The legacy `wait` is throttled (it can resume late under load), runs on the legacy 30 Hz scheduler, and is officially superseded. `task.wait` resumes on the next Heartbeat after the duration and returns the actual time elapsed.
- **Source:** https://devforum.roblox.com/t/taskwaitn-vs-waitn/1491119 (177 likes)

### 12.2 `spawn` vs coroutines vs `task.spawn`
- **Answer (modernized):** The 2019 accepted answer predates the task library. Now:
  - `task.spawn(f, ...)` runs at once, with errors reported and traced.
  - `task.defer(f, ...)` runs at the end of the current resumption cycle.
  - `task.delay(t, f, ...)` runs after a delay.
  - `task.cancel(thread)` stops a thread.
  - Use `coroutine.wrap` and `coroutine.create` only for generator or state-machine patterns. Errors inside `coroutine.resume` come back as return values and are easy to swallow silently.
- **Sources:** https://devforum.roblox.com/t/coroutines-vs-spawn-which-one-should-i-use/368966 ; https://devforum.roblox.com/t/should-i-be-using-taskspawn-or-coroutines/2483581

### 12.3 When to use `task.defer`
- **Answer:** Use it when the work should run *after* the current engine operation finishes. Typical cases: reacting to `ChildAdded` or `AncestryChanged`, where reparenting immediately would hit "parent property locked"; or batching several changes into one update. In other cases `task.spawn` is fine. Claims that `defer` is generally faster are speculation, and the poster says so.
- **Source:** https://devforum.roblox.com/t/practical-use-of-taskdefer/1751441

### 12.4 "Infinite yield possible on ..."
- **Cause:** `WaitForChild` has waited more than 5 seconds. It's only a warning, and the thread keeps waiting. The real bug is usually one of these: wrong name or path, the object is only created later (or never, on this side), the object was streamed out (§10), or it's server-only (in ServerStorage) and the client is looking for it.
- **Fix:** Check the path in the Explorer *during a play test, on the correct side* (switch between Client and Server views). For optional objects, pass a timeout and handle nil:

```lua
local shopZone = workspace:WaitForChild("EnterShop", 10)
if not shopZone then
	warn("EnterShop not found; shop disabled on this client")
	return
end
```
- **Sources:** https://devforum.roblox.com/t/whats-an-infinite-yield/530639 ; https://devforum.roblox.com/t/i-keep-getting-a-warning-of-infinite-yield-possible-and-its-awkward/2798667

### 12.5 Deferred signals change ordering
- **Symptom:** After the place switched `Workspace.SignalBehavior` to Deferred (the direction Roblox has announced for Default), code that set a property and expected the handler to have run on the next line breaks.
- **Cause:** With deferred events, handlers are queued and resumed together at fixed points in the frame, not immediately.
- **Fix:** Don't depend on a handler having run synchronously after `:Fire()` or a property set. Pass data explicitly, and use `:Once` together with explicit state. See 04 table row 27.
- **Source:** https://devforum.roblox.com/t/deferred-engine-events/2276564 (announcement)

### 12.6 "Heartbeat, Stepped and RenderStepped are deprecated?"
- **Answer:** They were briefly shown as deprecated in the docs in 2021. In the current API dump (2026) `Heartbeat`, `Stepped` and `RenderStepped` are **not** marked deprecated. The newer `PreSimulation` (≈ Stepped), `PostSimulation` (≈ Heartbeat) and `PreRender` (≈ RenderStepped) also exist. Either set is fine. Prefer the new names in new code, and use `PreRender` for camera and visual work on the client only.
- **Source:** https://devforum.roblox.com/t/heartbeat-stepped-and-renderstepped-are-deprecated-what-can-i-use-instead/1055275

---

## 13. Security and exploits

### 13.1 Client-side anticheats
- **Symptom:** Code-review posts like "How can I improve my anticheat?" or "Review my awesome anticheat" that detect speed, fly or noclip in a LocalScript.
- **Cause:** Exploiters control their client and can delete or patch any LocalScript. "This anticheat will … provide practically no reliability… flawed at the design level."
- **Fix:** Put checks on the server using values the server can see: position deltas over time, compared with `WalkSpeed` plus a tolerance (04 §4.5); ground and raycast checks for flying; validated remote arguments. Expect false positives from lag, seats, vehicles and conveyors, and handle them with rubber-banding (reset the position) rather than instant bans. Only ban on high confidence.
- **Sources:** https://devforum.roblox.com/t/how-can-i-improve-my-anticheat/627213 ; https://devforum.roblox.com/t/how-to-improve-this-anti-exploit-script/760066 ; https://devforum.roblox.com/t/review-my-awesome-anticheat-code-please/2517913 ; https://devforum.roblox.com/t/any-comments-on-my-walkspeed-detection-exploit-speed-detection/1345653

### 13.2 "How do hackers fly, speed or teleport if FE is on?"
- **Answer:** The client owns its own character's physics, so anything a LocalScript can do to its own character, an executor can do too, and it replicates. FilteringEnabled only stops client changes to instances the client doesn't own from replicating.
- **Fix:** Server movement validation (13.1). Remote validation for everything else.
- **Source:** https://devforum.roblox.com/t/how-do-hackers-hack-eg-flying/2632359 (270 likes)

### 13.3 "An exploiter changed the skybox and deleted the map for everyone"
- **Cause:** Almost always a **backdoor**: a `require(assetId)` or `loadstring` hidden in a free model, a plugin, or a fake "admin" or "fast load" script. Not a FilteringEnabled bypass.
- **Fix:** Audit every Script in the game. Search for `require(` with a number argument, `getfenv`, `loadstring`, `HttpService` calls you didn't write, and obfuscated strings. Keep `LoadStringEnabled` off. Only install plugins from trusted creators.
- **Sources:** https://devforum.roblox.com/t/how-did-an-exploiter-change-things-in-workspace-that-are-visible-to-everyone/187097

### 13.4 Stopping game theft (saveinstance, Dex)
- **Answer:** You can't. Anything replicated to the client (workspace, ReplicatedStorage, LocalScripts, ModuleScripts the client requires) can be copied. Detecting Dex by GUI names or CoreGui access is pointless: "Don't patch the GUI, patch the exploit."
- **Fix:** Keep valuable logic in ServerScriptService and ServerStorage, which never replicate. Make the server authoritative, so copied client code is useless without it. Use DMCA and IP takedowns for stolen content.
- **Sources:** https://devforum.roblox.com/t/is-there-anyway-to-stop-hackers-from-stealingcopying-your-game-and-scripts/688001 ; https://devforum.roblox.com/t/theft-of-game-content-using-saveinstance/3050674 ; https://devforum.roblox.com/t/how-do-you-detect-dark-dex/896546 (910 likes)

### 13.5 Exploiters crashing servers
- **Symptom:** Servers freeze and everyone gets "check your internet connection".
- **Cause:** Floods: remote spam, huge payloads, or abuse of an engine replication bug. The last kind can only be fixed by Roblox.
- **Fix:** Rate-limit every remote (§2.2). Cap payload sizes, such as string lengths and table counts. Never do unbounded work per request, such as creating instances or making DataStore calls. Report engine-level crashes to Roblox. One suggested snippet in that thread wrote `Cooldown[player.Name] = true` but checked `Cooldown[player.UserId]`, so it never limited anything. Use **one** key type consistently, preferably the Player object or UserId.
- **Source:** https://devforum.roblox.com/t/exploiters-crashing-my-servers-cause-unknown/473168 (584 likes)

### 13.6 Donation-game purchase exploit (changing the price mid-prompt)
- **Symptom:** In "donation" games, players change a clothing item's price between the prompt and confirmation, and the game credits the old price.
- **Cause:** The game credited the amount from a client-supplied or prompt-time value.
- **Fix:** Handle the purchase on the server. Remember which asset that player is buying (`player:SetAttribute("PendingAsset", id)`). On `MarketplaceService.PromptPurchaseFinished` (server), check that the asset matches and `isPurchased` is true, then read the price **again** on the server with `MarketplaceService:GetProductInfoAsync`. For Robux items you sell, use Developer Products with a receipt handler (04 §9.2).
- **Source:** https://devforum.roblox.com/t/how-to-fix-the-t-shirt-purchase-exploit-for-donation-games/2653583

### 13.7 Don't kick on "suspicion" in normal code paths
- **Symptom:** A shop review where the server kicks a player whose requested item doesn't exist.
- **Fix:** Treat malformed requests as no-ops with a log line. Your own bugs, renamed items or race conditions will produce them for honest players. Escalate only on repeated, clearly impossible input.
- **Source:** https://devforum.roblox.com/t/how-can-i-improve-my-shop-system/235722

---

## 14. Studio vs live differences

| Symptom | Likely cause | Fix | Source |
|---|---|---|---|
| Works in Studio, nothing happens live, no errors | Script changes saved as Team Create **drafts** but never committed, or the place not republished | Commit drafts (View → Drafts), then File → Publish to Roblox; check the live Developer Console (F9) | https://devforum.roblox.com/t/my-game-only-works-in-studio-really-confused/473859 ; https://devforum.roblox.com/t/roblox-player-has-bug-studio-does-not/3305455 |
| Character, backpack or GUI code fails live only | Timing: Studio's local server has no latency, so races don't show; the live Backpack and character arrive later and are recreated on respawn | `WaitForChild`, rebind on `CharacterAdded`; test with simulated latency (Studio Settings → Network → Incoming Replication Lag) | https://devforum.roblox.com/t/roblox-player-has-bug-studio-does-not/3305455 |
| Tool given on join works in Studio, not live | Tool cloned into `Backpack` once at `PlayerAdded`; the live first spawn recreates the Backpack | Give on `CharacterAdded`, or put the tool in `player.StarterGear` | https://devforum.roblox.com/t/script-works-in-studio-does-not-work-ingame/467552 |
| Animations play in Studio only | Asset owner differs from the experience owner (group vs user) | Publish animations under the experience owner (§7.2) | https://devforum.roblox.com/t/animation-only-works-in-studio-not-ingame/565465 |
| DataStore errors in Studio | API access disabled, or place never published | Publish; enable *Studio Access to API Services* | https://devforum.roblox.com/t/datastore-not-working/490557 |
| Save never finishes when pressing Stop | Studio shuts down at once; `PlayerRemoving` yields are cut off | `BindToClose` waiting on saves (§1.8) | https://devforum.roblox.com/t/datastore-not-saving-in-playerremoving/879024 |
| Long loop OK in Studio after raising the timeout, freezes live | `ScriptTimeoutLength` is a Studio setting | Budgeted batching (§9.3) | https://devforum.roblox.com/t/how-to-handle-script-timeout-exhausted-allowed-execution-time/533353 |
| `RunService:IsStudio()` branches behave differently | Intended; used for shorter BindToClose waits or debug tools | Keep Studio-only branches small; never gate security on it | https://devforum.roblox.com/t/playerremoving-and-bindtoclose-datastore-redundancy/281994 |

---

## 15. Mobile, console and cross-platform input

### 15.1 "How do I detect if the player is on a phone?"
- **Cause:** The accepted 2021 heuristic (`TouchEnabled and not KeyboardEnabled`) misreports tablets with keyboards and touchscreen laptops. A reply in the thread: "Adapt to the form of input the user wants to use, not what you think they should use."
- **Fix:** Use `UserInputService.PreferredInput` (`KeyboardAndMouse`, `Gamepad`, `Touch`, `MicroGamepad`) and react when it changes. Use `LastInputTypeChanged` for finer-grained prompts.

```lua
local UserInputService = game:GetService("UserInputService")

local function applyLayout(preferred: Enum.PreferredInput)
	local touch = preferred == Enum.PreferredInput.Touch
	local gamepad = preferred == Enum.PreferredInput.Gamepad
	-- e.g. show large on-screen buttons for touch, button glyphs for gamepad
	print("layout", touch, gamepad)
end

applyLayout(UserInputService.PreferredInput)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	applyLayout(UserInputService.PreferredInput)
end)
```
- **Sources:** https://devforum.roblox.com/t/how-to-check-if-a-player-is-mobile-or-pc/1384078 ; https://devforum.roblox.com/t/how-to-detect-if-player-is-using-a-phone/178533 (358 likes)

### 15.2 Buttons that work with mouse but not touch or gamepad
- **Cause:** `MouseButton1Click` and `MouseButton1Down` are mouse-centric. `Activated` fires for mouse click, touch tap and gamepad A on the selected object.
- **Fix:** Use `button.Activated:Connect(...)` everywhere. For gamepads, make buttons `Selectable` and set `GuiService.SelectedObject = firstButton` when a menu opens (set it to `nil` on close). Use `NextSelectionUp`/`Down` or `SelectionGroup` for navigation order. Don't fake a pointer for controllers.
- **Source:** https://devforum.roblox.com/t/how-would-i-activate-a-textbutton-with-a-controller/222593

### 15.3 TextBox won't focus on mobile
- **Cause:** `Active = false` on the TextBox (or a parent covering it), or another GUI on top that sinks input.
- **Fix:** `textBox.Active = true`, check ZIndex and overlapping frames, and call `TextBox:CaptureFocus()` from an `Activated` handler if needed.
- **Source:** https://devforum.roblox.com/t/textbox-isnt-working-on-mobile/581799

### 15.4 Hiding the mobile joystick and jump button (modernized)
- **Cause:** Old answers use `UserInputService.ModalEnabled`, which is deprecated, or disable all controls.
- **Fix:** `GuiService.TouchControlsEnabled = false` hides the default touch controls (client). To keep movement but hide only jump, set `StarterPlayer.CharacterJumpHeight = 0` or handle jump yourself. For custom mobile actions, use `ContextActionService:BindAction(name, fn, true, ...)`, where `true` creates a touch button you can position with `SetPosition`.
- **Source:** https://devforum.roblox.com/t/how-to-disable-mobile-buttons-eg-jump-and-joystick/917005

### 15.5 Safe areas and notches
- **Fix:** Leave `ScreenGui.ScreenInsets = DeviceSafeInsets` (the default) for interactive UI. Use `None` only for full-bleed backgrounds. Test with Studio's device emulator for phone, tablet and 10-foot console views.
- **Source (UI scale context):** https://devforum.roblox.com/t/how-do-i-make-the-billboardgui-not-change-its-size-while-zooming-outin/234443

---

## 16. The 30 most common Code Review critiques

These were collected from the top Code Review threads, plus a keyword pass over the reply text of all 1,200 mirrored threads (code blocks excluded). The most frequent reply themes, in order, were: performance, tweens instead of loops, OOP structure, trusting the client, readability, modularity, deprecated `wait()`, RunService usage, function splitting, repetition, server vs client, connection leaks, nesting, globals, naming, comments, magic numbers, lookup tables and raycast params. Before handing code to the user, the bot should check its own code against this list.

| # | Critique | What reviewers say to do | Example thread |
|---|---|---|---|
| 1 | Logic runs on the client that must be server-authoritative (anticheat, currency, damage) | Move it to the server; the client sends intent only | https://devforum.roblox.com/t/how-can-i-improve-my-anticheat/627213 |
| 2 | Remote handlers don't validate types, ranges or ownership | Type-check, clamp, check ownership and cooldown on the server | https://devforum.roblox.com/t/how-safe-are-remotefunctions/63336 |
| 3 | No rate limit on remotes | Per-player token bucket | https://devforum.roblox.com/t/how-to-check-if-a-player-is-spamming-a-remote-too-fast/245991 |
| 4 | `wait()` / `spawn()` / `delay()` | `task.*` | https://devforum.roblox.com/t/taskwaitn-vs-waitn/1491119 |
| 5 | `while true do wait() end` polling | Events (`Changed`, `HealthChanged`, attributes) or one central Heartbeat loop | https://devforum.roblox.com/t/feedback-on-health-bar-gui/238919 |
| 6 | One script per object (lights, coins, kill bricks) | One script plus CollectionService tags | https://devforum.roblox.com/t/flickering-light-script/578006 |
| 7 | Manual `for` loops stepping transparency or position | TweenService | https://devforum.roblox.com/t/is-there-a-way-to-make-music-fade-inout/793863 |
| 8 | Connections never disconnected / Player tables never cleared | Disconnect, `:Once`, Trove, clear on `PlayerRemoving` | https://devforum.roblox.com/t/psa-connections-can-memory-leak-instances/90082 |
| 9 | Not using `game:GetService` and `workspace` | `local Players = game:GetService("Players")` at the top; `workspace` instead of `game.Workspace` | https://devforum.roblox.com/t/pirate-wave-defense-core-script/953581 |
| 10 | `pairs` on arrays / unclear iteration | Generalized iteration `for i, v in t`; `ipairs` when stopping at nil matters | https://devforum.roblox.com/t/pirate-wave-defense-core-script/953581 ; https://devforum.roblox.com/t/ipairs-vs-pairs-whats-the-difference/1164958 |
| 11 | Copy-pasted blocks for each button, key or item | Data table plus one function; a dictionary keyed by `KeyCode` | https://devforum.roblox.com/t/ways-to-simplify-this-code/4771395 |
| 12 | Long `if/elseif` chains on a string or enum | Lookup table of handlers | https://devforum.roblox.com/t/ways-to-simplify-this-code/4771395 |
| 13 | Deep nesting | Guard clauses and early `return` | https://devforum.roblox.com/t/best-way-to-wait-for-character/996825 |
| 14 | Magic numbers scattered in code | Named constants in a frozen config module | https://devforum.roblox.com/t/good-scripting-practices/2739265 |
| 15 | Poor names (`v`, `p`, `peepee`…) | Descriptive names; `_` for unused loop variables | https://devforum.roblox.com/t/review-my-awesome-anticheat-code-please/2517913 |
| 16 | Giant monolithic script | ModuleScripts per system with a loader | https://devforum.roblox.com/t/questions-regarding-single-script-architecture-module-loaders/327169 |
| 17 | `_G` for shared state | ModuleScript returning a table | https://devforum.roblox.com/t/what-is-g-and-for-what-i-can-use-it/322199 |
| 18 | Player data in dozens of Value objects | Server-side table keyed by Player; replicate only what the UI needs | https://devforum.roblox.com/t/storing-player-data-in-game/250801 |
| 19 | DataStore calls without `pcall`, or saving on join | `pcall` plus retry; write only after a successful load | https://devforum.roblox.com/t/is-there-any-improvements-i-can-do-to-my-simple-datastore/2524948 |
| 20 | `SetAsync` for read-modify-write | `UpdateAsync` or ProfileStore | https://devforum.roblox.com/t/setting-up-a-datastore/295343 |
| 21 | `player.Character` accessed without nil handling, or not re-bound on respawn | `CharacterAdded` plus existing-character call | https://devforum.roblox.com/t/best-way-to-wait-for-character/996825 |
| 22 | Repetitive `WaitForChild` lines | Group assets in a Folder and iterate; one `WaitForChild` for the folder | https://devforum.roblox.com/t/better-alternative-to-waitforchild/665221 |
| 23 | Frame-rate-dependent lerps or movement | Scale by `dt`; `1 - f ^ dt` for smoothing | https://devforum.roblox.com/t/frame-rate-independent-lerp/352375 |
| 24 | Kicking or banning on suspicion in normal code paths | Ignore and log malformed input; escalate on repeated, impossible input | https://devforum.roblox.com/t/how-can-i-improve-my-shop-system/235722 |
| 25 | Security through obscurity (obfuscation, remote keys) | Server validation instead | https://devforum.roblox.com/t/remote-event-obsfucator/2432475 |
| 26 | Coroutines used where `task.spawn` is clearer (hidden errors) | `task.spawn`/`task.defer`; coroutines only for generators | https://devforum.roblox.com/t/should-i-be-using-taskspawn-or-coroutines/2483581 |
| 27 | Client-side speed checks reading `WalkSpeed` | Server compares position deltas | https://devforum.roblox.com/t/any-comments-on-my-walkspeed-detection-exploit-speed-detection/1345653 |
| 28 | Noclip or raycast checks with no thought about false positives (non-collidable parts, vehicles, lag) | Filter with `RaycastParams` (`Exclude`), check `CanCollide`, add tolerance | https://devforum.roblox.com/t/any-thoughts-on-my-anti-noclip-raycast/268584 |
| 29 | Excess getters/setters and over-engineered OOP for simple data | Plain tables and functions until behavior needs encapsulation | https://devforum.roblox.com/t/am-i-overusing-oop-getters/468704 |
| 30 | Running the whole game from free-model or unknown scripts ("is this a virus?") | Audit `require(id)`, `getfenv`, `loadstring`; remove backdoors | https://devforum.roblox.com/t/is-the-script-a-virus/1084519 |

Smaller but recurring notes: semicolons are optional style (https://devforum.roblox.com/t/is-using-semicolons-bad-practice/1088541). Set properties before `Parent` (§2.8). Prefer `Random.new` over the global RNG (§5.5). Use `--!strict` type annotations, which reviewers increasingly ask for in 2024–2026 threads (04 §1.1).

---

## 17. Debugging playbook (distilled from the threads)

When a user says "it doesn't work and there are no errors", go through these steps in order. Most threads are solved at step 1–4.

### Step 1: Confirm the code runs at all, on the side you think
- Put `print("[ShopServer] loaded")` at the top of the script and `print("[ShopServer] buy", player, itemId)` inside each handler. Many "no errors" threads are scripts that never ran. Common reasons:
  - A LocalScript placed in `workspace` or `ServerScriptService` (LocalScripts run only under PlayerScripts, PlayerGui, Backpack, the character, or ReplicatedFirst, unless they are Scripts with `RunContext = Client`).
  - A Script in `ReplicatedStorage`.
  - The script is disabled.
  - An earlier infinite yield blocks the line before the connection.
- In the Explorer during Play, switch between **Client** and **Server** views to see what actually exists on each side. Many "object is nil" bugs are objects that exist on one side only.

### Step 2: Read the Output properly
- Open Output (View → Output) and find the **first** error. Click it to jump to the line. Messages and what they usually mean:

| Message | Usual meaning | See |
|---|---|---|
| `attempt to index nil with 'X'` | The thing *before* `.X` is nil: wrong path, wrong side, not loaded yet, character not spawned | §1.1, §1.2 |
| `X is not a valid member of Y "Path"` | Wrong name or case, wrong side, not replicated yet, or streamed out | §10.1, §12.4 |
| `Infinite yield possible on 'Path:WaitForChild("X")'` | X never appears on this side (name, server-only, streaming) | §12.4 |
| `attempt to call a table value` / `nil value` | Called a library (`Vector3(...)`) or a misspelled method | §5.3 |
| `Requested module experienced an error while loading` | The module itself errored; scroll up | §11.1 |
| `Unable to cast to Dictionary` / `Unable to cast value to Object` | Wrong argument order or type for an engine API | §6.11 |
| `Can only tween objects in the workspace` | Tweening an instance that isn't in the DataModel | §6.11 |
| `Cannot load the AnimationClipProvider Service` | Rig not in workspace or a WorldModel | §7.3 |
| `Failed to load animation - sanitized ID` | Asset owner doesn't match the experience owner | §7.2 |
| `Failed to load sound ... Unable to download sound data` | Audio permission or privacy | §8.1 |
| `Script timeout: exhausted allowed execution time` | A non-yielding long loop | §9.3 |
| `DataStore request was added to queue` / 30x/50x errors | Throttling or budget; too many writes | 04 §5.1 |
| `SetCore: X has not been registered by the CoreScripts` | Called too early | §6.8 |
| `Parent property of X is locked` | Reparenting inside a handler during an engine change, or after `Destroy` | §12.3 |

### Step 3: Bisect with prints and breakpoints
- Add prints before and after each yield or condition until you find the last line that runs. Print the **values** (`print(typeof(x), x)`), not just "here".
- Use Studio breakpoints: click the gutter, then Play. Inspect the Watch, Call Stack and Variables windows. Conditional breakpoints (right-click → Edit Breakpoint) help with code that runs per frame. Breakpoints work in both server and client contexts during Play.
- `warn()` for important logs (yellow, easier to spot) and `error()` / `assert(cond, msg)` for broken invariants. Wrap system boundaries in `xpcall(fn, debug.traceback)` so you get stack traces (04 §15).

### Step 4: Isolate client vs server and timing
- Reproduce in a **2-player local server** (Test → Clients and Servers). Many bugs only appear with a second player: global debounces, `FireAllClients` loops, Player-keyed tables.
- Add latency with Studio's Incoming Replication Lag setting to expose race conditions that only appear live (§14).
- Make a minimal place: copy the failing system into an empty baseplate. If it works there, the bug is an interaction such as another script, a plugin, a free model, or StreamingEnabled. One thread's answer was literally "it's running fine in an empty baseplate".

### Step 5: Test live and read the Developer Console
- Publish and join the real game. Press **F9** (or type `/console` in chat) to open the Developer Console. The **Log** tab has Client and Server sections; server logs are visible to the experience owner and permitted collaborators.
- Other tabs: **Memory** (by category, to see whether memory grows per round), **Scripts** (Script Profiler: which functions cost CPU), **Network** (remote traffic), **Stats/Server Jobs**.

### Step 6: Profile performance instead of guessing
- **MicroProfiler** (Ctrl+Alt+F6 / ⌘⌥F6 in Studio or the client; server frames via Dev Console → MicroProfiler): pause on a spike frame and find the widest bars. `debug.profilebegin("Label")` / `debug.profileend()` put your own labels on the timeline.
- **Script Profiler** (Dev Console → Scripts, or Studio's Script Profiler): finds hot functions and per-frame loops.
- **Script Performance / activity %**: shows which scripts run constantly. Lower is better.
- **Memory**: watch `LuaHeap` and `Instances` over several rounds. Steady growth means leaks (§9.1).
- Typical findings in these threads: per-object loops, thousands of connections, many Humanoids, physics ownership churn, and oversized textures. Part count was rarely the cause.

### Step 7: Physics, network and data specifics
- Ownership: turn on *Studio Settings → Physics → Are Owners Shown* (colored outlines per owner), or print `part:GetNetworkOwner()` on the server.
- NaN: print positions and velocities with an `x ~= x` check (§4.8).
- DataStores: log every request's result. Check `DataStoreService:GetRequestBudgetForRequestType(...)` before bursts. Use a DataStore editor plugin to inspect keys, and never test against production keys by accident (use a separate store name in Studio).

### Step 8: When it's not your code
- If a message appears suddenly with no code change (examples: `Animator.EvaluationThrottled` spam, sound or library outages, the `Blacklist` enum removal), search the DevForum Announcements and Release Notes and the Roblox status page before rewriting code (§7.5, §8.1).
- For engine bugs, make a minimal repro place, then report it.

- **Sources:** https://devforum.roblox.com/t/how-to-measure-how-expensive-code-is/238408 ; https://devforum.roblox.com/t/help-needed-to-remove-lag-from-my-game/2924694 ; https://devforum.roblox.com/t/roblox-player-has-bug-studio-does-not/3305455 ; https://devforum.roblox.com/t/playersgetplayers-not-working-in-my-script/3619344 ; https://devforum.roblox.com/t/terrible-game-breaking-physics-glitch-urgent/3164927 ; https://devforum.roblox.com/t/roblox-just-removed-enumraycastfiltertypeblacklist-messed-up-my-whole-code/2394523 ; https://devforum.roblox.com/t/what-is-property-animatorevaluationthrottled-is-not-currently-enabled/2448273

---

## 18. Quick triage: "it doesn't work" → first three questions

1. **Which side, and where does the script live?** (client/server; container). Most bugs in §1, §2 and §6.1 end here.
2. **Does it fail the first time, after a respawn, only with 2+ players, or only live?** First time: lifecycle (§1). After respawn: stale references (§1.4, §1.5). 2+ players: shared debounce or tables (§1.3, §2.6). Live only: §14.
3. **What is the first line in Output, on which side?** Look it up in §17 step 2.

---

## Sources

Local mirror threads read for this chapter (all under `.sources/devforum/`; likes as of the 2026-11-05 snapshot):

- Lifecycle: 530935, 639085, 629126, 996825, 260923, 1600637, 2772465, 3305455, 1125765, 122798, 252778, 2511322, 3342715, 879024, 3263432, 969161, 281994, 441407, 3619344
- Remotes: 670130, 245991, 63336, 113386, 1309047, 1486049, 1730923, 3357571, 516408, 775727
- DataStores: 350773, 151616, 116953, 1611913, 161480, 2524948, 490557, 295343, 397438, 2703017; tutorials/resources 136317 (DataStore2), 3190543 (ProfileStore)
- Physics / CFrame: 2738378, 3370739, 1739208, 998621, 846239, 1166176, 1988812, 610386, 1398023, 60801, 3164927, 334624, 533558, 238958, 542038, 352375, 96945, 530582
- UI / input / mobile: 468533, 1197988, 234443, 793784, 1638919, 81276, 1691822, 914575, 1969975, 235833, 178365, 239206, 406928, 163436, 1384078, 178533, 222593, 581799, 917005
- Animation / sound: 60545, 315253, 565465, 575473, 2652038, 2556354, 1639315, 1182750, 661170, 2448273, 793863, 874349, 883232, 420413, 234314
- Performance / streaming: 90082, 374954, 238919, 578006, 533353, 2924694, 285814, 238408, 1221842, 2511448, 250801, 277160, 260694, 672658, 758953, 1751134
- Modules / scheduling: 524297, 170723, 223496, 327169, 138469, 368697, 322199, 1491119, 368966, 2483581, 1751441, 530639, 2798667, 1055275
- Security: 627213, 760066, 2517913, 1345653, 2632359, 187097, 688001, 3050674, 896546, 473168, 2653583, 235722
- Studio vs live: 473859, 467552
- Code Review: 953581, 4771395, 2739265, 665221, 468704, 1084519, 1088541, 268584, 2432475
- Announcements: 4975616 (PlayerCharacterDestroyBehavior default, 2026-11-11), 2276564 (Deferred engine events)

Each thread URL is `https://devforum.roblox.com/t/<id>`, and the full links are given inline above. API status was checked against `reference/api/API-Dump.txt` and `reference/creator-docs-live/deprecated-api-inventory.md` (for example `Humanoid:LoadAnimation`, `Model:SetPrimaryPartCFrame`, `Player:LoadCharacter`, BodyMovers, `UserInputService.ModalEnabled` and `Sound.EmitterSize` are deprecated; `RunService.Heartbeat` is not; `Enum.RaycastFilterType` has only `Exclude` and `Include`; `UserInputService.PreferredInput` and `GuiService.TouchControlsEnabled` exist).

Related chapters: [04-luau-engineering.md](04-luau-engineering.md) (patterns and bug table), [11-multiplayer-physics-combat-systems.md](11-multiplayer-physics-combat-systems.md) (hit validation and ownership in combat), [12-testing-qa-performance-analytics.md](12-testing-qa-performance-analytics.md) (profiling and QA), [15-platform-changes-and-deprecations.md](15-platform-changes-and-deprecations.md) (deprecation timeline).
