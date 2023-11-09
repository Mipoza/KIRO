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


def c_n(x, y, z, w, I):
    V_s = I[3]
    V_t = I[2]
    S = I[1]
    Q_0 = I[4]
    Q_s = I[5]
    omega = I[6]

    c = 0

    for i in V_s:
        tmp = 0
        pw = omega[w][1]
        for j in V_t:
            if z[(i, j)]:
                tmp += pw
        tmp_s = 0

        for s in S:
            tmp_s += S[s][2] * x[(i, s)]

        tmp_q = 0

        for q in Q_0:
            if (i, q) in y[0]:
                tmp_q += Q_0[q][2]

        m = min(tmp_q, tmp_s)

        tmp = tmp - m

        if tmp >= 0:
            c += tmp

    return c


def c_f(v, x, y, z, w, I):
    V_s = I[3]
    V_t = I[2]
    S = I[1]
    Q_0 = I[4]
    Q_s = I[5]
    omega = I[6]

    c = 0

    tmp = 0
    pw = omega[w][1]

    for j in V_t:
        if z[(v, j)]:
            tmp += pw

    tmp2 = 0

    for v_s in V_s:
        for q in Q_s:
            if [v, v_s, q] in y[1]:
                tmp2 += Q_s[q][1]

    if tmp - tmp2 >= 0:
        c += tmp - tmp2

    for vb in V_s:
        if vb != v:
            n_tmp = 0
            for j in V_t:
                if z[(vb, j)]:
                    tmp += pw

            n_tmp2 = 0
            for q in Q_s:
                if [v, vb, q] in y[1]:
                    n_tmp2 += Q_s[q][1]

            m1 = min(tmp, n_tmp2)

            n_tmp3 = 0
            for s in S:
                if x[(vb, s)]:
                    n_tmp3 += S[s][2]

            n_tmp4 = 0
            for q in Q_0:
                if (vb, q) in y[0]:
                    n_tmp4 += Q_0[q][2]

            m2 = min(n_tmp3, n_tmp4)

            if n_tmp + m1 - m2 >= 0:
                c += n_tmp + m1 - m2

    return c


def c_c(C, I):
    c = I[0][0] * C

    if C >= I[0][4]:
        c += I[0][1] * (C - I[0][4])
    return c


def p_f(v, x, y, I):
    V_s = I[3]
    V_t = I[2]
    S = I[1]
    Q_0 = I[4]
    Q_s = I[5]
    p = 0

    for s in S:
        if x[(v, s)]:
            p += S[s][1]

    for q in Q_0:
        if (v, q) in y[0]:
            p += Q_0[q][1]

    return p


def op_cost(x, y, z, I):
    p_gen = I[0]
    S = I[1]
    V_t = I[2]
    V_s = I[3]
    Q_0 = I[4]
    Q_s = I[5]
    omega = I[6]

    c = 0

    for w in omega:
        p_w = omega[w][0]

        tmp1 = 0
        for v in V_s:
            tmp1 += p_f(v, x, y, I) * c_c(c_f(v, x, y, z, w, I), I)

        tmp2 = 0
        for v in V_s:
            tmp2 += p_f(v, x, y, I)

        tmp2 = (1 - tmp2) * c_c(c_n(x, y, z, w, I), I)

        c += p_w * (tmp1 + tmp2)

    return c


def total_cost(x, y, z, I):
    return op_cost(x, y, z, I) + const_cost(x, y, z, I)
