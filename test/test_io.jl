# Try to open at least all downloaded datasets
@testset "Reading rasters" begin
    for f in remotefiles
        @testset "Reading $f" begin
            ga = GeoArrays.read(f)
        end
    end
end

@testset "Writing rasters" begin

    @testset "Simplest version" begin
        ga = GeoArray(rand(100,200,3))
        fn = GeoArrays.write!("test.tif", ga)
        GeoArrays.read(fn)
    end
    @testset "Simplest version" begin
        ga = GeoArray(rand(100,200,3))
        fn = GeoArrays.write!("test.img", ga)
        GeoArrays.read(fn)
    end

    @testset "Nodata" begin
        ga = GeoArray(Array{Union{Missing, Int32}}(rand(1:10,100,200,3)))
        fn = GeoArrays.write!("test_nodata.tif", ga, 1)
        GeoArrays.read(fn)
    end
    @testset "Nodata" begin
        ga = GeoArray(Array{Union{Missing, Int32}}(rand(1:10,100,200,3)))
        fn = GeoArrays.write!("test_nodata.img", ga, 1)
        GeoArrays.read(fn)
    end

end
