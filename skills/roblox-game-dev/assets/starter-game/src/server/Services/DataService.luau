--!strict
-- DataService: owns ALL persistent player data. The ONLY module that touches ProfileStore for
-- players. Session-locked (no dupes across servers), versioned (Data/Schema.luau migrations),
-- auto-saved by ProfileStore, final save on leave/shutdown (ProfileStore binds BindToClose).
--
-- Public API (server only):
--   DataService.get(player) -> Data?                 -- nil until loaded
--   DataService.waitFor(player) -> Data?             -- yields; nil if they left / load failed
--   DataService.getProfile(player) -> Profile?       -- for PurchaseService's save-confirm loop
--   DataService.addCoins(player, n, txType, sku?) -> boolean
--   DataService.trySpendCoins(player, n, txType, sku?) -> boolean
--   DataService.setSetting(player, key, value)
--   DataService.markOnboarding(player, step) -> boolean (true the first time ever)
--   DataService.Loaded:Connect(function(player, data) end)
--   DataService.Changed:Connect(function(player, key, value) end)  -- top-level keys
--
-- Rule: mutate profile.Data fields; never replace profile.Data. No yields between a check and
-- the write that depends on it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Server = script.Parent.Parent
local ProfileStore = require(Server.Packages.ProfileStore)
local DataSchema = require(Server.Data.Schema)
local Analytics = require(script.Parent.Analytics)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared.Packages.Signal)
local GameConfig = require(Shared.Config.GameConfig)

export type Data = DataSchema.Data
type Profile = ProfileStore.Profile<Data>

local DataService = {}
DataService.Priority = 100 -- Init before every service that listens to Loaded

DataService.Loaded = Signal.new() :: Signal.Signal<Player, Data>
DataService.Changed = Signal.new() :: Signal.Signal<Player, string, any>

-- In Studio, set the Workspace attribute UseMockData = true to never touch real DataStores.
-- (Without Studio API access ProfileStore already falls back to an in-memory store.)
local USE_MOCK = RunService:IsStudio() and Workspace:GetAttribute("UseMockData") == true

local PlayerStore = ProfileStore.New(GameConfig.DataStoreName, DataSchema.TEMPLATE)
local Store = if USE_MOCK then PlayerStore.Mock else PlayerStore

local profiles: { [Player]: Profile } = {}
local loading: { [Player]: boolean } = {}
local waiters: { [Player]: { thread } } = {}
local joinClock: { [Player]: number } = {}

local function resumeWaiters(player: Player, data: Data?)
	local list = waiters[player]
	waiters[player] = nil
	if list then
		for _, thread in list do
			task.spawn(thread, data)
		end
	end
end

local function applySettingAttributes(player: Player, data: Data)
	for key in GameConfig.Settings do
		player:SetAttribute(`Setting_{key}`, (data.Settings :: any)[key])
	end
end

local function onPlayerAdded(player: Player)
	if profiles[player] or loading[player] then
		return -- PlayerAdded + GetPlayers loop race: load once
	end
	loading[player] = true

	local profile = Store:StartSessionAsync(
		`Player_{player.UserId}`,
		{
			Cancel = function()
				return player.Parent ~= Players -- stop retrying if they leave mid-load
			end,
		} :: any
	) -- `Cancel` is documented (docs/api.md) but missing from the exported param type

	loading[player] = nil

	if profile == nil then
		-- Server shutting down, or the player left while loading.
		if player.Parent == Players then
			player:Kick("Your data could not be loaded. Please rejoin.")
		end
		resumeWaiters(player, nil)
		return
	end

	-- Migrate BEFORE Reconcile, so Reconcile only fills genuinely new fields.
	local result, fromVersion = DataSchema.migrate(profile.Data :: any)
	if result == "FromFuture" then
		warn(`[DataService] {player.UserId} has data v{fromVersion} > server v{DataSchema.VERSION}`)
		profile:EndSession()
		if player.Parent == Players then
			player:Kick("A newer version of the game is live. Please rejoin.")
		end
		resumeWaiters(player, nil)
		return
	end
	profile:AddUserId(player.UserId) -- GDPR right-to-erasure association
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Your data was loaded on another server. Please rejoin.")
		end
	end)

	profile.OnLastSave:Connect(function()
		-- Final chance to write session-derived data (must not yield).
		local started = joinClock[player]
		if started then
			profile.Data.Stats.PlaySeconds += math.floor(os.clock() - started)
			joinClock[player] = nil
		end
	end)

	if player.Parent ~= Players then
		profile:EndSession() -- left while loading
		resumeWaiters(player, nil)
		return
	end

	local now = os.time()
	if profile.Data.Stats.FirstJoin == 0 then
		profile.Data.Stats.FirstJoin = now
	end
	profile.Data.Stats.LastJoin = now
	joinClock[player] = os.clock()

	profiles[player] = profile
	player:SetAttribute(GameConfig.Currency, profile.Data.Coins)
	applySettingAttributes(player, profile.Data)

	DataService.Loaded:Fire(player, profile.Data)
	resumeWaiters(player, profile.Data)
	Analytics.onboarding(player, "DataLoaded")
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		profile:EndSession() -- OnLastSave fires, final save, session lock released
	end
	resumeWaiters(player, nil)
