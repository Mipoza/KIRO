using JSON
using HiGHS
using JuMP

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

I = read_instance("instances/KIRO-small.json")

model = Model(HiGHS.Optimizer)

V_s = I.substation_locations
S = I.substation_types
V_t = I.wind_turbines
Q_0 = I.land_substation_cable_types
Q_s = I.substation_substation_cable_types
Omega = I.wind_scenarios

@variable(model, x[1:length(V_s),1:length(S)], Bin)
@variable(model, y_0[1:length(V_s),1:length(Q_0)], Bin)
@variable(model, y_s[1:length(V_s),1:length(V_s),1:length(Q_s)], Bin)
@variable(model, z[1:length(V_s),1:length(V_t)], Bin)

@variable(model, ln[1:length(V_s)] >= 0)
@variable(model, cnp[1:length(V_s),1:length(Omega)] >= 0)
@variable(model, cfp1[1:length(V_s),1:length(Omega)] >= 0)
@variable(model, pf[1:length(V_s),1:(length(V_s)-1),1:length(Omega)] >=0)
@variable(model, lfv[1:length(V_s),1:(length(V_s)-1)] >= 0)
@variable(model, cfp2[1:length(V_s),1:(length(V_s)-1),1:length(Omega)] >=0)