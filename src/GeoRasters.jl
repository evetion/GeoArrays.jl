module GeoRasters

using ArchGDAL
using GDAL
using CoordinateTransformations
using StaticArrays

include("geoutils.jl")
include("geoarray.jl")
include("io.jl")

export GeoArray
export coords

end
