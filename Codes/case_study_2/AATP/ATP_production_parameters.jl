I = 1:5 # tasks - Heating, Rxn1, Rxn2, Rxn3, Distillation
J = 1:4 # Units - Heater, Reactior-1, Reactor-2, Distillation column
S = 1:9 # Materials - A,B,C,Hot-A,I-BC,P1,I-AB,E, P2
L = 1:3 # Utilities - HPS, LPS, CW
N = [6 9]   # Product identity

No_sell = [1,2,3,4,5,7,8] # materials which are not allowed to sell
No_buy = [4,5,6,7,8,9]    # materials which are not allowed to purchase

# Units which can perform task i
I_J = [1 0 0 0 0;
       0 1 1 1 0;
       0 1 1 1 0;
       0 0 0 0 1]

# Time for tasks
τ = [1 2 2 1 2]


# time for output of task i to state s
τ_bar = [0 0 0 1 0 0 0 0 0;
         0 0 0 0 2 0 0 0 0;
         0 0 0 0 0 2 2 0 0;
         0 0 0 0 0 0 0 1 0;
         0 0 0 0 0 0 2 0 1]

# Fixed utitlity for task
ϕ = [100 0 0 0 0;
        0 50 50 50 50;
        0 0 0 0 150]

# Variable utitlity for task
ψ = [2 0 0 0 0;
        0 2 1 2 1;
        0 0 0 0 2]

# Unit capacity       
β_max = [100,80,50,200]
β_min = [0,0,0,0]

# Fixed and variable cost
# πF = [10,20,10,20]
# πV = [0.2 1 1 0.5]

# Maximum available Utilities
XUT = [200 500 500]
#Storage capacity Materials - A,B,C,Hot-A,I-BC,P1, I-AB,E, P2
XMT = [1e9 1e9 1e9 100 150 1e9 200 100 1e9]

# Cost of Sales
πS = [-1e25 -1e25 -1e25 -1e25 -1e25 20 -1e25 -1e25 30]

# Cost of Purchase
πP = [5 5 10 1e25 1e25 1e25 1e25 1e25 1e25]


# Inventory holding Cost
λ = [5 5 10 0 0 20 0 0 30].*0.01/24
#  λ = [5 5 10 7 0 40 0 0 50].*0.01/24
# Cost of Utilities 
πU = [1 0.5 0.1]

# unit value of state s inventory at the end of the time horizon
# πInv = [4.5,4.5,9,0,0,18,0,0,27]

# Materials produced
ρ_out = [0 0 0 1 0 0 0 0 0;
       0 0 0 0 1 0 0 0 0;
       0 0 0 0 0 0.4 0.6 0 0;
       0 0 0 0 0 0 0 1 0;
       0 0 0 0 0 0 0.1 0 0.9]

# Materials Consumed
ρ_in = [1 0 0 0 0 0 0 0 0;
       0 0.5 0.5 0 0 0 0 0 0;
       0 0 0 0.4 0.6 0 0 0 0;
       0 0 0.2 0 0 0 0.8 0 0 ;
       0 0 0 0 0 0 0 1 0]