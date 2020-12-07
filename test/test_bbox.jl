# @testset "bbox"
begin
    ga = GeoArrays.read("/mnt/n/MODIS_gpp/2000-02-18.tif")
    tbbox = (min_x = -180.0, min_y = -60.0, max_x = 180.0, max_y = 90.0)
    println("old: ", ga.f)
    @test GeoArrays.bbox(ga) == tbbox

    
    bbox!(ga, tbbox)
    println("new: ", ga.f)
end

# AffineMap, yaxis is inversed
