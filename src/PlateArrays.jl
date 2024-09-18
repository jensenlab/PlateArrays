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
include("./assign/partition.jl")
include("./assign/assign_plates.jl")
include("./visualize/visualize_plate.jl")
include("./arrayer/arrayer.jl")





#types.jl
export PlateArray,Experiment,Expt,OccupancyError

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
#assign_plates
export assign_plates
#arrayer.jl
export arrayer
#visualize_plate
export plot



end # module PlateArrays
