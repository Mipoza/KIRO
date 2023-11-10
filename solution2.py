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
    return line_ss[-1]


def choix_ss(t_pos, V_s):
    """
    Cette fonction choisit la sous station à laquelle on va relier la ligne de turbine.
    L'heuristique actuelle est de prendre la dernière ss de la ligne la plus proche de la turbine.
    """
    mini = 100000
    s2 = V_s[0][-1]
    # Choix de la ligne
    for line_ss in V_s:
        # Choix de la sous station dans la ligne
        s3 = choix_ss_in_line(t_pos, line_ss)
        d = dist(t_pos, next(iter(s3.values())))
        if d < mini:
            mini = d
            s2 = s3
    return next(iter(s2.keys()))


# def choix_type_ss(id_ss, liste_id_t)


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

    ss_visitees = []

    # remplacer par un dictionnaire avec la sous station et la liste des turbines reliées à cette sous station

    # on peut optimiser sur le type de station choisi par défault
    type_ss = 1
    type_cable = 1

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
    for s in ss_visitees:
        x[(s, type_ss)] = 1
        y[0].append((s, type_cable))

    return (x, y, z, I2)
