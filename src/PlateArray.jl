module PlateArray


using Random,
JuMP,
Gurobi,
Distributions,
Plots

import Plots: plot

include("./utils.jl")
include("./MILP/hybrid_MILP.jl")

include("./MILP/distance_MILP.jl")

include("./Exchange/distance_exchange.jl")
include("./Exchange/hybrid_exchange.jl")
include("./Visualize/VisualizePlate.jl")



"""
    control_array(P::Int,N::Int,plate::BitMatrix;solver=hybrid_exchange,kwargs...)

Place optimal controls for detecting errors in microplate experiments

# Arguments 
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 
- `plate`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.

# Keyword Arguments 
- `solver`: The algoritm used to place the controls. There are currently four solvers available: 
    1. hybrid_exchange (default)
    2. hybrid_MILP 
    3. distance_exchange 
    4. distance_MILP

"""
function control_array(P::Int,N::Int,plate::BitMatrix;solver=hybrid_exchange,kwargs...)
    P >=0 ? nothing : error("P must be greater than or equal to 0")
    N >=0 ? nothing : error("N must be greater than or equal to 0")
    P+N <= sum(plate) ? nothing : error("The number of controls must be less than or equal to the number of available spaces.")
    return solver(P,N,plate;kwargs...)
end 


export PlateArray,fitness,fitness_distance,hybrid_MILP,distance_MILP,distance_exchange,hybrid_exchange, plot, control_array



end # module PlateArray
