module GeoRasters

using ArchGDAL
using GDAL
using CoordinateTransformations
using StaticArrays
using ImageCore
using ColorTypes
using RecipesBase

include("geoarray.jl")
include("geoutils.jl")
include("io.jl")
include("utils.jl")
include("plot.jl")
include("colors.jl")

export GeoArray
export coords

end
