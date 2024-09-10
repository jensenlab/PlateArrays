using JuMP , Gurobi






"""
    hybrid_MILP(P::Int,N::Int,wells::BitMatrix;MILP_timelimit=100,MILP_output=true,kwargs...)

MILP solver for control placment using a hybrid latin hypercube and distance criteria. Requires Gurobi licence.

# Arguments 
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 
- `wells`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.

# Keyword Arguments 
- `MILP_timelimit`: time limit in seconds for the solver to return a suboptimal solution if it hasn't found an optimal one
- `MILP_output`: if true, solver prints status updates to the console. 

"""
function hybrid_MILP(P::Int,N::Int,wells::BitMatrix;MILP_timelimit=100,MILP_output=true,kwargs...)

    P+N <= sum(wells) ? nothing : error("There are more controls to place than active wells on the plate")


    R,C=size(wells) # get the number of rows and columns in a plate
    model=JuMP.Model(Gurobi.Optimizer)
    set_attribute(model,"TimeLimit",MILP_timelimit)
    if !MILP_output
        set_attribute(model,"OutputFlag",0)
    end 
    @variable(model, x[1:R,1:C],Bin);
    @variable(model,y[1:R,1:C],Bin);
    @variable(model,dwx[1:R,1:C]>=0);
    @variable(model,dwy[1:R,1:C]>=0);



    @constraint(model, sum(x)==P); # place P positive controls on the plate 
    @constraint(model, sum(y)==N); # place N negative controls on the plate
    for row in 1:R
        for col in 1:C
            @constraint(model,x[row,col]+y[row,col]<=1) # at most one control per well 
            @constraint(model, x[row,col] <= wells[row,col]) # controls can only be placed in active wells
            @constraint(model,y[row,col] <= wells[row,col]) # controls can only be placed in active wells

        end
    end
    

    epr,epc,enr,enc=expected_LHS(P,N,wells) # given the plate shape, find the expected number of controls per row and column in a uniformly distributed array of controls. 

    #constrain the number of controls to be as close as possible to the expected LHS 
    for row in 1:R
        @constraint(model, sum(x[row,:])<= Int(ceil(epr[row]))) 
        @constraint(model,sum(x[row,:]) >= Int(floor(epr[row])))
        @constraint(model, sum(y[row,:])<= Int(ceil(enr[row])))
        @constraint(model,sum(y[row,:])>= Int(floor(enr[row])))
    end 

    for col in 1:C
        @constraint(model,sum(x[:,col])<= Int(ceil(epc[col])))
        @constraint(model,sum(x[:,col])>= Int(floor(epc[col])))
        @constraint(model,sum(y[:,col])<= Int(ceil(enc[col])))
        @constraint(model,sum(y[:,col])>= Int(floor(enc[col])))
    end

    M=max(R,C) # M is the maximum distance for a nearest control search. 
    # constrain the distance variable to serve as a measure of control spacing. 
    for row in 1:R
        for col in 1:C
            for ring in 0:M
                w=get_ring(row,col,ring,R,C)
                r=map(y->y[1],w)
                c=map(y->y[2],w)
                @constraint(model,dwx[row,col]>=ring+1-(ring+1)*sum([x[r[i],c[i]] for i =1:length(w)]));
                @constraint(model,dwy[row,col]>=ring+1-(ring+1)*sum([y[r[i],c[i]] for i =1:length(w)]))
            end
        end
    end
        @objective(model,Min,sum(wells .* (dwx+dwy)));
    optimize!(model)
    pos=BitMatrix(JuMP.value.(x))
    neg=BitMatrix(JuMP.value.(y))
    out=PlateArray(wells,pos,neg)
    return out
end 
#

#= test 

R=16
C=24

N_pos=12

N_neg=12

wells=13:132
expts,pos,neg=ControlMILP(N_pos,N_neg,R,C,wells,timelimit=100)

experiment=ExperimentArray(R,C,expts,pos,neg,0)

VisualizePlate(experiment)
=#