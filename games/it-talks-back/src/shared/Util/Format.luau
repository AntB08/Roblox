--!strict
-- Format: number formatting for UI (pure).
--   Format.commas(1234567)     --> "1,234,567"
--   Format.abbreviate(1530)    --> "1.5K"
--   Format.duration(3725)      --> "1:02:05"

local Format = {}

local SUFFIXES = { "K", "M", "B", "T", "Qa", "Qi" }

function Format.commas(n: number): string
	local negative = n < 0
	local digits = tostring(math.floor(math.abs(n)))
	local formatted = string.reverse((string.gsub(string.reverse(digits), "(%d%d%d)", "%1,")))
	if string.sub(formatted, 1, 1) == "," then
		formatted = string.sub(formatted, 2)
	end
	return if negative then "-" .. formatted else formatted
end

function Format.abbreviate(n: number): string
	local absolute = math.abs(n)
	if absolute < 1000 then
		return tostring(math.floor(n))
	end
	local index = 0
	local value = absolute
	while value >= 1000 and index < #SUFFIXES do
		value /= 1000
		index += 1
	end
	-- One decimal below 100 ("1.5K", "12.3K"), none above ("150K"); never show "1.0K".
	local text = if value < 100 then string.format("%.1f", math.floor(value * 10) / 10) else tostring(math.floor(value))
	text = string.gsub(text, "%.0$", "")
	return (if n < 0 then "-" else "") .. text .. SUFFIXES[index]
end

function Format.duration(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local h = s // 3600
	local m = (s % 3600) // 60
	local sec = s % 60
	if h > 0 then
		return string.format("%d:%02d:%02d", h, m, sec)
	end
	return string.format("%d:%02d", m, sec)
end

return table.freeze(Format)
