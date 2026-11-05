--!strict
-- CodeFormat: normalization rules for redeemable codes (unit-tested). Shared so the client can
-- pre-validate input, but the server always re-normalizes. The code LIST is server-only
-- (src/server/Config/Codes.luau + LiveConfig "codes"); never put codes in ReplicatedStorage.

local CodeFormat = {}

CodeFormat.MAX_RAW_LENGTH = 40 -- bytes accepted from the client before normalizing
CodeFormat.MIN_LENGTH = 3
CodeFormat.MAX_LENGTH = 32

-- Uppercases, strips ALL whitespace, and checks charset [A-Z0-9_-] and length.
-- Returns the normalized code, or nil if the input can never be a valid code.
function CodeFormat.normalize(raw: any): string?
	if typeof(raw) ~= "string" or #raw > CodeFormat.MAX_RAW_LENGTH then
		return nil
	end
	local stripped = string.gsub(raw, "%s+", "")
	local s = string.upper(stripped)
	if #s < CodeFormat.MIN_LENGTH or #s > CodeFormat.MAX_LENGTH then
		return nil
	end
	if not string.match(s, "^[%w_%-]+$") then
		return nil
	end
	return s
end

return table.freeze(CodeFormat)
