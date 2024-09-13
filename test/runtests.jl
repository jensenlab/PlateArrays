using Test , PlateArrays

import PlateArrays: OccupancyError,margins,expected_LHS,neighbors

@testset "Construction" begin
    @test isa(PlateArray(trues(8,12),falses(8,12),falses(8,12)),PlateArray)
    @test isa(PlateArray(trues(16,24),falses(16,24),falses(16,24)),PlateArray)
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


wells=trues(8,12)
wells[1:4,1].=false
wells[:,12].=false

pos=falses(8,12)
pos[2,2]=true
pos[3,8]=true
pos[5,1]=true
pos[4,6]=true
pos[5,5]=true
pos[6,3]=true
pos[6,8]=true
pos[7,4]=true
neg=falses(8,12)
neg[2,4]=true
neg[3,5]=true
neg[4,2]=true
neg[4,8]=true
neg[5,2]=true
neg[6,6]=true
neg[8,7]=true
neg[4,10]=true

plate=PlateArray(wells,pos,neg)

@testset "ScoringTests" begin
    
    @test margins(wells) == ([10, 10, 10, 10, 11, 11, 11, 11], [4, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0])
    @test LHS(plate) ≈ 18.31746031746031
    @test neighbors(4,4,8,12) ==  [(3, 4),(5, 4),(4, 5),(4, 3)]
    @test minimax(plate) ==322
    @test hybrid(plate;lambda=0.5) ≈ LHS(plate)/2 + minimax(plate)/2
    @test hybrid(plate;lambda=0) ≈ LHS(plate)
    @test hybrid(plate; lambda=1) ≈ minimax(plate)
    
end





