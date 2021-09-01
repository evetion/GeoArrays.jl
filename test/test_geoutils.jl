const tbbox = (min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6)

@testset "GeoUtils" begin
    @testset "bbox" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        @test GeoArrays.bbox(ga) == tbbox
    end

    @testset "bbox!" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        @test GeoArrays.bbox(ga) == tbbox
        GeoArrays.bbox!(ga, GeoArrays.bbox(ga))
        @test GeoArrays.bbox(ga) == tbbox
    end

    @testset "flip upside down" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        ga_identical = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        @test ga.A == ga_identical.A
        @test ga.f == ga_identical.f
        @test ga.crs == ga_identical.crs
        GeoArrays.flipud!(ga)
        @test ga.f != ga_identical.f
        @test GeoArrays.bbox(ga) == tbbox
        GeoArrays.flipud!(ga)
        @test ga.f == ga_identical.f
        @test ga.A == ga_identical.A
    end

    @testset "geotransform should remain the same" begin
        gt = [1000.,1.,0.2,2000.,0.,1.]
        f = GeoArrays.geotransform_to_affine(gt)
        gtnew = GeoArrays.affine_to_geotransform(f)
        @test gt == gtnew
    end

    @testset "bbox overlapping" begin
        @test GeoArrays.bbox_overlap((min_x = 10, min_y = 10, max_x = 1000, max_y = 1000), (min_x = 20, min_y = 20, max_x = 900, max_y = 1100)) == true
        @test GeoArrays.bbox_overlap((min_x = 10, min_y = 10, max_x = 100, max_y = 100), (min_x = 200, min_y = 200, max_x = 400, max_y = 400)) == false
        @test GeoArrays.bbox_overlap((min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6), (min_x = 442720.0, min_y = 3.94532e6, max_x = 456720.0, max_y = 3.75032e6)) == true
        @test GeoArrays.bbox_overlap((min_x = 440720.0, min_y = 3.74532e6, max_x = 446720.0, max_y = 3.75132e6), (min_x = 342720.0, min_y = 3.94532e6, max_x = 356720.0, max_y = 3.75032e6)) == false
    end
end
