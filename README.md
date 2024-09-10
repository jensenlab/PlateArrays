# PlateArrays.jl
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/jensenlab/ControlArray/blob/main/LICENSE)


# Description 
Place optimal controls for detecting errors in microplate experiments. 

# Installing PlateArrays
 Requires installation of  [Julia](https://julialang.org/downloads/). Once Julia is installed. Install ControlArray by navigating to package mode:  

```julia 
add https://github.com/jensenlab/PlateArrays
```

# Overview  
the `control_array` function generates microplate designs with optimal control placment. `control_array` takes three arguments: 
1.  `P`: The number of positive controls in the design 
2.  `N`: The number of negative controls in the design 
3.  `plate`: A binary array showing the shape of the plate and active wells (wells that are allowed to be used for controls or experiments) 

`control_array` places controls using using one of four solvers: 

1. `hybrid_exchange` (default): A coordinate exchange algorithm that uses a [hybrid latin hypercube and maximin objective criteria](https://bookdown.org/rbg/surrogates/chap4.html) to place controls.
2. `distance_exchange`: A coordinate exchange algorithm that uses only a maximin distance criteria to place controls    
3. `hybrid_MILP`: An [MILP](https://en.wikipedia.org/wiki/Integer_programming) formulation of the control placement problem using the hybrid objective
4. `distance_MILP`: An MILP formulation using only a maximin distance objective

**Note**: MILP solvers return globally optimal solutions but their runtimes can be unpredictable; conversely, coordinate exchange algorithms are not gauranteed to be globally optimal but scale more favorably for large problems. In practice, we find that the exchange algorithm returns near optimal solutions in a fraction of the time of the MILP solver for 384 and 1536 well plate problems. See documentation for solver hyperparameters. 
# Example Usage 
```julia
    using PlateArray 
    plate = trues(8,12) # 96 well plate
    design=control_array(12,12,plate;solver=hybrid_exchange)
    plot(design)
```
![example_plate](https://github.com/jensenlab/ControlArray/blob/main/example_plate.svg)  


The solvers can handle situations when certain wells are "blocked". Here, wells A1-E2 are unavailable. The algorithms place controls that fill the new geometry of available wells. 
```julia 
    plate[:,1].=false
    plate[1:5,2].=false
    design=control_array(12,12,plate;solver=hybrid_exchange)
    plot(design)
```
![example_plate_blocked](https://github.com/jensenlab/ControlArray/blob/main/example_plate_blocked.svg)



