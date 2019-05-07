using GeoRasters
using Test

@testset "GeoRasters" begin
    cd(dirname(@__FILE__)) do
        include("get_testdata.jl")
        include("test_geoutils.jl")
        include("test_io.jl")
        include("test_interpolate.jl")
    end
end
