module PlateArrays


using Random,
JuMP,
Gurobi,
Distributions,
Plots

import Plots: plot
include("./types.jl")
include("./utils.jl")
include("./solvers/scoring.jl")
include("./solvers/exchange.jl")
include("./solvers/MILP.jl")
include("./visualize/visualize_plate.jl")



"""
    place_controls(wells::BitMatrix,P::Int,N::Int;solver::Function=exchange,objective::Function=hybrid,kwargs...)

Place optimal controls for detecting errors in microplate experiments

# Arguments 
- `wells`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 

# Keyword Arguments 
- `solver`: The algoritm used to place the controls. There are currently two solvers available: 
    1. exchange (default)
    2. MILP 
- `objective`: The objective the solver uses to score plate array candidates. 
    1. minimax -> Minimize the maximmum distance in wells from an active well to its nearest control. 
    2. LHS -> Find an approximate latin hypercube sample of the available wells in the plate. 
    3. hybrid (default) -> a weighted combination of both criteria
"""
function place_controls(wells::BitMatrix,P::Int,N::Int;solver::Function=exchange,objective::Function=hybrid,kwargs...)
    in(objective,[minimax,hybrid,LHS]) ? nothing : throw(ArgumentError("Accepted objective types are 'minimax','LHS' or 'hybrid'"))
    in(solver,[exchange,MILP]) ? nothing : throw(ArgumentError("Accepted solver types are 'exchange' and 'MILP'"))
    P >=0 ? nothing : throw(DomainError(P,"P must be >= 0"))
    N >=0 ? nothing : throw(DomainError(N,"N must be >=  0"))
    P+N <= sum(wells) ? nothing : throw(OccupancyError("The number of controls must be less than or equal to the number of available spaces."))
    return solver(wells,P,N;objective=objective,kwargs...)
        
end 


export PlateArray,place_controls,exchange,MILP,minimax,LHS,hybrid,plot



end # module PlateArrays
