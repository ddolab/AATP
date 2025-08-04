# @info "Entering schedule Module"
#@info "Start time $start_time end time $end_time Fixed_Horizon $Fixed_Horizon"
 println("Time: ",T)

# println("Order Id:           ",OiD)
# println("Product type:       ",O)
# println("Arrival Dates:      ",ae)
# println("Response Dates:     ",al)
# println("Early Due Dates:    ",de)
# println("Lateness Date:      ",dl)
# println("Min order Quantity: ",ce)
# println("Max order quantity: ",cl)
# println("decisions:          ",decision)
# println("due date:           ",due_time)
# println("start end time:     ",start_time, " ", end_time)
# Big-M for modelling
# M = 1000;

K = 1:length(F_O) # number of orders
# K = 1:4
# O = [6 9 6 9]
# order denial penality
println("Forecast Inventory: ", F_INV_initial)

γ = zeros(maximum(K)) # denial penalty
γp = zeros(maximum(K)) # partial rejection penaltyF
# γd = zeros(maximum(K)) # partial rejection penalty
for k in K
       γ[k] = πS[F_O[k]]*F_prt[k]
       γp[k] = γ[k]*0.75
end


# Initialize JuMP model
STNSch = Model(optimizer_with_attributes(Gurobi.Optimizer,"Threads"=>32))

# STNSch = Model(optimizer_with_attributes(Gurobi.Optimizer))
set_optimizer_attribute(STNSch, MOI.Silent(), true)
# set_optimizer_attribute(STNSch,"OptimalityTol",1e-9)
#  set_optimizer_attribute(STNSch,"FeasibilityTol",1e-2)
# set_optimizer_attribute(STNSch, "NumericFocus", 3)
# set_optimizer_attribute(STNSch, "MIPFocus", 1)
# set_optimizer_attribute(STNSch, "IntFeasTol", 1e-9)
set_time_limit_sec(STNSch, 3600.0)
set_optimizer_attribute(STNSch, "MIPGap", 0.01)  # 1% optimality gap

@variables(STNSch,begin
# X[I,J,T], Bin   # if a batch j of task i is started at time t
# B[I,J,T] >= 0   # Amount of material in task i of unit j at time t
Inv[S,T] >=0    # inventory of material K at time point t
RMP[S,T] >=0    # amount purchased
RMS[S,T] >=0    # amount Sales
# UT[L,T]>=0      # utitlites required at time point t
Z[K], Bin       # If a order k is accepted or not
C[k in K, t in F_de[k]:F_dl[k]] >= 0     # quantity of order k promised in time t
D[k in K, t in F_de[k]:F_dl[k]], Bin     # delivery timeframe indicator for order k
# CT[K,T], Bin    # Customer is willing to wait for a response
X_SS[i in I,J,T,m=1:τ[i]+1], Bin
B_SS[i in I,J,T,m=1:τ[i]+1] >=0
end)

if(schedule_iter>1)

       for i in I, j in J, t in schedule_start_time:T[end]-schedule_interval, m in 1:τ[i]+1
              # Set the start value only for batch size and task assignment varibles
              set_start_value(X_SS[i, j, t, m], X_SS_initial[i, j, t, m])
              set_start_value(B_SS[i, j, t, m], B_SS_initial[i, j, t, m])
       end

end

if (schedule_iter>1)
       @constraint(STNSch, [i in I, j in J, t = schedule_start_time:schedule_end_time-schedule_interval, m=1:τ[i]+1],X_SS[i,j,t,m] == X_SS_initial[i,j,t,m]) 
       @constraint(STNSch, [i in I, j in J, t = schedule_start_time:schedule_end_time-schedule_interval, m=1:τ[i]+1],B_SS[i,j,t,m] == B_SS_initial[i,j,t,m]) 
       # println(schedule_start_time)
else
       @constraint(STNSch,[i in I, j in J, t=T[1], m=2:τ[i]+1], X_SS[i,j,t,m]==0)
       @constraint(STNSch,[i in I, j in J, t=T[1], m=2:τ[i]+1], B_SS[i,j,t,m]==0)
end


@constraint(STNSch,[i in I, j in J, t in T[2]:T[end], m=2:τ[i]+1], X_SS[i,j,t,m]==X_SS[i,j,t-1,m-1])
@constraint(STNSch,[i in I, j in J, t in T[2]:T[end], m=2:τ[i]+1], B_SS[i,j,t,m]==B_SS[i,j,t-1,m-1])

# lower and upper bound on deliverd quanitites
for k in K
       
       if (F_OiD[k] in order_Id)
              @constraint(STNSch,Z[k]==0)
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] <= F_cl[k]*D[k,t]) ## ce is maximum order quantites, cl is minimum order quantites
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] >= F_ce[k]*D[k,t])
       else
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] <= round(F_ce[k],digits=3)*D[k,t])
       end
