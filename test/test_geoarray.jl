
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

@testset "GeoArray constructors" begin
    x,y,z = range(4, stop=8.0, length=10), range(0,stop=1,length=9), range(-1,stop=2,length=8)
    ga2 = GeoArray(rand(10,9), x, y)
    ga3 = GeoArray(rand(10,9,8), x, y, z)
    for i=1:length(x), j=1:length(y)
        @test GeoArrays.centercoords(ga2, [i,j])≈[x[i],y[j]]
    end
    for i=1:length(x), j=1:length(y), k=1:length(z)
        @test_broken GeoArrays.centercoords(ga3, [i,j])≈[x[i],y[j]]
    end
end
