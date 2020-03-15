import ArchGDAL

@testset "CRS" begin

    epsg_nl_code = 28992
    epsg_nl_str = "EPSG:28992"
    merc_proj_string = "+proj=merc +lat_ts=56.5 +ellps=GRS80"

    # ArchGDAL contains different versions of Proj depending on the Julia version...
    if VERSION >= v"1.3"
        epsg_nl_wkt = "PROJCS[\"Amersfoort / RD New\",GEOGCS[\"Amersfoort\",DATUM[\"Amersfoort\",SPHEROID[\"Bessel 1841\",6377397.155,299.1528128,AUTHORITY[\"EPSG\",\"7004\"]],AUTHORITY[\"EPSG\",\"6289\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4289\"]],PROJECTION[\"Oblique_Stereographic\"],PARAMETER[\"latitude_of_origin\",52.1561605555556],PARAMETER[\"central_meridian\",5.38763888888889],PARAMETER[\"scale_factor\",0.9999079],PARAMETER[\"false_easting\",155000],PARAMETER[\"false_northing\",463000],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"28992\"]]"
        merc_wkt = "PROJCS[\"unknown\",GEOGCS[\"unknown\",DATUM[\"Unknown_based_on_GRS80_ellipsoid\",SPHEROID[\"GRS 1980\",6378137,298.257222101,AUTHORITY[\"EPSG\",\"7019\"]]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Mercator_2SP\"],PARAMETER[\"standard_parallel_1\",56.5],PARAMETER[\"central_meridian\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]"
        wgs84_wkt = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
    else
        epsg_nl_wkt = "PROJCS[\"Amersfoort / RD New\",GEOGCS[\"Amersfoort\",DATUM[\"Amersfoort\",SPHEROID[\"Bessel 1841\",6377397.155,299.1528128,AUTHORITY[\"EPSG\",\"7004\"]],TOWGS84[565.2369,50.0087,465.658,-0.406857330322,0.350732676543,-1.87034738361,4.0812],AUTHORITY[\"EPSG\",\"6289\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4289\"]],PROJECTION[\"Oblique_Stereographic\"],PARAMETER[\"latitude_of_origin\",52.1561605555556],PARAMETER[\"central_meridian\",5.38763888888889],PARAMETER[\"scale_factor\",0.9999079],PARAMETER[\"false_easting\",155000],PARAMETER[\"false_northing\",463000],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"28992\"]]"
        merc_wkt = "PROJCS[\"unknown\",GEOGCS[\"unknown\",DATUM[\"Unknown_based_on_GRS80_ellipsoid\",SPHEROID[\"GRS 1980\",6378137,298.257222101,AUTHORITY[\"EPSG\",\"7019\"]]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Mercator_2SP\"],PARAMETER[\"standard_parallel_1\",56.5],PARAMETER[\"central_meridian\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]"
        wgs84_wkt = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
    end


    @testset "Set CRS on GeoArray" begin
        ga = GeoArray(rand(10,10))
        epsg!(ga, 28992)
        @test ga.crs == epsg_nl_wkt

        epsg!(ga, "EPSG:28992")
        @test ga.crs == epsg_nl_wkt
    end

    @testset "Proj string" begin
        result = GeoArrays.str2wkt(merc_proj_string)
        @test result == merc_wkt
    end

    @testset "EPSG code" begin
        result = GeoArrays.epsg2wkt(epsg_nl_code)
        @test result == epsg_nl_wkt
    end

    @testset "Projection string checking" begin
        # EPSG string handling
        result = GeoArrays.str2wkt(epsg_nl_str)
        @test result == epsg_nl_wkt

        # Proj string handling
        result = GeoArrays.str2wkt(merc_proj_string)
        @test result == merc_wkt

        # WKT string handling
        result = GeoArrays.str2wkt(merc_wkt)
        @test result == merc_wkt

        # Invalid string
        @test_throws ArchGDAL.GDAL.GDALError GeoArrays.str2wkt("INVALID")

    end

    @testset "Check projection of file" begin
        ga = GeoArrays.read("gdalworkshop/world.tif")
        @test ga.crs == wgs84_wkt
    end

end
