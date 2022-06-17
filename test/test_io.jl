# Try to open at least all downloaded datasets
@testset "Reading rasters" begin
    for f in remotefiles
        @testset "Reading $f" begin
            ga = GeoArrays.read(joinpath(testdatadir, f))
        end
    end
end

@testset "Reading rasters first band" begin
    for f in remotefiles
        @testset "Reading $f" begin
            ga = GeoArrays.read(joinpath(testdatadir, f), band=1)
            @test last(size(ga)) == 1
        end
    end
end

@testset "Reading rasters streaming" begin
    for f in remotefiles
        @testset "Reading $f streaming" begin
            ga = GeoArrays.read(joinpath(testdatadir, f), masked=false)
            ga[1, 1, 1]
        end
    end
end

@testset "Reading rasters streaming first band" begin
    for f in remotefiles
        @testset "Reading $f streaming" begin
            ga = GeoArrays.read(joinpath(testdatadir, f), masked=false, band=1)
            @test last(size(ga)) == 1
            ga[1, 1, 1]
        end
    end
end

@testset "Reading rasters and writing" begin
    for (i, f) in enumerate(remotefiles)
        @testset "Reading and writing $f" begin
            ga = GeoArrays.read(joinpath(testdatadir, f))
            GeoArrays.write!(joinpath(tempdir(), "test_$i.tif"), ga)
            ga_copy = GeoArrays.read(joinpath(tempdir(), "test_$i.tif"))
            @test ga[1, 1, 1] === ga_copy[1, 1, 1]
            @test ga[end, end, end] === ga_copy[end, end, end]
        end
    end
end

@testset "Read second band" begin
    fn = joinpath(testdatadir, remotefiles[end-1])
    GeoArrays.read(fn, band=2)
end


@testset "Writing rasters" begin

    @testset "Simplest version" begin
        ga = GeoArray(rand(100, 200, 3))
        fn = GeoArrays.write!(joinpath(tempdir(), "test.tif"), ga)
        GeoArrays.read(fn)
        fn = GeoArrays.write!(joinpath(tempdir(), "test.img"), ga)
        GeoArrays.read(fn)
    end
    @testset "Nodata" begin
        ga = GeoArray(Array{Union{Missing,Int32}}(rand(1:10, 100, 200, 3)))
        fn = GeoArrays.write!(joinpath(tempdir(), "test_nodata.tif"), ga, 1)
        GeoArrays.read(fn)
        fn = GeoArrays.write!(joinpath(tempdir(), "test_nodata.img"), ga, 1)
        GeoArrays.read(fn)
    end
    @testset "COG" begin
        ga = GeoArray(Array{Union{Missing,Int32}}(rand(1:10, 2048, 2048, 3)))
        fn = GeoArrays.write(joinpath(tempdir(), "test_cog.tif"), ga, 1, "COG")
        GeoArrays.read(fn)
    end
    @testset "Kwargs" begin
        ga = GeoArray(rand(100, 200, 3))
        fn = GeoArrays.write(joinpath(tempdir(), "test.tif"), ga; shortname="COG", nodata=1.0, options=Dict("compression" => "deflate"))
        GeoArrays.read(fn)
    end

end
