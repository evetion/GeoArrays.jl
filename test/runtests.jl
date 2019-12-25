using GeoArrays
using Test

@testset "GeoArrays" begin
    cd(dirname(@__FILE__)) do
        include("get_testdata.jl")
        include("test_geoutils.jl")
        include("test_io.jl")
        include("test_interpolate.jl")
        include("test_crs.jl")
        include("test_operations.jl")
    end
end
