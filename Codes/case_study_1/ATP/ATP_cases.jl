using JuMP, Gurobi, Random, Logging, XLSX, Plots, StatsPlots

different_batching_interval = parse(Int, ARGS[1])
different_scenario = parse(Int, ARGS[2])
output_row = parse(Int, ARGS[3]) + 1
# different_batching_interval =  72

Total_orders = 150
println("Case ", different_batching_interval , " ", different_scenario," ",output_row)

if !isfile("ATP_Output.xlsx")
    XLSX.openxlsx("ATP_Output.xlsx", mode="w") do xf
        sheet = xf["Sheet1"]
        XLSX.rename!(sheet, "Output")
        sheet = xf["Output"]
        sheet["A1"] = "Batching_Interval"
        sheet["B1"] = "scenario"
        sheet["C1"] = "Rejected_Orders"
        sheet["D1"] = "Accepted_Orders"
        sheet["E1"] = "Missed_Orders"
        sheet["F1"] = "Rescheduled"
        sheet["G1"] = "Partial_Order_filled"
        sheet["H1"] = "Parital_rejction_penalty"
        sheet["I1"] = "Denial_penalty"
        sheet["J1"] = "Purchase_cost"
        sheet["K1"] = "Utility_cost"
        sheet["L1"] = "Inventory_cost"
        sheet["M1"] = "Production_cost"
        sheet["N1"] = "Revenue_orders"
        sheet["O1"] = "Inventory_remaining"
        sheet["P1"] = "revnue_all"
        sheet["Q1"] = "Profit"
        sheet["R1"] = "Profit_unrealised"  
        sheet["S1"] = "Priority_orders"
        sheet["T1"] = "Total_Penalty"
        sheet["U1"] = "Objective"
    end
end



for case_bi in different_batching_interval
    for case_sc in different_scenario
        global case_batching_interval = case_bi
        global case_scenario = case_sc
        Batching_Interval = case_bi
        scenario = case_sc
        println("Batching_Interval = $case_bi ; scenario = $case_sc")
        include("ATP_demand_forecast.jl")
        xf=XLSX.readxlsx("Data/ATP_Cost-Data-output-BI-$case_bi-scenario-$case_sc-forecast.xlsx")
        sheet = xf["Final Decisions Orders"]
        accepted_orders = sum(sheet["L"][2:end])
        reschedule_orders = sum(sheet["P"][2:end])
        missed_orders = sum(sheet["Q"][2:end])
        parital_orers = sum(sheet["O"][2:end])
        rejected_orders = Total_orders -  missed_orders - accepted_orders 
        penalty_orders = sum(sheet["S"][2:end])
        denial_orders = sum(sheet["T"][2:end])
        Revenue_orders = sum(sheet["N"][2:end].*sheet["I"][2:end])  
        col_l = sheet["L"][2:end]
        col_j = sheet["J"][2:end]
        priority_order = sum(col_l[i] for i in 1:length(col_l) if col_j[i]==2)
        sheet = xf["Costs"]
        Purchase_cost = sum(sheet["B"][2:end])
        Utility_cost  =  sum(sheet["D"][2:end])
        Inventory_cost = sum(sheet["E"][2:end])
        Production_cost =  Purchase_cost + Utility_cost 
        sheet = xf["Inventory"]
        inventory_remaining = sheet["E"][end]
        XLSX.openxlsx("ATP_Output.xlsx", mode="rw") do xf
            sheet = xf[1]
            sheet[output_row,1] = case_bi
            sheet[output_row,2] = case_sc
            sheet[output_row,3] = rejected_orders 
            sheet[output_row,4] = accepted_orders
            sheet[output_row,5] = missed_orders
            sheet[output_row,6] = reschedule_orders  
            sheet[output_row,7] = parital_orers  
            sheet[output_row,8] = penalty_orders
            sheet[output_row,9] = denial_orders
            sheet[output_row,10] = Purchase_cost
            sheet[output_row,11] = Utility_cost
            sheet[output_row,12] = Inventory_cost
            sheet[output_row,13] = Production_cost
            sheet[output_row,14] = Revenue_orders
            sheet[output_row,15] = inventory_remaining
            sheet[output_row,16] = Revenue_orders + inventory_remaining*20*0.9
            sheet[output_row,17] = Revenue_orders - Production_cost - Inventory_cost
            sheet[output_row,18] = Revenue_orders - Production_cost - Inventory_cost + inventory_remaining*20*0.9
            sheet[output_row,19] = priority_order
            sheet[output_row,20] = penalty_orders + denial_orders
            sheet[output_row,21] = Revenue_orders - Production_cost - Inventory_cost + penalty_orders + denial_orders

        end
        global output_row+=1
    end
end
