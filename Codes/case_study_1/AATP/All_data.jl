# @info "Data extraction started"
# if(iter == last_itr)
#        T = start_time:end_time
# else
#        T = start_time:start_time+Batching_Interval
# end
# println(T)
if (iter==1)
   XLSX.openxlsx("Data/ATP_Cost-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast.xlsx", mode="w") do xf
      sheet = XLSX.addsheet!(xf,"Orders")
      sheet = XLSX.addsheet!(xf,"schedule")
      sheet = XLSX.addsheet!(xf, "Sale")
      sheet = XLSX.addsheet!(xf, "Production")
      sheet = XLSX.addsheet!(xf, "Consumption")
      sheet = XLSX.addsheet!(xf, "Inventory")
      sheet = XLSX.addsheet!(xf, "Purchase")
      sheet = XLSX.addsheet!(xf, "Utility")
      sheet = xf["Sheet1"]
      XLSX.rename!(sheet, "Costs")
   end
end  

XLSX.openxlsx("Data/ATP_Cost-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast.xlsx", mode="rw") do xf
   sheet = xf["Costs"]
   sheet1 = xf["schedule"]
   sheet["A1"] = "Time"
   sheet["B1"] = "Purchase"
   sheet["C1"] = "Sales"
   sheet["D1"] = "Utility"
   sheet["E1"] = "Inventory Holding"   
   sheet["F1"] = "Total"
   sheet1["A1"] = "Time"
   sheet1["B1"] = "Task-1 Batch Size"
   sheet1["C1"] = "Task-1 Batch Count"
   sheet1["D1"] = "Task-2 Batch Size"
   sheet1["E1"] = "Task-2 Batch Count"
   sheet1["F1"] = "Task-3 Batch Size"
   sheet1["G1"] = "Task-3 Batch Count"
   sheet1["H1"] = "Task-4 Batch Size"
   sheet1["I1"] = "Task-4 Batch Count"
   sheet1["J1"] = "Task-5 Batch Size"
   sheet1["K1"] = "Task-5 Batch Count"
   row = start_time
   for t in T
      row = row+1
      col = 1
      sheet[row,col] = t
      sheet1[row,col] = t
      col+=1
      sheet[row,col] = 0*sum(value(RMP[s,t])*πP[s] for s in S)
      col+=1
      sheet[row,col] = sum(value(RMS[s,t])*πS[s] for s in S)
      col+=1
      sheet[row,col] = sum(value(X_SS[i,j,t,1])*πF[i] + value(B_SS[i,j,t,1])*πV[i] for i in I for j in J if I_J[j,i]>0.1) #sum(value(UT[l,t])*πU[l] for l in L)
      col+=1
      sheet[row,col] = sum(λ[s] * (value(Inv[s, t]) + sum(value(C[k, de[k]]) for k in K if OiD[k] > 1000 && O[k] == s && de[k] <= t; init=0.0)) for s in S)
      col+=1
      sheet[row,col] =  sum(value(RMS[s,t])*πS[s] for s in S) - 0*sum(value(RMP[s,t])*πP[s] for s in S)  - sum(λ[s] * (value(Inv[s, t]) + sum(value(C[k, de[k]]) for k in K if OiD[k] > 1000 && O[k] == s && de[k] <= t; init=0.0)) for s in S)
      col+=1
      col=2
      for i in I
         sheet1[row,col+(i-1)*2] = sum(value(B_SS[i,j,t,1]) for j in J)  
         sheet1[row,col+(i-1)*2+1] = sum(value(X_SS[i,j,t,1]) for j in J if I_J[j,i]>0)     
      end
   end


   sheet = xf["Orders"]

   column=1
   row=1
   sheet[row,column] = "Order ID."
   column+=1
   sheet[row,column] = "Product type"
   column+=1
   sheet[row,column] = "Arrival Time"
   column+=1
   sheet[row,column] = "Response Time"
   column+=1
   sheet[row,column] = "Earliest due time"
   column+=1
   sheet[row,column] = "Latest due time"
   column+=1
   sheet[row,column] = "Minimum quanitites"
   column+=1
   sheet[row,column] = "Maximum quantiies"
   column+=1
   sheet[row,column] = "selling price per kg"
   column+=1
   sheet[row,column] = "Denial Penalty per kg"
   column+=1
   sheet[row,column] = "Partial Rejection Penalty per kg"
   column+=1
   sheet[row,column] = "Priority"
   column+=1
   sheet[row,column] = "Acceptance/delination"
   column+=1
   sheet[row,column] = "Assigned Due date"
   column+=1
   sheet[row,column] = "Promised quanitites"
   column+=1
   sheet[row,column] = "Order fullfillment"
   column+=1
   sheet[row,column] = "Partial rejection Penalty"
   column+=1
   sheet[row,column] = "Rejction Penalty"
   column+=1
   sheet[row,column] = "Total Penalty"
   column+=1
   sheet[row,column] = "Start Time"
   column+=1
   sheet[row,column] = "Fixed_Horizon"
   column+=1
   sheet[row,column] = "End_Time"
   row = prev_rows+1

   for k in K
      row+=1
      column=1
      sheet[row,column] = OiD[k]
      column+=1
      sheet[row,column] = O[k]
      column+=1
      sheet[row,column] = ae[k]
      column+=1
      sheet[row,column] = al[k]
      column+=1
      sheet[row,column] = de[k]
      column+=1
      sheet[row,column] = dl[k]
      column+=1
      sheet[row,column] = ce[k]
      column+=1
      sheet[row,column] = cl[k]
      column+=1
      sheet[row,column] = πS[O[k]]
      column+=1
      sheet[row,column] = γ[k]
      column+=1
      sheet[row,column] = γp[k]
      column+=1
      sheet[row,column] = prt[k]
      column+=1
      sheet[row,column] = value(Z[k])
      column+=1
      sheet[row,column] = sum(value(D[k,t])*t for t in de[k]:dl[k])
      column+=1
      sheet[row,column] = sum(value(C[k,t]) for t in de[k]:dl[k])
      column+=1
      sheet[row,column] = (abs(cl[k]*value(Z[k]) - sum(value(C[k,t]) for t in de[k]:dl[k])) > 0.01 ? 1 : 0 )
      column+=1
      sheet[row,column] = -γp[k]*(cl[k]*value(Z[k])-sum(value(C[k,t]) for t in de[k]:dl[k]))
      column+=1
      sheet[row,column] = -γ[k]*ce[k]*(1-value(Z[k]))
      column+=1
      sheet[row,column] = -γ[k]*ce[k]*(1-value(Z[k]))-γp[k]*(cl[k]*value(Z[k])-sum(value(C[k,t]) for t in de[k]:dl[k]))
      column+=1
      sheet[row,column] = start_time
      column+=1
      sheet[row,column] = Fixed_Horizon
      column+=1
      sheet[row,column] = end_time
   end

   global prev_rows = row+1
   sheet3 = xf["Sale"]
   sheet3["A1"] = "Time"
   sheet5 = xf["Production"]
   sheet5["A1"] = "Time"
   sheet6 = xf["Consumption"]
   sheet6["A1"] = "Time"
   sheet1 = xf["Inventory"]
   sheet1["A1"] = "Time"
   mat = ["A","B","C","P1"]
   sheet2 = xf["Purchase"]
   sheet2["A1"] = "Time"
   sheet4 = xf["Utility"]
   sheet4["A1"] = "Time"
   sheet4["B1"] = "HPS"
   sheet4["C1"] = "LPS"
   sheet4["D1"] = "CW"
   row = 1
   column = 2
   for m in mat
      sheet1[row,column] = m
      sheet2[row,column] = m
      sheet3[row,column] = m
      sheet5[row,column] = m
      sheet6[row,column] = m
      column += 1
   end

   for t in T
      row = t+1
      column = 1
      sheet1[row,column] = t
      sheet2[row,column] = t
      sheet3[row,column] = t
      sheet4[row,column] = t
      sheet5[row,column] = t
      sheet6[row,column] = t
      column += 1
      for s in S
         sheet1[row,column] = value(Inv[s, t]) + sum(value(C[k, de[k]]) for k in K if OiD[k] > 1000 && O[k] == s && de[k] <= t; init=0.0)
         sheet2[row,column] = value(RMP[s,t])
         sheet3[row,column] = value(RMS[s,t])
         sheet5[row,column] =  sum(ρ_out[i,s]*value(B_SS[i,j,t,τ[i]+1]) for i in I for j in J if I_J[j,i]>=0.1)
         sheet6[row,column] = -sum(ρ_in[i,s]*value(B_SS[i,j,t,1]) for i in I for j in J if I_J[j,i]>0.1) 
         column+=1
      end
      column = 2
      for l in L
         sheet4[row,column] = 0 #value(UT[l,t])
         column+=1
      end

   end
end

# @info "Data extraction ended"