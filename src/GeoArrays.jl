module GeoArrays

import GeoFormatTypes as GFT
using ArchGDAL
using CoordinateTransformations
using StaticArrays
import GeoInterface as GI
using IterTools: partition
import DataAPI
import Extents

include("geoarray.jl")
include("geoutils.jl")
include("utils.jl")
include("io.jl")
include("interpolate.jl")
include("crs.jl")
include("operations.jl")
include("plot.jl")
include("geointerface.jl")

export GeoArray

export crs, affine
export coords
export indices
export Vertex, Center

export bbox
export bbox!
export bboxes

export compose!

export bbox_overlap
export crop

export interpolate!

export epsg!
export crs!

export profile

end
