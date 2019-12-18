@testset "operations" begin
    a = GeoArray(rand(5, 5))
    b = GeoArray(rand(5, 6))

    @test_throws DimensionMismatch a - b
    #@test_throws ErrorException c - d
end