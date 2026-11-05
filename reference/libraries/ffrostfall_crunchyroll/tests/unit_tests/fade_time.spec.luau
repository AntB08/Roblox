local animation_solver = require("@src/animation_solver")
local process = require("@lune/process")
local TEST, CASE, CHECK, FINISH = require("@vendor/testkit").test()

TEST("animation track solver", function()
	CASE("nan case: alpha==0 length==0")
	do
		local alpha = animation_solver.solve_fade_time_influence(0, 0, 0, 0)

		CHECK(alpha == alpha)
	end

	CASE("nan case: alpha==1 length==0")
	do
		local alpha = animation_solver.solve_fade_time_influence(1, 0, 0, 0)

		CHECK(alpha == alpha)
	end

	CASE("nan case: alpha==0 length==1")
	do
		local alpha = animation_solver.solve_fade_time_influence(0, 1, 0, 0)

		CHECK(alpha == alpha)
	end

	CASE("nan case: alpha==1 length==1")
	do
		local alpha = animation_solver.solve_fade_time_influence(1, 1, 0, 0)

		CHECK(alpha == alpha)
	end
end)

if not FINISH() then
	process.exit(1)
end

return true
