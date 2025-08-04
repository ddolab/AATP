# @info "Entering aATP Module"
#@info "Start time $start_time end time $end_time Fixed_Horizon $Fixed_Horizon"
println("Time: ",T)
println("start ", schedule_start_time, " end ", schedule_end_time)
# println("Order Id:           ",F_OiD)
# println("Product type:       ",O)
# println("Arrival Dates:      ",ae)
# println("Response Dates:     ",al)
# println("Early Due Dates:    ",de)
# println("Lateness Date:      ",dl)
# println("Min order Quantity: ",F_ce)
# println("Max order quantity: ",F_cl)
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
# set_optimizer_attribute(STNSch, MOI.Silent(), true)
# set_optimizer_attribute(STNSch,"OptimalityTol",1e-9)
# set_optimizer_attribute(STNSch,"FeasibilityTol",1e-4)
set_optimizer_attribute(STNSch, "NumericFocus", 3)
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
UT[L,T]>=0      # utitlites required at time point t
Z[K], Bin       # If a order k is accepted or not
C[k in K, t in F_de[k]:F_dl[k]] >= 0     # quantity of order k promised in time t
D[k in K, t in F_de[k]:F_dl[k]], Bin     # delivery timeframe indicator for order k
# CT[K,T], Bin    # Customer is willing to wait for a response
X_SS[i in I,J,T,m=1:τ[i]+1], Bin
B_SS[i in I,J,T,m=1:τ[i]+1] >=0
end)


# assignment from previous run
# for k in eachindex(decision)
#        if(decision[k]>-0.5) # fixed decisions for accepted orders 
#               @constraint(STNSch,Z[k]==decision[k])
#               # println("Fixing decision for order" , OiD[k])
#               if(due_time[k]>0 && OiD[k] in order_Id)
#               #       println("Fixing the due date and quanitites ",OiD[k]," ", due_time[k]," ",decision[k])
#                      @constraint(STNSch,D[k,due_time[k]]==1)
#                      @constraint(STNSch,C[k,due_time[k]]==accepted_quantities[k])
#               end
#        end
# end

# initial value for X and B variables

# for k in K
#        if(OiD[k] in order_Id && decision[k] < 0.5)
#               set_start_value(Z[k],0)
#        else
#               set_start_value(Z[k],1)
#        end
# end

# if(schedule_iter>1)

#        for i in I, j in J, t in schedule_start_time:T[end]-schedule_interval, m in 1:τ[i]+1
#               # Set the start value only for batch size and task assignment varibles
#               set_start_value(X_SS[i, j, t, m], X_SS_initial[i, j, t, m])
#               set_start_value(B_SS[i, j, t, m], B_SS_initial[i, j, t, m])
#        end

# end

if (schedule_iter>1)
       @constraint(STNSch, [i in I, j in J, t = schedule_start_time:schedule_end_time-schedule_interval, m=1:τ[i]+1],X_SS[i,j,t,m] == X_SS_initial[i,j,t,m]) 
       @constraint(STNSch, [i in I, j in J, t = schedule_start_time:schedule_end_time-schedule_interval, m=1:τ[i]+1],B_SS[i,j,t,m] == B_SS_initial[i,j,t,m]) 
       # println(schedule_start_time)
else
       @constraint(STNSch,[i in I, j in J, t=T[1], m=2:τ[i]+1], X_SS[i,j,t,m]==0)
       @constraint(STNSch,[i in I, j in J, t=T[1], m=2:τ[i]+1], B_SS[i,j,t,m]==0)
end

# delivery only once a day

# for t in T
#        if(rem(t-1,24)!=0)
#               @constraint(STNSch,[s in S],RMS[s,t]==0)
#        end
# end
# lifting constraints
# @constraint(STNSch,[i in I, j in J, t in T, m=[1]], X_SS[i,j,t,m]==X[i,j,t])
# @constraint(STNSch,[i in I, j in J, t in T, m=[1]], B_SS[i,j,t,m]==B[i,j,t])


@constraint(STNSch,[i in I, j in J, t in T[2]:T[end], m=2:τ[i]+1], X_SS[i,j,t,m]==X_SS[i,j,t-1,m-1])
@constraint(STNSch,[i in I, j in J, t in T[2]:T[end], m=2:τ[i]+1], B_SS[i,j,t,m]==B_SS[i,j,t-1,m-1])

