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
        @test GeoArrays.bbox(ga) == (min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6)
        GeoArrays.flipud!(ga)
        @test ga == ga_identical
    end

    @testset "geotransform should remain the same" begin
        gt = [1000.,1.,0.2,2000.,0.,1.]
        f = GeoArrays.geotransform_to_affine(gt)
        gtnew = GeoArrays.affine_to_geotransform(f)
        @test gt == gtnew
    end
end
