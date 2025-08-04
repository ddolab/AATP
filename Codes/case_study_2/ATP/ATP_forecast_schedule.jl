@info "\n\n Scheduling Model"

F_OiD = []
F_O = []
F_ce = Float64[]
F_cl = Float64[]
F_de = []
F_dl = []
F_ae = []
F_al = []
F_prt = []
F_decision = []
F_due_time = Int[]
F_accepted_quantities = []

if(schedule_iter>1)
    for s in S
    # F_INV_initial[s] = trunc.(value.(Inv[s,schedule_start_time]),digits=1)
    F_INV_initial[s] = value.(Inv[s,schedule_start_time])
    end
end

for idx in eachindex(FQ_ID)
    if (!(FQ_ID[idx] in F_OiD) && (FQ[idx] > 0.0) && FQ_DE[idx] > schedule_start_time && FQ_DE[idx] <= schedule_end_time)
        # println("Entering forecasted order ",FQ_ID[idx], " qty ", FQ[idx], " date ", FQ_DE[idx])
        push!(F_OiD,FQ_ID[idx])
        push!(F_O,FQ_P[idx])
        push!(F_ce,trunc(FQ[idx],digits=1))
        push!(F_cl,trunc(FQ[idx],digits=1))
        push!(F_de,FQ_DE[idx])
        push!(F_dl,FQ_DL[idx])
        push!(F_ae,start_time)
        push!(F_al,FQ_DL[idx])
        push!(F_prt,0.75)
        push!(F_decision,1)               # All the forecasted demands will be accepted if decision is 1
        push!(F_due_time,FQ_DE[idx])      # forecasted demands delivery will be schedule on its forecasted due time 
        push!(F_accepted_quantities,FQ[idx])
    end
end
global T = schedule_start_time:schedule_end_time


include("ATP_forecast_ss.jl")
# include("ATP_cost_data_forecast.jl")
# include("ATP_extract_data_forecast.jl")




# println("Start_time:  ", start_time)
# for s in S
#     INV_initial[s] = round.(value.(Inv[s,start_time]),digits=8) + sum(value(C[k, F_de[k]]) for k in K if F_OiD[k] > 1000 && F_O[k] == s && F_de[k] <= start_time; init=0.0)
# end


indicies = 1:length(F_OiD)
deleteat!(F_OiD,indicies)
deleteat!(F_O,indicies)
deleteat!(F_ae,indicies)
deleteat!(F_al,indicies)
deleteat!(F_prt,indicies)
deleteat!(F_ce,indicies)
deleteat!(F_cl,indicies)
deleteat!(F_de,indicies)
deleteat!(F_dl,indicies)
deleteat!(F_due_time,indicies) 
deleteat!(F_decision,indicies) 
deleteat!(F_accepted_quantities,indicies) 

schedule_start_time += schedule_interval
schedule_end_time = min(schedule_end_time + schedule_interval, scheduling_end_time)
schedule_iter += 1
@info "Scheduling model ends here\n\n"