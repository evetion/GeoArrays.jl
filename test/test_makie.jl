using Makie

@testset "Makie" begin
    ga = GeoArray(Union{Missing,UInt8}[1 2; missing 4])
    x, y, z = Makie.convert_arguments(Heatmap, ga)
    @test eltype(z) == Float32
    @test isnan(z[2, 1])
    @test heatmap(ga).plot isa Heatmap
end
