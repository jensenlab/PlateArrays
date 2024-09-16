# PlateArrays.jl

*Arraying software for microwell plates* 

A julia package for placing experiments onto mircowell plates. 


# Package Features

* Array runs for experiments onto any size plate 
* Optimally place control wells for any run array. 
* Block wells from being used
* Minimize labware usage by binpacking runs from multiple experiments onto as few plates as possible.


## Getting Started 

PlateArrays is currently unregistered with Julia, but instead can be installed using the followng command: 

```julia 
pkg> add https://github.com/jensenlab/PlateArrays
```




```@docs
place_controls(wells::BitMatrix,P::Int,N::Int;solver::Function=exchange,objective::Function=hybrid,kwargs...)
```