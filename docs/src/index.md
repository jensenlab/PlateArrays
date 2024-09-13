# PlateArrays.jl

*Arraying software for microwell plates* 

A julia package for placing experiments onto mircowell plates. 


# Package Features

* Place experiments onto any size plate 
* Optionally block certain wells from being used



## Getting Started 

PlateArrays is currently unregistered with Julia, but instead can be installed using the followng command: 

```julia 
pkg> add https://github.com/jensenlab/PlateArrays
```




```@docs
place_controls(wells::BitMatrix,P::Int,N::Int;solver::Function=exchange,objective::Function=hybrid,kwargs...)
```