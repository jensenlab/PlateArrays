function distance_exchange(P,N,plate;iterations=2000,kwargs...)

    best_design=initialize_population(1,plate,P,N)[1]
    best_score=fitness_distance(best_design;kwargs...)
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

        score=fitness_distance(design;kwargs...)
        if score > best_score 
            best_score=score 
            best_design=deepcopy(design)
        end 
    end 
    return best_design
end 
