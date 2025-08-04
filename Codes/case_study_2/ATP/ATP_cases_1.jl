if !isfile("ATP_Output_1.xlsx")
    XLSX.openxlsx("ATP_Output_1.xlsx", mode="w") do xf
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
        sheet["O1"] = "Profit"
        sheet["P1"] = "Product_1_missed_orders"
        sheet["Q1"] = "Product_1_rejected_orders"
        sheet["R1"] = "Product_1_accepted_orders"
        sheet["S1"] = "Product_1_partial_accepted_orders"
        sheet["T1"] = "Product_2_missed_orders"
        sheet["U1"] = "Product_2_rejected_orders"
        sheet["V1"] = "Product_2_accepted_orders"
        sheet["W1"] = "Product_2_partial_accepted_orders"
        sheet["X1"] = "Product_1_inventory"
        sheet["Y1"] = "Product_2_inventory"
        # sheet["X1"] = "Product_1_denial_penalty"
        # sheet["Y1"] = "Product_1_partial_denial_penalty"
        # sheet["Z1"] = "Product_2_denial_penalty"
        # sheet["AA1"] = "Product_2_partial_denial_penalty"
    end
end



xf=XLSX.readxlsx("Data/ATP_Cost-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast.xlsx")
sheet = xf["Final Decisions Orders New"]
accepted_orders = sum(sheet["L"][2:end])
p1_accepted_orders =sum(sheet["L"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 6)
p2_accepted_orders = sum(sheet["L"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 9)
reschedule_orders = sum(sheet["P"][2:end])
missed_orders = sum(sheet["Q"][2:end])
p1_missed_orders = sum(sheet["Q"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 6)
p2_missed_orders = sum(sheet["Q"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 9)  
parital_orers = sum(sheet["O"][2:end])
p1_parital_orers =sum(sheet["O"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 6)
p2_parital_orers = sum(sheet["O"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 9) 
rejected_orders = Total_orders -  missed_orders - accepted_orders 
p1_rejected_orders = sum(sheet["B"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 6)/6 -  p1_missed_orders - p1_accepted_orders 
p2_rejected_orders = sum(sheet["B"][i] for i in 2:length(sheet["B"]) if sheet["B"][i] == 9)/9 -  p2_missed_orders - p2_accepted_orders

penalty_orders = sum(sheet["S"][2:end])
denial_orders = sum(sheet["T"][2:end])
Revenue_orders = sum(sheet["N"][2:end].*sheet["I"][2:end])  
sheet = xf["Costs"]
Purchase_cost = sum(sheet["B"][2:end])
Utility_cost  =  sum(sheet["D"][2:end])
Inventory_cost = sum(sheet["E"][2:end])
Production_cost =  Purchase_cost + Utility_cost 

sheet = xf["Inventory"]
p1_inv = sheet["G"][end]
p2_inv = sheet["J"][end]

XLSX.openxlsx("ATP_Output_1.xlsx", mode="rw") do xf
    sheet = xf[1]
    sheet[output_row,1] = Batching_Interval
    sheet[output_row,2] = scenario
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
    sheet[output_row,15] = Revenue_orders - Utility_cost - Purchase_cost - Inventory_cost
    sheet[output_row,16] = p1_missed_orders
    sheet[output_row,17] = p1_rejected_orders
    sheet[output_row,18] = p1_accepted_orders
    sheet[output_row,19] = p1_parital_orers 
    sheet[output_row,20] = p2_missed_orders
    sheet[output_row,21] = p2_rejected_orders
    sheet[output_row,22] = p2_accepted_orders
    sheet[output_row,23] = p2_parital_orers 
    sheet[output_row,24] = p1_inv
    sheet[output_row,25] = p2_inv
end
