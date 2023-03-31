using GeoArrays
using Test

# using Aqua
# Aqua.test_all(GeoArrays)
ENV["PROJ_NETWORK"] = "ON"

@testset "GeoArrays" begin
    cd(dirname(@__FILE__)) do
        include("get_testdata.jl")
        include("test_geoutils.jl")
        include("test_geoarray.jl")
        include("test_io.jl")
        include("test_interpolate.jl")
        include("test_crs.jl")
        include("test_operations.jl")
        include("test_utils.jl")
    end
end
