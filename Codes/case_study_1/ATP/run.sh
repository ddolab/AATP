#!/bin/bash -l
#SBATCH --time=4:00:00           # Set the wall time limit
#SBATCH --array=1-10              # Number of jobs (tasks) in the array (1-5 for 5 tasks)
#SBATCH --nodes=1                # Number of nodes (1 node per job)
#SBATCH --ntasks-per-node=1      # Number of tasks (1 task per node)
#SBATCH --cpus-per-task=4        # Number of CPU cores per task
#SBATCH --mem=8G                # Memory per node
#SBATCH --tmp=8G                # Temporary disk space per node
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=sahu0047@umn.edu

# Load necessary modules (adjust as per your environment)
module load gurobi julia

# # Define batching intervals and scenarios
# define_batching_intervals=(72) # (168 144 120 96 72 48 24)  # Example intervals in days
# define_scenarios=(1 2 3 4 5)

# # Calculate current batching interval and scenario based on SLURM_ARRAY_TASK_ID
# define_batching_interval_index=$(((SLURM_ARRAY_TASK_ID - 1) / 7))
# define_scenario_index=$(((SLURM_ARRAY_TASK_ID - 1) % 5))

# define_batching_interval=${define_batching_intervals[$define_batching_interval_index]}
# define_scenario=${define_scenarios[$define_scenario_index]}

# # Run your Julia script with the calculated parameters
srun --exclusive julia ATP_cases.jl 72 $SLURM_ARRAY_TASK_ID  $SLURM_ARRAY_TASK_ID 




# if [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then
#     srun --exclusive julia ATP_cases.jl 1 1 40
# elif [ $SLURM_ARRAY_TASK_ID -eq 2 ]; then
#     srun --exclusive julia ATP_cases.jl 1 2 41
# elif [ $SLURM_ARRAY_TASK_ID -eq 3 ]; then
#     srun --exclusive julia ATP_cases.jl 1 3 42
# elif [ $SLURM_ARRAY_TASK_ID -eq 4 ]; then
#     srun --exclusive julia ATP_cases.jl 1 4 43
# elif [ $SLURM_ARRAY_TASK_ID -eq 5 ]; then
#     srun --exclusive julia ATP_cases.jl 1 5 44  
# elif [ $SLURM_ARRAY_TASK_ID -eq 6 ]; then
#     srun --exclusive julia ATP_cases.jl 3 5 45                        
# fi