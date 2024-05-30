




function distance_MILP(P::Int,N::Int,plate::BitMatrix;minimize=true,timelimit=100)
    R,C=size(plate)
    model=Model(Gurobi.Optimizer)
    set_attribute(model,"TimeLimit",timelimit)
    @variable(model, x[1:R,1:C],Bin);
    @variable(model,y[1:R,1:C],Bin);
    @variable(model,dwx[1:R,1:C]>=0);
    @variable(model,dwy[1:R,1:C]>=0);




    @constraint(model, sum(x)==P);
    @constraint(model, sum(y)==N);
    for row in 1:R
        for col in 1:C
            @constraint(model,x[row,col]+y[row,col]<=1)
            @constraint(model, x[row,col] <= plate[row,col])
            @constraint(model,y[row,col] <= plate[row,col])

        end
    end
    M=max(R,C)


    if minimize
        for row in 1:R
            for col in 1:C
                for ring in 0:M
                    wells=get_ring(row,col,ring,R,C)
                    r=map(y->y[1],wells)
                    c=map(y->y[2],wells)
                    @constraint(model,dwx[row,col]>=ring+1-(ring+1)*sum([x[r[i],c[i]] for i =1:length(wells)]));
                    @constraint(model,dwy[row,col]>=ring+1-(ring+1)*sum([y[r[i],c[i]] for i =1:length(wells)]))
                end
            end
        end
        @objective(model,Min,sum(plate .* (dwx+dwy)));
    else 
        @variable(model, Idwx[1:R,1:C,1:M+1],Bin)
        @variable(model,Idwy[1:R,1:C,1:M+1],Bin)

        for row in 1:R
            for col in 1:C
                for ring in 0:M
                    wells=get_ring(row,col,ring,R,C)
                    r=map(y->y[1],wells)
                    c=map(y->y[2],wells)
                    @constraint(model ,Idwx[row,col,ring+1] => {sum([x[r[i],c[i]] for i =1:length(wells)]) ==0})
                    @constraint(model ,Idwy[row,col,ring+1] => {sum([y[r[i],c[i]] for i =1:length(wells)]) ==0})
                    
                    @constraint(model,dwx[row,col]<= ring +M*Idwx[row,col,ring+1])
                    @constraint(model,dwy[row,col]<= ring +M*Idwy[row,col,ring+1])
                    
                    
 

                end
            end
        end
        @objective(model,Min,-1*sum(plate.*(dwx+dwy)));
    end
    optimize!(model)
    return PlateArray(P,N,plate,BitMatrix(JuMP.value.(x)),BitMatrix(JuMP.value.(y)))
end

#= test 

R=16
C=24

N_pos=12

N_neg=12

wells=13:81
x,y,dwx,dwy,model=ControlDistanceMILP(N_pos,N_neg,R,C,wells,minimize=false)
=#