end

-- ===== Public API ========================================================================

function DataService.get(player: Player): Data?
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

function DataService.getProfile(player: Player): Profile?
	return profiles[player]
end

function DataService.waitFor(player: Player): Data?
	local profile = profiles[player]
	if profile then
		return profile.Data
	end
	if player.Parent ~= Players then
		return nil
	end
	local list = waiters[player]
	if list == nil then
		list = {}
		waiters[player] = list
	end
	table.insert(list, coroutine.running())
	return coroutine.yield()
end

local function assertAmount(amount: number)
	assert(
		typeof(amount) == "number" and amount == amount and amount >= 0 and amount % 1 == 0,
		"amount must be a non-negative integer"
	)
end

local function setCoins(player: Player, profile: Profile, value: number)
	profile.Data.Coins = value
	player:SetAttribute(GameConfig.Currency, value)
	DataService.Changed:Fire(player, "Coins", value)
end

-- Source of currency. transactionType: Enum.AnalyticsEconomyTransactionType (Gameplay, IAP, ...)
function DataService.addCoins(
	player: Player,
	amount: number,
	transactionType: Enum.AnalyticsEconomyTransactionType,
	sku: string?
): boolean
	assertAmount(amount)
	local profile = profiles[player]
	if not profile then
		return false
	end
	setCoins(player, profile, profile.Data.Coins + amount)
	Analytics.source(player, GameConfig.Currency, amount, profile.Data.Coins, transactionType, sku)
	return true
end

-- Atomic check-and-deduct (no yields between check and write).
function DataService.trySpendCoins(
	player: Player,
	amount: number,
	transactionType: Enum.AnalyticsEconomyTransactionType,
	sku: string?
): boolean
	assertAmount(amount)
	local profile = profiles[player]
	if not profile or profile.Data.Coins < amount then
		return false
	end
	setCoins(player, profile, profile.Data.Coins - amount)
	Analytics.sink(player, GameConfig.Currency, amount, profile.Data.Coins, transactionType, sku)
	return true
end

-- Re-publishes Coins after a direct profile.Data edit (e.g. a receipt grant).
function DataService.refreshCoins(player: Player)
	local profile = profiles[player]
	if profile then
		setCoins(player, profile, profile.Data.Coins)
	end
end

function DataService.setSetting(player: Player, key: string, value: number)
	local spec = (GameConfig.Settings :: any)[key]
	local profile = profiles[player]
	if not spec or not profile then
		return
	end
	local clamped = math.clamp(value, spec.min, spec.max);
	(profile.Data.Settings :: any)[key] = clamped
	player:SetAttribute(`Setting_{key}`, clamped)
end

function DataService.markOnboarding(player: Player, step: string): boolean
	local profile = profiles[player]
	if not profile or profile.Data.Onboarding[step] then
		return false
	end
	profile.Data.Onboarding[step] = true
	return true
end

-- ===== Lifecycle =========================================================================

function DataService:Init()
	ProfileStore.OnError:Connect(function(message: string, storeName: string, key: string)
		warn(`[DataService] DataStore error {storeName}/{key}: {message}`)
	end)
	ProfileStore.OnCriticalToggle:Connect(function(isCritical: boolean)
		warn(`[DataService] DataStore critical state: {isCritical}`)
	end)
end

function DataService:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do -- joined before Start ran
		task.spawn(onPlayerAdded, player)
	end
end

return DataService
