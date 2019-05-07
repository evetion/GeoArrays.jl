@testset "GeoUtils" begin
    ga = GeoRasters.read("data/utmsmall.tif")
    @test GeoRasters.bbox(ga) == (min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6)
end
