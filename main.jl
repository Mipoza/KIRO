using JSON
using HiGHS
using JuMP

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")


I = read_instance("instances/KIRO-small.json")

model = Model(HiGHS.Optimizer)

V_s = I.substation_locations
S = I.substation_types
V_t = I.wind_turbines
Q_0 = I.land_substation_cable_types
Q_s = I.substation_substation_cable_types
Omega = I.wind_scenarios
c_0 = I.curtailing_cost
c_p = I.curtailing_penalty

@variable(model, x[1:length(V_s), 1:length(S)], Bin)
@variable(model, y_0[1:length(V_s), 1:length(Q_0)], Bin)
@variable(model, y_s[1:length(V_s), 1:length(V_s), 1:length(Q_s)], Bin)
@variable(model, z[1:length(V_s), 1:length(V_t)], Bin)

@variable(model, ln[1:length(V_s)] >= 0)
@variable(model, cnp[1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, cfp1[1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, pf[1:length(V_s), 1:(length(V_s)-1), 1:length(Omega)] >= 0)
@variable(model, lfv[1:length(V_s), 1:(length(V_s)-1)] >= 0)
@variable(model, cfp2[1:length(V_s), 1:(length(V_s)-1), 1:length(Omega)] >= 0)
@variable(model, cfmax[1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, cnmax[1:length(Omega)] >= 0)

@variable(model, muxf1[1:length(S), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muxf2[1:length(S), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muyf1[1:length(Q_0), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muyf2[1:length(Q_0), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muxfmax[1:length(S), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muyfmax[1:length(Q_0), 1:length(V_s), 1:length(Omega)] >= 0)

@variable(model, muxn[1:length(S), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muyn[1:length(Q_0), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muxnmax[1:length(S), 1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, muynmax[1:length(Q_0), 1:length(V_s), 1:length(Omega)] >= 0)

cc1 = sum(x[i, j] * S[j].cost for i in 1:length(V_s), j in 1:length(S))
cc2 = sum(y_0[i, j] * land_cable_cost(I, V_s[i].id, Q_0[j].id) for i in 1:length(V_s), j in 1:length(Q_0))
cc3 = sum(y_s[i, j, k] * inter_station_cable_cost(I, V_s[i].id, V_s[j].id, Q_s[k].id) for i in 1:length(V_s), j in 1:length(V_s), k in 1:length(Q_s))
cc4 = sum(z[i, j] * turbine_cable_cost(I, V_s[i].id, V_t[j].id) for i in 1:length(V_s), j in 1:length(V_t))

function cf_wv(w, v)
    sum_xcf1 = sum(c_0 * S[s].probability_of_failure * muxf1[s, v, w] for s in 1:length(S))
    sum_xcf2 = sum(c_0 * S[s].probability_of_failure * muxf2[s, v, w] for s in 1:length(S))

    sum_ycf1 = sum(c_0 * Q_0[q].probability_of_failure * muyf1[q, v, w] for q in 1:length(Q_0))
    sum_ycf2 = sum(c_0 * Q_0[q].probability_of_failure * muyf2[q, v, w] for q in 1:length(Q_0))

    sum_xmaxf = sum(c_p * S[s].probability_of_failure * muxfmax[s, v, w] for s in 1:length(S))
    sum_ymaxf = sum(c_p * Q_0[q].probability_of_failure * muyfmax[q, v, w] for q in 1:length(Q_0))

    sum_xcn = -sum(c_0 * S[s].probability_of_failure * muxn[s, v, w] for s in 1:length(S))
    sum_ycn = -sum(c_0 * Q_0[q].probability_of_failure * muyn[q, v, w] for q in 1:length(Q_0))

    sum_xmaxn = -sum(c_p * S[s].probability_of_failure * muxnmax[s, v, w] for s in 1:length(S))
    sum_ymaxn = -sum(c_p * Q_0[q].probability_of_failure * muynmax[q, v, w] for q in 1:length(Q_0))



    return sum_xcf1 + sum_xcf2 + sum_ycf1 + sum_ycf2 + sum_xmaxf + sum_ymaxf + sum_xcn + sum_ycn + sum_xmaxn + sum_ymaxn
end

function cf_sumv(w)
    return sum(cf_wv(w, v) for v in 1:length(V_s))
end

@objective(model, Min, cc1 + cc2 + cc3 + cc4 + sum( Omega[w].probability*(cf_sumv(w)+ sum(c_0*cnp[i,w] for i in 1:length(V_s)) + c_p*cnmax[w]) for w in 1:length(Omega))) #no problem avec les id scenario et w

#CELA EST TERRIFIANT 
