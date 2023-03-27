using CoordinateTransformations

@testset "operations" begin
    @testset "dimension error test" begin
        a = GeoArray(rand(5, 5))
        b = GeoArray(rand(5, 6))
        @test_throws DimensionMismatch a - b
        @test_throws DimensionMismatch a + b
        @test_throws DimensionMismatch a * b
        @test_throws DimensionMismatch a / b
    end

    @testset "affine error tests" begin
        c = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]), "")
        d = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]), "")
        @test_throws DimensionMismatch c - d
        @test_throws DimensionMismatch c + d
        @test_throws DimensionMismatch c * d
        @test_throws DimensionMismatch c / d
    end

    @testset "crs error test" begin
        e = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]), "")
        f = GeoArray(rand(5, 5, 1), AffineMap([1.0 0.0; 0.0 -1.0], [375000.03, 380000.03]), "PROJCS[\"NAD27 / UTM zone 11N\",GEOGCS[\"NAD27\",DATUM[\"North_American_Datum_1927\",SPHEROID[\"Clarke 1866\",6378206.4,294.9786982138982,AUTHORITY[\"EPSG\",\"7008\"]],AUTHORITY[\"EPSG\",\"6267\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433],AUTHORITY[\"EPSG\",\"4267\"]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-117],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AUTHORITY[\"EPSG\",\"26711\"]]")
        @test_throws DimensionMismatch e - f
        @test_throws DimensionMismatch e + f
        @test_throws DimensionMismatch e * f
        @test_throws DimensionMismatch e / f
    end

    @testset "operations" begin
        g = GeoArray(rand(5, 5))
        h = GeoArray(rand(5, 5))
        @test typeof(g - h).name.name == :GeoArray
        @test typeof(g + h).name.name == :GeoArray
        @test typeof(g * h).name.name == :GeoArray
        @test typeof(g / h).name.name == :GeoArray

        g = GeoArray([1 missing; 2 3])
        @inferred coalesce(g, 0)
        gg = coalesce(g, 0)
        @test gg.A[3] == 0
        @test eltype(gg) == Int64

        g = GeoArray([1.0 missing; 2 3])
        @inferred coalesce(g, Inf)
        gg = coalesce(g, Inf)
        @test gg.A[3] == Inf
        @test eltype(gg) == Float64

        g = GeoArray(ones(10, 10))
        @test sum(g) == 100
    end

    @testset "warp" begin
        ENV["PROJ_NETWORK"] = "ON"
        ga = GeoArray(zeros((360, 180)))
        bbox!(ga, (min_x=-180, min_y=-90, max_x=180, max_y=90))
        crs!(ga, GeoFormatTypes.EPSG(9754))
        ga2 = GeoArrays.warp(ga, Dict("t_srs" => "EPSG:4326+3855"))
        @test sum(ga2) != 0

        ga = GeoArray(ones((360, 180)))
        ga2 = GeoArray(zeros((180, 90)))
        ga3 = GeoArrays.warp(ga, ga2)
        @test size(ga3) == size(ga2)
        @test sum(ga3) == length(ga3)
    end
end
