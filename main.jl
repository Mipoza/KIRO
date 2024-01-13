using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")


I = read_instance("instances/KIRO-huge.json")

sol::Solution = resolution_sixtine(I)
write_solution(sol, "solutions/solution.json")
print(is_feasible(sol, I))
print(cost(sol, I))
