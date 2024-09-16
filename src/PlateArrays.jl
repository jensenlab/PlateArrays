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
include("./controls/place_controls.jl")
include("./arrayer/partition.jl")
include("./visualize/visualize_plate.jl")





#types.jl
export PlateArray

#utils.jl
export runs, random_platearray,active_indices
#scoring.jl
export minimax,LHS,hybrid
#exchange.jl 
export exchange
#MILP.jl
export MILP
#place_controls.jl
export place_controls
#partition.jl
export partition
#visualize_plate
export plot



end # module PlateArrays
