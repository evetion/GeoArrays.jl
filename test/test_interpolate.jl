using GeoStats
using StaticArrays

@testset "Interpolating rasters" begin
    @testset "Regular Grid interpolation" begin
        ga = GeoArray(Array{Union{Missing, Float64}}(rand(10, 10)))
        ga.A[2,2] = missing
        @test count(ismissing, ga) == 1
        GeoArrays.interpolate!(ga, Kriging())
        @test count(ismissing, ga) == 0
    end
    @testset "Irregular Grid interpolation (not yet supported)" begin
        ga = GeoArray(Array{Union{Missing, Float64}}(rand(10, 10, 1)), GeoArrays.geotransform_to_affine(SVector(0.,1.,1.,0.,0.,1.)), "")
        @test_throws ErrorException GeoArrays.interpolate!(ga, Kriging())
    end
end
