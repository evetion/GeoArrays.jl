using StaticArrays
using GeoStatsTransforms
using GeoStatsModels


@testset "Interpolating rasters" begin
    @testset "Regular Grid interpolation" begin
        ga = GeoArray(Array{Union{Missing,Float64}}(rand(10, 10, 1)), GeoArrays.geotransform_to_affine(SVector(0.0, 1.0, 0.0, 0.0, 0.0, 1.0)), "")
        ga.A[2, 2, 1] = missing
        @test count(ismissing, ga.A) == 1
        GeoArrays.fill!(ga, IDW())
        @test count(ismissing, ga.A) == 0
    end
    @testset "Regular Grid interpolation with negative spacing" begin
        ga = GeoArray(Array{Union{Missing,Float64}}(rand(10, 10, 1)), GeoArrays.geotransform_to_affine(SVector(0.0, 1.0, 0.0, 0.0, 0.0, -1.0)), "")
        ga.A[2, 2, 1] = missing
        @test count(ismissing, ga.A) == 1
        GeoArrays.fill!(ga, IDW())
        @test count(ismissing, ga.A) == 0
    end
    # TODO Currently broken
    # @testset "Irregular Grid interpolation" begin
    # ga = GeoArray(Array{Union{Missing,Float64}}(rand(10, 10, 1)), GeoArrays.geotransform_to_affine(SVector(0.0, 1.0, 1.0, 0.0, 0.0, 1.0)), "")
    # ga.A[2, 2, 1] = missing
    # @test count(ismissing, ga.A) == 1
    # GeoArrays.fill!(ga, IDW(2), maxneighbors=5)
    # @test count(ismissing, ga.A) == 0
    # end
end
