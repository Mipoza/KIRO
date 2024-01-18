using JSON
using HiGHS
using JuMP
using Random
using Dates
ENV["GUROBI_HOME"] = "/home/mipoza/Documents/gurobi1100/linux64"
using Gurobi

include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")
include("sixtine_sol.jl")
include("scenario_finder.jl")

I = read_instance("instances/KIRO-large.json")

#sol = read_solution("small-linear.json", I)
#println(cost(sol,I))

model = Model(Gurobi.Optimizer)


function c_positive_part(model, beta, mu, M)
    y = @variable(model, binary = true) 
    @constraint(model,  0 <= y -beta/M <= 1)
    @constraint(model, mu - y*M <= 0)
    @constraint(model, beta - M*(1-y) - mu <= 0)
    @constraint(model, 0 <= beta + M*(1-y) - mu)
end

function c_min(model, alpha, beta, mu, M)
    y = @variable(model, binary = true)
    @constraint(model, mu <= alpha)
    @constraint(model, mu <= beta)
    @constraint(model, alpha - beta + 2*M*(1-y) >= 0)
    @constraint(model, alpha - beta - 2*M*y <= 0)
    @constraint(model, 0 >= alpha - 2*M*y - mu)
    @constraint(model, 0 >= beta - 2*M*(1-y) - mu)
end 

function c_prod(model, alpha, beta, mu, M)
    @constraint(model, mu - alpha*M <= 0)
    @constraint(model, beta - M*(1-alpha) -mu <= 0)
    @constraint(model, mu - beta <= 0 )
end

V_s = get_last_turbine_col_large(I)
S = I.substation_types
V_t = I.wind_turbines
Q_0 = I.land_substation_cable_types
Q_s = I.substation_substation_cable_types
Omega = get_scenario_with_max_power(I, 10)
#Omega = get_uniform_scecario_distribution(I, 30)
c_0 = I.curtailing_cost
c_p = I.curtailing_penalty
c_max = I.maximum_curtailing

set_time_limit_sec(model, 120.0)

@variable(model, x[1:length(V_s), 1:length(S)], Bin)
@variable(model, y_0[1:length(V_s), 1:length(Q_0)], Bin)
@variable(model, y_s[1:length(V_s), 1:length(V_s), 1:length(Q_s)], Bin)
@variable(model, z[1:length(V_s), 1:length(V_t)], Bin)

