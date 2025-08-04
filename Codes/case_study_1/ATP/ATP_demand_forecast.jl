include("ATP_production_parameters.jl")

days = 42
Random.seed!(24)

############################# Forecast demands start here #######################################
FQ_Total_orders = days
FQ_P1_Total_orders = days
FQ_P2_Total_orders = 0
FQ_ID = (1101:2000)[1:FQ_Total_orders]
FQ_P = shuffle!(vcat(fill(4,FQ_P1_Total_orders),fill(9,FQ_P2_Total_orders)))
FQ_Demand = []
FQ_Demand_scenario = 1
for i in 1:FQ_Demand_scenario
    demand = []
    for j in 1:FQ_Total_orders
        # push!(demand, FQ_P[j]==6 ? rand(20:100) : rand(20:150))
        push!(demand,400)
    end
    push!(FQ_Demand,demand)
end

FQ = round.(sum(FQ_Demand)./FQ_Demand_scenario,digits=3)

# FQ_DE = sort(shuffle!(collect(8:24*days+1))[1:FQ_Total_orders])
global DE_4 = 25
# global DE_9 = 25

FQ_DE = []

for i in 1:FQ_Total_orders

    # if (FQ_P[i]==6)
        push!(FQ_DE,DE_4)
        global DE_4 += 24
    # else
    #     push!(FQ_DE,DE_9)
    #     global DE_9 += 24
    # end
end


# FQ_DE = sort(shuffle!(collect(8:24*days+1))[1:FQ_Total_orders])
FQ_DL = FQ_DE
FQ_order_decision = zeros(length(FQ))
FQ_order_missed = zeros(length(FQ))
FQ_qty = copy(FQ)
FQ_Order_promised_quantites = zeros(FQ_Total_orders)
FQ_order_assigned_due_time = zeros(FQ_Total_orders)
############################# Forecast demands ends here #######################################


################## Actual orders starts here #########################################################

Random.seed!(26)
First_arrival_time = -47
Last_arrival_time = 24*(days-12)
Total_orders = 150
P1_Total_orders = 150
P2_Total_orders = 0
order_Id = collect(1:999)[1:Total_orders]
Arrival_Time = sort(rand(First_arrival_time:Last_arrival_time,Total_orders))
Product_Type = shuffle!(vcat(fill(4,P1_Total_orders),fill(9,P2_Total_orders)))
Order_priority_p1 = shuffle!(vcat(fill(2,Int(P1_Total_orders/2)),fill(1,Int(P1_Total_orders*1/2))))
# Order_priority_p2 = shuffle!(vcat(fill(2,Int(P2_Total_orders/2)),fill(1.5,Int(P2_Total_orders*1/2))))
#### Generate Earliest and Latest due time Ensuring they lies in the planning horizon ###
Order_priority = Order_priority_p1
# p1_index = 1
# p2_index = 1

# for i in Product_Type
#     if(i==4)
#         push!(Order_priority,Order_priority_p1[p1_index])
#         global p1_index+=1
#     else
#         push!(Order_priority,Order_priority_p2[p2_index])
#         global p2_index+=1
#     end
# end

Response_Time = []
Earliest_Due_Time = []
Latest_Due_Time = []
Min_Order_Quantity = []
Max_Order_Quantity = []

Order_batch_interval = 12
Order_Planning_Horizon = 24*13
order_start_time = First_arrival_time
order_end_time = order_start_time + Order_batch_interval


while order_end_time <= Last_arrival_time + Order_batch_interval
    global indicies = findall(order_time -> order_time >= order_start_time && order_time < order_end_time,Arrival_Time)
    for idx in indicies
        EDT = min(rand(Arrival_Time[idx]+72:Arrival_Time[idx]+Order_Planning_Horizon),24*days+1)
        LDT = min(rand(EDT:Arrival_Time[idx]+Order_Planning_Horizon),24*days+1)
        RT  = min(rand(Arrival_Time[idx]+48:EDT-24),24*days+1)
        mnq = rand(20:300)
        push!(Earliest_Due_Time,EDT)
        push!(Latest_Due_Time,LDT)
        push!(Response_Time,RT)
        push!(Min_Order_Quantity,floor(mnq*rand(5:10)/10))
        push!(Max_Order_Quantity,mnq)
    end
    global order_start_time += Order_batch_interval
    global order_end_time += Order_batch_interval
    if(length(Earliest_Due_Time)==Total_orders)
        break
    end
end


