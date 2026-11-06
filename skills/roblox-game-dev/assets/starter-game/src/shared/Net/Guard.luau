--!strict
-- Guard: runtime validators for anything that crosses the network. Luau types do not exist at
-- runtime, so every RemoteEvent/RemoteFunction argument is checked with one of these.
-- Each constructor returns a Check: (value: any) -> boolean. Pure module (unit-tested).

export type Check = (value: any) -> boolean

local Guard = {}

local function isFinite(n: number): boolean
	return n == n and n ~= math.huge and n ~= -math.huge
end
Guard.isFinite = isFinite

function Guard.number(min: number?, max: number?): Check
	return function(v: any): boolean
		if typeof(v) ~= "number" or not isFinite(v) then
			return false
		end
		if min ~= nil and v < min then
			return false
		end
		if max ~= nil and v > max then
			return false
		end
		return true
	end
end

function Guard.integer(min: number?, max: number?): Check
	local num = Guard.number(min, max)
	return function(v: any): boolean
		return num(v) and v % 1 == 0
	end
end

-- Length is counted in UTF-8 code points; invalid UTF-8 is rejected.
function Guard.string(maxLength: number, minLength: number?): Check
	return function(v: any): boolean
		if typeof(v) ~= "string" then
			return false
		end
		if #v > maxLength * 4 then
			return false -- cheap byte cap before walking the string
		end
		local len = utf8.len(v)
		if len == nil then
			return false
		end
		return len <= maxLength and len >= (minLength or 0)
	end
end

function Guard.boolean(): Check
	return function(v: any): boolean
		return typeof(v) == "boolean"
	end
end

-- Value must be a key of `set` (e.g. an item catalog or a settings table).
function Guard.oneOf(set: { [any]: any }): Check
	return function(v: any): boolean
		local t = typeof(v)
		if t ~= "string" and t ~= "number" then
			return false
		end
		if t == "number" and not isFinite(v) then
			return false
		end
		return set[v] ~= nil
	end
end

function Guard.vector3(maxMagnitude: number?): Check
	return function(v: any): boolean
		if typeof(v) ~= "Vector3" then
			return false
		end
		if not (isFinite(v.X) and isFinite(v.Y) and isFinite(v.Z)) then
			return false
		end
		return maxMagnitude == nil or v.Magnitude <= maxMagnitude
	end
end

-- Instance of a class (IsA), optionally required to be under `ancestor`.
-- Remember: an Instance the client cannot see arrives as nil, and the client chooses WHICH
-- instance it sends. Always re-check game rules (tags, distance, ownership) on the server.
function Guard.instanceOf(className: string, ancestor: Instance?): Check
	return function(v: any): boolean
		if typeof(v) ~= "Instance" or not v:IsA(className) then
			return false
		end
		return ancestor == nil or v:IsDescendantOf(ancestor)
	end
end

function Guard.optional(check: Check): Check
	return function(v: any): boolean
		return v == nil or check(v)
	end
end

-- Validates an argument list against a list of checks.
-- Returns (true) or (false, reason). Extra arguments beyond #checks are rejected.
function Guard.args(checks: { Check }, ...: any): (boolean, string?)
	local argc = select("#", ...)
	if argc > #checks then
		return false, `too many args ({argc} > {#checks})`
	end
	for i, check in checks do
		local v = select(i, ...)
		if not check(v) then
			return false, `arg #{i} failed validation (got {typeof(v)})`
		end
	end
	return true, nil
end

return table.freeze(Guard)
