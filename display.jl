include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")

using Plots
gr()

txt = "KIRO-huge"
I = read_instance("instances/" * txt * ".json")
sol::Solution = resolution_sixtine(I)
write_solution(sol, "solutions/" * txt * ".json")
solution = read_solution("solutions/" * txt * ".json", I)

function display_instance(instance::Instance)
    V_t = instance.wind_turbines
    V_s = instance.substation_locations

    # Create a plot
    plot()

    r = 0.02
    ms2 = 2

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

# Exemple d'utilisation
display_instance(I)

function display_solution(solution::Solution, instance::Instance)
    V_t = instance.wind_turbines
    V_s = instance.substation_locations
    ms2 = 2

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
    display(plot!())
end


# Exemple d'utilisation
display_solution(solution, I)




# def display_type_ss(I):
#     S = I[1]
#     fig, ax = plt.subplots()

#     costs = [s[0] for s in S.values()]
#     failure = [s[1] for s in S.values()]
#     rating = [s[2] for s in S.values()]
#     id = [s for s in S.keys()]

#     # Sur chaque point, ajouter une étiquette avec son identifiant
#     for i, txt in enumerate(id):
#         ax.annotate(txt, (costs[i], failure[i]))
#     plt.scatter(costs, failure, c=rating, cmap="viridis")
#     plt.xlabel("Cost")
#     plt.ylabel("Failure probability")

#     # add legend for rating
#     plt.colorbar()

#     # add title
#     plt.title("Type of substations possible")

#     plt.show()


# def display_type_cable_land_ss(I):
#     Q_0 = I[4]
#     fig, ax = plt.subplots()
#     id = [q for q in Q_0.keys()]
#     fcosts = [q[0] for q in Q_0.values()]
#     rating = [q[1] for q in Q_0.values()]
#     failure = [q[2] for q in Q_0.values()]
#     vcosts = [q[3] for q in Q_0.values()]
#     tot_costs = [q[0] + q[3] for q in Q_0.values()]

#     # for i, txt in enumerate(id):
#     #     ax.annotate(txt, (vcosts[i], fcosts[i]))
#     # plt.scatter(vcosts, fcosts, c=rating, cmap="viridis")
#     # plt.xlabel("Variable cost")
#     # plt.ylabel("Variable cost")
#     # plt.colorbar()
#     # plt.show()

#     for i, txt in enumerate(id):
#         ax.annotate(txt, (tot_costs[i], failure[i]))
#     plt.scatter(tot_costs, failure, c=rating, cmap="viridis")
#     plt.xlabel("Total cost")
#     plt.ylabel("Failure probability")
#     plt.title("Type of cables possible")
#     plt.colorbar()
#     plt.show()


# # def load_sol(file_path):
# #     with open(file_path, "r") as json_file:
# #         data = json.load(json_file)

# #     # Initialiser les structures de données
# #     x = {}
# #     y = [[], []]
# #     z = {}

# #     # Remplir les structures de données à partir du contenu du fichier JSON
# #     for substation in data.get("substations", []):
# #         substation_id = substation["id"]
# #         substation_type = substation["substation_type"]
# #         x[(substation_id, substation_type)] = 1

# #     for cable in data.get("substation_substation_cables", []):
# #         substation_id = cable["substation_id"]
# #         other_substation_id = cable["other_substation_id"]
# #         cable_type = cable["cable_type"]
# #         y[1].append((substation_id, other_substation_id, 0, cable_type))

# #     for turbine in data.get("turbines", []):
# #         substation_id = turbine["substation_id"]
# #         turbine_id = turbine["id"]
# #         z[(substation_id, turbine_id)] = 1

# #     return x, y, z

# # # Exemple d'utilisation
# # file_path = "solutions/votre_solution.json"
# # x, y, z = load_sol(file_path)
