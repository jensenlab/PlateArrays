

function arrayer(wells::BitMatrix,experiments::Vararg{Experiment};kwargs...)

    assignments=assign_plates(wells,experiments...)

    n,p=size(assignments)

    



end 