@info "Plotings begin"
task_data = []
# println(T)
for i in I
       for t in T
              for j in J
                     if value(B[i, j, t]) > 1
                            task_start_time = t
                            task_end_time = task_start_time + τ[i]
                            push!(task_data, ("Task $i, Unit $j", task_start_time, task_end_time,i,j))  # Concatenate indices i and j to uniquely identify each task
                            # break  # Break once task i starts
                     end
              end
       end
end


# Plot the Gantt chart
p = plot(legend=false, xlabel="time", ylabel="task", size=(800,400))
q = plot(legend=false, xlabel="time", ylabel="unit", size=(800,400))

# Plot tasks
task_colors = ["red", "green","skyblue","orange","purple"]  # Add more colors as needed for additional units

for (idx, (task_name, task_start_time, task_end_time,task,unit)) in enumerate(task_data)
       rect_x = [task_start_time, task_end_time, task_end_time, task_start_time]
       rect_y = [task - 0.3, task - 0.3, task + 0.3, task + 0.3]
       rect_z = [unit - 0.3, unit - 0.3, unit + 0.3, unit + 0.3]
       plot!(p, rect_x, rect_y, seriestype=:shape, lw=1, label="", color=task_colors[unit])
       plot!(q, rect_x, rect_z, seriestype=:shape, lw=1, label="", color=task_colors[task])
       # plot!(p, [(task_start_time, unit), (task_end_time, unit)], color=task_colors[task], lw=10, linealpha=0.5, label=task)  # Add task name as label
       # plot!(q, [(task_start_time, task), (task_end_time, task)], color=task_colors[unit], lw=10, linealpha=0.5, label=task)  # Add task name as label
end



savefig(p,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/grantt_chart-unit-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")
savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/grantt_chart-task-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")


inv = []
buy = []
sell = []
for s in S
       v = []
       r = []
       cs = []
       for t in T
              push!(v,value(Inv[s,t]))
              push!(r,value(RMP[s,t]))
              push!(cs,value(RMS[s,t]))
       end
       push!(inv,v)
       push!(buy,r)
       push!(sell,cs)
end

#Storage capacity Materials - A,B,C,Hot-A,I-BC,P1, I-AB,E, P2
q = plot(xlabel="Time", ylabel="Inventory Level", lw=2)



plot!(q,T,inv[1,:],label="A",linestyle=:auto)
plot!(q,T,inv[2,:],label="B",linestyle=:auto)
plot!(q,T,inv[3,:],label="C",linestyle=:auto)
plot!(q,T,inv[4,:],label="Hot-A",linestyle=:auto)
plot!(q,T,inv[7,:],label="AB",linestyle=:auto)
plot!(q,T,inv[5,:],label="BC",linestyle=:auto)
plot!(q,T,inv[8,:],label="E",linestyle=:auto)

# Set x-grids to have a length of 1

savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/Inventory_profile-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")

q = plot(xlabel="Time", ylabel="Purchase amount", lw=2)
plot!(q,T,buy[1,:],label="A",linestyle=:auto)
plot!(q,T,buy[2,:],label="B",linestyle=:auto)
plot!(q,T,buy[3,:],label="C",linestyle=:auto)
plot!(q,T,buy[4,:],label="Hot-A",linestyle=:auto)
plot!(q,T,buy[5,:],label="BC",linestyle=:auto)
plot!(q,T,buy[6,:],label="P1",linestyle=:auto)
plot!(q,T,buy[7,:],label="AB",linestyle=:auto)
plot!(q,T,buy[8,:],label="E",linestyle=:auto)
plot!(q,T,buy[9,:],label="P2",linestyle=:auto)
# Set x-grids to have a length of 1

savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/Raw_Material_Purchased-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")

q = plot(xlabel="Time", ylabel="Sale amount", lw=2)
plot!(q,T,sell[6,:],label="P_1",linestyle=:auto)
plot!(q,T,sell[9,:],label="P_2",linestyle=:auto)
# Set x-grids to have a length of 1

savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/Sales-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")

q = plot(xlabel="Time", ylabel="Inventory Level", lw=2)
plot!(q,T,inv[6,:],label="P1",linestyle=:auto)
plot!(q,T,inv[9,:],label="P2",linestyle=:auto)

# Set x-grids to have a length of 1

savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/Product_inventory_profile-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")

q = plot(xlabel="Time", ylabel="utitlites", lw=2)
HPS = Array(value.(UT[1,:]))
LPS = Array(value.(UT[2,:]))
CW = Array(value.(UT[3,:]))
plot!(q,T,HPS,label="HPS",linestyle=:auto)
plot!(q,T,LPS,label="LPS",linestyle=:auto)
plot!(q,T,CW,label="CW",linestyle=:auto)
# Set x-grids to have a length of 1

savefig(q,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/Utility_profile-$iter-BS-$Batching_Interval-FH-$Fixed_Horizon-PH-$Planning_horizon.png")

@info "Plotings completed"