local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local mirror_configs = fs.readDir("./benches/mirror_list")

-- thank you nick from lute
local function get_git_version(): { major: number, minor: number, path: number }
	local git_ver_string = process.exec("git", { "--version" }).stdout
	local git_ver = string.split(git_ver_string, " ")[3]
	local components = string.split(git_ver, ".")

	return {
		major = tonumber(components[1]) or 0,
		minor = tonumber(components[2]) or 0,
		path = tonumber(components[3]) or 0,
	}
end

local git_version = get_git_version()

for _, file_name in mirror_configs do
	local path = "./benches/mirror_list/" .. file_name

	local config: unknown = serde.decode("toml", fs.readFile(path))
	assert(type(config) == "table", `[mirror] {path} must be a table`)

	-- Lovely type errors :3
	assert(type(config.revision) == "string", `[mirror] {path} config.revision must be a string`)
	assert(type(config.branch) == "string", `[mirror] {path} config.branch must be a string`)
	assert(type(config.name) == "string", `[mirror] {path} config.name must be a string`)
	assert(type(config.remote) == "string", `[mirror] {path} config.remote must be a string`)

	local mirror_path = "./benches/mirrors/" .. config.name
	local full_mirror_path = mirror_path .. "/src/"
	if fs.isDir(mirror_path) then
		process.exec(
			"git",
			{ "fetch", "--depth=1", "origin", config.revision },
			{ stdio = "forward", cwd = full_mirror_path }
		)

		process.exec(
			"git",
			{ "checkout", config.revision },
			{ stdio = "forward", cwd = full_mirror_path }
		)

		continue
	end

	if git_version.major >= 3 or (git_version.major == 2 and git_version.minor >= 49) then
		process.exec("git", {
			"clone",
			"--depth=1",
			"--revision",
			config.revision,
			config.remote,
			full_mirror_path,
		})
	else
		process.exec("git", {
			"clone",
			"--depth=1",
			"--branch",
			config.branch,
			config.remote,
			full_mirror_path,
		})
	end
end