######## update the forecast as exactly same as the actual total demand
FQ = FQ .* 0
cummulative_demand = FQ.*0
Random.seed!(24+case_scenario)
for i in eachindex(order_Id)
    global idx = rand(((Earliest_Due_Time[i] - 1)÷ 24):((Latest_Due_Time[i] -1) ÷ 24))
    # println(order_Id[i], " qty ",Max_Order_Quantity[i] , "early due ", Earliest_Due_Time[i],"late due ",Latest_Due_Time[i] , " going in ", idx)
    FQ[idx] += Min_Order_Quantity[i]*rand(80:120)/100   
    cummulative_demand[((Latest_Due_Time[i] -1) ÷ 24)] += Max_Order_Quantity[i] 
end


order_decision = zeros(Total_orders)
Assign_due_time_prev = zeros(Total_orders)
Assign_due_time_new = zeros(Total_orders)
Order_Reschedule = zeros(Total_orders)
Order_promised_quantites = zeros(Total_orders)
order_assigned_due_time = zeros(Total_orders)
order_missed = zeros(Total_orders)

scenario = case_scenario
Batching_Interval = case_batching_interval
Fixed_Horizon = 1 # because indicies starts from 1 
Planning_horizon = 24*14
P = plot(xlabel="due_date", ylabel="Amt.", xticks=0:2:24*days)
# plot!(P,FQ_DE./24,FQ,seriestype=:bar,label="Forecast")
# plot!(FQ_DE./24 ,cummulative_demand,seriestype=:bar,label="Demand")
groupedbar(FQ_DE./24 ,[cummulative_demand FQ], label=["Demand" "Forecast"])
savefig("Demand_scenaio-$scenario.png")



OiD = []
O = []
ce = Float64[]
cl = Float64[]
de = []
dl = []
ae = []
al = []
prt = []
decision = []
due_time = Int[]
accepted_quantities = []
# println(Min_Order_Quantity)

if !isdir("Data")
    mkpath("Data")
end
if !isdir("BI-$Batching_Interval")
    mkpath("BI-$Batching_Interval")
    mkpath("BI-$Batching_Interval/Schedule")
end



scheduling_end_time = 24*days+1
global start_time = 1
global end_time = 24*(42+14)+1


INV_initial = zeros(length(S))
F_INV_initial = zeros(length(S))
B_SS_initial = zeros(length(I),length(J),end_time,maximum(τ)+1)
X_SS_initial = zeros(length(I),length(J),end_time,maximum(τ)+1)

global schedule_start_time = 1
global schedule_end_time = 24*21+1
schedule_interval = 24*7
schedule_iter = 1
schedule_prev_rows = 1
flag = 1
# include("ATP_forecast_schedule.jl")
global start_time = 1
global end_time = Planning_horizon + 1

