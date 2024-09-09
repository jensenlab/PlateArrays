mutable struct Plate
    P::Int # number of positive controls 
    N::Int # number of negative controls 
    wells::BitMatrix # indicator for which wells are active on the plate
    pos::BitMatrix # indicator for positive control wells
    neg::BitMatrix # indicator for negative control wells
    Plate(P,N,wells,pos,neg)= any(pos .&& .!wells) || any(neg .&& .!wells) ? new(P,N,wells,pos,neg)
end 


function get_margins(plate::BitMatrix)
    R,C=size(plate)
    rowsum=sum(plate[:,i] for i in 1:C)
    colsum=sum(plate[i,:] for i in 1:R)
    return rowsum,colsum
end 


function expected_LHS(P::Int,N::Int,plate::BitMatrix)
    row_margin,col_margin=get_margins(plate)


    e_p_rows=P*row_margin/sum(row_margin)
    e_p_cols=P*col_margin/sum(col_margin)

    e_n_rows=N*row_margin/sum(row_margin)
    e_n_cols=N*col_margin/sum(col_margin)
    return e_p_rows,e_p_cols,e_n_rows,e_n_cols
end 

function get_neighbors(row,col,R,C)
    ringarray=Tuple{Int,Int}[]
    push!(ringarray,(max(row-1,1),col))
    push!(ringarray,(min(row+1,R),col))
    push!(ringarray,(row,min(col+1,C)))
    push!(ringarray,(row,max(col-1,1)))
    return ringarray

end
function get_ring(row,col,ring,R,C)
    wells=[(row,col)]
    orig=(row,col)
    sol=Tuple{Int,Int}[]
    sol=vcat(sol,wells)
    for i=1:ring
        rows=map(y -> y[1],wells)
        cols=map(y -> y[2],wells)
        wells=get_neighbors.(rows,cols,R,C)
        wells=reduce(vcat,wells)
        wells=unique(wells)
        sol=vcat(sol,wells)

    end
    return unique(sol)
end

function manhattan_distance(p1::Tuple{Int,Int},p2::Tuple{Int,Int})

    return sum(abs.(p1.-p2))
end 










function LHS_score(design::PlateArray)
    row_margin,col_margin=get_margins(design.plate)

    row_idxs=findall(x-> x>0,row_margin)
    col_idxs=findall(x->x>0,col_margin)

    # grab only rows that have active wells (avoid divide by zero error later)
    valid_rows=row_margin[row_idxs]
    valid_cols=col_margin[col_idxs]
    P=design.P
    N=design.N


    p_rows,p_cols=get_margins(design.pos)
    n_rows,n_cols=get_margins(design.neg)

    p_rows=p_rows[row_idxs]
    p_cols=p_cols[col_idxs]
    n_rows=n_rows[row_idxs]
    n_cols=n_cols[col_idxs]

    expected_p_rows=P*valid_rows/sum(valid_rows)
    expected_p_cols=P*valid_cols/sum(valid_cols)

    expected_n_rows=N*valid_rows/sum(valid_rows)
    expected_n_cols=N*valid_cols/sum(valid_cols)

    pos_score= sum((p_rows.-expected_p_rows).^2) +sum((p_cols.-expected_p_cols).^2)
    neg_score= sum((n_rows.-expected_n_rows).^2) + sum((n_cols.-expected_n_cols).^2)

    return pos_score + neg_score 
end 


function approximate_LHS_bound(design::PlateArray)
    lb=0
    row_margin,col_margin=get_margins(design.plate)
    P=design.P
    N=design.N
    row_idxs=findall(x-> x>0,row_margin)
    col_idxs=findall(x->x>0,col_margin)
    valid_rows=row_margin[row_idxs]
    valid_cols=col_margin[col_idxs]


    expected_p_rows=P*valid_rows/sum(valid_rows)
    expected_p_cols=P*valid_cols/sum(valid_cols)

    expected_n_rows=N*valid_rows/sum(valid_rows)
    expected_n_cols=N*valid_cols/sum(valid_cols)




    p_rows=[0 for _ in 1:length(row_idxs)]
    p_cols=[0 for _ in 1:length(col_idxs)]
    n_rows=[0 for _ in 1:length(row_idxs)]
    n_cols=[0 for _ in 1:length(col_idxs)]

    pos_array=falses(length(row_idxs),length(col_idxs))
    neg_array=falses(length(row_idxs),length(col_idxs))
    dir=false
    if length(col_idxs) > length(row_idxs)
        dir=true
    end 

    p_rows,p_cols=fill_array_max_var(pos_array,P;coldir=dir)
    n_rows,n_cols=fill_array_max_var(neg_array,N;coldir=dir)


    pos_score= sum((p_rows.-expected_p_rows).^2) +sum((p_cols.-expected_p_cols).^2)
    neg_score= sum((n_rows.-expected_n_rows).^2) + sum((n_cols.-expected_n_cols).^2)


    ub=pos_score+neg_score

    return lb,ub

