import json

# parameter of an instance

Q_0 = {}
Q_s = {}

file = "instances/toy.json"


def parse_instance(file):
    """
    Parse the input file and return a list of parameters and data structures needed for the optimization problem.

    :param file: The path to the input file.
    :type file: str
    :return: A list containing the following elements:
        - A list of general parameters, including curtailing cost, curtailing penalty, fixed cost of cable, coordinates of the main land station, maximum curtailing, maximum power, and variable cost of cable.
        - A dictionary of substation types, where each key is a substation ID and each value is a list containing the cost, probability of failure, and rating of the substation.
        - A dictionary of wind turbines, where each key is a wind turbine ID and each value is a list containing the x and y coordinates of the wind turbine.
        - A dictionary of substation locations, where each key is a substation ID and each value is a list containing the x and y coordinates of the substation.
        - A dictionary of cable types for land substations, where each key is a cable type ID and each value is a list containing the fixed cost, probability of failure, rating, and variable cost of the cable.
        - A dictionary of cable types for substation-substation connections, where each key is a cable type ID and each value is a list containing the fixed cost, rating, and variable cost of the cable.
    :rtype: list
    """
    f = open(file)
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

    f.close()

    return [[c_0, c_p, c_ft, v_0, c_max, p_max, c_lt], S, V_t, V_s, Q_0, Q_s]


def parse_sol(file):
    pass


print(parse_instance(file))
