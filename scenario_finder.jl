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

function get_large_turbine_partition(I::Instance)
    S1 = []
    S2 = []
    S3 = []
    S4 = I.wind_turbines

    for s in 1:length(I.wind_turbines)  
        """      
        if I.wind_turbines[s].y < -1.2
            push!(S1, I.wind_turbines[s])
        elseif I.wind_turbines[s].y > -1.2 && I.wind_turbines[s].y < 1.2
            push!(S2, I.wind_turbines[s])
        else
            push!(S3, I.wind_turbines[s])
        end
        """
        if I.wind_turbines[s].y < 0.2
            push!(S2, I.wind_turbines[s])
        else
            push!(S3, I.wind_turbines[s])
        end
    end
    return [S4]   
end

function get_large_station_partition(I::Instance)
    S1 = [I.substation_locations[8]]
    S2 = [I.substation_locations[15], I.substation_locations[8]]
    S3 = [I.substation_locations[22]]
    S4 = [I.substation_locations[8], I.substation_locations[15], I.substation_locations[22]]
    indices = [1, 8, 15, 22, 29]
    """
    for s in 1:length(I.substation_locations)
        if I.substation_locations[s].id in indices
            if I.substation_locations[s].y <= -1 && I.substation_locations[s].y > -2
                #push!(S1, I.substation_locations[s])
            end
            if I.substation_locations[s].y > -2 && I.substation_locations[s].y <= 2
                push!(S2, I.substation_locations[s])
            end
            if I.substation_locations[s].y > 1 && I.substation_locations[s].y <= 2
                push!(S3, I.substation_locations[s])
            end
        end 
    end
    """
    return [S4]    
end

