import json
from collections import defaultdict
from math import sqrt

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
    
    wind_sen = data['wind_scenarios']
    omega = {s['id']: [s['probability'], s['power_generation']] for s in wind_sen}

    f.close()

    return [[c_0,c_p,c_ft,v_0,c_max,p_max,c_lt],S,V_t,V_s,Q_0,Q_s,omega]


def length(v_s,v_t):
    return sqrt((v_s['x']-v_t['x'])**2 +  (v_s['y']-v_t['y'])**2 )

def const_cost(x,y,z,I):
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
            c += x[(i,j)]*S[j][0]

    for i in V_s:
        for j in V_t:
            if z[(i,j)]:
                c += z[(i,j)]*(p_gen[2]+p_gen[6]*length(V_s[i],V_t[j]))

    #y[0] = [[i,j],...]
    y = [[],[]]
    for h in y[0]:
        c += Q_0[h[1]][0] + Q_0[h[1]][3] 

def op_cost(x,y,z,I):
    pass

def total_cost(x,y,z,I):
    return total_cost(x,y,z,I)

print(parse_instance('tiny.json'))