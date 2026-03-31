using CoordinateTransformations
import GeoFormatTypes as GFT
using StaticArrays

@testset "Indexing" begin
    x = GeoArray(rand(5, 5, 5))
    @test length(x[1]) == 1
    @test length(x[1, 2, :]) == 5
    @test size(x[1:3, 1:3, :]) == (3, 3, 5)
    @test size(x[1:3, 1:3, 1:3]) == (3, 3, 3)

    @inferred size(x)
    @inferred size(x[1, 1, 1])

    x = GeoArray(rand(10, 10, 2))
    xs = x[1:2:end, 1:2:end]
    @test size(xs) == (5, 5, 2)
    @test bbox(xs) == bbox(x)

    @test_throws BoundsError x[1, 1] = 1
    x[1, 1, 1] = 1
    @test x[1, 1, 1] == 1.0
    x[1, 1, :] .= 2
    @test x[1, 1, 1] == 2.0
    @test x[1, 1, 2] == 2.0

    x = GeoArray(rand(5, 5))
    @test x[1, 1] == x[1, 1, 1]
    x[1, 1] = 5
    @test x[1, 1] == 5.0
end

@testset "Concrete" begin
    ga = GeoArray(rand(5, 5))
    @test isconcretetype(typeof(ga))
    @test isconcretetype(typeof(ga.A))
    @test isconcretetype(typeof(ga.f))
    @test isconcretetype(typeof(ga.crs))
end

@testset "Reading rasters" begin
    ga = GeoArrays.read(joinpath(testdatadir, "data/utmsmall.tif"))
    @test bbox(ga) == GeoArrays._convert(Extent, (; min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6))
    @inferred bbox(ga)
    @test bboxes(ga)[1] == GeoArrays._convert(Extent, (; min_x=440720.0, max_x=440780.0, min_y=3.75126e6, max_y=3.75132e6))
    @test bboxes(ga)[end] == GeoArrays._convert(Extent, (; min_x=446660.0, max_x=446720.0, min_y=3.74532e6, max_y=3.74538e6))
    @inferred bboxes(ga)
end

@testset "Coords" begin
    straight = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]), "")
    rot = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.5; 0.1 1.0], [0.0, 0.0]), "")
    @inferred coords(straight, :x, GeoArrays.Vertex())
    @test coords(straight, :x, GeoArrays.Vertex()) == collect(375000.03:1:375005.03)
    @test coords(straight, :y, GeoArrays.Vertex()) == collect(380000.03:-1:379995.03)
    @test_throws ErrorException coords(straight, :z)
    @test_throws ErrorException coords(rot, :x)
    @test_throws ErrorException coords(rot, :y)
end

@testset "GeoArray constructors" begin
    x, y = range(4, stop=8.0, length=10), range(0, stop=1, length=9)
    ga2 = GeoArray(rand(10, 9), x, y)
    @inferred GeoArray(rand(10, 9), x, y)
    ga2 = GeoArray(rand(10, 9), x, y, "")
    ga3 = GeoArray(rand(10, 9, 8), x, y)
    ga3 = GeoArray(rand(10, 9, 8), x, y, "")
    ga4 = GeoArray(rand(10, 9, 8), ga3.f, ga3.crs)
    for i in 1:length(x), j in 1:length(y)
        @test GeoArrays.coords(ga2, [i, j]) ≈ [x[i], y[j]]
    end
    for i in 1:length(x), j in 1:length(y)
        @test GeoArrays.coords(ga3, [i, j]) ≈ [x[i], y[j]]
    end
    x, y = range(4, stop=8.0, length=11), range(0, stop=1, length=9)
    @test_throws ErrorException GeoArray(rand(10, 9), x, y)

    # Test array-only constructor (issue #184)
    ga = GeoArray(rand(5, 5))
    @test ga isa GeoArray
    @test size(ga) == (5, 5)
    ga = GeoArray(rand(5, 5, 3))
    @test ga isa GeoArray
    @test size(ga) == (5, 5, 3)

    # Test AffineMap + String CRS constructor (issue #184)
    f = GeoArrays.geotransform_to_affine(SVector(0.0, 1.0, 0.0, 0.0, 0.0, 1.0))
    ga = GeoArray(rand(5, 5), f, "")
    @test ga isa GeoArray
    @test GFT.val(ga.crs) == ""
    ga = GeoArray(rand(5, 5, 3), f, "EPSG:4326")
    @test ga isa GeoArray
    @test GFT.val(ga.crs) == "EPSG:4326"

    # Test AffineMap-only constructor
    ga = GeoArray(rand(5, 5), f)
    @test ga isa GeoArray

    # Test AffineMap + WKT CRS constructor
    ga = GeoArray(rand(5, 5), f, GFT.WellKnownText(GFT.CRS(), ""))
    @test ga isa GeoArray

    # Test AffineMap + String CRS + metadata constructor
    ga = GeoArray(rand(5, 5), f, "EPSG:4326", Dict{String,Any}("key" => "value"))
    @test ga isa GeoArray
    @test GFT.val(ga.crs) == "EPSG:4326"
    @test ga.metadata["key"] == "value"
end

@testset "Conversions" begin
    ga = GeoArray(rand(1:32000, 5, 5))
    @inferred GeoArrays.write!(joinpath(testdatadir, "test_conversion.tif"), ga)
    @inferred GeoArrays.write(joinpath(testdatadir, "test_conversion.tif"), ga)

    ga = GeoArray(rand(Bool, 5, 5))
    GeoArrays.write(joinpath(testdatadir, "test_conversion.tif"), ga)
end

@testset "Similar" begin
    ga = GeoArrays.read(joinpath(testdatadir, remotefiles[end-1]))
    gg = ga[250:end-2, 250:end-250]
    @test gg[1, 1, :] == ga[250, 250, :]
    @test coords(gg, [1, 1]) == coords(ga, [250, 250])
    GeoArrays.write!("test.tif", gg)
end

@testset "Conversion" begin
    ga = GeoArrays.GeoArray(rand(Int16, 10, 10))
    gc = convert(GeoArrays.GeoArray{Float32,2}, ga)
    @test gc isa GeoArray
    @test eltype(gc) == Float32
    @test all(ga .== gc)
end

@testset "Broadcast" begin
    ga = GeoArrays.GeoArray(rand(Int16, 10, 10))
    gc = clamp.(ga, 0, 1)
    @test gc isa GeoArray
    @test sum(gc) < length(gc)
    gd = gc .+ 1
    @test sum(gd) > length(gc)
end

@testset "Indexing" begin
    ga = GeoArray(rand(10, 10))
    @inferred ga[Float32(1.0), Float32(2.0)]
    i, j = 2, 5
    X = coords(ga, (i, j))
    ii, jj = indices(ga, X).I
    @inferred indices(ga, X)
    @test ii == i
    @test jj == j

    @test indices.(Ref(ga), GeoArrays.coords(ga)) == CartesianIndices(ga[:, :, 1])
end

@testset "Ranges" begin
    ga = GeoArray(rand(Bool, 21601, 10801))
    ga.f = AffineMap([0.016666666666666666 0.0; 0.0 -0.016666666666666666], [-180.00833333333333, 90.00833333333334])
    X, Y = GeoArrays.ranges(ga)
    @test last(X) ≈ 180.00
    @test last(Y) ≈ -90.00
    @test length(X) == 21601
    @test length(Y) == 10801
    X, Y = GeoArrays.ranges(ga, GeoArrays.Vertex())
    @test length(X) == 21602
    @test length(Y) == 10802
    @test last(X) ≈ 180.00833333333333
    @test last(Y) ≈ -90.00833333333334
end
