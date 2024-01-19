using JSON
using Random

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

function get_scenario_with_max_power(I::Instance, k)
    scenarios = I.wind_scenarios
    sorted_scenarios = sort(scenarios, by = x -> x.power_generation, rev=true)
    return sorted_scenarios[1:k]
end

function get_uniform_scecario_distribution(I::Instance, k)
    scenarios = I.wind_scenarios
    sorted_scenarios = sort(scenarios, by = x -> x.power_generation)
    n = length(scenarios)
    indices = [Int(floor((i)*n/k)) for i in 1:k]
    println(indices)
    println(sorted_scenarios[indices])
    return sorted_scenarios[indices]
end

function get_last_turbine_line(I::Instance)
    indices = [3, 13, 23, 8, 18, 28]
    return I.substation_locations[indices]
end

function get_last_turbine_col_large(I::Instance)
    #indices = [1, 8, 15, 22, 29] #large
    #indices = [3,8,13,18,23,28] #medium
    #indices = [3,8,13,18,28]
    #indices = [4,13,22,31,40,49,58,67,76, 8,17,26,35,44,53,62,71,80] #semifull huge
    indices = [4,13,22,31,40,49,58,67,76]
    #indices = [22,49,67,76]
    #indices = [67]
    indices = [4,67]
    return I.substation_locations[indices]
end