using Random
using JSON

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

function dist(s, t)
    return sqrt((s[1] - t[1])^2 + (s[2] - t[2])^2)
end

function choix_ss_in_line(t_pos, line_ss)
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine dans la ligne de ss donnée.
    L'heuristique actuelle est de prendre la dernière ss de la ligne.
    """
    x = 0
    ss0 = line_ss[1]
    for ss in line_ss
        pos_ss = first(values(ss))
        if pos_ss[1] > x
            x = pos_ss[1]
            ss0 = ss
        end
    end
    return first(keys(ss0))
end

function choix_ss_in_line2(t_pos, line_ss)
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine dans la ligne de ss donnée.
    L'heuristique actuelle est de prendre la première ss de la ligne.
    """
    x = 1000
    ss0 = line_ss[1]
    for ss in line_ss
        pos_ss = first(values(ss))
        if pos_ss[1] < x
            x = pos_ss[1]
            ss0 = ss
        end
    end
    return first(keys(ss0))
end

function choix_ss(t_pos, V_s)
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la dernière ss de la ligne la plus proche de la turbine.

    t_pos est la position de la turbine de la ligne
    """
    mini = 100000
    s2 = first(keys(V_s[1][end]))
    for line_ss in V_s
        s3 = choix_ss_in_line2(t_pos, line_ss)
        d = dist(t_pos, first(values(s3)))
        if d < mini
            mini = d
            s2 = first(keys(s3))
        end
    end
    return s2
end

function choix_type_ss(S)
    """
    Cette fonction choisit le type de sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre le risque de failure le plus grand et de cout minimal.
    C'est actuellement indépendant de la ss ou du nombre de lignes de turbines reliées à la ss.
    """
    type_ss = keys(S[end])[1]
    mini = S[end][1]

    while type_ss > 1 && S[type_ss - 1][1] <= mini
        mini = S[type_ss - 1][1]
        type_ss -= 1
    end
    return type_ss
end

function choix_type_cable_land_ss(Q_0)
    """
    On choisit min failure et min cout total
    """
    type_cable = keys(Q_0[end])[1]
    mini = Q_0[end][1] + Q_0[end][3]
    while type_cable > 1 && Q_0[type_cable - 1][1] + Q_0[type_cable - 1][3] <= mini
        mini = Q_0[type_cable - 1][1] + Q_0[type_cable - 1][3]
        type_cable -= 1
    end
    return type_cable
end

function solution_naive2(I)
    """
    Cette solution consiste à mettre toutes les turbines d'une même ligne sur une même sous station la plus proche.

    I2 est l'instance obtenue avec la fonction parse_instance2 du fichier parser.py

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
