from collections import defaultdict


def solution_naive(I):
    """
    La solution naive c'est toutes les turbines sur une sous station
    """

    V_s = I[3]
    V_t = I[2]

    # construire la sous station 1 avec le type 1
    x = defaultdict(int)
    x[(1, 1)] = 1

    # relier toutes les turbine à la sous station 1
    z = defaultdict(int)
    for t in V_t:
        z[(1, t)] = 1

    # relier la sous station 1 à la station de terre avec un cable de type 1
    y = [[], []]
    y[0] = [(1, 1)]

    return (x, y, z, I)
