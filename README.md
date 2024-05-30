# ControlArray.jl
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/jensenlab/ControlArray/blob/main/LICENSE)


# Description 
Place optimal controls for detecting errors in microplate experiments. 

# Installing ControlArray
 Requires installation of  [Julia](https://julialang.org/downloads/). Once Julia is installed. Install ControlArray by navigating to package mode:  

```julia 
add https://github.com/jensenlab/ControlArray
```

# Example Usage  
 CobraDispense generates a directory populated with the appropriate dispense files to control the Cobra Liquid handler

```julia
    using ControlArray 
    plate = trues(8,12) # 96 well plate
    design=control_array(12,12,plate;solver=hybrid_exchange)

    plot(design)
```
[![example_plate](https://github.com/jensenlab/ControlArray/blob/main/example_plate.svg) ]  

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




