from collections import defaultdict
from math import sqrt


def dist(v_s, v_t):
    return sqrt((v_s[0] - v_t[0]) ** 2 + (v_s[1] - v_t[1]) ** 2)


def const_cost(x, y, z, I):
    p_gen = I[0]
    S = I[1]
    V_t = I[2]
    V_s = I[3]
    Q_0 = I[4]
    Q_s = I[5]
    omega = I[6]

    c = 0

    for i in V_s:
        for j in S:
            c += x[(i, j)] * S[j][0]

    for i in V_s:
        for j in V_t:
            if z[(i, j)]:
                c += z[(i, j)] * (p_gen[2] + p_gen[6] * dist(V_s[i], V_t[j]))

    for h in y[0]:
        c += Q_0[h[1]][0] + Q_0[h[1]][3] * dist(V_s[h[0]], p_gen[3])

    for h in y[1]:
        c += Q_s[h[2]][0] + Q_s[h[2]][2] * dist(V_s[h[0]], V_s[h[1]])

    return c


def op_cost(x, y, z, I):
    pass


def total_cost(x, y, z, I):
    return total_cost(x, y, z, I)
