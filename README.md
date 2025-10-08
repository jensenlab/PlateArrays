# PlateArrays.jl
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/jensenlab/ControlArray/blob/main/LICENSE)


# Description 
Place optimal controls for detecting errors in microplate experiments. 

# Installing PlateArrays
 Requires installation of  [Julia](https://julialang.org/downloads/). Once Julia is installed. Install ControlArray by navigating to package mode:  

```julia 
add https://github.com/jensenlab/PlateArrays
```

# The `place_controls` function

Place optimal controls for detecting errors in microplate experiments

## Arguments 
- `wells`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 

## Keyword Arguments 
- `solver`: The algoritm used to place the controls. There are currently two solvers available: 
    1. exchange (default)
    2. MILP 
- `objective`: The objective the solver uses to score plate array candidates. 
    1. minimax -> Minimize the maximmum distance in wells from an active well to its nearest control. 
    2. LHS -> Find an approximate latin hypercube sample of the available wells in the plate. 
    3. hybrid (default) -> a weighted combination of both criteria


**Note**: MILP solvers return globally optimal solutions but their runtimes can be unpredictable; conversely, coordinate exchange algorithms are not gauranteed to be globally optimal but scale more favorably for large problems. In practice, we find that the exchange algorithm returns near optimal solutions in a fraction of the time of the MILP solver for 384 and 1536 well plate problems. See documentation for solver hyperparameters. 
## Example Usage 
```julia
    using PlateArrays 
    plate = trues(8,12) # 96 well plate
    # place 12 positive and 12 negative controls with a minimax objective and exchange algorithm
    design=place_controls(plate,12,12;solver = exchange, objective=hybrid)
    plot(design)
```
![example_plate](https://github.com/jensenlab/PlateArrays/blob/main/example_plate.svg)  


The solvers can handle situations when certain wells are "blocked". Here, wells A1-E2 are unavailable. The algorithms place controls that fill the new geometry of available wells. 
```julia 
    plate[:,1].=false
    plate[1:5,2].=false
    design=place_controls(plate,12,12;solver = exchange, objective=hybrid)
    plot(design)
```
![example_plate_blocked](https://github.com/jensenlab/PlateArrays/blob/main/example_plate_blocked.svg)



# The `arrayer` function 

Schedule Experiment objects onto plates in three steps: 
1. assign all experiments to as few plates as possible
2. partition plates that contain multiple experiments and select wells to hold each run. Use central wells first. 
3. place a full complement of controls on each plate that has a given experiment

## Arguments 
- `wells`: A BitMatrix of active wells on each plate (block any inactive wells by setting them to false)
- `experiments`: Array a variable number of `Experiment` objects
"""

## Example Usage 

```julia 
using PlateArrays 

expt1 = Experiment(128,12,12) # an experiment that has 128 total runs. Each plate that has runs from this experiment should have 12 positive and 12 negative controls 
expt2 = Experiment(42, 8,8) 
plate = trues(8,12) # a standard 96 well plate 

plate_arrays = arrayer(plate,expt1,expt2) 

array_plots = plot.(plate_arrays)


```
![example_plate_blocked](https://github.com/jensenlab/PlateArrays/blob/main/readme_figs/arrayer.png)


