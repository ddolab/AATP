I = 1:3 # tasks - Mixing, reaction, purification
J = 1:3 # Units - mixer, reactor, distillation
S = 1:4 # Materials - s1, s2,s3,s4
L = 1:3 # Utilities - HPS, LPS, CW
N = [4]   # Product

No_sell = [1,2,3] # materials which are not allowed to sell
sell = [4]
No_buy = [2 3 4]    # materials which are not allowed to purchase
buy = [1]

# Units which can perform task i
I_J = [1 0 0;
       0 1 0;
       0 0 1]

# Process time for each tasks
τ = [4 2 1]

# time for output of task i to state s
τ_bar = [0 4 0 0;
         0 0 2 0;
         0 0 0 1]

# Unit capacities      
β_max = [100,75,50]
β_min = [50,25,25]

# Fixed and variable cost
πF = [150 100 150]
πV = [1 0.5 1]

# Maximum available Utilities
# XUT = [200 500 500]
#Storage capacity Materials - A B C P1
XMT = [1e25 100 100 1e25]

# Cost of Sales
πS = [-1e25 -1e25 -1e25 20]

# Cost of Purchase
πP = [0 1e25 1e25 1e25]


# Inventory holding Cost
λ = [0 2.5 5 20].*0.001
# Cost of Utilities 
# πU = [1 0.5 0.1]

# Materials produced
ρ_out = [0 1 0 0;
         0 0 1 0;
         0 0 0 1]

# Materials Consumed
ρ_in = [1 0 0 0;
        0 1 0 0;
        0 0 1 0]