end

function fill_array_max_var(initial_array,n;coldir=false)
    if coldir
        initial_array=initial_array'
    end 
    for i in 1:n
        initial_array[i]=true
    end 
    if coldir
        initial_array=initial_array'
    end 
    return get_margins(initial_array)
end 







function distance_score_ring(design::PlateArray)
    R,C=size(design.plate)
    pos_dist=zeros(Int,R,C)
    neg_dist=zeros(Int,R,C)
    

    M=max(R,C)

    for r in 1:R
        for c in 1:C
            if !design.plate[r,c]
                continue 
            else 
                for ring in 0:M
                    idxs=CartesianIndex.(get_ring(r,c,ring,R,C))
                    foundpos=any(design.pos[idxs])
                    foundneg=any(design.neg[idxs])
                    if foundpos && foundneg 
                        break 
                    else
                        if !foundpos 
                            pos_dist[r,c]+=1
                        end 
                        if !foundneg
                            neg_dist[r,c]+=1
                        end 
                    end 
                end 
            end 
        end 
    end 

    return sum(pos_dist .+ neg_dist)
end 



function distance_score_brute(design::PlateArray;distance=manhattan_distance,kwargs...)
    R,C=size(design.plate)
    pos_dist=zeros(Int,R,C)
    neg_dist=zeros(Int,R,C)
    
    pos_coords=Tuple.(findall(x->x==true,design.pos))
    neg_coords=Tuple.(findall(x->x==true,design.neg))
    if length(pos_coords)==0
        pos_dist.=max(R,C)*design.plate
    else
        for r in 1:R 
            for c in 1:C
                if !design.plate[r,c]
                    continue 
                else 
                    pos_dist[r,c] = minimum(distance.(((r,c),), pos_coords ))

                end 
            end 
        end
    end 
    
    if length(neg_coords)==0
        neg_dist.=max(R,C)*design.plate
    else


        for r in 1:R 
            for c in 1:C
                if !design.plate[r,c]
                    continue 
                else 

                    neg_dist[r,c]= minimum(distance.(((r,c),), neg_coords ))
                end 
            end 
        end
    end 
    return sum(pos_dist .+ neg_dist)
end 


function scale(num,lb,ub)

    return (num-lb)/(ub-lb)
end 


function fitness(design::PlateArray;lambda=0.5,lb_dist=0,ub_dist=1,lb_LHS=0,ub_LHS=1,kwargs...)

    0<=lambda<=1 ? nothing : error("lambda must be between 0 and 1 inclusive.")
    s1=scale(distance_score_brute(design;kwargs...),lb_dist,ub_dist)
    s2=scale(LHS_score(design),lb_LHS,ub_LHS)

    score=lambda*s1 + (1-lambda)*s2
    return -score 
end 




function fitness_distance(design::PlateArray;minimize=true,kwargs...)

    if minimize
        return -distance_score_brute(design;kwargs...)
    else 
        return distance_score_brute(design;kwargs...)
    end 
end 

function initialize_population(popsize::Int,plate::BitMatrix,P,N)
    population=[]
    availables=findall(x->x==true,plate)

    for i=1:popsize
        pos=falses(size(plate))
        neg=falses(size(plate))
        pos_idx=sample(availables,P;replace=false)
        pos[pos_idx] .=true 
        neg_available=findall(x->x==true, plate .&& .!pos)
        neg_idx=sample(neg_available,N;replace=false)
        neg[neg_idx].=true
        design=PlateArray(P,N,plate,pos,neg)
        push!(population,design)
    end 
    return population
end