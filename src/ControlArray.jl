module ControlArray


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

function control_array(P::Int,N::Int,plate::BitMatrix;solver=hybrid_exchange,kwargs...)
    return solver(P,N,plate;kwargs...)
end 


export PlateArray,fitness,fitness_distance,hybrid_MILP,distance_MILP,distance_exchange,hybrid_exchange, plot, control_array



end # module ControlArray
