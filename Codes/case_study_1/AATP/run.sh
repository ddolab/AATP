#!/bin/bash -l
#SBATCH --time=20:00:00           # Set the wall time limit
#SBATCH --array=1-10              # Number of jobs (tasks) in the array (1-5 for 5 tasks)
#SBATCH --nodes=1                # Number of nodes (1 node per job)
#SBATCH --ntasks-per-node=1      # Number of tasks (1 task per node)
#SBATCH --cpus-per-task=4        # Number of CPU cores per task
#SBATCH --mem=20G                # Memory per node
#SBATCH --tmp=20G                # Temporary disk space per node
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=sahu0047@umn.edu

# Load necessary modules (adjust as per your environment)
module load gurobi julia

# Define batching intervals and scenarios
define_batching_intervals=(168 144 120 96 72 48 24)  # Length of batching interval
define_scenarios=(1 2 3 4 5 6 7 8 9 10).             # Different scenario index - used to create different demand forecasts

# Calculate current batching interval and scenario based on SLURM_ARRAY_TASK_ID
define_batching_interval_index=$(((SLURM_ARRAY_TASK_ID - 1) / 10))
define_scenario_index=$(((SLURM_ARRAY_TASK_ID - 1) % 10))

define_batching_interval=${define_batching_intervals[$define_batching_interval_index]}
define_scenario=${define_scenarios[$define_scenario_index]}

# # Run your Julia script with the calculated parameters
srun --exclusive julia AATP_cases.jl $define_batching_interval $define_scenario $SLURM_ARRAY_TASK_ID 



