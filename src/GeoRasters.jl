module GeoRasters

using ArchGDAL
using GDAL
using CoordinateTransformations

include("geoutils.jl")
include("geoarray.jl")
include("io.jl")

export GeoArray

end
