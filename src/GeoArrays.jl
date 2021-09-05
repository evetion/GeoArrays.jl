module GeoArrays

using GeoFormatTypes
using ArchGDAL
using CoordinateTransformations
using StaticArrays
const GFT = GeoFormatTypes

include("geoarray.jl")
include("geoutils.jl")
include("utils.jl")
include("io.jl")
include("interpolate.jl")
include("crs.jl")
include("operations.jl")
include("plot.jl")

export GeoArray

export coords
export indices
export Vertex, Center

export bbox
export bbox!
export bboxes

export compose!

export interpolate!

export epsg!
export crs!

export -,+,*,/

end
