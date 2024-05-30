# JensenLabDispense.jl
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/jensenlab/JensenLabDispense/blob/main/LICENSE)
# Contents 
[Description](#description) \
[Installing JensenLabDispense](#installing-jensenlabdispense) \
[Cobra](#cobra)


# Description 
Julia Package for controlling liquid handlers in the Jensen Lab 

# Installing JensenLabDispense
 Requires installation of  [Julia](https://julialang.org/downloads/). Once Julia is installed. Install JensenLabDispense by navigating to package mode:  

```julia 
add https://github.com/jensenlab/JensenLabDispense
```

# Cobra  
 CobraDispense generates a directory populated with the appropriate dispense files to control the Cobra Liquid handler

```julia
    CobraDispense(
        design::DataFrame,
        directory::String,
        source::String,
        destination::String,
        liquidclasses::Vector{String} ;
        kwargs...)
```
    

Create Cobra dipsense instructions for microplate source to destination operations

  ## Arguments 
  * `design`: a (# of experiments) x (# of reagents) dataframe containing the volume of each reagent for each experiment
  * `directory`: the ouput directory of the files. directory should be empty to begin with. 
  * `source`: The source plate type. See **keys(cobra_platetypes)** for available options.
  * `destination`: The destination plate type. See keys(cobra_platetypes) for available options. 
  * `liquidclasses`: A vector of liquid class types. There must be a class for each reagents. Use "Water" as default. 

  ## Keyword Arguments 
  * `washtime`: The length of the wash step in milliseconds between each dispensing operation. Default is 20000 ms.
  * `dispensepause`: if true, Cobra pauses over dispense wells to ensure large volume dispenses are accurately placed. Default is false 
  * `predispensecount`: number of predispenses. Default is 3. 




