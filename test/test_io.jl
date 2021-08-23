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
            ga[1,1,1]
        end
    end
end

@testset "Reading rasters streaming first band" begin
    for f in remotefiles
        @testset "Reading $f streaming" begin
            ga = GeoArrays.read(joinpath(testdatadir, f), masked=false, band=1)
            @test last(size(ga)) == 1
            ga[1,1,1]
        end
    end
end

@testset "Writing rasters" begin

    @testset "Simplest version" begin
        ga = GeoArray(rand(100, 200, 3))
        fn = GeoArrays.write!(joinpath(testdatadir, "test.tif"), ga)
        GeoArrays.read(fn)
    end
    @testset "Simplest version" begin
        ga = GeoArray(rand(100, 200, 3))
        fn = GeoArrays.write!(joinpath(testdatadir, "test.img"), ga)
        GeoArrays.read(fn)
    end

    @testset "Nodata" begin
        ga = GeoArray(Array{Union{Missing,Int32}}(rand(1:10, 100, 200, 3)))
        fn = GeoArrays.write!(joinpath(testdatadir, "test_nodata.tif"), ga, 1)
        GeoArrays.read(fn)
    end
    @testset "Nodata" begin
        ga = GeoArray(Array{Union{Missing,Int32}}(rand(1:10, 100, 200, 3)))
        fn = GeoArrays.write!(joinpath(testdatadir, "test_nodata.img"), ga, 1)
        GeoArrays.read(fn)
    end

end
