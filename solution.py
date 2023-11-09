from collections import defaultdict

from cost import total_cost


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


def improve_nbr_ss(x, y, z, I):
    V_s = I[3]
    V_t = I[2]
    S = I[1]

    cout = total_cost(x, y, z, I)

    # pour chaque sous station
    # pour chaque turbine, est-ce que le cout diminue si on passe par la nouvelle sous station

    for s in V_s:
        print(cout)
        x2 = x.copy()
        y0 = y[0].copy()

        # on ajoute la nouvelle sous station et on la relie à la terre
        x2[(s, 1)] = 1
        y0.append((s, 1))

        for t in V_t:
            z2 = z.copy()
            # on relie la nouvelle sous station à la turbine et on enlève la liaison avec la sous station auquel elle était reliée
            z2[(s, t)] = 1

            # retrouver l'indice s2 de la sous station vérifiant z2(s2,t)==1
            s2 = [key[0] for key, value in z2.items() if value == 1 and key[1] == t][0]
            z2[(s2, t)] = 0

            cout2 = total_cost(x2, [y0, y[1]], z2, I)
            if cout2 < cout:
                x = x2
                y[0] = y0
                z = z2
                cout = cout2
    return (x, y, z, I)


def improve_type_ss(x, y, z, I):
    V_s = I[3]
    S = I[1]

    cout = total_cost(x, y, z, I)

    # pour chaque sous station on change le type de sous station si cela diminue le cout
    for s in V_s:
        for j in S.keys()-1:
            print(cout)
            x2 = x.copy()
            x2[(s, j)] = 0
            x2[(s, j+1)] = 1

            cout2 = total_cost(x2, y, z, I)
            if cout2 < cout:
                x = x2
                cout = cout2
        x2[(s, S.keys())] = 0
    
    return (x, y, z, I)

def solution_moins_naive(I):
    return improve_nbr_ss(*solution_naive(I))
