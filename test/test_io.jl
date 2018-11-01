# Try to open at least all downloaded datasets

@testset "Reading rasters" begin
for f in remotefiles
    @testset "Reading $f" begin
        ga = GeoRasters.read(f)
    end
end
end

@testset "Writing rasters" begin
    ga = GeoArray(rand(100,200,3))
    GeoRasters.write!("test.tif", ga)
end
