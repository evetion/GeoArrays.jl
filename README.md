[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://evetion.github.io/GeoArrays.jl/) [![Build Status](https://travis-ci.org/evetion/GeoArrays.jl.svg?branch=master)](https://travis-ci.org/evetion/GeoArrays.jl) [![Build status](https://ci.appveyor.com/api/projects/status/shk6aock4h80cd7j?svg=true)](https://ci.appveyor.com/project/evetion/GeoArrays-jl) [![codecov](https://codecov.io/gh/evetion/GeoArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/evetion/GeoArrays.jl)
# GeoArrays
Simple geographical raster interaction built on top of [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/), [GDAL](https://github.com/JuliaGeo/GDAL.jl) and [CoordinateTransformations](https://github.com/FugroRoames/CoordinateTransformations.jl).

A GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world.

## Installation
```julia
(v1.3) pkg> add GeoArrays
```

## Examples
#### Basic Usage
```julia
julia> using GeoArrays

# Read TIF file
julia> fn = download("https://github.com/yeesian/ArchGDALDatasets/blob/master/data/utmsmall.tif?raw=true")
julia> geoarray = GeoArrays.read(fn)
100×100×1 GeoArray{UInt8}:
...

# Affinemap containing offset and scaling
julia> geoarray.f
AffineMap([60.0 0.0; 0.0 -60.0], [440720.0, 3.75132e6])

# WKT projection string
julia> geoarray.crs
"PROJCS[\"NAD27 / UTM zone 11N\",GEOGCS[\"NAD27\",DATUM[\"North_American_Datum_1927\",SPHEROID[\"Clarke 1866\",6378206.4,294.9786982138982,AUTHORITY[\"EPSG\",\"7008\"]],AUTHORITY[\"EPSG\",\"6267\"]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433],AUTHORITY[\"EPSG\",\"4267\"]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-117],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AUTHORITY[\"EPSG\",\"26711\"]]"

# Create and write a TIFF
julia> ga = GeoArray(rand(100,200,3))
julia> GeoArrays.write!("test.tif", ga)
```

#### Using coordinates
```julia
# Find coordinates by index
julia> coords(geoarray, [1,1])
2-element StaticArrays.SArray{Tuple{2},Float64,1,2}:
 440720.0
      3.75132e6

# Find index by coordinates
julia> indices(geoarray, [440720.0, 3.75132e6])
2-element StaticArrays.SArray{Tuple{2},Int64,1,2}:
 1
 1

# Find all coordinates
julia> coords(geoarray)
101×101 Array{StaticArrays.SArray{Tuple{2},Float64,1,2},2}:
 [440720.0, 3.75132e6]  [440720.0, 3.75126e6]  [440720.0, 3.7512e6] ...
 ...
```
#### Manipulation
```julia
# Translate complete raster by x + 100
julia> trans = Translation(100, 0)
julia> compose!(ga, trans)


# Math with GeoArrays (- + * /)
julia> GeoArray(rand(5,5,1)) - GeoArray(rand(5,5,1))
5×5×1 GeoArray{Float64}:
[:, :, 1] =
 0.417168   0.253739  0.132952   0.0702787  0.34263
```
#### Plotting
```julia
julia> using Plots
julia> fn = download("https://github.com/yeesian/ArchGDALDatasets/blob/master/pyrasterio/RGB.byte.tif?raw=true")
julia> ga = GeoArrays.read(fn)
julia> plot(ga)
```
![example plot](docs/img/RGB.byte.png)
