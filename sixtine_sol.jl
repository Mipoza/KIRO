using Random
using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

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

function choix_ss(turbine::Location, substation_locations::Vector{Location})
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la ss la plus proche de la turbine.
    """

    mini = 100000
    id_substation = substation_locations[end].id
    for substation in substation_locations
        d = distance(turbine, substation)
        if d < mini
            mini = d
            id_substation = substation.id
        end
    end
    return id_substation
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
    - optimiser sur le type de station choisi par défault
    - optimiser sur le type de cable choisi par défault
    - choix de la ss référente de la ligne
    - relier les sous stations entre elles
    - optimiser sur le type de cable choisi pour relier les sous stations entre elles
    """


    substations = []
    inter_station_cables = zeros(Int, nb_station_locations(instance), nb_station_locations(instance))
    turbine_links = zeros(nb_turbines(instance))

    ss_visited = []
    lines_turbines = lines(instance.wind_turbines)

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
    for line_turbines in lines_turbines
        id_substation = choix_ss(first(line_turbines), instance.substation_locations)
        ss_visited = [ss_visited..., id_substation]
        for turbine in line_turbines
            turbine_links[turbine.id] = id_substation
        end
    end
    for substation in ss_visited
        push!(substations, SubStation(substation, type_ss, type_cable))
    end
    return Solution(; turbine_links, inter_station_cables, substations)
end
