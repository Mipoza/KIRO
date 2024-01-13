using Random
using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")


function choix_ss(turbine::Location, substation_locations::Vector{Location})
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la ss la plus proche de la turbine.
    """

    mini = 100000
    id_substation = substation_locations[-1].id
    for substation in substation_locations
        d = dist(turbine, substation)
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

    id_type_ss = substation_types[-1].id
    mini = substation_types[-1].probability_of_failure

    while id_type_ss > 1 && substation_types[id_type_ss - 1].probability_of_failure <= mini
        mini = substation_types[id_type_ss - 1].probability_of_failure
        id_type_ss -= 1
    end
    return id_type_ss
end

function choix_type_cable_land_ss(land_substation_cable_types::Vector{CableType})
    """
    On choisit min failure et min cout total
    """

    id_type_cable = land_substation_cable_types[-1].id
    mini = land_substation_cable_types[-1].probability_of_failure + land_substation_cable_types[-1].variable_cost
    while id_type_cable > 1 && land_substation_cable_types[id_type_cable - 1].probability_of_failure + land_substation_cable_types[id_type_cable - 1].variable_cost <= mini
        mini = land_substation_cable_types[id_type_cable - 1].probability_of_failure + land_substation_cable_types[id_type_cable - 1].variable_cost
        id_type_cable -= 1
    end    
    return type_cable
end

function solution(instance::Instance)
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
    V_s = I.substation_locations
    V_t = I.wind_turbines
    S = I.substation_types
    Q_0 = I.land_substation_cable_types

    ss_visitees = []

    z = Dict()

    for line in V_t
        id_ss = choix_ss(first(values(first(line))), V_s)

        ss_visitees = [ss_visitees..., id_ss]

        for t in line
            z[(id_ss, first(keys(t)))] = 1
        end
    end

    x = Dict()
    y = [[], []]

    type_ss = choix_type_ss(S)
    type_cable = choix_type_cable_land_ss(Q_0)

    println("type_ss= ", type_ss)
    println("type_cable= ", type_cable)

    for s in ss_visitees
        x[(s, type_ss)] = 1
        push!(y[1], (s, type_cable))
    end

    return (x, y, z, I)
end
