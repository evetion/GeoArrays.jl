module GeoArrays

import GeoFormatTypes as GFT
using ArchGDAL
using CoordinateTransformations
using StaticArrays
import GeoInterface as GI
using IterTools: partition
import DataAPI
using Extents: Extent, intersects
using PrecompileTools    # this is a small dependency

include("geoarray.jl")
include("geoutils.jl")
include("utils.jl")
include("io.jl")
include("interpolate.jl")
include("crs.jl")
include("operations.jl")
include("plot.jl")
include("geointerface.jl")


@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    A = rand(10, 10)
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        GeoArray(A)
    end
end

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
