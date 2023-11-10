from collections import defaultdict
from math import sqrt

from cost import total_cost


def dist(s, t):
    return sqrt((s[0] - t[0]) ** 2 + (s[1] - t[1]) ** 2)


def choix_ss_in_line(t_pos, line_ss):
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine dans la ligne de ss donnée.
    L'heuristique actuelle est de prendre la dernière ss de la ligne.
    """
    x = 0
    ss0 = line_ss[0]
    for ss in line_ss:
        pos_ss = next(iter(ss.values()))
        if pos_ss[0] > x:
            x = pos_ss[0]
            ss0 = ss
    # return line_ss[-1]
    return ss0


def choix_ss_in_line2(t_pos, line_ss):
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine dans la ligne de ss donnée.
    L'heuristique actuelle est de prendre la première ss de la ligne.
    """
    x = 1000
    ss0 = line_ss[0]
    for ss in line_ss:
        pos_ss = next(iter(ss.values()))
        if pos_ss[0] < x:
            x = pos_ss[0]
            ss0 = ss
    return ss0


def choix_ss(t_pos, V_s):
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la dernière ss de la ligne la plus proche de la turbine.

    t_pos est la position de la turbine de la ligne
    """
    mini = 100000
    s2 = V_s[0][-1]
    # Choix de la ligne
    for line_ss in V_s:
        # Choix de la sous station dans la ligne
        s3 = choix_ss_in_line2(t_pos, line_ss)
        d = dist(t_pos, next(iter(s3.values())))
        if d < mini:
            mini = d
            s2 = s3
    return next(iter(s2.keys()))


def choix_type_ss(S):
    """
    Cette fonction choisit le type de sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre le risque de failure le plus grand et de cout minimal.
    C'est actuellement indépendant de la ss ou du nombre de lignes de turbines reliées à la ss.
    """

    # sub["id"]: [sub["cost"], sub["probability_of_failure"], sub["rating"]]
    type_ss = list(S.keys())[-1]
    mini = S[type_ss][0]

    while type_ss > 1 and S[type_ss - 1][0] <= mini:
        mini = S[type_ss - 1][0]
        type_ss -= 1
    return type_ss


def choix_type_cable_land_ss(Q_0):
    """
    On choisit min failure et min cout total
    """
    type_cable = list(Q_0.keys())[-1]
    mini = Q_0[type_cable][0] + Q_0[type_cable][2]
    while type_cable > 1 and Q_0[type_cable - 1][0] + Q_0[type_cable - 1][2] <= mini:
        mini = Q_0[type_cable - 1][0] + Q_0[type_cable - 1][2]
        type_cable -= 1
    return type_cable


def solution_naive2(I2):
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

    V_s = I2[3]
    V_t = I2[2]
    S = I2[1]
    Q_0 = I2[4]

    ss_visitees = []

    # remplacer par un dictionnaire avec la sous station et la liste des turbines reliées à cette sous station

    # relier toutes les turbine d'une même ligne à la sous station correspondante
    z = defaultdict(int)
    for line in V_t:
        # Choix de la sous station référente de la ligne
        id_ss = choix_ss(next(iter(line[0].values())), V_s)

        # relier les turbines de la ligne à la sous station
        ss_visitees.append(id_ss)
        for t in line:
            z[(id_ss, next(iter(t.keys())))] = 1

    # construire chaque sous station visistée avec le type 1 et les relier à la terre
    x = defaultdict(int)
    y = [[], []]
    type_ss = choix_type_ss(S)
    type_cable = choix_type_cable_land_ss(Q_0)
    print("type_ss= ", type_ss)
    print("type_cable= ", type_cable)
    for s in ss_visitees:
        x[(s, type_ss)] = 1
        y[0].append((s, type_cable))

    return (x, y, z, I2)
