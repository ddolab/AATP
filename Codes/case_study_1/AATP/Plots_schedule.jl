############################# Used to create the gantt plot of schedules #############################

@info "Plotings begin"
task_data = []

# if(iter == last_itr)
#     T = start_time:end_time
# else
#     T = start_time:start_time+Batching_Interval
# end
# println(T)
for i in I
       for t in T
              for j in J
                     if value(X_SS[i, j, t,1]) > 0.5
                            task_start_time = t
                            task_end_time = task_start_time + τ[i]
                            push!(task_data, ("Task $i, Unit $j", task_start_time, task_end_time,i,j))  # Concatenate indices i and j to uniquely identify each task
                            # break  # Break once task i starts
                     end
              end
       end
end


# Plot the Gantt chart
gantt_task = plot()
# gantt_unit = plot()

# Plot tasks
task_colors = ["red", "green","skyblue","orange","purple"]  # Add more colors as needed for additional units

for (idx, (task_name, task_start_time, task_end_time,task,unit)) in enumerate(task_data)
       rect_x = [task_start_time, task_end_time, task_end_time, task_start_time]
       rect_y = [task - 0.2, task - 0.2, task + 0.2, task + 0.2]
       rect_z = [unit - 0.2, unit - 0.2, unit + 0.2, unit + 0.2]
       plot!(gantt_task, rect_x, rect_y, seriestype=:shape, lw=1, label="", color=task_colors[unit])
       # plot!(gantt_unit, rect_x, rect_z, seriestype=:shape, lw=1, label="", color=task_colors[task])
       # plot!(p, [(task_start_time, unit), (task_end_time, unit)], color=task_colors[task], lw=10, linealpha=0.5, label=task)  # Add task name as label
       # plot!(q, [(task_start_time, task), (task_end_time, task)], color=task_colors[unit], lw=10, linealpha=0.5, label=task)  # Add task name as label
end


savefig(gantt_task,"BI-$Batching_Interval/Schedule/ATP-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast-iteration-$iter.png")
# savefig(gantt_unit,"BI-$Batching_Interval/Schedule/ATP-Data-output-BI-$Batching_Interval-scenario-$scenario-forecast-iteration-$iter.png")


# inv = []
# buy = []
# sell = []
# for s in S
#        v = []
#        r = []
#        cs = []
#        for t in T
#               push!(v,value(Inv[s,t]))
#               push!(r,value(RMP[s,t]))
#               push!(cs,value(RMS[s,t]))
#        end
#        push!(inv,v)
#        push!(buy,r)
#        push!(sell,cs)
# end


# plot!(Inventory_plot,T,inv[1,:],label="A",linestyle=:auto)
# plot!(Inventory_plot,T,inv[2,:],label="B",linestyle=:auto)
# plot!(Inventory_plot,T,inv[3,:],label="C",linestyle=:auto)
# plot!(Inventory_plot,T,inv[4,:],label="Hot-A",linestyle=:auto)
# plot!(Inventory_plot,T,inv[7,:],label="AB",linestyle=:auto)
# plot!(Inventory_plot,T,inv[5,:],label="BC",linestyle=:auto)
# plot!(Inventory_plot,T,inv[8,:],label="E",linestyle=:auto)

# Set x-grids to have a length of 1

# savefig(Inventory_plot,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/All-Inventory_profile-$iter-BS-$Batching_Interval-PH-$Planning_horizon.png")


# plot!(Purchase_plot,T,buy[1,:],label="A",linestyle=:auto)
# plot!(Purchase_plot,T,buy[2,:],label="B",linestyle=:auto)
# plot!(Purchase_plot,T,buy[3,:],label="C",linestyle=:auto)
# plot!(Purchase_plot,T,buy[4,:],label="Hot-A",linestyle=:auto)
# plot!(Purchase_plot,T,buy[5,:],label="BC",linestyle=:auto)
# plot!(Purchase_plot,T,buy[6,:],label="P1",linestyle=:auto)
# plot!(Purchase_plot,T,buy[7,:],label="AB",linestyle=:auto)
# plot!(Purchase_plot,T,buy[8,:],label="E",linestyle=:auto)
# plot!(Purchase_plot,T,buy[9,:],label="P2",linestyle=:auto)
# Set x-grids to have a length of 1
# savefig(Purchase_plot,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/All-Raw_Material_Purchased-$iter-BS-$Batching_Interval-PH-$Planning_horizon.png")


# plot!(Sale_plot,T,sell[6,:],label="P_1",linestyle=:auto)
# plot!(Sale_plot,T,sell[9,:],label="P_2",linestyle=:auto)
# Set x-grids to have a length of 1

# savefig(Sale_plot,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/All-Sales-$iter-BS-$Batching_Interval-PH-$Planning_horizon.png")

# plot!(product_inventory_level_plot ,T,inv[6,:],label="P1",linestyle=:auto)
# plot!(product_inventory_level_plot ,T,inv[9,:],label="P2",linestyle=:auto)

# Set x-grids to have a length of 1

# savefig(product_inventory_level_plot ,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/All-Product_inventory_profile-$iter-BS-$Batching_Interval-PH-$Planning_horizon.png")


# HPS = Array(value.(UT[1,T]))
# LPS = Array(value.(UT[2,T]))
# CW = Array(value.(UT[3,T]))
# plot!(utility_plot,T,HPS,label="HPS",linestyle=:auto)
# plot!(utility_plot,T,LPS,label="LPS",linestyle=:auto)
# plot!(utility_plot,T,CW,label="CW",linestyle=:auto)
# # Set x-grids to have a length of 1

# savefig(utility_plot,"Scenario-$scenario/Batching_Interval-$Batching_Interval-Fixed_Horizon-$Fixed_Horizons/All-Utility_profile-$iter-BS-$Batching_Interval-PH-$Planning_horizon.png")

T = start_time:end_time
@info "Plotings completed"