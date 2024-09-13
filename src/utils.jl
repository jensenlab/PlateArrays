


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





"""
    runs(platearray::PlateArray)

Compute the non-control active wells of a PlateArray.

"""
function runs(platearray::PlateArray)
    return platearray.wells .&& .!platearray.positives .&& .!platearray.negatives
end 


"""
    active_indices(plate::BitMatrix)

Compute the integer indices of active wells. 
"""
function active_indices(plate::BitMatrix)
    r,c=size(plate)
    x=vec(reshape(plate,r*c,1))
    return findall(y->y==true,x)
end 
