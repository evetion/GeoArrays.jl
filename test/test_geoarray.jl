using CoordinateTransformations

@testset "Indexing" begin
    x = GeoArray(rand(5, 5, 5))
    @test length(x[1]) == 1
    @test length(x[1, 2]) == 5
    @test size(x[1:3, 1:3]) == (3, 3, 5)
    @test size(x[1:3, 1:3, 1:3]) == (3, 3, 3)

    x = GeoArray(rand(10, 10, 2))
    xs = x[1:2:end, 1:2:end]
    @test size(xs) == (5, 5, 2)
    @test bbox(xs) == bbox(x)
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
    @test bbox(ga) == (min_x=440720.0, min_y=3.74532e6, max_x=446720.0, max_y=3.75132e6)
    @test bboxes(ga)[1] == (min_x=440720.0, max_x=440780.0, min_y=3.75126e6, max_y=3.75132e6)
    @test bboxes(ga)[end] == (min_x=446660.0, max_x=446720.0, min_y=3.74532e6, max_y=3.74538e6)
end

@testset "Coords" begin
    straight = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]), "")
    rot = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.5; 0.1 1.0], [0.0, 0.0]), "")
    @test coords(straight, :x, GeoArrays.Vertex()) == collect(375000.03:1:375005.03)
    @test coords(straight, :y, GeoArrays.Vertex()) == collect(380000.03:-1:379995.03)
    @test_throws ErrorException coords(straight, :z)
    @test_throws ErrorException coords(rot, :x)
    @test_throws ErrorException coords(rot, :y)
end

@testset "GeoArray constructors" begin
    x, y = range(4, stop=8.0, length=10), range(0, stop=1, length=9)
    ga2 = GeoArray(rand(10, 9), x, y)
    ga2 = GeoArray(rand(10, 9), x, y, "")
    ga3 = GeoArray(rand(10, 9, 8), x, y)
    ga3 = GeoArray(rand(10, 9, 8), x, y, "")
    for i in 1:length(x), j in 1:length(y)
        @test GeoArrays.coords(ga2, [i, j]) ≈ [x[i], y[j]]
    end
    for i in 1:length(x), j in 1:length(y)
        @test GeoArrays.coords(ga3, [i, j]) ≈ [x[i], y[j]]
    end
    x, y = range(4, stop=8.0, length=11), range(0, stop=1, length=9)
    @test_throws ErrorException GeoArray(rand(10, 9), x, y)
end

@testset "Conversions" begin
    ga = GeoArray(rand(1:32000, 5, 5))
    GeoArrays.write!(joinpath(testdatadir, "test_conversion.tif"), ga)

    ga = GeoArray(rand(Bool, 5, 5))
    @test_throws ErrorException GeoArrays.write!(joinpath(testdatadir, "test_conversion.tif"), ga)
end

@testset "Similar" begin
    ga = GeoArrays.read(joinpath(testdatadir, remotefiles[end-1]))
    gg = ga[250:end-2, 250:end-250]
    @test gg[1, 1] == ga[250, 250]
    @test coords(gg, [1, 1]) == coords(ga, [250, 250])
    GeoArrays.write!("test.tif", gg)
end

@testset "Indexing" begin
    ga = GeoArray(rand(10, 10))
    ga[Float32(1.0), Float32(2.0)]
    i, j = 2, 5
    x, y = coords(ga, (i, j))
    ii, jj = indices(ga, (x, y))
    @test ii == i
    @test jj == j
end
