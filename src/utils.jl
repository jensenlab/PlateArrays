


function random_platearray(wells::BitMatrix,P::Int,N::Int)
    availables=findall(x->x==true,wells)
    R,C=size(wells)
    pos=falses(R,C)
    neg=falses(R,C)
    pos_idx=sample(availables,P;replace=false)
    pos[pos_idx] .=true 
    neg_available=findall(x->x==true, wells .&& .!pos)
    neg_idx=sample(neg_available,N;replace=false)
    neg[neg_idx].=true
    return PlateArray(wells,pos,neg)
end 