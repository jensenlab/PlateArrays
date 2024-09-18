

function arrayer(wells::BitMatrix,experiments::Vararg{Experiment};kwargs...)

    assignments=assign_plates(wells,experiments...;kwargs...)

    N,P=size(assignments)
    r,c=size(wells)
    plate_arrays=[PlateArray(falses(r,c),falses(r,c),falses(r,c)) for n in 1:N,p in 1:P]

    for p in 1:P 
        well_partitions=partition(wells,assignments[:,p]...) 
        for n in 1:N 
            if assignments[n,p]==0 
                continue 
            else 
                plate_arrays[n,p]=place_controls(well_partitions[n],experiments[n].positive_controls,experiments[n].negative_controls;kwargs...)
            end
        end 
    end 
    return plate_arrays

end 