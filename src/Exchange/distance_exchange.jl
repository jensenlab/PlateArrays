

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
function distance_exchange(P::Int,N::Int,wells::BitMatrix;restarts::Int=10,iterations::Int=1000,kwargs...)
    global_best=PlateArray[]
    objective=Float64[]
    for i in 1:restarts 

        
        best_design=initialize_population(1,wells,P,N)[1]
        best_score=fitness_distance(best_design;kwargs...)
        for _ in 1:iterations
            pos=rand(Bernoulli(0.5))
            cand_positives=deepcopy(best_design.positives)
            cand_negatives=deepcopy(best_design.negatives)
            if pos
                current_controls= cand_positives .|| cand_negatives
                available= wells .&& .!current_controls
                pos_idxs=findall(x->x==true,cand_positives)
                if length(pos_idxs) ==0
                    continue 
                end 
                current_idx=rand(pos_idxs)
                new_idx=rand(findall(x->x==true,available))

                cand_positives[current_idx]=false # swap the location of the active bits 
                cand_positives[new_idx]=true 
            else
                current_controls= cand_positives .|| cand_negatives
                available= wells .&& .!current_controls
                neg_idxs=findall(x->x==true,cand_negatives)
                if length(neg_idxs) ==0
                    continue 
                end 
                current_idx=rand(neg_idxs)
                new_idx=rand(findall(x->x==true,available))

                cand_negatives[current_idx]=false # swap the location of the active bits 
                cand_negatives[new_idx]=true 
            end 
            design=PlateArray(wells,cand_positives,cand_negatives)
            score=fitness_distance(design;kwargs...)
            if score > best_score 
                best_score=score 
                best_design=deepcopy(design)
            end 
        end 
        push!(global_best,best_design)
        push!(objective,best_score)
    end 


    best_idx=findmax(objective)[2]
    return global_best[best_idx]
end 
