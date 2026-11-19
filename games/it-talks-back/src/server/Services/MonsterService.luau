--!strict
-- MonsterService: "The Tenant". One server-owned humanoid with a small state machine:
--
--   Dormant ──wake──► Patrol ◄──────────────────────────────┐
--                       │ hears noise / callout              │ done looking
--                       ▼                                    │
--                   Investigate ── arrives, looks around ────┘
--                       │ sees a player (any state)
--                       ▼
--                     Chase ── loses sight > 3.5 s ──► Search ──► Patrol
--                       │  └─ target hid while being watched ──► PullOut ──┐
--                       ▼ within reach                                     ▼
--                     catch ──► player caged ──► Cooldown (walks away) ──► Patrol
--
-- Senses (all server-side, nothing trusted from clients):
--   * sight: range + field of view + raycast line of sight. Crouching shrinks the range, a lit
--     flashlight grows it. Hidden players are invisible.
--   * hearing: NoiseService (footsteps measured on the server, fuses, closets, rescues) and
--     callouts (CalloutService) - including lies, which it remembers per player.
-- It also talks (VoiceService): ambient taunts, reactions, and fuse "hints" that are true or a
-- trap (when it lies, it goes to wait in that room).
--
-- Tuning lives in Shared/Config/HorrorConfig.luau.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Rooms = require(Shared.Rooms)
local Types = require(Shared.Types)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local MonsterRig = require(Game.MonsterRig)
local NoiseService = require(script.Parent.NoiseService)
local HideService = require(script.Parent.HideService)
local CageService = require(script.Parent.CageService)
local FuseService = require(script.Parent.FuseService)
local VoiceService = require(script.Parent.VoiceService)
local CalloutService = require(script.Parent.CalloutService)
local MovementService = require(script.Parent.MovementService)
local DataService = require(script.Parent.DataService)
local Analytics = require(script.Parent.Analytics)

type Mode = "Dormant" | "Patrol" | "Investigate" | "Chase" | "Search" | "PullOut" | "Cooldown"
type Lure = { player: Player, room: string, wasLie: boolean }

local TICK = 0.1
local ARRIVE_DISTANCE = 3
local LOOK_STEP_SECONDS = 1.2
local STUCK_CHECK_SECONDS = 1.5

local cfg = HorrorConfig.Monster
local rng = Random.new()

local MonsterService = {}
MonsterService.Priority = 40

local model: Model? = nil
local root: BasePart? = nil
local head: BasePart? = nil
local humanoid: Humanoid? = nil

local path = PathfindingService:CreatePath({
	AgentRadius = 2,
	AgentHeight = 8,
	AgentCanJump = false,
	AgentCanClimb = false,
	WaypointSpacing = 5,
})

-- Brain state -----------------------------------------------------------------------------------
local mode: Mode = "Dormant"
local goal: Vector3? = nil
local waitUntil = 0 -- > 0 while standing still / looking around at the goal
local nextLook = 0
local target: Player? = nil
local lastSeenAt = 0
local lastKnown: Vector3? = nil
local modeUntil = 0
local reason = ""
local lure: Lure? = nil
local pullCloset: Model? = nil
local rage = false
local nextAmbient = 0
local nextHint = 0
local lastChaseLine = 0
local recentRooms: { string } = {}
local lies: { [Player]: number } = {}
local grudgeUntil: { [Player]: number } = {}

-- Mover state -------------------------------------------------------------------------------------
local waypoints: { PathWaypoint } = {}
local waypointIndex = 0
local computing = false
local pathGoal: Vector3? = nil
local pathAt = 0
local pathFailed = false
local failedGoal: Vector3? = nil -- the goal the last failed path was for
local progressAt = 0
local progressPos = Vector3.zero
local stuckCount = 0

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude
losParams.IgnoreWater = true

local function refreshFilter()
	local ignore: { Instance } = {}
	if model then
		table.insert(ignore, model)
	end
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(ignore, player.Character)
		end
	end
	losParams.FilterDescendantsInstances = ignore
