

"""
    hybrid_exchange(P,N,plate;iterations=10000,kwargs...)   

MILP solver for control placment using a hybrid latin hypercube and distance criteria. Requires Gurobi licence.

# Arguments 
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 
- `plate`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.

# Keyword Arguments 
- `iterations`: number of exchange iterations 
- `lambda`: weight given to distance criteria, can range from (0,1). 0 means that we only care about the latin hypercube critera, 1 means we only care about distance. default is 0.5.  

"""
function hybrid_exchange(P::Int,N::Int,plate::BitMatrix;iterations::Int=10000,kwargs...)
    best_design=initialize_population(1,plate,P,N)[1]
    lb_LHS,ub_LHS=approximate_LHS_bound(best_design)
    min_dist_design=distance_exchange(P,N,plate;iterations=iterations)
    max_dist_design=distance_exchange(P,N,plate;minimize=false,iterations=iterations)
    lb_dist=distance_score_brute(min_dist_design)
    ub_dist=distance_score_brute(max_dist_design)
    
    best_score=fitness(best_design;lb_LHS=lb_LHS,ub_LHS=ub_LHS,lb_dist=lb_dist,ub_dist=ub_dist,kwargs...)
    for _ in 1:iterations
        design=deepcopy(best_design)
        pos=rand(Bernoulli(0.5))
        if pos
            current_controls= design.pos .|| design.neg
            available= design.plate .&& .!current_controls
            pos_idxs=findall(x->x==true,design.pos)
            if length(pos_idxs) ==0
                continue 
            end 
            current_idx=rand(pos_idxs)
            new_idx=rand(findall(x->x==true,available))

            design.pos[current_idx]=false # swap the location of the active bits 
            design.pos[new_idx]=true 
        else
            current_controls= design.pos .|| design.neg
            available= design.plate .&& .!current_controls
            neg_idxs=findall(x->x==true,design.neg)
            if length(neg_idxs) ==0
                continue 
            end 
            current_idx=rand(neg_idxs)
            new_idx=rand(findall(x->x==true,available))

            design.neg[current_idx]=false # swap the location of the active bits 
            design.neg[new_idx]=true 
        end 

        score=fitness(design;lb_LHS=lb_LHS,ub_LHS=ub_LHS,lb_dist=lb_dist,ub_dist=ub_dist,kwargs...)
        if score > best_score 
            best_score=score 
            best_design=deepcopy(design)
        end 
    end 
    return best_design
end 
