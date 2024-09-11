using Test , PlateArrays

import PlateArrays: OccupancyError

@testset "Construction" begin
    @test isa(PlateArray(trues(8,12),falses(8,12),falses(8,12)),PlateArray)
    @test_throws DimensionMismatch PlateArray(trues(8,12),falses(16,24),falses(8,12))
    x=falses(8,12)
    x[1,1]=true
    @test_throws OccupancyError PlateArray(trues(8,12),x,x)
    x=trues(8,12)
    x[1,1]=false 
    y=falses(8,12)
    y[1,1]=true
    @test_throws OccupancyError PlateArray(x,y,falses(8,12))
    @test_throws OccupancyError PlateArray(x,falses(8,12),y)
end