end

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function setMood(mood: Types.Mood)
	if model and model:GetAttribute("Mood") ~= mood then
		model:SetAttribute("Mood", mood)
	end
end

local function setTarget(player: Player?)
	target = player
	if model then
		model:SetAttribute("TargetUserId", if player then player.UserId else 0)
	end
end

local function randomName(): string?
	local list = State.participants()
	if #list == 0 then
		return nil
	end
	return list[rng:NextInteger(1, #list)].DisplayName
end

-- ===== Movement ======================================================================================

local function requestPath(to: Vector3)
	if computing or not root then
		return
	end
	computing = true
	local from = root.Position
	task.spawn(function()
		local ok = pcall(function()
			path:ComputeAsync(from, to)
		end)
		if ok and path.Status == Enum.PathStatus.Success then
			waypoints = path:GetWaypoints()
			waypointIndex = math.min(2, #waypoints)
			pathFailed = false
		else
			waypoints = {}
			waypointIndex = 0
			pathFailed = true
			failedGoal = to
		end
		pathGoal = to
		pathAt = os.clock()
		computing = false
	end)
end

local function clearLine(from: Vector3, to: Vector3): boolean
	local dir = to - from
	if dir.Magnitude < 0.5 then
		return true
	end
	return Workspace:Spherecast(from, 1.4, dir, losParams) == nil
end

local function arrived(at: Vector3, tolerance: number?): boolean
	if not root then
		return false
	end
	local d = flat(at - root.Position).Magnitude
	return d <= (tolerance or ARRIVE_DISTANCE) and math.abs(at.Y - root.Position.Y) < 7
end

-- Walks toward `to`. `direct` allows a straight line when nothing is in the way (chases).
local function moveToward(to: Vector3, speed: number, direct: boolean?)
	local h, r = humanoid, root
	if not h or not r then
		return
	end
	h.WalkSpeed = speed
	local rootLevel = Vector3.new(to.X, r.Position.Y, to.Z)
	if direct and math.abs(to.Y - r.Position.Y) < 3.5 and clearLine(r.Position, rootLevel) then
		waypoints = {}
		pathGoal = nil
		h:MoveTo(to)
		return
	end
	local refresh = if mode == "Chase" then 0.5 else 4
	if pathGoal == nil or (pathGoal - to).Magnitude > 4 or os.clock() - pathAt > refresh then
		requestPath(to)
	end
	if #waypoints == 0 then
		return
	end
	local wp = waypoints[waypointIndex]
	if wp and flat(wp.Position - r.Position).Magnitude < 2.5 and waypointIndex < #waypoints then
		waypointIndex += 1
		wp = waypoints[waypointIndex]
	end
	if wp then
		h:MoveTo(wp.Position)
	end
end

local function standStill()
	if humanoid and root then
		humanoid:MoveTo(root.Position)
	end
end

local function lookAround()
	local h, r = humanoid, root
	if not h or not r or os.clock() < nextLook then
		return
	end
	nextLook = os.clock() + LOOK_STEP_SECONDS
	local angle = rng:NextNumber(0, math.pi * 2)
	h.WalkSpeed = 3
	h:MoveTo(r.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * 1.5)
end

-- ===== Senses ========================================================================================

local function canSee(player: Player, chasingThis: boolean): boolean
	local r, eyes = root, head
	local character = player.Character
	local targetRoot = State.rootOf(player)
	if not r or not eyes or not character or not targetRoot then
		return false
	end
	local targetHead = character:FindFirstChild("Head")
	local headPos = if targetHead and targetHead:IsA("BasePart") then targetHead.Position else targetRoot.Position
	local toTarget = headPos - eyes.Position
	local distance = toTarget.Magnitude
	local lit = MovementService.isLit(player)

	local range = cfg.ViewDistance
	if chasingThis then
		range = cfg.ViewDistance * 1.2
	elseif lit then
		range = cfg.FlashlightViewDistance
	elseif MovementService.isCrouched(player) then
		range = cfg.CrouchViewDistance
	end
	if rage then
		range *= 1.15
	end
	if distance > range then
		return false
	end
	if distance > cfg.CloseSense and not chasingThis then
		local look = flat(r.CFrame.LookVector).Unit
		local dir = flat(toTarget)
		if dir.Magnitude > 0.01 then
			local fov = if lit then cfg.FovDot - 0.5 else cfg.FovDot -- a beam is seen from the side too
			if look:Dot(dir.Unit) < fov then
				return false
			end
		end
	end
	for _, point in { headPos, targetRoot.Position } do
		if Workspace:Raycast(eyes.Position, point - eyes.Position, losParams) == nil then
			return true
		end
	end
	return false
end

local function closestVisible(): Player?
	local best: Player? = nil
	local bestDistance = math.huge
	if not root then
		return nil
	end
	for _, player in State.playersWith("Alive") do
		local pr = State.rootOf(player)
		if pr and canSee(player, player == target and mode == "Chase") then
			local d = (pr.Position - root.Position).Magnitude
			if d < bestDistance then
				best, bestDistance = player, d
			end
		end
	end
	return best
end

-- ===== Mode changes ===================================================================================

local function patrolPointIn(room: string): Vector3?
	local options = {}
	for _, point in Map.patrolPoints() do
		if point.room == room then
			table.insert(options, point.part.Position)
		end
	end
	return if #options > 0 then options[rng:NextInteger(1, #options)] else nil
end

local function enterPatrol()
	mode = "Patrol"
	goal = nil
	waitUntil = 0
	reason = ""
	setTarget(nil)
	setMood("Calm")
end

-- Noises often come from places it can't stand (inside the generator, on a counter): walk to
-- the nearest patrol point in the same room instead (or the nearest one anywhere).
local function walkableNear(at: Vector3): Vector3
	local room = Rooms.at(at)
	local best, bestD = at, math.huge
	for _, point in Map.patrolPoints() do
		local p = point.part.Position
		local d = (p - at).Magnitude + (if room and point.room ~= room then 1000 else 0)
		if d < bestD then
			best, bestD = p, d
		end
	end
	return best
end

local function investigate(at: Vector3, why: string, lureRecord: Lure?)
	mode = "Investigate"
	goal = walkableNear(at)
	waitUntil = 0
	reason = why
	lure = lureRecord
	setMood("Alert")
end

local function search(at: Vector3?)
	mode = "Search"
	goal = at
	waitUntil = 0
	setTarget(nil)
	setMood("Alert")
	VoiceService.say("Lost")
end

local function startChase(player: Player)
	local wasChasing = mode == "Chase"
	mode = "Chase"
	setTarget(player)
	lastSeenAt = os.clock()
	local pr = State.rootOf(player)
	lastKnown = if pr then pr.Position else nil
	lure = nil
	setMood("Chase")
	if not wasChasing and os.clock() - lastChaseLine > 10 then
		lastChaseLine = os.clock()
		VoiceService.say("ChaseStart", { name = player.DisplayName }, true)
	end
end

local function pickPatrolGoal(): Vector3?
	local points = Map.patrolPoints()
	if #points == 0 then
		return nil
	end
	local here = if root then Rooms.at(root.Position) else nil
	-- Pressure: sometimes head for a room where somebody is.
	if rng:NextNumber() < (if rage then 0.5 else 0.35) then
		local alive = State.playersWith("Alive")
		if #alive > 0 then
			local pr = State.rootOf(alive[rng:NextInteger(1, #alive)])
			local room = pr and Rooms.at(pr.Position)
			local p = if room and room ~= here then patrolPointIn(room) else nil
			if p then
				return p
			end
		end
	end
	local options = {}
	for _, point in points do
		if point.room ~= here and not table.find(recentRooms, point.room) then
			table.insert(options, point)
		end
	end
	if #options == 0 then
		options = points
	end
	local choice = options[rng:NextInteger(1, #options)]
	table.insert(recentRooms, choice.room)
	if #recentRooms > 2 then
		table.remove(recentRooms, 1)
	end
	return choice.part.Position
end

local function catch(player: Player)
	local pr = State.rootOf(player)
	if not pr then
		return
	end
	local room = Rooms.at(pr.Position) or "Unknown"
	FuseService.drop(player, pr.Position) -- before the teleport, so the fuse stays here
	for _, other in State.participants() do
		Net.fire("Caught", other, player.DisplayName, other == player)
	end
	CageService.put(player)
	VoiceService.say("Caught", { name = player.DisplayName }, true)
	DataService.bumpStat(player, "TimesCaught")
	Analytics.custom(player, "PlayerCaught", 1, room)

	-- Walk away from the cage so caught players can be rescued (no camping).
	mode = "Cooldown"
	modeUntil = os.clock() + cfg.PostCatchCooldown
	setTarget(nil)
	setMood("Calm")
	goal = patrolPointIn("Study") or patrolPointIn("Kitchen") or pickPatrolGoal()
	waitUntil = os.clock() + 1.2 -- savor it for a moment
end

local function doHint()
	local fuseRooms = FuseService.roomsWithFuses()
	if next(fuseRooms) == nil then
		return
	end
	local truthful = rng:NextNumber() < cfg.HintTruthChance
	local pool = {}
	for _, room in HorrorConfig.Rooms do
		if (fuseRooms[room] == true) == truthful then
			table.insert(pool, room)
		end
	end
	if #pool == 0 then
		return
	end
	local room = pool[rng:NextInteger(1, #pool)]
	if not VoiceService.say("Hint", { room = room }, true) then
		return
	end
	if not truthful then
		local ambush = patrolPointIn(room)
		if ambush then
			investigate(ambush, "Ambush")
			waitUntil = 0
		end
	end
end

-- ===== Per-tick behavior ==============================================================================

local function tickChase(seen: Player?)
	local t = target
	if not t or not root then
		enterPatrol()
		return
	end
	local status = State.getStatus(t)
	if status == "Hidden" then
		local since = HideService.hiddenSince(t)
		local closet = HideService.closetOf(t)
		if since and closet and since - lastSeenAt <= cfg.SawHideWindow then
			mode = "PullOut"
			modeUntil = os.clock() + 6 -- give up if the closet can't be reached
			pullCloset = closet
			VoiceService.say("PullOut", nil, true)
			return
		end
		search(lastKnown)
		return
	elseif status ~= "Alive" then
		search(lastKnown)
		return
	end

	local visible = seen == t or canSee(t, true)
	local tr = State.rootOf(t)
	if visible and tr then
		lastSeenAt = os.clock()
		lastKnown = tr.Position
	elseif seen and seen ~= t then
		startChase(seen) -- lost the old target but someone else is right there
		return
	end
	if os.clock() - lastSeenAt > cfg.LoseSightSeconds then
		search(lastKnown)
		return
	end
	local speed = if rage then cfg.RageChaseSpeed else cfg.ChaseSpeed
	local dest = if visible and tr then tr.Position else lastKnown
	if dest then
		moveToward(dest, speed, visible)
	end
	if visible and tr and (tr.Position - root.Position).Magnitude <= cfg.CatchDistance then
		catch(t)
	end
end

local function tickPullOut()
	local t, closet = target, pullCloset
	if not t or not closet or HideService.closetOf(t) ~= closet or os.clock() > modeUntil then
		search(lastKnown)
		return
	end
	local front = HideService.frontOf(closet)
	if not front then
		search(lastKnown)
		return
	end
	moveToward(front, cfg.ChaseSpeed, true)
	if arrived(front, 4.5) then
		HideService.unhide(t, true)
		catch(t)
	end
end

local function finishInvestigation()
	local record = lure
	lure = nil
	if record and record.player.Parent == Players then
		local anyone = false
		for _, player in State.playersWith("Alive") do
			local pr = State.rootOf(player)
			if pr and Rooms.at(pr.Position) == record.room then
				anyone = true
			end
		end
		if not anyone then
			VoiceService.say("CalloutEmpty")
		end
		if record.wasLie then
			local n = (lies[record.player] or 0) + 1
			lies[record.player] = n
			if n >= cfg.LiesBeforeGrudge then
				lies[record.player] = 0
				grudgeUntil[record.player] = os.clock() + cfg.GrudgeSeconds
				VoiceService.say("Grudge", { name = record.player.DisplayName }, true)
			end
		end
	end
	enterPatrol()
end

-- Shared "walk to goal, then stand and look around for `linger` seconds" behavior.
-- Returns true when the linger time is over.
local function walkAndLinger(speed: number, linger: number): boolean
	local g = goal
	if not g then
		return true
	end
	if waitUntil == 0 then
		local unreachable = pathFailed and not computing and failedGoal ~= nil and (failedGoal - g).Magnitude < 1
		if arrived(g) or unreachable then
			waitUntil = os.clock() + linger
			standStill()
		else
			moveToward(g, speed)
		end
		return false
	end
	lookAround()
	return os.clock() >= waitUntil
end

local function checkStuck()
	if not root or waitUntil > 0 or mode == "Dormant" then
		return
	end
	local now = os.clock()
	if now - progressAt < STUCK_CHECK_SECONDS then
		return
	end
	local moved = (root.Position - progressPos).Magnitude
	progressAt, progressPos = now, root.Position
	if moved < 1 and goal then
		stuckCount += 1
		pathGoal = nil -- force a fresh path
		if stuckCount >= 3 then
			stuckCount = 0
			if mode ~= "Chase" and mode ~= "PullOut" then
				enterPatrol()
			end
		end
	else
		stuckCount = 0
	end
end

local function tick()
	if mode == "Dormant" or not root or not humanoid then
		return
	end
	refreshFilter()
	local now = os.clock()

	-- Sight interrupts almost everything.
	local seen = if mode ~= "Cooldown" and mode ~= "PullOut" then closestVisible() else nil
	if seen and mode ~= "Chase" then
		startChase(seen)
	end

	if mode == "Chase" then
		tickChase(seen)
	elseif mode == "PullOut" then
		tickPullOut()
	elseif mode == "Cooldown" then
		if now < waitUntil then
			standStill()
		elseif goal and not arrived(goal) then
			moveToward(goal, cfg.InvestigateSpeed)
		end
		if now >= modeUntil then
			enterPatrol()
		end
	elseif mode == "Search" then
		if walkAndLinger(cfg.InvestigateSpeed, cfg.SearchSeconds) then
			enterPatrol()
		end
	elseif mode == "Investigate" then
		local linger = if reason == "Ambush" then 9 else cfg.SearchSeconds * 0.6
		if walkAndLinger(cfg.InvestigateSpeed, linger) then
			finishInvestigation()
		end
	elseif mode == "Patrol" then
		if goal == nil then
			goal = pickPatrolGoal()
			waitUntil = 0
		end
		if walkAndLinger(cfg.PatrolSpeed, rng:NextNumber(1.5, 3)) then
			goal = nil
		end
		if now >= nextAmbient then
			nextAmbient = now + rng:NextNumber(HorrorConfig.Voice.AmbientMin, HorrorConfig.Voice.AmbientMax)
			VoiceService.say("Ambient", { name = randomName() })
		end
		if now >= nextHint then
			nextHint = now + rng:NextNumber(cfg.HintIntervalMin, cfg.HintIntervalMax)
			doHint()
		end
	end
	checkStuck()
end

-- ===== Hearing ======================================================================================

local function canReact(): boolean
	return mode == "Patrol" or mode == "Investigate" or mode == "Search"
end

local function onNoise(noise: NoiseService.Noise)
	if not root or not canReact() then
		return
	end
	local dy = math.abs(noise.position.Y - root.Position.Y)
	local radius = noise.radius * (if dy > 8 then cfg.OtherFloorHearing else 1)
	if (noise.position - root.Position).Magnitude > radius then
		return
	end
	local wasCalm = mode == "Patrol"
	if reason == "Callout" and lure and noise.radius < HorrorConfig.Noise.Sprint then
		return -- a quiet footstep doesn't distract it from a callout it is following
	end
	investigate(noise.position, "Noise")
	if wasCalm and rng:NextNumber() < 0.6 then
		VoiceService.say("Heard", { room = Rooms.at(noise.position) })
	end
end

local function onCallout(player: Player, room: string, actual: string?)
	if not canReact() then
		return
	end
	if (grudgeUntil[player] or 0) > os.clock() then
		return -- it stopped listening to this liar
	end
	local at = patrolPointIn(room)
	if not at then
		return
	end
	investigate(at, "Callout", { player = player, room = room, wasLie = actual ~= room })
	VoiceService.say("HeardCallout", { room = room, name = player.DisplayName })
end

-- ===== Lifecycle (called by RoundService) ============================================================

function MonsterService.reset()
	mode = "Dormant"
	goal = nil
	waitUntil = 0
	lure = nil
	pullCloset = nil
	rage = false
	setTarget(nil)
	table.clear(lies)
	table.clear(grudgeUntil)
	table.clear(recentRooms)
	waypoints = {}
	waypointIndex = 0
	pathGoal = nil
	pathFailed = false
	failedGoal = nil
	stuckCount = 0
	modeUntil = 0
	setMood("Dormant")
	if model and humanoid then
		local spawnPart = Map.one("MonsterSpawn")
		model:PivotTo(spawnPart.CFrame)
		humanoid.WalkSpeed = 0
		standStill()
	end
end

function MonsterService.wake()
	local now = os.clock()
	enterPatrol()
	nextAmbient = now + 10
	nextHint = now + rng:NextNumber(cfg.HintIntervalMin, cfg.HintIntervalMax) * 0.6
	progressAt, progressPos = now, if root then root.Position else Vector3.zero
	VoiceService.say("RoundStart", nil, true)
end

function MonsterService.sleep()
	mode = "Dormant"
	setTarget(nil)
	setMood("Dormant")
	standStill()
end

function MonsterService.position(): Vector3?
	return if root then root.Position else nil
end

local function spawnModel()
	local m = MonsterRig.build(cfg.Name)
	local spawnPart = Map.one("MonsterSpawn")
	m:PivotTo(spawnPart.CFrame)
	m.Parent = Workspace
	model = m
	root = m:FindFirstChild("HumanoidRootPart") :: BasePart
	head = m:FindFirstChild("Head") :: BasePart
	humanoid = m:FindFirstChildOfClass("Humanoid")
	pcall(function()
		(root :: BasePart):SetNetworkOwner(nil) -- the server moves it; no client may own its physics
	end)
	setMood("Dormant")
end

function MonsterService:Init()
	NoiseService.Emitted:Connect(onNoise)
	CalloutService.Called:Connect(onCallout)
	FuseService.Inserted:Connect(function(_player: Player, count: number, total: number)
		if count < total then
			VoiceService.say("FuseInserted", { count = count, total = total }, true)
		end
	end)
	FuseService.PowerRestored:Connect(function()
		rage = true
		VoiceService.say("PowerRestored", nil, true)
	end)
	CageService.Rescued:Connect(function()
		VoiceService.say("Rescued", nil, true)
		if canReact() then
			local cage = Map.one("CageOutside")
			investigate(cage.Position, "Noise")
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		lies[player] = nil
		grudgeUntil[player] = nil
		if target == player then
			search(lastKnown)
		end
	end)
end

function MonsterService:Start()
	spawnModel()
	while true do
		task.wait(TICK)
		local ok, err = pcall(tick)
		if not ok then
			warn(`[MonsterService] tick error: {err}`)
			task.wait(1)
		end
	end
end

return MonsterService
