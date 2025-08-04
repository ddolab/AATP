using JuMP, Gurobi, Random, Logging, XLSX, Plots
include("ATP_production_parameters.jl")
include("ATP_demand_forecast.jl")

scenario = 1
Batching_Interval = 4
Fixed_Horizons = Batching_Interval+1
include("ATP_initilaization.jl")
include("ATP_Demand.jl")


last_itr = 10
for itr = 1:last_itr
    @info "Scheduling window is $start_time:$end_time"
    global iter = itr
    global T = start_time:end_time

    include("ATP_collect_orders.jl")

    if(length(O)>0)
        include("ATP_SS_online.jl")
        include("ATP_create_plots.jl")
        include("ATP_extract_data.jl")
        include("ATP_cost_data.jl")
        include("ATP_plots.jl")
    else
        println("No orders in the Time Interval", T)   
    end

        # remove the forcasted order_Id
        indicies= findall(id->id>1000,OiD)
        if(length(indicies)>0)
            for k in indicies
                # println("Modifying inventory ", OiD[k]," ",ce[k]," ",sum(value(D[k,t])*t for t in T)," ", T," " ,INV_initial[O[k]])
                if(value(Z[k])==1 && sum(value(D[k,t])*t for t in T)<start_time+Batching_Interval)
                    INV_initial[O[k]] += ce[k] 
                    println("Modifying inventory ", OiD[k]," ",ce[k]," ", INV_initial[O[k]])
                    delete_at_indices!([OiD,O,ae,al,ce,cl,de,dl],k)
                    deleteat!(due_time,k) 
                    deleteat!(decision,k) 
                end
            end    
        end

    # orders which are accepted and have Assigned due date in the Fixed_Horizon , fix the decision and due date for these
    indicies = findall(k -> sum(value(D[k,t])*t for t in T) < start_time + Fixed_Horizons &&  value.(Z[k]) == 1, 1:length(al))
    # println(start_time, " ", OiD," ",indicies)
    if (length(indicies)>0)
        for k in indicies
            decision[k] = 1
            due_time[k] = sum(value(D[k,t])*t for t in T)
            # println(OiD[k], " ",due_time[k], " ",start_time, " ", start_time+Fixed_Horizons," ",Fixed_Horizons)
        end
    end

    # orders which are accepted fix the decision for these
    indicies = findall(k -> value.(Z[k]) == 1, 1:length(al))
    # println(indicies)
    if (length(indicies)>0)
        for k in indicies
            decision[k] = 1
        end
    end
   
    global start_time = start_time + Batching_Interval

    indicies = findall(k -> sum(value(D[k,t])*t for t in T) < start_time &&  value.(Z[k]) == 1, 1:length(al))
  
    if (length(indicies)>0)
        delete_at_indices!([OiD,O,ae,al,ce,cl,de,dl],indicies)
        deleteat!(due_time,indicies) 
        deleteat!(decision,indicies) 
    end
   
    # Remove the orders which have latest due date before the next start time
    indicies = findall(k -> dl[k] < start_time , 1:length(dl))

    if(length(indicies)>0) 
        delete_at_indices!([OiD,O,ae,al,ce,cl,de,dl],indicies)
        deleteat!(due_time,indicies) 
        deleteat!(decision,indicies) 
    end
    

    if(iter>1)
        global Fixed_Horizon = Fixed_Horizon + Batching_Interval
    end
   
    global end_time = end_time + Batching_Interval
end

