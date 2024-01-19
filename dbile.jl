using JSON
using HiGHS
using JuMP
using Random
using Dates
ENV["GUROBI_HOME"] = "/home/mipoza/Documents/gurobi1100/linux64"
using Gurobi

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")
include("scenario_finder.jl")
include("display.jl")

I = read_instance("instances/KIRO-medium.json")
S = read_solution("opt_sol/medium.json", I)

print(is_feasible(S, I))
print(cost(S, I))

display_solution(S, I)
display_instance(I)
