using Random
using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")


# Checher que c'est le bon choix de type de cable et de ss

function lines(wind_turbines::Vector{Location})
    """
    Cette fonction renvoie les lignes de turbines i.e y = constante
    """
    turbines = sort(wind_turbines, by=x -> x.y)
    lines = []
    line = []
    y = turbines[1].y
    for turbine in turbines
        if turbine.y == y
            push!(line, turbine)
        else
            push!(lines, line)
            line = [turbine]
            y = turbine.y
        end
    end
    push!(lines, line)
    return lines
end

function maxed_out(substation_used::Vector{Int64}, n_max::Int64)
    maxed = false
    i = 1
    while i < length(substation_used) + 1 && !maxed
        if substation_used[i] == n_max
            maxed = true
        end
    end
    return maxed
end

function test_order(v1::UnitRange{Int64}, n::Int64)
    v2 = [[] for _ in 1:n]
    m = v1.stop
    p = 0
    r = 1
    while r < n + 1
        while p * n + r < m + 1
            push!(v2[r], v1[p*n+r])
            p += 1
        end
        r += 1
        p = 0
    end
    return v2
end

function order(v1::Vector{Any}, n::Int64)
    #réordoner modulo n ie : 1, n+1, 2n +1 , ... , 2, n+2, 2n +2, ...
    #order(lines(instance.wind_turbines),n_ligne_ss)

    # v2 = [[] for _ in 1:n]
    # m = length(v1)
    # k = 1
    # r = m % n
    # q = div(m - r, n)
    # for i in 1:n
    #     for _ in 1:q
    #         push!(v2[i], v1[k])
    #         k += 1
    #     end
    #     if r > 0
    #         push!(v2[i], v1[k])
    #         k += 1
    #         r -= 1
    #     end
    # end
    # return v2

    v2 = []
    for line in v1
        push!(v2, [line])
    end
    return v2
end

function choix_ss(turbine::Location, substation_locations::Vector{Location}, substation_used::Vector{Int})
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la ss la plus proche de la turbine.

    substation_used permet de ne pas surcharger une sous station. (au plus n_max ligne de turbines par ss)
    """

    n_max = 1
    mini = 100000
    id_substation = substation_locations[end].id
    # while !maxed_out(substation_used, n_max) 
    for substation in substation_locations
        d = distance(turbine, substation)
        if d < mini && substation_used[substation.id] < n_max
            mini = d
            id_substation = substation.id
        end
    end
    # if maxed_out(substation_used, n_max)
    # n_max +=1
    # end
    # end
    substation_used[id_substation] += 1
    return id_substation, substation_used
end

function choix_type_ss(substation_types::Vector{SubStationType})
    """
    Cette fonction choisit le type de sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre le risque de failure le plus grand et de cout minimal.
    C'est actuellement indépendant de la ss ou du nombre de lignes de turbines reliées à la ss.
    """

    id_type_ss = substation_types[end].id
    mini = substation_types[end].probability_of_failure

    while id_type_ss > 1 && substation_types[id_type_ss-1].probability_of_failure <= mini
        mini = substation_types[id_type_ss-1].probability_of_failure
        id_type_ss -= 1
    end
    return id_type_ss
end

function choix_type_cable_land_ss(land_substation_cable_types::Vector{CableType})
    """
    On choisit min failure et min cout total
    """

    id_type_cable = land_substation_cable_types[end].id
    mini = land_substation_cable_types[end].probability_of_failure + land_substation_cable_types[end].variable_cost
    while id_type_cable > 1 && land_substation_cable_types[id_type_cable-1].probability_of_failure + land_substation_cable_types[id_type_cable-1].variable_cost <= mini
        mini = land_substation_cable_types[id_type_cable-1].probability_of_failure + land_substation_cable_types[id_type_cable-1].variable_cost
        id_type_cable -= 1
    end
    return id_type_cable
end

function resolution_sixtine(instance::Instance)
    """
    Cette solution consiste à mettre toutes les turbines d'une même ligne sur une même sous station la plus proche.

    parser selon lignes

    Piste d'amélioration:
    - Limiter le nombre de turbine par station
    - Attribuer intelligement les stations
    """


    substations = []
    inter_station_cables = zeros(Int, nb_station_locations(instance), nb_station_locations(instance))
    turbine_links = zeros(nb_turbines(instance))

    ss_visited = []
    substation_used = zeros(Int, nb_station_locations(instance))
    n_ligne_ss = length(lines(instance.substation_locations))
    #Changer ordre parcours ligne_turbine
    # ! Risque danger parsing
    lines_turbines = lines(instance.wind_turbines)
    lines_turbines = order(lines_turbines, n_ligne_ss)


    # On choisit un type de ss ( substation_types)
    # On choisit un type de cable pour relier une station à la terre (land_substation_cable_types)
    # pour chaque ligne de turbines
    # --- on choisit une ss (la plus proche de la première turbine de la ligne)
    # --- on ajoute la ss à la liste des ss visitées
    # --- pour chaque turbine de la ligne de turbines
    # --- --- On relie la turbine à la ss : turbine_links[turbine.id] = ss.id
    # Pour chaque ss visitée
    # --- On construit la ss : substations.append(Substation(id, substation_type, land_cable_type))
    # Renvoyer la solution

    type_ss = choix_type_ss(instance.substation_types)
    type_cable = choix_type_cable_land_ss(instance.land_substation_cable_types)
    for v2 in lines_turbines
        for line_turbines in v2
            id_substation, substation_used = choix_ss(first(line_turbines), instance.substation_locations, substation_used)
            ss_visited = [ss_visited..., id_substation]
            for turbine in line_turbines
                turbine_links[turbine.id] = id_substation
            end
        end
    end
    for substation in ss_visited
        push!(substations, SubStation(substation, type_ss, type_cable))
    end
    return Solution(; turbine_links, inter_station_cables, substations)
end