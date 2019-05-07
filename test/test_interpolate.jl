using GeoStats

@testset "Interpolating rasters" begin
    ga = GeoArray(Array{Union{Missing, Float64}}(rand(10, 10)))
    ga.A[2,2] = missing
    @test sum(ismissing.(ga)) == 1
    GeoRasters.interpolate!(ga, Kriging())
    @test sum(ismissing.(ga)) == 0
end
