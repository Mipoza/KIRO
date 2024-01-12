using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

I = read_instance("instances/KIRO-small.json")
print(I.fixed_cost_cable)