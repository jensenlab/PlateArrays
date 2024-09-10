
function hybrid_exchange_timeseries(P::Int,N::Int,plate::BitMatrix;iterations::Int=10000,kwargs...)
    best_design=initialize_population(1,wells,P,N)[1]
    lb_LHS,ub_LHS=approximate_LHS_bound(best_design)
    min_dist_design=distance_exchange(P,N,wells;iterations=iterations)
    max_dist_design=distance_exchange(P,N,wells;minimize=false,iterations=iterations)
    lb_dist=distance_score_brute(min_dist_design)
    ub_dist=distance_score_brute(max_dist_design)
    all_best=PlateArray[]
    all_best_score=Float64[]
    best_score=fitness(best_design;lb_LHS=lb_LHS,ub_LHS=ub_LHS,lb_dist=lb_dist,ub_dist=ub_dist,kwargs...)
    for _ in 1:iterations
        pos=rand(Bernoulli(0.5))
        cand_positives=best_design.positives
        cand_negatives=best_design.negatives
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
        score=fitness(design;lb_LHS=lb_LHS,ub_LHS=ub_LHS,lb_dist=lb_dist,ub_dist=ub_dist,kwargs...)
        if score > best_score 
            best_score=score 
            best_design=deepcopy(design)
            push!(all_best,best_design)
            push!(all_best_score,best_score)
        end 
    end 
    return all_best, all_best_score
end 