@variable(model, ln[1:length(V_s)] >= 0)
@variable(model, cnp[1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, cfp1[1:length(V_s), 1:length(Omega)] >= 0)
@variable(model, pf[1:length(V_s), 1:(length(V_s)), 1:length(Omega)] >= 0)
@variable(model, lfv[1:length(V_s), 1:(length(V_s))] >= 0)
@variable(model, cfp2[1:length(V_s), 1:(length(V_s)), 1:length(Omega)] >= 0)
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
#0.5 car y_s symétrique et arrêtes non orientées
cc3 = sum(0.5*y_s[i, j, k] * inter_station_cable_cost(I, V_s[i].id, V_s[j].id, Q_s[k].id) for i in 1:length(V_s), j in 1:length(V_s), k in 1:length(Q_s))
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

#Contraintes

for v in 1:length(V_s)
    c_min(model, sum(S[j].rating*x[v,j] for j in 1:length(S)), sum(Q_0[j].rating*y_0[v,j] for j in 1:length(Q_0)), ln[v], Mnl(I))

    for v_b in 1:length(V_s)
        if v_b != v
            c_min(model, sum(S[s].rating*x[v_b,s] for s in 1:length(S)), sum(Q_0[q].rating*y_0[v_b,q] for q in 1:length(Q_0)), lfv[v,v_b], Mfl(I))
        else
            @constraint(model, lfv[v,v_b] == 0)
        end
    end

    for w in 1:length(Omega)
        c_positive_part(model, Omega[w].power_generation*sum(z[v,t] for t in 1:length(V_t))-ln[v], cnp[v,w], Mnplusw(I, Omega[w]))
        c_positive_part(model, Omega[w].power_generation*sum(z[v,t] for t in 1:length(V_t))-sum(Q_s[q].rating*y_s[v,v_b,q] for v_b in 1:length(V_s), q in 1:length(Q_s)), cfp1[v,w], Mfplus1(I, Omega[w]))
        for v_b in 1:length(V_s)
            if v_b != v
                c_min(model, sum(Q_s[q].rating*y_s[v,v_b,q] for q in 1:length(Q_s)), Omega[w].power_generation*sum(z[v,t] for t in 1:length(V_t)), pf[v,v_b,w], Mfp(I, Omega[w]))
                c_positive_part(model, Omega[w].power_generation*sum(z[v_b,t] for t in 1:length(V_t)) + pf[v,v_b,w] - lfv[v,v_b] , cfp2[v,v_b,w], Mfplus2w(I, Omega[w]))
            else
                @constraint(model, pf[v,v_b,w] == 0)
                @constraint(model, cfp2[v,v_b,w] == 0)
            end
        end
        c_positive_part(model, cfp1[v,w] + sum(cfp2[v,v_b,w] for v_b in 1:length(V_s)) - c_max , cfmax[v,w], Mcfw(I, Omega[w]))

        for s in 1:length(S)
            c_prod(model, x[v,s], cfp1[v,w], muxf1[s,v,w], Mfplus1(I, Omega[w]))
            c_prod(model, x[v,s], sum(cfp2[v,v_b,w] for v_b in 1:length(V_s)), muxf2[s,v,w], length(V_s)*Mfplus2w(I, Omega[w]))
            c_prod(model, x[v,s], cfmax[v,w], muxfmax[s,v,w], Mcfw(I, Omega[w]))
            c_prod(model, x[v,s], sum(cnp[v_b,w] for v_b in 1:length(V_s)), muxn[s,v,w], length(V_s)*Mnplusw(I, Omega[w]))
            c_prod(model, x[v,s], cnmax[w], muxnmax[s,v,w], Mcnw(I, Omega[w]))
        end

        for q in 1:length(Q_0)
            c_prod(model, y_0[v,q], cfp1[v,w], muyf1[q,v,w], Mfplus1(I, Omega[w]))
            c_prod(model, y_0[v,q], sum(cfp2[v,v_b,w] for v_b in 1:length(V_s)), muyf2[q,v,w], length(V_s)*Mfplus2w(I, Omega[w]))
            c_prod(model, y_0[v,q], cfmax[v,w], muyfmax[q,v,w], Mcfw(I, Omega[w]))
            c_prod(model, y_0[v,q], sum(cnp[v_b,w] for v_b in 1:length(V_s)), muyn[q,v,w], length(V_s)*Mnplusw(I, Omega[w]))
            c_prod(model, y_0[v,q], cnmax[w], muynmax[q,v,w], Mcnw(I, Omega[w]))
        end
    end

end

for w in 1:length(Omega)
    c_positive_part(model, sum(cnp[v,w] for v in 1:length(V_s)) - c_max, cnmax[w], Mcnw(I, Omega[w]))
end

for v in 1:length(V_s)
    @constraint(model, sum(x[v,s] for s in 1:length(S)) <= 1)
    @constraint(model, sum(y_0[v,q] for q in 1:length(Q_0))-sum(x[v,s] for s in 1:length(S)) == 0)
    @constraint(model, sum(y_s[v,v_p,q] for q in 1:length(Q_s), v_p in 1:length(V_s)) - sum(x[v,s] for s in 1:length(S)) <=0 )
end

for t in 1:length(V_t)
    @constraint(model, sum(z[v,t] for v in 1:length(V_s)) == 1)
    for v in 1:length(V_s)
        @constraint(model, z[v,t] <= sum(x[v,s] for s in 1:length(S)))
    end
end

for q in 1:length(Q_s)
    for v in 1:length(V_s)
        for v_p in 1:length(V_s)
            if v != v_p
                @constraint(model, y_s[v,v_p,q]- y_s[v_p,v,q]==0)
            else
                @constraint(model, y_s[v,v,q] == 0)
            end
            
        end
    end
end

optimize!(model)

println("*** Values ***")
println(string("Obj : "),objective_value(model))

t_links = zeros(length(V_t))
sub = SubStation[]
sub_cable = zeros(Int,length(I.substation_locations),length(I.substation_locations))

for t in 1:length(V_t)
    for v in 1:length(V_s)
        if value(z[v,t]) > 0
            t_links[t] = V_s[v].id
            break
        end
    end
end

for s in 1:length(S)
    for v in 1:length(V_s)
        if value(x[v,s]) > 0
            for q in 1:length(Q_0)
                if value(y_0[v,q]) > 0
                    push!(sub, SubStation(id=V_s[v].id, substation_type=s, land_cable_type=q))    
                    break 
                end
            end
        end
    end
end

baty_sol = Solution(turbine_links=t_links,inter_station_cables=sub_cable,substations=sub)
print(is_feasible(baty_sol, I))
println(cost(baty_sol, I))
write_solution(baty_sol, "solutions/last-large.json")
write_solution(baty_sol, string("solutions/large", Dates.format(now(), "yyyy-mm-ddTHH:MM:SS"), ".json"))
for v in 1:length(V_s)
    for s in 1:length(S)
        if value(x[v,s]) > 0
            println(V_s[v].id)
        end
    end
end
"""
println(" x ")
println(value(x[1,1]))
println(value(x[1,2]))
println(value(x[2,1]))
println(value(x[2,2]))
println(" z ")
for v in 1:length(V_s)
    for t in 1:length(V_t)
        println("v=",v,",t=",t," : ",value(z[v,t]))
    end
end
println(" y_0 ")
for v in 1:length(V_s)
    for q in 1:length(Q_0)
        println("v=",v,",q=",q," : ",value(y_0[v,q]))
    end
end
println(" y_s ")
for v in 1:length(V_s)
    for v_p in 1:length(V_s)
        for q in 1:length(Q_s)
            println("v=",v,",v'=",v_p,",q=",q," : ",value(y_s[v,v_p,q]))
        end
    end
end
"""