

"""
    distance_exchange(P::Int,N::Int,plate::BitMatrix;iterations=2000,kwargs...)   

MILP solver for control placment using a hybrid latin hypercube and distance criteria. Requires Gurobi licence.

# Arguments 
- `P`: The integer number of positive controls
- `N`: The integer number of negative controls 
- `plate`: A BitMatrix indicating the shape and active wells, use `trues(n,m)` for a full n x m plate.

# Keyword Arguments 
- `iterations`: number of exchange iterations  

"""
function distance_exchange(P::Int,N::Int,plate::BitMatrix;iterations=2000,kwargs...)

    best_design=initialize_population(1,plate,P,N)[1]
    best_score=fitness_distance(best_design;kwargs...)
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

        score=fitness_distance(design;kwargs...)
        if score > best_score 
            best_score=score 
            best_design=deepcopy(design)
        end 
    end 
    return best_design
end 
