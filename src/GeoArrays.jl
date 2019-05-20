module GeoArrays

using ArchGDAL
using GDAL
using CoordinateTransformations
using StaticArrays

include("geoarray.jl")
include("geoutils.jl")
include("io.jl")
include("utils.jl")
include("interpolate.jl")

export GeoArray
export coords

end
