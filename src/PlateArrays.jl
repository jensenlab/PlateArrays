module PlateArrays


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
include("./Visualize/visualize_plate.jl")



"""
    control_array(P::Int,N::Int,wells::BitMatrix;solver=hybrid_exchange,kwargs...)

Place optimal controls for detecting errors in microplate experiments

# Arguments 
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 
- `wells`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.

# Keyword Arguments 
- `solver`: The algoritm used to place the controls. There are currently four solvers available: 
    1. hybrid_exchange (default)
    2. hybrid_MILP 
    3. distance_exchange 
    4. distance_MILP

"""
function place_controls(P::Int,N::Int,wells::BitMatrix;solver::Function=hybrid_exchange,kwargs...)
    P >=0 ? nothing : throw(DomainError(P,"P must be >= 0"))
    N >=0 ? nothing : throw(DomainError(N,"N must be >=  0"))
    P+N <= sum(wells) ? nothing : throw(OccupancyError("The number of controls must be less than or equal to the number of available spaces."))
    return solver(P,N,wells;kwargs...)
        
end 


export PlateArray,fitness,fitness_distance,hybrid_MILP,distance_MILP,distance_exchange,hybrid_exchange, plot, place_controls



end # module PlateArrays
