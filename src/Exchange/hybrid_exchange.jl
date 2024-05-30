function hybrid_exchange(P,N,plate;iterations=10000,kwargs...)
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
            current_idx=rand(findall(x->x==true,design.pos))
            new_idx=rand(findall(x->x==true,available))

            design.pos[current_idx]=false # swap the location of the active bits 
            design.pos[new_idx]=true 
        else
            current_controls= design.pos .|| design.neg
            available= design.plate .&& .!current_controls
            current_idx=rand(findall(x->x==true,design.neg))
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
