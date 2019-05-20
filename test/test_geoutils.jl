@testset "GeoUtils" begin
    @testset "bbox" begin
        ga = GeoArrays.read("data/utmsmall.tif")
        @test GeoArrays.bbox(ga) == (min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6)
    end

    @testset "flip upside down" begin
        ga = GeoArrays.read("data/utmsmall.tif")
        ga_identical = GeoArrays.read("data/utmsmall.tif")
        @test ga == ga_identical
        GeoArrays.flipud!(ga)
        @test ga != ga_identical
        GeoArrays.flipud!(ga)
        @test ga == ga_identical
    end
end
