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
        ga = GeoArray(fill(0, (100, 200, 3)))
        fn = GeoArrays.write(joinpath(tempdir(), "test_nodata_hardcoded.tiff"), ga; nodata=0)
        ga = GeoArrays.read(fn)
        @test all(ismissing.(ga))
    end
    @testset "Nodata with dtype" begin
        ga = GeoArray(Array{Union{Missing,Int8}}(rand(1:10, 100, 200, 3)))
        fn = GeoArrays.write!(joinpath(tempdir(), "test_nodata.tif"), ga, 1)
        GeoArrays.read(fn)
    end
    @testset "COG" begin
        ga = GeoArray(Array{Union{Missing,Int32}}(rand(1:10, 2048, 2048, 3)))
        fn = GeoArrays.write(joinpath(testdatadir, "test_cog.tif"), ga; nodata=-1, shortname="COG", options=Dict("compress" => "ZSTD"))
        GeoArrays.read(fn)
        ga = GeoArray(Array{Union{Missing,Float32}}(rand(1:10, 2048, 2048, 3)))
        fn = GeoArrays.write(joinpath(testdatadir, "test_cogf.tif"), ga; nodata=Inf, shortname="COG", options=Dict("compress" => "ZSTD"))
        GeoArrays.read(fn)
    end
    @testset "Kwargs" begin
        ga = GeoArray(rand(100, 200, 3))
        fn = GeoArrays.write(joinpath(tempdir(), "test.tif"), ga; shortname="COG", nodata=1.0, options=Dict("compress" => "deflate"))
        GeoArrays.read(fn)
    end
    @testset "NetCDF" begin
        ga = GeoArrays.read("NetCDF:$(joinpath(testdatadir, "netcdf", "sentinel5p_fake.nc")):my_var")
        @test size(ga) == (61, 89, 1)
    end
    @testset "Virtual" begin
        ga = GeoArrays.read("/vsicurl/https://github.com/OSGeo/gdal/blob/master/autotest/alg/data/2by2.tif?raw=true")
        @test size(ga) == (2, 2, 1)
    end
    @testset "Complex numbers" begin
        for T in (Complex{Int16}, Complex{Int32}, Complex{Float32}, Complex{Float64})
            ga = GeoArray(rand(T, 1024, 1024, 3))
            fn = joinpath(tempdir(), "test_complex_$T.tif")
            GeoArrays.write(fn, ga)
            ga2 = GeoArrays.read(fn)
            @test ga2 == ga
        end
    end
    @testset "Bandnames" begin
        ga = GeoArray(rand(100, 200, 3))
        ga.metadata = Dict("" => Dict("FOO" => "BAR"))
        fn = GeoArrays.write(joinpath(tempdir(), "test_bandnames.tif"), ga; shortname="COG", nodata=1.0, options=Dict("compress" => "deflate"), bandnames=["a", "b", "c"])
        GeoArrays.read(fn)
    end
    @testset "Metadata" begin
        ga = GeoArray(rand(100, 200, 3))
        d = Dict("" => Dict("FOO" => "BAR"))
        ga.metadata = d
        fn = GeoArrays.write(joinpath(tempdir(), "test_metadata.tif"), ga)
        ga2 = GeoArrays.read(fn)
        GeoArrays.metadata(ga2) == d
    end
end
