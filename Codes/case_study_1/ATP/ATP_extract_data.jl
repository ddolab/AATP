# @info "Data extraction started"
# println(T)
XLSX.openxlsx("BI-$Batching_Interval/ATP-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast-iteration-$iter.xlsx", mode="w") do xf
       sheet = xf[1]
       sheet["A1"] = "Time"
       sheet["B1"] = "Task/Units"
       row = 1
       column = 3
       for j in J 
              sheet[row,column]=j
              column += 1
       end
       for t in T
              for i in I
                     column = 1
                     row = row + 1
                     sheet[row,column]=t
                     column = column + 1
                     sheet[row,column]=i
                     for j in J
                            column = column + 1
                            sheet[row,column]=value.(B_SS[i,j,t,1])
                     end
              end
       end
       sheet = XLSX.addsheet!(xf,"Orders")
       row=1
       sheet3 = XLSX.addsheet!(xf, "Sale")
       sheet3["A1"] = "Time"
       sheet5 = XLSX.addsheet!(xf, "Production")
       sheet5["A1"] = "Time"
       sheet6 = XLSX.addsheet!(xf, "Consumption")
       sheet6["A1"] = "Time"
       sheet1 = XLSX.addsheet!(xf, "Inventory")
       sheet1["A1"] = "Time"
       mat = ["A","B","C","Hot-A","I-BC","P1", "I-AB","E", "P2"]
       sheet2 = XLSX.addsheet!(xf, "Purchase")
       sheet2["A1"] = "Time"
       sheet4 = XLSX.addsheet!(xf, "Utility")
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
              row += 1
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
       sheet[row,column] = "denial Penalty per kg"
       column+=1
       sheet[row,column] = "partial Rejection Penalty per kg"
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
       sheet[row,column] = "Partial rejction Penalty"
       column+=1
       sheet[row,column] = "denial Penalty"
       column+=1
       sheet[row,column] = "Total Penalty"
       column+=1
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
       end
   
       sheet = XLSX.addsheet!(xf, "Profit")
       sheet["A1"] = "Time"
       sheet["B1"] = "Purchase"
       sheet["C1"] = "Sales"
       sheet["D1"] = "Utility"
       sheet["E1"] = "Inventory Holding"  
       sheet["F1"] = "Total"
       row = 1
       col = 1
       for t in T
          row = row+1
          col = 1
          sheet[row,col] = t
          col+=1
          sheet[row,col] = 0*sum(value(RMP[s,t])*πP[s] for s in S)
          col+=1
          sheet[row,col] = sum(value(RMS[s,t])*πS[s] for s in S)
          col+=1
          sheet[row,col] = sum(value(X_SS[i,j,t,1])*πF[i] + value(B_SS[i,j,t,1])*πV[i] for i in I for j in J if I_J[j,i]>0.1) 
          col+=1
          sheet[row,col] = sum(λ[s] * (value(Inv[s, t]) + sum(value(C[k, de[k]]) for k in K if OiD[k] > 1000 && O[k] == s && de[k] <= t; init=0.0)) for s in S)
          col+=1
          sheet[row,col] =  sum(value(RMS[s,t])*πS[s] for s in S) - 0*sum(value(RMP[s,t])*πP[s] for s in S)  - sum(λ[s] * (value(Inv[s, t]) + sum(value(C[k, de[k]]) for k in K if OiD[k] > 1000 && O[k] == s && de[k] <= t; init=0.0)) for s in S)
       end
   end
   
   # @info "Data extraction ended"