end

# order should be deliverd once Only
@constraint(STNSch,[k in K], sum(D[k,t] for t in F_de[k]:F_dl[k]) == Z[k])


# Relating sales from STN to ATP

@constraint(STNSch,[t in T, n in N], sum(C[k,t] for k in K if F_O[k]==n && t >= F_de[k] && t <= F_dl[k]) == RMS[n,t])

# Only one batch in one unit for any given time

@constraint(STNSch,[j in J, t in T],sum(X_SS[i,j,t,m] for i in I  for m in 1:τ[i] if I_J[j,i]>=0.1)<=1)  # in terms of lifting variables


# unit capacity Constraint
@constraint(STNSch,[i in I, j in J, t in T, m in 1:τ[i]+1], B_SS[i,j,t,m] <= X_SS[i,j,t,m]*β_max[j]*I_J[j,i])  # in terms of lifting variables
@constraint(STNSch,[i in I, j in J, t in T, m in 1:τ[i]+1], B_SS[i,j,t,m] >= X_SS[i,j,t,m]*β_min[j]*I_J[j,i])  # in terms of lifting variables


# Storage constraint
@constraint(STNSch,[s in S, t in T], Inv[s,t] <= XMT[s])

# Utility required
# @constraint(STNSch,[l in L, t in T], UT[l,t] == sum(ϕ[l,i]*X_SS[i,j,t,m] + ψ[l,i]*B_SS[i,j,t,m] for i in I for j in J for m in 1:τ[i] if I_J[j,i]>0.1))  # in terms of lifting variables
# @constraint(STNSch,[l in L, t in T], UT[l,t] == sum(ϕ[l,i]*X[i,j,θ] + ψ[l,i]*B[i,j,θ] for i in I for j in J for θ in t-τ[i]+1:t if I_J[j,i]>0.1 && θ>=1))
# Utility constraint
# @constraint(STNSch,[l in L, t in T], UT[l,t] <= XUT[l])

# Mass balance
@constraint(STNSch,[s in S, t in T[2]:T[end]], Inv[s,t] == 
Inv[s,t-1] - sum(ρ_in[i,s]*B_SS[i,j,t,1] for i in I for j in J if I_J[j,i]>0.1) - RMS[s,t] +
sum(ρ_out[i,s]*B_SS[i,j,t,τ_bar[i,s]+1] for i in I for j in J if I_J[j,i]>=0.1) + RMP[s,t])

if (schedule_iter ==1)
       @constraint(STNSch,[s in S, t=[T[1]]], Inv[s,t]== F_INV_initial[s]-sum(ρ_in[i,s]*B_SS[i,j,t,1] for i in I for j in J if I_J[j,i]>0.1) - RMS[s,t] +
       sum(ρ_out[i,s]*B_SS[i,j,t,τ_bar[i,s]+1] for i in I for j in J if I_J[j,i]>=0.1) + RMP[s,t])
else
       @constraint(STNSch,[s in S, t=[T[1]]], Inv[s,t]== F_INV_initial[s]- RMS[s,t] + RMP[s,t]) 
end


# No buying of intermediates and products
@constraint(STNSch,[s in No_buy, t in T], RMP[s,t]==0)

# No selling of raw material, intermediates 
@constraint(STNSch,[s in No_sell, t in T], RMS[s,t]==0)


@objective(STNSch,Max,sum(RMS[s,t]*πS[s] for s in S for t in T if !(s in No_sell))
                     - sum(RMP[s,t]*πP[s] for s in S for t in T if !(s in No_buy))
                     - sum(γ[k]*F_ce[k]*(1-Z[k]) for k in K)
                     - sum(γp[k]*(Z[k]*F_cl[k]-sum(C[k,t] for t in F_de[k]:F_dl[k])) for k in K)
                     - sum(λ[s]*Inv[s,t] for s in S for t in T)
                     - sum(X_SS[i,j,t,1]*πF[i] + B_SS[i,j,t,1]*πV[i] for i in I for j in J for t in T if I_J[j,i]>0.1)
         )


optimize!(STNSch)

solution_summary(STNSch)

print("\nObjective value: ",objective_value(STNSch),"\n")

for i in I
    for j in J
       for t in T
              for m in 1:τ[i]+1
                     X_SS_initial[i,j,t,m] = (value.(X_SS[i,j,t,m])) > 0.5 ? 1 : 0
                     if (value.(B_SS[i,j,t,m])  > 0.5)
                            B_SS_initial[i,j,t,m] = round.(value.(B_SS[i,j,t,m]),digits=3)
                     else
                            B_SS_initial[i,j,t,m] = 0.0
                     end
              end
       end
    end
end


# @info "Exiting schedule Module"