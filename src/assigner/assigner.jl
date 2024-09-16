using JuMP , Gurobi



function bound_plates(wells::BitMatrix,runs,controls)
    N=sum(wells)
    n_plates=0
    for i in eachindex(runs)
        max_runs_per_plate=N-controls[i]
        runs_fit=0
        while runs_fit < runs[i]
            runs_fit+=min(max_runs_per_plate,runs[i])
            n_plates+=1
        end 
    end 

    return n_plates
end 







function assign_plates(wells::BitMatrix,runs::Vector{Int},controls::Vector{Int};bound_plates=bound_plates,plate_timelimit=100,quiet=true,kwargs...)
    length(runs)==length(controls) ? nothing : throw(ArgumentError("the runs and controls vectors must be the same length"))
    ## Place experiments on plates by sequential minimization of the following criteria 
    # 1. minimize the number of plates used 
    # 2. minimize the number of splits between experiments on plates 
    # 3. minimize the total number of runs (minimize the number of controls needed because of splitting) 
    W=sum(wells)
    N=length(runs) # number of experiments 

    P=bound_plates(wells,runs,controls) # bound on number of plates

    model=Model(Gurobi.Optimizer)
    set_attribute(model,"TimeLimit",plate_timelimit)
    if quiet 
        set_silent(model)
    end 

    @variable(model, r[1:N,1:P] >= 0, Int ) # number of runs from experiment n on plate p
    @variable(model, c[1:N,1:P], Bin) # indicator for controls for experiment n on plate p 
    @variable(model, Ip[1:P],Bin) # indicator for if plate p is needed

    for p in 1:P
        @constraint(model, sum(r[:,p]+controls.*c[:,p]) <= W * Ip[p]) # number of runs per plate in use must be less than or equal to the plate size across all experiments
        for n in 1:N
         @constraint(model, !c[n,p] => {r[n,p] == 0})  # having runs from experiment i on plate j requires the controls from experiment i on plate j 
        end 
    end 

    for n in 1:N 
        @constraint(model ,sum(r[n,:])== runs[n]) # each run from experiment i must be placed on a plate 
    end 

    @objective(model, Min, sum(Ip)) # first objective, minimize plates
    optimize!(model)
    active_plates=JuMP.value.(Ip)
    min_p=sum(active_plates) # constrain the number of plates to meet this minimum
    @constraint(model, sum(Ip)==min_p)

    @objective(model, Min, sum(c)) # second objective, minimize splits (the control indicator maps whether runs exist on a plate)
    optimize!(model)
    active_splits=JuMP.value.(c)
    min_splits=sum(active_splits)
    @constraint(model, sum(c)==min_splits) 

    @objective(model, Min,sum([controls[n]*c[n,p] for n in 1:N for p in 1:P]))

    optimize!(model)

    r_out=Int.(round.(JuMP.value.(r)))
    c_out=Bool.(round.(JuMP.value.(c)))
    Ip_out=Bool.(round.(JuMP.value.(Ip)))
    k=[controls[n]*c_out[n,p] for n in 1:N, p in 1:P]

    out=r_out .+ k 
    return out[:,Ip_out]

end 





#= testing 

runs=[400,250,87]
controls=[82,150,20]

platesize=384

s,c,I=PlateMILP(runs,controls,platesize)

=#