last_itr = 100
prev_rows = 1
for itr = 1:last_itr
    global T = start_time:end_time
    global iter = itr
    # println("Interval ",start_time, " ", end_time)
    println("BI = ", Batching_Interval, " Scenario = ", scenario," iter = ",itr)

    ##################### Add forecast demand order to the order list OiD to be feed in the model #####################
    # global indicies = findall(forecast_due_time  -> (forecast_due_time > start_time && forecast_due_time <= end_time),FQ_DE)
    # #println("Forecast Orders in iteration $iter ",FQ_ID[indicies])

    # for idx in indicies

    if (start_time>=schedule_start_time && schedule_start_time +24*21<=schedule_end_time)
        include("ATP_forecast_schedule.jl")
    end
    global T = start_time:end_time


    if(iter==1)
        global indicies = findall(arrival_time -> ( arrival_time <= 1),Arrival_Time)
      
    else
        global indicies = findall(arrival_time -> (arrival_time > Batching_Interval*(iter-2)+1 &&  arrival_time <= Batching_Interval*(iter-1)+1),Arrival_Time)
    end

    #=
    ##################### Add actual demand orders to the order list #####################

  
    println("Forecast neeting uniform")
    total_demand = 0
    for idx in indicies
        # if(!(order_Id[idx] in OiD))
        total_demand += Max_Order_Quantity[idx]
        println("Demand ", total_demand, " order ", idx, " ",  order_Id[idx], " quantity ",Max_Order_Quantity[idx])
        # end
    end

    total_forecast_demand = 0

    for idx in eachindex(OiD)
        if(OiD[idx] > 1100)
            total_forecast_demand += ce[idx]
            println("Forecast ", total_forecast_demand, " order ", OiD[idx], " quantity  ", ce[idx])
        end
    end

    println(total_demand, " ", total_forecast_demand)
    
    forecast_demand = 0
    if (total_demand < total_forecast_demand)
        forecast_demand = round((total_forecast_demand - total_demand)/14,digits=0)
    end
    
    println("forecast demand ", forecast_demand )

    for idx in eachindex(OiD)
        if(OiD[idx] > 1100)
            ce[idx] = forecast_demand
            cl[idx] = forecast_demand

            for id in eachindex(FQ_ID)
                if(OiD[idx]==FQ_ID[id])
                    FQ[id] = forecast_demand
                end     
            end
        end
    end
    =#
    ##################### Forecast Netting #####################
    for idx in indicies

        if(Response_Time[idx] >= start_time && Latest_Due_Time[idx] >= start_time) # Add only those orders whose response time is not passed

            # println("Order Id: ",order_Id[idx], " min: ",  Min_Order_Quantity[idx], "Max: ",  Max_Order_Quantity[idx])
            # ## find all the overlapping forecast demand delivery time with the actual order
            # # netted_indicies = findall(forecast_due_time  -> (forecast_due_time >= Earliest_Due_Time[idx] && forecast_due_time <= Latest_Due_Time[idx]),FQ_DE)
            # netted_indicies = sort(findall(forecast_due_time  -> (forecast_due_time <= Latest_Due_Time[idx]),FQ_DE),rev=true)
            # println("Netting Ids ", FQ_ID[netted_indicies])
            # global netted_qty = Max_Order_Quantity[idx]
            # for net_idx in netted_indicies
            #     if (FQ_ID[net_idx] in OiD && FQ_P[net_idx] == Product_Type[idx] && FQ[net_idx] > 0)
            #         global index = findfirst(id -> id == FQ_ID[net_idx], OiD)
            #         println("index in the order list ",index, " forecast: ", ce[index]," Actual: ",Min_Order_Quantity[idx], " Netted: ", netted_qty)

            #         if (FQ[net_idx] >= netted_qty)
            #             println("before ", ce)
            #             ce[index] -=  netted_qty
            #             FQ[net_idx] -= netted_qty
            #             global netted_qty -= netted_qty
            #             println("reduing forecast demand")
            #             println("after ",ce)
            #             FQ[net_idx] = round(FQ[net_idx],digits=3)
            #             ce[index] = round(ce[index],digits=3)
            #             println(FQ[net_idx], " ",ce[index])
            #             break
            #         else
            #             println("before ", ce)
            #             global netted_qty -= FQ[net_idx]
            #             ce[index] -= ce[index]
            #             FQ[net_idx] -= FQ[net_idx] 
            #             FQ[net_idx] = round(FQ[net_idx],digits=3)
            #             ce[index] = round(ce[index],digits=3)
            #             println(FQ[net_idx], " ",ce[index])
            #             FQ_order_decision[net_idx] = 2
            #             println("removing forecast demand")
            #             println("after ",ce)
            #         end
            #     end
            #     if (netted_qty == 0.0)
            #         break
            #     end
            # end

            # net_idx = findall(qty->qty<=1e-3,ce) 
            # deleteat!(OiD,net_idx)
            # deleteat!(O,net_idx)
            # deleteat!(ae,net_idx)
            # deleteat!(al,net_idx)
            # deleteat!(prt,net_idx)
            # deleteat!(ce,net_idx)
            # deleteat!(cl,net_idx)
            # deleteat!(de,net_idx)
            # deleteat!(dl,net_idx)
            # deleteat!(due_time,net_idx) 
            # deleteat!(decision,net_idx)
            # deleteat!(accepted_quantities,net_idx) 
            # #println(ce)
            ######################## add the order to the order list #####################################
            push!(OiD,order_Id[idx])
            push!(O,Product_Type[idx])
            push!(cl,Max_Order_Quantity[idx])
            push!(ce,Min_Order_Quantity[idx])
            push!(ae,Arrival_Time[idx])
            push!(al,Response_Time[idx])
            push!(prt,Order_priority[idx])
            push!(de,Earliest_Due_Time[idx])
            push!(dl,Latest_Due_Time[idx])
            push!(decision,-1)
            push!(due_time,-1)
            push!(accepted_quantities,-1)
        else
            order_missed[idx] = 1
        end
    end

   
    # println("Orders: ", OiD)
    # println("Quanti: ",ce)
    # println("early : ",de)
    # println("latnes: ",dl)

    

    for k in eachindex(de)
        if de[k] < start_time
            de[k] = start_time
        end
        if(dl[k] < start_time && OiD[k] in order_Id)
            local idx = findfirst(id -> id == OiD[k], order_Id)
            order_missed[idx] = 1
        end
        if(dl[k] < start_time && OiD[k] in FQ_ID)
            local idx = findfirst(id -> id == OiD[k], FQ_ID)
            FQ_order_missed[idx] = 1
        end
    end

    ##################### Initiate ATP run #####################
    if(length(OiD)>0)
        include("ATP_SS_online.jl")
        include("ATP_cost_data.jl")
        include("ATP_extract_data.jl")
        # include("ATP_plots.jl")
    end
    ##################### Model Decesions on Order acceptance and due times #####################
    for k in eachindex(OiD)
        if(value(Z[k])==1 && OiD[k] in order_Id)
            global idx = findfirst(id->id==OiD[k],order_Id)
            #println("ids in original ", idx)
            Assign_due_time_prev[idx] = Assign_due_time_new[idx]
            Assign_due_time_new[idx] = sum(value(D[k,t])*t for t in de[k]:dl[k])
            if(Assign_due_time_new[idx] != Assign_due_time_prev[idx] && Assign_due_time_prev[idx]!=0)
                Order_Reschedule[idx] += 1
            end
        end
    end

    ##################### Model decisions review for next iteration #####################

    # Update the different times for new iteration
    global start_time = start_time + Batching_Interval
    global end_time = min(end_time + Batching_Interval,scheduling_end_time)
    global Fixed_Horizon += Batching_Interval


    ## find the decision for which response time has been passed
    for k in eachindex(OiD)
            if(al[k] <= start_time)
                decision[k] = value(Z[k]) > 0.5 ? 1 : 0
                due_time[k] = Int(ceil(sum(value(D[k,t])*t for t in de[k]:dl[k])))
                accepted_quantities[k] = round(sum(value(C[k,t]) for t in de[k]:dl[k]),digits=3)
           
                if(OiD[k] in order_Id)
                    global idx = findfirst(id->id==OiD[k],order_Id)
                    order_decision[idx] = decision[k]
                    Order_promised_quantites[idx] = accepted_quantities[k]
                    order_assigned_due_time[idx] = due_time[k]
                else
                    global idx = findfirst(id->id==OiD[k],FQ_ID)
                    FQ_order_decision[idx] = decision[k]
                    FQ_Order_promised_quantites[idx] = accepted_quantities[k]
                    FQ_order_assigned_due_time[idx] = due_time[k]
                end
           end
    end

    # Fix the decision for orders which are accepted
    # global indicies = findall(k -> value.(Z[k]) == 1, 1:length(al))
    # # #println(indicies)
    # if (length(indicies)>0)
    #     for k in indicies
    #         if Response_Time[k] < start_time
    #             decision[k] = 1
    #             # Fix the due time for order which have due time in the fixed horizon
    #             if(sum(value(D[k,t])*t for t in de[k]:dl[k]) <= Fixed_Horizon)
    #                 due_time[k] = Int(ceil(sum(value(D[k,t])*t for t in de[k]:dl[k])))
    #             end
    #         end
    #     end
    # end

    


    # Remove orders which have the assign due time before the new start time 
    global indicies = findall(k -> sum(value(D[k,t])*t for t in de[k]:dl[k]) <= start_time &&  value.(Z[k]) == 1, 1:length(al))
    
    for k in indicies
        # update product inventory from the forecasted demand
        if(OiD[k] in FQ_ID)
             println("#######################################", OiD[k], " ",O[k], " ", sum(value(C[k,t]) for t in de[k]:dl[k]))
            INV_initial[O[k]] += sum(value(C[k,t]) for t in de[k]:dl[k]) 
        end

        if(OiD[k] in order_Id)
            global idx = findfirst(id->id==OiD[k],order_Id)
            order_decision[idx] =  value(Z[k]) > 0.5 ? 1 : 0
            Order_promised_quantites[idx] = round(sum(value(C[k,t]) for t in de[k]:dl[k]),digits=3)
            order_assigned_due_time[idx] = Int(ceil(sum(value(D[k,t])*t for t in de[k]:dl[k])))
        end
    end

    deleteat!(OiD,indicies)
    deleteat!(O,indicies)
    deleteat!(ae,indicies)
    deleteat!(al,indicies)
    deleteat!(prt,indicies)
    deleteat!(ce,indicies)
    deleteat!(cl,indicies)
    deleteat!(de,indicies)
    deleteat!(dl,indicies)
    deleteat!(due_time,indicies) 
    deleteat!(decision,indicies) 
    deleteat!(accepted_quantities,indicies) 

    # Remove orders which have latest due time before the new start time
    global indicies = findall(k -> dl[k] < start_time , 1:length(dl))
    if(length(indicies)>0) 
        deleteat!(OiD,indicies)
        deleteat!(O,indicies)
        deleteat!(ae,indicies)
        deleteat!(al,indicies)
        deleteat!(prt,indicies)
        deleteat!(ce,indicies)
        deleteat!(cl,indicies)
        deleteat!(de,indicies)
        deleteat!(dl,indicies)
        deleteat!(due_time,indicies) 
        deleteat!(decision,indicies) 
        deleteat!(accepted_quantities,indicies) 
    end

    if start_time >= scheduling_end_time
        break
    end
    

end



 ##################### Output final decisions  ##################### 

 include("ATP_final_decisions.jl")
 include("ATP_final_decision_forecast.jl")