[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://evetion.github.io/GeoRasters.jl/) [![Build Status](https://travis-ci.org/evetion/GeoRasters.jl.svg?branch=master)](https://travis-ci.org/evetion/GeoRasters.jl) [![Build status](https://ci.appveyor.com/api/projects/status/shk6aock4h80cd7j?svg=true)](https://ci.appveyor.com/project/evetion/georasters-jl)
# GeoRasters
Simple geographical raster interaction built on top of [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/), [GDAL](https://github.com/JuliaGeo/GDAL.jl) and [CoordinateTransformations](https://github.com/FugroRoames/CoordinateTransformations.jl).

A GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world.

*this is a work in progress*

## Examples

```julia
julia> geoarray = GeoRaster.read(fn)
10001×10001×3 GeoRaster.GeoArray{Union{Missing, UInt8},3}:
 0x36  0x3a  0x40  0x48  0x46  0x37  0x35  0x43  0x3f  0x37  …  0x98         0x85         0x89
 0x3f  0x40  0x45  0x50  0x53  0x43  0x37  0x3b  0x3b  0x34     0x91         0x7d         0x79
 0x49  0x43  0x41  0x4a  0x52  0x46  0x37  0x35  0x31  0x2f     0x83         0x78         0x78
 0x49  0x3e  0x33  0x36  0x3e  0x39  0x31  0x32  0x27  0x2d     0x77         0x78         0x7c
 0x3b  0x34  0x2b  0x2b  0x30  0x2d  0x29  0x2e  0x2a  0x31     0x79         0x71         0x73
    ⋮                             ⋮                          ⋱                               ⋮
 0x31  0x33  0x34  0x33  0x35  0x3a  0x44  0x4d  0x58  0x57  …      missing      missing      missing
 0x32  0x33  0x32  0x30  0x32  0x39  0x47  0x52  0x50  0x51         missing      missing      missing
 0x34  0x34  0x32  0x2f  0x31  0x38  0x44  0x4e  0x58  0x69         missing      missing      missing
 0x35  0x34  0x33  0x31  0x35  0x3a  0x42  0x47  0x4d  0x6e         missing      missing      missing
 0x35  0x34  0x33  0x36  0x3c  0x40  0x42  0x42  0x3e  0x55         missing

julia> sum(skipmissing(ga))
0x000000012e1bd50a

# Find coordinates by index
julia> coords(geoarray, [1,1])
2-element Array{Float64,1}:
 409999.95
      9.80300005e6

# Find index by coordinates
julia> coords(geoarray, [409999.95, 9.80300005e6])
2-element Array{Int64,1}:
 1
 1

# Or directly
julia> geoarray[409999.95, 9.80300005e6]
3-element Array{Union{Missing, UInt8},1}:
 0x36
 0x37
 0x32

# Find all coordinates
julia> coords(geoarray)
10002×10002 Array{StaticArrays.SArray{Tuple{2},Float64,1,2},2}:
 [410000.0, 9.803e6]   [410000.0, 9.803e6]   …  [410000.0, 9.802e6]   [410000.0, 9.802e6]
 [410000.0, 9.803e6]   [410000.0, 9.803e6]      [410000.0, 9.802e6]   [410000.0, 9.802e6]
 [4.1e5, 9.803e6]      [4.1e5, 9.803e6]         [4.1e5, 9.802e6]      [4.1e5, 9.802e6]
 [4.1e5, 9.803e6]      [4.1e5, 9.803e6]         [4.1e5, 9.802e6]      [4.1e5, 9.802e6]
 [4.1e5, 9.803e6]      [4.1e5, 9.803e6]         [4.1e5, 9.802e6]      [4.1e5, 9.802e6]
 [4.1e5, 9.803e6]      [4.1e5, 9.803e6]      …  [4.1e5, 9.802e6]

# Write a TIFF
julia> ga = GeoArray(rand(100,200,3))
julia> GeoRasters.write!("test.tif", ga)

```

