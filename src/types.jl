
struct OccupancyError <: Exception 
    msg::AbstractString
end 


""" 
    struct PlateArray
        wells::BitMatrix
        positives::BitMatrix 
        negatives::BitMatrix
    end
    
    A PlateArray object describes the layout of a microwell plate that includes the active experimental wells and controls. 
"""
struct PlateArray
    wells::BitMatrix # indicator for which wells are active on the plate
    positives::BitMatrix # indicator for positive control wells
    negatives::BitMatrix # indicator for negative control wells
    function PlateArray(wells,positives,negatives)
        allequal([size(wells),size(positives),size(negatives)]) ? nothing : throw(DimensionMismatch("All array sizes must be equal"))
        any(positives .&& negatives ) ? throw(OccupancyError("positive and negative controls cannot occupy the same well")) : nothing 
        any(positives .&& .!wells) ? throw(OccupancyError("positive controls cannot occupy an inactive well")) : nothing 
        any(negatives .&& .!wells) ? throw(OccupancyError("negative controls cannot occupy an inactive well")) : nothing 
        return new(wells,positives,negatives)
    end 
end 


