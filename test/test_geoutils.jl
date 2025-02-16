import GeoInterface as GI
import GeoFormatTypes as GFT
using Extents: Extents, Extent
using CoordinateTransformations

const tbbox = GeoArrays._convert(Extent, (min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6))

@testset "GeoUtils" begin
    @testset "bbox" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        @test GeoArrays.bbox(ga) == tbbox
    end

    @testset "affine!" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        GeoArrays.affine!(ga, affine(ga))
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
        gt = [1000.0, 1.0, 0.2, 2000.0, 0.0, 1.0]
        f = GeoArrays.geotransform_to_affine(gt)
        gtnew = GeoArrays.affine_to_geotransform(f)
        @test gt == gtnew
    end

    @testset "bbox overlapping" begin
        @test GeoArrays.bbox_overlap((min_x=10, min_y=10, max_x=1000, max_y=1000), (min_x=20, min_y=20, max_x=900, max_y=1100)) == true
        @test GeoArrays.bbox_overlap((min_x=10, min_y=10, max_x=100, max_y=100), (min_x=200, min_y=200, max_x=400, max_y=400)) == false
        @test GeoArrays.bbox_overlap((min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6), (min_x=442720.0, min_y=3.74532e6, max_x=456720.0, max_y=3.75032e6)) == true
        @test GeoArrays.bbox_overlap((min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6), (min_x=342720.0, min_y=3.94532e6, max_x=356720.0, max_y=3.95032e6)) == false
    end

    @testset "crop by bbox or ga" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        cbox = GeoArrays._convert(Extent, (min_x=441260.0, min_y=3.75012e6, max_x=442520.0, max_y=3.75078e6))
        ga_s = ga[10:30, 20:50, begin:end]

        ga_c = GeoArrays.crop(ga, cbox)
        ga_s_c = GeoArrays.crop(ga, ga_s)

        @test GeoArrays._size(ga_c) == (21, 11, 1)
        @test GeoArrays.bbox(ga_c) == cbox

        @test size(ga_s_c) == size(ga_s)
        @test GeoArrays.bbox(ga_s_c) == GeoArrays.bbox(ga_s)

        ga = GeoArray(rand(100, 100))
        bbox!(ga, (min_x=0.5, min_y=0.5, max_x=100.5, max_y=100.5))
        extent = bbox(ga)
        ga0 = crop(ga, extent)
        @test ga0 == ga

        gaf = GeoArrays.flipud!(ga)
        ga1 = crop(gaf, extent)
        @test gaf == ga1
    end

    @testset "profile" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        a = 441064.0, 3745555.0
        b = 442864.0, 3747309.0
        box = bbox(ga)
        values = Float32[]
        GeoArrays.profile!(values, ga, a, b, 1)
        values_r = Float32[]
        GeoArrays.profile!(values_r, ga, b, a, 1)
        @test values == reverse(values_r)

        # TODO profile with smaller dy than dx step

        struct LineString end
        lcoord = [[1, 2], [3, 3.5]]
        GI.isgeometry(::LineString) = true
        GI.geomtrait(::LineString) = GI.LineStringTrait()
        GI.ncoord(::GI.LineStringTrait, ::LineString) = 2
        GI.ngeom(::GI.LineStringTrait, ::LineString) = 2
        GI.getgeom(::GI.LineStringTrait, ::LineString) = lcoord

        ga = GeoArray(rand(4, 4))
        values = GeoArrays.profile(ga, LineString())
        # @test length(values) == 3

        GI.getgeom(::GI.LineStringTrait, ::LineString) = reverse(lcoord)
        values2 = GeoArrays.profile(ga, LineString())
        @test length(values2) == 3
        @test values == reverse(values2)

    end

    @testset "GeoInterface" begin
        ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
        @test GI.crs(ga) isa GFT.GeoFormat
        @test !isempty(GFT.val(GI.crs(ga)))
        @test GI.extent(ga) isa Extents.Extent
        @test GI.extent(ga) == Extents.Extent(X=(440720.0, 446720.0), Y=(3.74532e6, 3.75132e6))
        @test GI.crstrait(ga) isa GI.ProjectedTrait
    end

    @testset "Compose" begin
        ga = GeoArray(rand(10, 10))
        compose!(ga::GeoArray, AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]))
        @test affine(ga).linear == AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]).linear
        @test affine(ga).translation == AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]).translation

        ga = GeoArray(rand(10, 10))
        compose!(ga::GeoArray, Translation([5.0, 5.0]))
        @test affine(ga).translation == [5.0, 5.0]
    end

end