# lower and upper bound on deliverd quanitites
for k in K
       if (F_OiD[k] in order_Id)
              @constraint(STNSch,Z[k]==0)
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] <= F_cl[k]*D[k,t]) ## ce is maximum order quantites, cl is minimum order quantites
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] >= F_ce[k]*D[k,t])
       else
              # @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] <= round(F_ce[k],digits=3)*D[k,t])
              @constraint(STNSch,[t = F_de[k]:F_dl[k]], C[k,t] <= F_ce[k]*D[k,t])
       end
end
# @constraint(STNSch,[k in K, t = F_de[k]:F_dl[k]], C[k,t] == F_ce[k]*D[k,t])
# @constraint(STNSch,[k in K, t = F_de[k]:F_dl[k]], C[k,t] >= F_ce[k]*0.5*D[k,t])
# order should be deliverd once Only
@constraint(STNSch,[k in K], sum(D[k,t] for t in F_de[k]:F_dl[k]) == Z[k])
# @constraint(STNSch,[k in K], sum(D[k,t] for t in T) <= 1)

# # delivery limitation constraints

# @constraint(STNSch, [k in K, t in T], C[k,t] <= D[k,t]*M)
# @constraint(STNSch, [k in K, t in T], D[k,t] <= C[k,t]*M)

# @constraint(STNSch, [k in K], sum(C[k,t] for t in T) <= Z[k]*M)
# @constraint(STNSch, [k in K], Z[k] <= sum(C[k,t] for t in T)*M)

# Relating sales from STN to ATP

@constraint(STNSch,[t in T, n in N], sum(C[k,t] for k in K if F_O[k]==n && t >= F_de[k] && t <= F_dl[k]) == RMS[n,t])

# Only one batch in one unit for any given time

@constraint(STNSch,[j in J, t in T],sum(X_SS[i,j,t,m] for i in I  for m in 1:τ[i] if I_J[j,i]>=0.1)<=1)  # in terms of lifting variables

# @constraint(STNSch,[j in J, t in T],sum(X[i,j,θ] for i in I for θ in t-τ[i]+1:t if I_J[j,i]>=0.1 && θ>=1)<=1)
# @constraint(STNSch,[j in J, t in T], sum(X[i,j,t] for i in I if(I_J[j,i]<=0.1)) == 0)

# unit capacity Constraint
@constraint(STNSch,[i in I, j in J, t in T, m in 1:τ[i]+1], B_SS[i,j,t,m] <= X_SS[i,j,t,m]*β_max[j]*I_J[j,i])  # in terms of lifting variables
@constraint(STNSch,[i in I, j in J, t in T, m in 1:τ[i]+1], B_SS[i,j,t,m] >= X_SS[i,j,t,m]*β_min[j]*I_J[j,i])  # in terms of lifting variables

# @constraint(STNSch,[i in I, j in J, t in T], B[i,j,t] <= X[i,j,t]*β[j])

# Storage constraint
@constraint(STNSch,[s in S, t in T], Inv[s,t] <= XMT[s])

# Utility required
@constraint(STNSch,[l in L, t in T], UT[l,t] == sum(ϕ[l,i]*X_SS[i,j,t,m] + ψ[l,i]*B_SS[i,j,t,m] for i in I for j in J for m in 1:τ[i] if I_J[j,i]>0.1))  # in terms of lifting variables
# @constraint(STNSch,[l in L, t in T], UT[l,t] == sum(ϕ[l,i]*X[i,j,θ] + ψ[l,i]*B[i,j,θ] for i in I for j in J for θ in t-τ[i]+1:t if I_J[j,i]>0.1 && θ>=1))
# Utility constraint
@constraint(STNSch,[l in L, t in T], UT[l,t] <= XUT[l])

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

# @constraint(STNSch,[s in S, t in 2:T[end]], Inv[s,t] == 
# Inv[s,t-1] - sum(ρ_in[i,s]*B[i,j,t] for i in I for j in J if I_J[j,i]>0.1) - RMS[s,t] +
# sum(ρ_out[i,s]*B[i,j,t-τ_bar[i,s]] for i in I for j in J if I_J[j,i]>=0.1 && (t-τ_bar[i,s]) >=1) + RMP[s,t])


