using PlateArrays 



expt1 = Experiment(128,12,12) # an experiment that has 128 total runs. Each plate that has runs from this experiment should have 12 positive and 12 negative controls 
expt2 = Experiment(42, 8,8) 
plate = trues(8,12) # a standard 96 well plate 

plate_arrays = arrayer(plate,expt1,expt2) 

plts= plot.(plate_arrays) 

for e in 1:size(plts)[1]
    for p in 1:size(plts)[2] 

        png(plts[e,p],"./readme_figs/exp_$(e)_plt$(p).png")
    end 
end 

