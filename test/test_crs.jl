@testset "CRS" begin

    epsg_nl_code = 28992
    epsg_nl_str = "EPSG:28992"
    epsg_nl_wkt = "PROJCS[\"Amersfoort / RD New\",GEOGCS[\"Amersfoort\",DATUM[\"Amersfoort\",SPHEROID[\"Bessel 1841\",6377397.155,299.1528128,AUTHORITY[\"EPSG\",\"7004\"]],TOWGS84[565.2369,50.0087,465.658,-0.406857,0.350733,-1.87035,4.0812],AUTHORITY[\"EPSG\",\"6289\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4289\"]],PROJECTION[\"Oblique_Stereographic\"],PARAMETER[\"latitude_of_origin\",52.15616055555555],PARAMETER[\"central_meridian\",5.38763888888889],PARAMETER[\"scale_factor\",0.9999079],PARAMETER[\"false_easting\",155000],PARAMETER[\"false_northing\",463000],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"X\",EAST],AXIS[\"Y\",NORTH],AUTHORITY[\"EPSG\",\"28992\"]]"

    merc_proj_string = "+proj=merc +lat_ts=56.5 +ellps=GRS80"
    merc_wkt = "PROJCS[\"unnamed\",GEOGCS[\"GRS 1980(IUGG, 1980)\",DATUM[\"unknown\",SPHEROID[\"GRS80\",6378137,298.257222101]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433]],PROJECTION[\"Mercator_2SP\"],PARAMETER[\"standard_parallel_1\",56.5],PARAMETER[\"central_meridian\",0],PARAMETER[\"false_easting\",0],PARAMETER[\"false_northing\",0]]"

    @testset "Set CRS on GeoArray" begin
        ga = GeoArray(rand(10,10))
        epsg!(ga, 28992)
        @test ga.crs == epsg_nl_wkt

        epsg!(ga, "EPSG:28992")
        @test ga.crs == epsg_nl_wkt
    end

    @testset "Proj string" begin
        result = GeoRasters.str2wkt(merc_proj_string)
        @test result == merc_wkt
    end

    @testset "EPSG code" begin
        result = GeoRasters.epsg2wkt(epsg_nl_code)
        @test result == epsg_nl_wkt
    end

    @testset "Projection string checking" begin
        # EPSG string handling
        result = GeoRasters.str2wkt(epsg_nl_str)
        @test result == epsg_nl_wkt

        # Proj string handling
        result = GeoRasters.str2wkt(merc_proj_string)
        @test result == merc_wkt

        # WKT string handling
        result = GeoRasters.str2wkt(merc_wkt)
        @test result == merc_wkt

        # Invalid string
        @test_throws ArgumentError GeoRasters.str2wkt("INVALID")

    end

    @testset "Check projection of file" begin
        ga = GeoRasters.read("gdalworkshop/world.tif")
        @test ga.crs == "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433],AUTHORITY[\"EPSG\",\"4326\"]]"
    end

end
