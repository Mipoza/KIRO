from collections import defaultdict
from math import sqrt

from cost import total_cost


def dist(s, t):
    return sqrt((s[0] - t[0]) ** 2 + (s[1] - t[1]) ** 2)


def solution_naive2(I2):
    """
    Cette solution consiste à mettre toutes les turbines d'une même ligne sur une même sous station la plus proche.

    I2 est l'instance obtenue avec la fonction parse_instance2 du fichier parser.py
    """

    V_s = I2[3]
    V_t = I2[2]

    ss_visitees = []

    # on peut optimiser sur le type de station choisi par défault
    type_ss = 1
    type_cable = 1

    # relier toutes les turbine d'une même ligne à la sous station correspondante
    z = defaultdict(int)
    for l in V_t:
        # trouver la sous station la plus proche
        mini = 100000
        t = l[0]
        s = V_s[0][-1]
        for ls in V_s:
            s2 = ls[-1]
            d = dist(next(iter(s2.values())), next(iter(t.values())))
            if d < mini:
                mini = d
                s = s2
        ss_visitees.append(next(iter(s.keys())))
        for t in l:
            z[(next(iter(s.keys())), next(iter(t.keys())))] = 1

    # construire chaque sous station visistée avec le type 1 et les relier à la terre
    x = defaultdict(int)
    y = [[], []]
    for s in ss_visitees:
        x[(s, type_ss)] = 1
        y[0].append((s, type_cable))

    return (x, y, z, I2)
