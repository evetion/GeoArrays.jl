using GeoRasters
using Test

@testset "ArchGDAL" begin
    cd(dirname(@__FILE__)) do
        include("get_testdata.jl")
        include("test_geoutils.jl")
    end
end
