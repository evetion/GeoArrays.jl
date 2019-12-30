
@testset "Reading rasters" begin
    ga = GeoArrays.read("data/utmsmall.tif")
    @test bbox(ga) == (min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6)
    @test bboxes(ga)[1] == (min_x=440720.0, max_x=440780.0, min_y=3.75126e6, max_y=3.75132e6)
    @test bboxes(ga)[end] == (min_x=446660.0, max_x=446720.0, min_y=3.74532e6, max_y=3.74538e6)
end