# @constraint(STNSch,[s in S, t=1], Inv[s,t]== -sum(ρ_in[i,s]*B[i,j,t] for i in I for j in J if I_J[j,i]>0.1) - RMS[s,t] +
# sum(ρ_out[i,s]*B[i,j,t-τ_bar[i,s]] for i in I for j in J if I_J[j,i]>=0.1 && (t-τ_bar[i,s]) >=1) + RMP[s,t])



# No buying of intermediates and products
@constraint(STNSch,[s in No_buy, t in T], RMP[s,t]==0)

# No selling of raw material, intermediates 
@constraint(STNSch,[s in No_sell, t in T], RMS[s,t]==0)


# @constraint(STNSch,[i in I, j in J], sum(X[i,j,t] for t in T) <= floor(Planning_horizon/τ[i]))

# 0*sum(Inv[s,H+1]*πInv[s] for s in S)
@objective(STNSch,Max,sum(RMS[s,t]*πS[s] for s in S for t in T if !(s in No_sell))
                     - sum(RMP[s,t]*πP[s] for s in S for t in T if !(s in No_buy))
                     - sum(UT[l,t]*πU[l] for l in L for t in T)
                     - sum(γ[k]*F_ce[k]*(1-Z[k]) for k in K)
                     - sum(γp[k]*(Z[k]*F_cl[k]-sum(C[k,t] for t in F_de[k]:F_dl[k])) for k in K)
                     - sum(λ[s]*Inv[s,t] for s in S for t in T)
        )


optimize!(STNSch)

if termination_status(STNSch) == MOI.INFEASIBLE || termination_status(STNSch) == MOI.INFEASIBLE_OR_UNBOUNDED
       # set_optimizer_attribute(STNSch, "DualReductions", 0)
       @info "CHANGING DEFAULT FEASIBILITY TOLERANCE"
       model = STNSch
       compute_conflict!(model)
# Retrieve all constraints from the model
    constraints = JuMP.all_constraints(model, include_variable_in_set_constraints=true)
    compute_conflict!(model)
    # Retrieve conflict status for constraints
    conflict_status = MOI.get.(model, MOI.ConstraintConflictStatus(), constraints)
    
    # Print constraints with their conflict status as strings
   
    for (con, status) in zip(constraints, conflict_status)
        status_str = string(status)
        if status_str == "IN_CONFLICT"
            println("Constraint $(con) has status: $status_str")
        end
    end
end

# if termination_status(STNSch) == MOI.INFEASIBLE || termination_status(STNSch) == MOI.INFEASIBLE_OR_UNBOUNDED
#        # set_optimizer_attribute(STNSch, "DualReductions", 0)
#        @info "CHANGING DEFAULT FEASIBILITY TOLERANCE"
#        set_optimizer_attribute(STNSch,"FeasibilityTol",1e-2)
#        optimize!(STNSch)
# end


# println("Order decisions")
for k in K
       println("order id ", F_OiD[k], " decision ", value(Z[k]), " quantity ", value(sum(C[k,t] for t in F_de[k]:F_dl[k])), " due date ", value(sum(D[k,t]*t for t in F_de[k]:F_dl[k])))
end
solution_summary(STNSch)

print("\nObjective value: ",objective_value(STNSch),"\n")

# if (start_time+Batching_Interval-1<scheduling_end_time)
#        INV_initial[:] = round.(value.(Inv[:,start_time+Batching_Interval]),digits=8)
# end
# println("Inventory  ", F_INV_initial)

for i in I
    for j in J
       for t in T
              for m in 1:τ[i]+1
                     X_SS_initial[i,j,t,m] = (value.(X_SS[i,j,t,m])) 
                     B_SS_initial[i,j,t,m] = value.(B_SS[i,j,t,m])
                     # if (value.(B_SS[i,j,t,m])  > 0.0001)
                     #        # B_SS_initial[i,j,t,m] = round.(value.(B_SS[i,j,t,m]),digits=3)
                     #        B_SS_initial[i,j,t,m] = value.(B_SS[i,j,t,m])
                     # else
                     #        B_SS_initial[i,j,t,m] = 0.0
                     # end
              end
       end
    end
end


# @info "Exiting aATP Module"