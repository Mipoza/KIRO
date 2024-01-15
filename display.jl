include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")

using Plots
gr()

ms2 = 2


function display_instance(instance::Instance)
    V_t = instance.wind_turbines
    V_s = instance.substation_locations

    # Create a plot
    plot()

    r = 0.02

    # Draw a red filled circle for each wind turbine
    for (id, turbine) in pairs(V_t)
        plot!([turbine.x], [turbine.y], st=:scatter, ms=ms2, m=:circle, color="red")
        #annotate!(turbine.x, turbine.y, text(string(id), :left, 4, :red))
    end

    # Draw a blue circle for each substation
    for (id, substation) in pairs(V_s)
        plot!([substation.x], [substation.y], st=:scatter, ms=ms2 * 4, m=:circle, color="blue")
        annotate!(substation.x, substation.y + 0.3, text(string(id), :bottom, 8, :blue))
    end

    # Draw a green circle for the land station (in 0,0)
    land = instance.land
    plot!([land.x], [land.y], st=:scatter, ms=ms2 * 5, m=:circle, color="green", legend=false)

    # Set axis limits
    # plot!([-5, 85], [-10, 10], legend=false)

    # Display the plot
    display(plot!())
end

function display_solution(solution::Solution, instance::Instance)
    V_t = instance.wind_turbines
    V_s = instance.substation_locations

    plot()

    for (id, substation) in pairs(V_s)
        plot!([substation.x], [substation.y], st=:scatter, ms=ms2, m=:circle, color="blue")
    end

    # Draw a blue circle for each built substation
    for substation in values(solution.substations)
        ss = V_s[substation.id]
        plot!([ss.x], [ss.y], st=:scatter, ms=ms2 * 4, m=:circle, color="blue")
        annotate!(ss.x - ms2, ss.y, text(substation.substation_type, :bottom, 8, :blue))
        plot!([ss.x, 0], [ss.y, 0], color="green")
        annotate!((ss.x + 0) / 2, (ss.y + 0) / 2, text(substation.land_cable_type, :top, 8, :green))
    end

    # Draw a green circle for the land station (in 0,0)
    land = instance.land
    plot!([land.x], [land.y], st=:scatter, ms=ms2 * 5, m=:circle, color="green", legend=false)

    # Draw the links between substations
    for i in 1:nb_station_locations(instance)
        for j in (i+1):nb_station_locations(instance)
            if solution.inter_station_cables[i, j] > 0
                plot!([V_s[i].x, V_s[j].x], [V_s[i].y, V_s[j].y], color="black")
                annotate!((V_s[i].x + V_s[j].x) / 2, (V_s[i].y + V_s[j].y) / 2, text(solution.inter_station_cables[i, j], :bottom, 8, :black))
            end
        end
    end

    # Draw a red filled circle for each wind turbine
    for id_t in 1:nb_turbines(instance)
        id_s = solution.turbine_links[id_t]
        plot!([V_s[id_s].x, V_t[id_t].x], [V_s[id_s].y, V_t[id_t].y], color="red")
        # annotate!((V_s[id_s].x + V_t[id_t].x) / 2, (V_s[id_s].y + V_t[id_t].y) / 2, text(id_t, :top, 4, :red))
        plot!([V_t[id_t].x], [V_t[id_t].y], st=:scatter, ms=ms2, m=:circle, color="red", legend=false)
        annotate!((V_s[id_s].x + V_t[id_t].x) / 2, (V_s[id_s].y + V_t[id_t].y) / 2, text(id_t, :right, 4, :red))
    end

    # Set axis limits
    # plot!([-5, 85], [-10, 10], legend=false)

    # Display the plot
    title!("Cost: " * string(cost(solution, instance)))
    display(plot!())
end


function display_type_ss(I::Instance)
    plot()

    for s in values(I.substation_types)
        plot!([s.cost], [s.probability_of_failure], st=:scatter, ms=ms2, m=:circle, color="blue")
        annotate!(s.cost, s.probability_of_failure, text(s.id, :bottom, 8, :blue))
    end

    xlabel!("Cost")
    ylabel!("Failure probability")
    title!("Type of substations possible")

    display(plot!())
end


function display_type_cable_land_ss(I::Instance)
    plot()

    # tot_costs = [q.variable_cost + q.fixed_cost for q in values(Q_0)]
    # failure = [q.probability_of_failure for q in values(Q_0)]
    # rating = [q.rating for q in values(Q_0)]

    for q in values(I.land_substation_cable_types)
        plot!([q.variable_cost + q.fixed_cost], [q.probability_of_failure], st=:scatter, ms=ms2, m=:circle, color="green")
        annotate!(q.variable_cost + q.fixed_cost, q.probability_of_failure, text(q.id, :bottom, 8))
    end

    # scatter!(tot_costs, failure, c=rating, cmap="viridis")
    xlabel!("Total cost")
    ylabel!("Failure probability")
    title!("Type of cables possible (land -> substation))")

    display(plot!())
end




# ------------- Exemple d'utilisation -------------


txt = "KIRO-huge"
I = read_instance("instances/" * txt * ".json")
sol::Solution = resolution_sixtine(I)
write_solution(sol, "solutions/" * txt * "2.json")
# solution = read_solution("solutions/" * txt * ".json", I)
solution2 = read_solution("solutions/" * txt * "2.json", I)


# display_instance(I)
# display_solution(solution, I)
display_solution(solution2, I)

# print(cost(solution, I))
# print(cost(solution2, I))

# display_type_ss(I)
# display_type_cable_land_ss(I)

