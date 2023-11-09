import json

#parameter of an instance

Q_0 = {}
Q_s = {}


def parse_instance(file):
    f = open('instances/'+file)
    data = json.load(f)

    gen_p = data['general_parameters']

    c_0 = gen_p['curtailing_cost']
    c_p = gen_p['curtailing_penalty']
    c_ft = gen_p['fixed_cost_cable']
    v_0 = [gen_p['main_land_station']['x'],gen_p['main_land_station']['y']]
    c_max = gen_p['maximum_curtailing']
    p_max = gen_p['maximum_power']
    c_lt = gen_p['variable_cost_cable']
    
    sub_type = data['substation_types']
    S = {sub['id']: [sub['cost'], sub['probability_of_failure'], sub['rating']] for sub in sub_type}

    wt = data['wind_turbines']
    V_t = {w['id']: [w['x'],w['y']] for w in wt}

    sub_l = data['substation_locations']
    V_s = {s['id']: [s['x'],s['y']] for s in sub_l}

    cabletype_sub = data['land_substation_cable_types']
    Q_0 = {cbt['id']: [cbt['fixed_cost'], cbt['probability_of_failure'], cbt['rating'], cbt['variable_cost']] for cbt in cabletype_sub}

    cabletype_subsub = data['substation_substation_cable_types'] #never fail
    Q_s = {cbts['id']: [cbts['fixed_cost'], cbts['rating'], cbts['variable_cost']] for cbts in cabletype_subsub}
    
    f.close()

    return [[c_0,c_p,c_ft,v_0,c_max,p_max,c_lt],S,V_t,V_s,Q_0,Q_s]

def parse_sol(file):
    pass

print(parse_instance('toy.json'))