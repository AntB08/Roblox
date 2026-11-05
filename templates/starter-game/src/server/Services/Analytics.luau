--!strict
-- Analytics: the ONLY module that calls AnalyticsService (server-side API; every call takes a
-- Player). Enforces allowlists (cardinality limits), a rate budget (120 + 20*CCU per minute,
-- with 25% headroom), pcall safety, and once-per-session onboarding steps.
--
--   Analytics.onboarding(player, "FirstCollect")
--   Analytics.source(player, "Coins", 5, balance, Enum.AnalyticsEconomyTransactionType.Gameplay, "CollectNode")
--   Analytics.sink(player, "Coins", 100, balance, Enum.AnalyticsEconomyTransactionType.Shop, "SpeedBoost")
--   Analytics.custom(player, "CodeRedeemed", 1, "RELEASE")
--   local sid = Analytics.newFunnelSession(); Analytics.funnelStep(player, "Shop", sid, 1, "Opened")
--
-- Put variety in custom fields, not in event names. Names are permanent chart series.

local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CF1 = Enum.AnalyticsCustomFieldKeys.CustomField01.Name
local CF2 = Enum.AnalyticsCustomFieldKeys.CustomField02.Name
local CF3 = Enum.AnalyticsCustomFieldKeys.CustomField03.Name

-- ===== Allowlists (protect cardinality limits) ===========================================
local CURRENCIES = { Coins = true } -- keep <= 5
local FUNNELS = { Shop = true } -- keep <= 10
local CUSTOM_EVENTS = { -- keep well under 100
	ServerError = true,
	ClientError = true,
	CodeRedeemed = true,
	DailyClaimed = true,
	PassOwned = true,
}
-- Onboarding funnel, in order (step number = index). Append new steps at the END only.
local ONBOARDING_STEPS = { "DataLoaded", "FirstCollect", "TenCollects", "FirstDailyClaim" }

local Analytics = {}
Analytics.Priority = 200 -- no dependencies; Init first

local enabled = true

-- ===== Rate budget =======================================================================
local windowStart = os.clock()
local sentThisWindow = 0

local function budgetAllows(): boolean
	local now = os.clock()
	if now - windowStart >= 60 then
		windowStart, sentThisWindow = now, 0
	end
	local limit = (120 + 20 * #Players:GetPlayers()) * 0.75
	if sentThisWindow >= limit then
		return false
	end
	sentThisWindow += 1
	return true
end

local function safeCall(fn: (...any) -> ...any, ...: any)
	if not enabled or not budgetAllows() then
		return
	end
	local ok, err = pcall(fn, AnalyticsService, ...)
	if not ok and RunService:IsStudio() then
		warn("[Analytics] call failed:", err)
	end
end

local function fields(a: string?, b: string?, c: string?): { [string]: string }?
	if not (a or b or c) then
		return nil
	end
	local t: { [string]: string } = {}
	if a then
		t[CF1] = a
	end
	if b then
		t[CF2] = b
	end
	if c then
		t[CF3] = c
	end
	return t
end

-- ===== Onboarding (each step once per server session; persist "once ever" via
-- DataService.markOnboarding before calling) ===============================================
local onboardingDone: { [Player]: { [number]: boolean } } = {}

function Analytics.onboarding(player: Player, stepName: string)
	local step = table.find(ONBOARDING_STEPS, stepName)
	if not step then
		warn("[Analytics] unknown onboarding step", stepName)
		return
	end
	local done = onboardingDone[player]
	if not done then
		done = {}
		onboardingDone[player] = done
	end
	if done[step] then
		return
	end
	done[step] = true
	safeCall(AnalyticsService.LogOnboardingFunnelStepEvent, player, step, stepName)
end

-- ===== Recurring funnels =================================================================
function Analytics.newFunnelSession(): string
	return HttpService:GenerateGUID(false)
end

function Analytics.funnelStep(
	player: Player,
	funnel: string,
	sessionId: string?,
	step: number,
	stepName: string,
	field1: string?
)
	if not FUNNELS[funnel] then
		warn("[Analytics] funnel not allowlisted", funnel)
		return
	end
	safeCall(AnalyticsService.LogFunnelStepEvent, player, funnel, sessionId, step, stepName, fields(field1))
end

-- ===== Economy ===========================================================================
local function economy(
	flow: Enum.AnalyticsEconomyFlowType,
	player: Player,
	currency: string,
	amount: number,
	endingBalance: number,
	transactionType: Enum.AnalyticsEconomyTransactionType,
	sku: string?
)
	if not CURRENCIES[currency] then
		warn("[Analytics] currency not allowlisted", currency)
		return
	end
	if amount <= 0 then
		return
	end
	safeCall(
		AnalyticsService.LogEconomyEvent,
		player,
		flow,
		currency,
		amount,
		math.max(0, endingBalance),
		transactionType.Name,
		sku
	)
end

function Analytics.source(
	player: Player,
	currency: string,
	amount: number,
	endingBalance: number,
	transactionType: Enum.AnalyticsEconomyTransactionType,
	sku: string?
)
	economy(Enum.AnalyticsEconomyFlowType.Source, player, currency, amount, endingBalance, transactionType, sku)
end

function Analytics.sink(
	player: Player,
	currency: string,
	amount: number,
	endingBalance: number,
	transactionType: Enum.AnalyticsEconomyTransactionType,
	sku: string?
)
	economy(Enum.AnalyticsEconomyFlowType.Sink, player, currency, amount, endingBalance, transactionType, sku)
end

-- ===== Custom events =====================================================================
function Analytics.custom(player: Player, eventName: string, value: number?, f1: string?, f2: string?, f3: string?)
	if not CUSTOM_EVENTS[eventName] then
		warn("[Analytics] event not allowlisted", eventName)
		return
	end
	safeCall(AnalyticsService.LogCustomEvent, player, eventName, value or 1, fields(f1, f2, f3))
end

function Analytics.setEnabled(on: boolean)
	enabled = on
end

function Analytics:Init()
	Players.PlayerRemoving:Connect(function(player)
		onboardingDone[player] = nil
	end)
end

return Analytics
