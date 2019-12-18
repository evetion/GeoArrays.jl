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
include("crs.jl")
include("operations.jl")

export GeoArray

export coords
export centercoords
export indices

export compose!

export interpolate!

export epsg!

export -

end
