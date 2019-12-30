module GeoArrays

using GDAL
using ArchGDAL
using CoordinateTransformations
using StaticArrays

include("geoarray.jl")
include("geoutils.jl")
include("io.jl")
include("utils.jl")
include("interpolate.jl")
include("crs.jl")
include("operations.jl")
include("plot.jl")

export GeoArray

export coords
export centercoords
export indices

export bbox
export bboxes

export compose!

export interpolate!

export epsg!

export -,+,*,/

end
