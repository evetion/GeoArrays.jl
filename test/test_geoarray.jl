
@testset "Reading rasters" begin
    ga = GeoArrays.read("data/utmsmall.tif")
    @test bbox(ga) == (min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6)
    @test bboxes(ga)[1] == (min_x=440720.0, max_x=440780.0, min_y=3.75126e6, max_y=3.75132e6)
    @test bboxes(ga)[end] == (min_x=446660.0, max_x=446720.0, min_y=3.74532e6, max_y=3.74538e6)
end

using CoordinateTransformations
@testset "coords" begin
    straight = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]),"")
    rot = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.5; 0.1 1.0], [0.0, 0.0]),"")
    @test coords(straight, :x) == collect(375000.03:1:375005.03)
    @test coords(straight, :y) == collect(380000.03:-1:379995.03)
    @test_throws ErrorException coords(straight, :z)
    @test_throws ErrorException coords(rot, :x)
    @test_throws ErrorException coords(rot, :y)
end
