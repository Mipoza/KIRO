import json
from collections import defaultdict
from math import sqrt


def parse_instance(file):
    """
    Parse the input file and return a list of parameters and data structures needed for the optimization problem.
    """
    f = open("instances/" + file)
    data = json.load(f)

    gen_p = data["general_parameters"]

    c_0 = gen_p["curtailing_cost"]
    c_p = gen_p["curtailing_penalty"]
    c_ft = gen_p["fixed_cost_cable"]
    v_0 = [gen_p["main_land_station"]["x"], gen_p["main_land_station"]["y"]]
    c_max = gen_p["maximum_curtailing"]
    p_max = gen_p["maximum_power"]
    c_lt = gen_p["variable_cost_cable"]

    sub_type = data["substation_types"]
    S = {
        sub["id"]: [sub["cost"], sub["probability_of_failure"], sub["rating"]]
        for sub in sub_type
    }

    wt = data["wind_turbines"]
    V_t = {w["id"]: [w["x"], w["y"]] for w in wt}

    sub_l = data["substation_locations"]
    V_s = {s["id"]: [s["x"], s["y"]] for s in sub_l}

    cabletype_sub = data["land_substation_cable_types"]
    Q_0 = {
        cbt["id"]: [
            cbt["fixed_cost"],
            cbt["probability_of_failure"],
            cbt["rating"],
            cbt["variable_cost"],
        ]
        for cbt in cabletype_sub
    }

    cabletype_subsub = data["substation_substation_cable_types"]  # never fail
    Q_s = {
        cbts["id"]: [cbts["fixed_cost"], cbts["rating"], cbts["variable_cost"]]
        for cbts in cabletype_subsub
    }

    cabletype_subsub = data["substation_substation_cable_types"]  # never fail
    Q_s = {
        cbts["id"]: [cbts["fixed_cost"], cbts["rating"], cbts["variable_cost"]]
        for cbts in cabletype_subsub
    }

    wind_sen = data["wind_scenarios"]
    omega = {s["id"]: [s["probability"], s["power_generation"]] for s in wind_sen}

    f.close()

    return [[c_0, c_p, c_ft, v_0, c_max, p_max, c_lt], S, V_t, V_s, Q_0, Q_s, omega]


def parse_instance2(file):
    """
    V_t is reformatted as a list of lists -> each sublist represents a line of turbines with the same y coordinate
    V_s is reformatted as a list of lists -> each sublist represents a line of substations with the same y coordinate
    """
    I = parse_instance(file)

    V_t = I[2]
    V_s = I[3]

    V_t2 = []
    V_s2 = []

    y = V_t[1][1]
    l = []
    for t, pos in V_t.items():
        if pos[1] == y:
            l.append({t: pos})
        else:
            V_t2.append(l)
            l = []
            y = pos[1]
            l.append({t: pos})
    V_t2.append(l)

    y = V_s[1][1]
    l = []
    for s, pos in V_s.items():
        if pos[1] == y:
            l.append({s: pos})
        else:
            V_s2.append(l)
            l = []
            y = pos[1]
            l.append({s: pos})
    V_s2.append(l)

    return [I[0], I[1], V_t2, V_s2, I[4], I[5], I[6]]


def find_type(liste_de_couples, i_cherche):
    for i, k in liste_de_couples:
        if i == i_cherche:
            return k
    return None


def save_sol(x, y, z, I, name):
    V_s = I[3]
    V_t = I[2]
    S = I[1]
    Q_0 = I[4]
    Q_s = I[5]
    omega = I[6]

    file_path = "solutions/" + name + ".json"

    data = {}

    data["substations"] = []

    for key, value in x.items():
        if value == 1:
            d_s = {}
            d_s["id"] = key[0]
            d_s["land_cable_type"] = find_type(y[0], key[0])
            d_s["substation_type"] = key[1]
            data["substations"].append(d_s)

    data["substation_substation_cables"] = []

    for c in y[1]:
        d_s = {}
        d_s["substation_id"] = c[0]
        d_s["other_substation_id"] = c[1]
        d_s["cable_type"] = c[3]
        data["substation_substation_cables"].append(d_s)

    data["turbines"] = []

    for key, value in z.items():
        d_t = {}
        d_t["id"] = key[1]
        d_t["substation_id"] = key[0]
        data["turbines"].append(d_t)

    with open(file_path, "w") as json_file:
        json.dump(data, json_file)


# print(parse_instance("tiny.json"))
# print(parse_instance2("tiny.json"))
