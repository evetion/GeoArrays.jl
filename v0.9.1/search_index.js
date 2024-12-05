var documenterSearchIndex = {"docs":
[{"location":"CHANGELOG/#Changelog","page":"Changelog","title":"Changelog","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"All notable changes to this project will be documented in this file.","category":"page"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.","category":"page"},{"location":"CHANGELOG/#[Unreleased]","page":"Changelog","title":"[Unreleased]","text":"","category":"section"},{"location":"CHANGELOG/#[0.9.1]-2024-12-5","page":"Changelog","title":"[0.9.1] - 2024-12-5","text":"","category":"section"},{"location":"CHANGELOG/#Added","page":"Changelog","title":"Added","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Added Makie plotting extension for GeoArrays. Use plot(ga) to plot a GeoArray with Makie.","category":"page"},{"location":"CHANGELOG/#[0.9.0]-2024-06-11","page":"Changelog","title":"[0.9.0] - 2024-06-11","text":"","category":"section"},{"location":"CHANGELOG/#Changes","page":"Changelog","title":"Changes","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"[Breaking] Changed type signature of GeoArray to include the number of dimensions. This allows","category":"page"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"for single \"band\" GeoArrays to be represented as matrices as well. This should make it easier to  work with single band rasters and the image ecosystem.","category":"page"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"[Breaking] bbox and friends now return an Extents.Extent instead of a NamedTuple.\n[Breaking] Reverted rename of equals to Base.isequal, now called isgeoequal.\n[Breaking] getindex, indices and sample now use the rounding mode RoundNearestTiesUp instead of RoundNearest.","category":"page"},{"location":"CHANGELOG/#Deprecated","page":"Changelog","title":"Deprecated","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"[Breaking] Bounding box input for crop, warp and others is now deprecated. Use an Extent instead.","category":"page"},{"location":"CHANGELOG/#Fixed","page":"Changelog","title":"Fixed","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Try to release file lock on close as soon as possible.\nIndexing a GeoArray with [:, :] now returns a GeoArray","category":"page"},{"location":"CHANGELOG/#Added-2","page":"Changelog","title":"Added","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Added enable_online_warp function to enable online access to PROJ data for warp.\nAdded rounding argument to indices to control rounding mode used.","category":"page"},{"location":"CHANGELOG/#[0.8.5]-2024-01-07","page":"Changelog","title":"[0.8.5] - 2024-01-07","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Fix small bug in metadata\nMove GeoStatsBase into an extension","category":"page"},{"location":"CHANGELOG/#[0.8.4]-2024-01-07","page":"Changelog","title":"[0.8.4] - 2024-01-07","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Fix crop returning too small an array\nUpdate GeoStatsBase compat bounds and fix interpolation","category":"page"},{"location":"CHANGELOG/#[0.8.3]-2023-10-14","page":"Changelog","title":"[0.8.3] - 2023-10-14","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Correct roundoff errors in ranges\nDrop Julia 1.6 (LTS), now requires 1.9","category":"page"},{"location":"CHANGELOG/#[0.8.2]-2023-05-10","page":"Changelog","title":"[0.8.2] - 2023-05-10","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Fix backwards compatible constructors for metadata, so the old constructor GeoArray(A, f, crs) still works.","category":"page"},{"location":"CHANGELOG/#[0.8.1]-2023-04-06","page":"Changelog","title":"[0.8.1] - 2023-04-06","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Documented bandnames kwarg of write\nFixed plotting being broken in 0.8\nExtended broadcast (isinf.(ga::GeoArray) now works)\nSupport writing Boolean GeoArrays as UInt8.","category":"page"},{"location":"CHANGELOG/#[0.8.0]-2023-03-31","page":"Changelog","title":"[0.8.0] - 2023-03-31","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Added warp for warping GeoArrays.\nAdded ranges for returning the x and y StepRange of coordinates.\nReplaced equals with Base.isequal and made sure to compare the AffineMap only approximately to account for floating point precision.\ncoords(ga) now returns an iterator. Apply collect on it for the old behaviour.\nindices now returns a CartesianIndex instead of i, j. Call .I on it for the old behaviour.\nwrite takes a bandnames keyword, which can be used to set the band description\nmetadata, used in both reading and writing, has been added to a GeoArrays.","category":"page"},{"location":"CHANGELOG/#[0.7.13]-2023-01-12","page":"Changelog","title":"[0.7.13] - 2023-01-12","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Added convert, affine!\nAdded broadcast for GeoArray, so ga .+ 1 isa GeoArray","category":"page"},{"location":"CHANGELOG/#[0.7.12]-2023-01-12","page":"Changelog","title":"[0.7.12] - 2023-01-12","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Fix interpolation, update to GeoStatsSolvers\nFix indexing bug in non-singleton sized GeoArrays","category":"page"},{"location":"CHANGELOG/#[0.7.11]-2023-01-09","page":"Changelog","title":"[0.7.11] - 2023-01-09","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Update compat bounds to use ArchGDAL 0.10","category":"page"},{"location":"CHANGELOG/#[0.7.10]-2022-12-14","page":"Changelog","title":"[0.7.10] - 2022-12-14","text":"","category":"section"},{"location":"CHANGELOG/#Added-3","page":"Changelog","title":"Added","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Add profile tool to sample raster values.\nSubsample GeoArrays in plotting for performance. Use scalefactor to control this.","category":"page"},{"location":"CHANGELOG/#Changed","page":"Changelog","title":"Changed","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Changed GeoArray eltype to allow for Complex numbers.","category":"page"},{"location":"CHANGELOG/#[0.7.9]-2022-10-15","page":"Changelog","title":"[0.7.9] - 2022-10-15","text":"","category":"section"},{"location":"CHANGELOG/#Added-4","page":"Changelog","title":"Added","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Added coalesce option for a GeoArray\nAdded pre:and:post fixes to filenames, now supports netcdf and s3 like paths","category":"page"},{"location":"CHANGELOG/#Fixed-2","page":"Changelog","title":"Fixed","text":"","category":"section"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"Fixed iterate specification so sum on a GeoArray is correct","category":"page"},{"location":"CHANGELOG/","page":"Changelog","title":"Changelog","text":"[unreleased]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.1...HEAD [0.9.0]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.5...v0.9.0 [0.8.5]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.4...v0.8.5 [0.8.4]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.3...v0.8.4 [0.8.3]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.2...v0.8.3 [0.8.2]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.1...v0.8.2 [0.8.1]: https://github.com/evetion/GeoArrays.jl/compare/v0.8.0...v0.8.1 [0.8.0]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.13...v0.8.0 [0.7.13]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.12...v0.7.13 [0.7.12]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.11...v0.7.12 [0.7.11]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.10...v0.7.11 [0.7.10]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.9...v0.7.10 [0.7.9]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.8...v0.7.9","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = GeoArrays","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: ) (Image: ) (Image: CI) (Image: codecov)","category":"page"},{"location":"#GeoArrays","page":"Home","title":"GeoArrays","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Simple geographical raster interaction built on top of ArchGDAL, GDAL and CoordinateTransformations.","category":"page"},{"location":"","page":"Home","title":"Home","text":"A GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world. It's three dimensional and can be seen as a stack (3D) of 2D geospatial rasters (bands), the dimensions are :x, :y, and :bands. The AffineMap and CRS (coordinates) only operate on the :x and :y dimensions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This packages takes its inspiration from Python's rasterio.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(v1.8) pkg> add GeoArrays","category":"page"},{"location":"#Examples","page":"Home","title":"Examples","text":"","category":"section"},{"location":"#Basic-Usage","page":"Home","title":"Basic Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Load the GeoArrays package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using GeoArrays","category":"page"},{"location":"","page":"Home","title":"Home","text":"Read a GeoTIFF file and display its information, i.e. AffineMap and projection (CRS).","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Read TIF file\njulia> fn = download(\"https://github.com/yeesian/ArchGDALDatasets/blob/master/data/utmsmall.tif?raw=true\")\njulia> geoarray = GeoArrays.read(fn)\n100x100x1 Array{UInt8,3} with AffineMap([60.0 0.0; 0.0 -60.0], [440720.0, 3.75132e6]) and CRS PROJCS[\"NAD27 / UTM zone 11N\"...\n\n# Affinemap containing offset and scaling\njulia> geoarray.f\nAffineMap([60.0 0.0; 0.0 -60.0], [440720.0, 3.75132e6])\n\n# WKT projection string\njulia> geoarray.crs\nGeoFormatTypes.WellKnownText{GeoFormatTypes.CRS}(GeoFormatTypes.CRS(), \"PROJCS[\\\"NAD27 / UTM zone 11N\\\",GEOGCS[\\\"NAD27\\\",DATUM[\\\"North_American_Datum_1927\\\",SPHEROID[\\\"Clarke 1866\\\",6378206.4,294.978698213898,AUTHORITY[\\\"EPSG\\\",\\\"7008\\\"]],AUTHORITY[\\\"EPSG\\\",\\\"6267\\\"]],PRIMEM[\\\"Greenwich\\\",0],UNIT[\\\"degree\\\",0.0174532925199433,AUTHORITY[\\\"EPSG\\\",\\\"9122\\\"]],AUTHORITY[\\\"EPSG\\\",\\\"4267\\\"]],PROJECTION[\\\"Transverse_Mercator\\\"],PARAMETER[\\\"latitude_of_origin\\\",0],PARAMETER[\\\"central_meridian\\\",-117],PARAMETER[\\\"scale_factor\\\",0.9996],PARAMETER[\\\"false_easting\\\",500000],PARAMETER[\\\"false_northing\\\",0],UNIT[\\\"metre\\\",1,AUTHORITY[\\\"EPSG\\\",\\\"9001\\\"]],AXIS[\\\"Easting\\\",EAST],AXIS[\\\"Northing\\\",NORTH],AUTHORITY[\\\"EPSG\\\",\\\"26711\\\"]]\")","category":"page"},{"location":"#Writing-to-GeoTIFF","page":"Home","title":"Writing to GeoTIFF","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Create a random GeoArray and write it to a GeoTIFF file.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Create, reference and write a TIFF\njulia> ga = GeoArray(rand(100,200))\njulia> bbox!(ga, (min_x=2., min_y=51., max_x=5., max_y=54.))  # roughly the Netherlands\njulia> epsg!(ga, 4326)  # in WGS84\njulia> GeoArrays.write(\"test.tif\", ga)\n# Or write it with compression and tiling\njulia> GeoArrays.write(\"test_compressed.tif\", ga; options=Dict(\"TILED\"=>\"YES\", \"COMPRESS\"=>\"ZSTD\"))","category":"page"},{"location":"#Streaming-support","page":"Home","title":"Streaming support","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The package supports streaming reading.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Read in 39774x60559x1 raster (AHN3), but without masking (missing) support\njulia> @time ga = GeoArrays.read(fn, masked=false)\n  0.001917 seconds (46 allocations: 2.938 KiB)\n39774x60559x1 ArchGDAL.RasterDataset{Float32,ArchGDAL.IDataset} with AffineMap([1.0433425614165472e-6 0.0; 0.0 -1.0433425614165472e-6], [0.8932098305563291, 0.11903776654646055]) and CRS PROJCS[\"Amersfoort / RD New\",GEOGCS[\"Amersfoort\",DATUM[\"Amersfoort\",SPHEROID[\"Bessel 1841\",6377397.155,299.1528128,AUTHORITY[\"EPSG\",\"7004\"]],AUTHORITY[\"EPSG\",\"6289\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4289\"]],PROJECTION[\"Oblique_Stereographic\"],PARAMETER[\"latitude_of_origin\",52.1561605555556],PARAMETER[\"central_meridian\",5.38763888888889],PARAMETER[\"scale_factor\",0.9999079],PARAMETER[\"false_easting\",155000],PARAMETER[\"false_northing\",463000],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"28992\"]]","category":"page"},{"location":"#Reading-bands","page":"Home","title":"Reading bands","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GeoTIFFs can be large, with several bands, one can read.","category":"page"},{"location":"","page":"Home","title":"Home","text":"When working with large rasters, e.g. with satellite images that can be GB in size, it is useful to be able to read only one band (or a selection of them) to GeoArray. When using read, one can specify the band.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Get file\njulia> fn = download(\"https://github.com/yeesian/ArchGDALDatasets/blob/master/pyrasterio/RGB.byte.tif?raw=true\")\n\n# Read band 2\njulia> ga_band = GeoArrays.read(fn, masked=false, band=2)\n791x718x1 Array{UInt8, 3} with AffineMap([300.0379266750948 0.0; 0.0 -300.041782729805], [101985.0, 2.826915e6]) and CRS PROJCS[\"UTM Zone 18, Northern Hemisphere\",GEOGCS[\"Unknown datum based upon the WGS 84 ellipsoid\",DATUM[\"Not_specified_based_on_WGS_84_spheroid\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-75],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]","category":"page"},{"location":"","page":"Home","title":"Home","text":"In case there is missing data, the type will be a Union{Missing, T}. To convert to a GeoArray without missing, you can call coalesce(ga, value_to_replace_missing).","category":"page"},{"location":"#Using-coordinates","page":"Home","title":"Using coordinates","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GeoArrays have geographical coordinates for all array elements (pixels). They can be retrieved with the GeoArrays.coords function.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Find coordinates by index\njulia> GeoArrays.coords(geoarray, (1,1))\n2-element StaticArrays.SArray{Tuple{2},Float64,1,2}:\n 440720.0\n      3.75132e6","category":"page"},{"location":"","page":"Home","title":"Home","text":"All coordinates (tuples) are obtained as generator when omitting the index parameter.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Find all coordinates\njulia> collect(GeoArrays.coords(geoarray))\n101×101 Matrix{StaticArraysCore.SVector{2, Float64}}:\n [440720.0, 3.75132e6]  [440720.0, 3.75126e6]  [440720.0, 3.7512e6] ...\n ...","category":"page"},{"location":"","page":"Home","title":"Home","text":"Similarly, one can find the coordinates ranges of a GeoArray","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> x, y = GeoArrays.ranges(geoarray)\n(440750.0:60.0:446690.0, 3.75129e6:-60.0:3.74535e6)","category":"page"},{"location":"","page":"Home","title":"Home","text":"The operation can be reversed, i.e. row and column index can be computed from coordinates with the indices function.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Find index by coordinates\njulia> indices(geoarray, [440720.0, 3.75132e6])\nCartesianIndex(1, 1)","category":"page"},{"location":"#Manipulation","page":"Home","title":"Manipulation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Basic GeoArray manipulation is implemented, e.g. translation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Translate complete raster by x + 100\njulia> trans = Translation(100, 0)\njulia> compose!(ga, trans)","category":"page"},{"location":"","page":"Home","title":"Home","text":"When GeoArrays have the same dimensions, AffineMap and CRS, addition, subtraction, multiplication and division can be used.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Math with GeoArrays (- + * /)\njulia> GeoArray(rand(5,5,1)) - GeoArray(rand(5,5,1))\n5x5x1 Array{Float64,3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS","category":"page"},{"location":"","page":"Home","title":"Home","text":"One can also warp an array, using GDAL behind the scenes. For example, we can vertically transform from the ellipsoid to the EGM2008 geoid using EPSG code 3855. Note that the underlying PROJ library needs to find the geoidgrids, so if they're not available locally, one needs to set ENV[\"PROJ_NETWORK\"] = \"ON\" as early as possible, ideally before loading GeoArrays.","category":"page"},{"location":"","page":"Home","title":"Home","text":"ga = GeoArray(zeros((360, 180)))\nbbox!(ga, (min_x=-180, min_y=-90, max_x=180, max_y=90))\ncrs!(ga, GeoFormatTypes.EPSG(4979))  # WGS83 in 3D (reference to ellipsoid)\nga2 = GeoArrays.warp(ga, Dict(\"t_srs\" => \"EPSG:4326+3855\"))","category":"page"},{"location":"#Nodata-filling","page":"Home","title":"Nodata filling","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GeoArrays with missing data can be filled with the fill! function.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using GeoStatsSolvers  # or any estimation solver from the GeoStats ecosystem\njulia> ga = GeoArray(Array{Union{Missing, Float64}}(rand(5, 1)))\njulia> ga.A[2,1] = missing\n[:, :, 1] =\n 0.6760718768442127\n  missing\n 0.852882193026649\n 0.7137410453351622\n 0.5949409082233854\njulia> GeoArrays.fill!(ga, IDW(:band => (neighbors=3,)))  # band is the hardcoded variable\n[:, :, 1] =\n 0.6760718768442127\n 0.7543298370153771\n 0.852882193026649\n 0.7137410453351622\n 0.5949409082233854","category":"page"},{"location":"#Plotting","page":"Home","title":"Plotting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Individual bands from a GeoArray can be plotted with the plot function. By default the first band is used.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Plot a GeoArray\njulia> using Plots\njulia> fn = download(\"https://github.com/yeesian/ArchGDALDatasets/blob/master/pyrasterio/RGB.byte.tif?raw=true\")\njulia> ga = GeoArrays.read(fn)\njulia> plot(ga)\n\n# or plot a band other than the first one\njulia> plot(ga, band=2)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: example plot)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note that for larger GeoArrays, only a sample of the data is plotted for performance. By default the sample size is twice figure size. You can control this factor by calling plot(ga, scalefactor=2), where higher scalefactor yields higher sizes, up to the original GeoArray size.","category":"page"},{"location":"#Subsetting-arrays","page":"Home","title":"Subsetting arrays","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GeoArrays can be subset by row, column and band using the array subsetting notation, e.g. ga[100:200, 200:300, 1:2].","category":"page"},{"location":"","page":"Home","title":"Home","text":"# Get file\njulia> fn = download(\"https://github.com/yeesian/ArchGDALDatasets/blob/master/pyrasterio/RGB.byte.tif?raw=true\")\n\n# Read the entire file\njulia> ga = GeoArrays.read(fn);\n\njulia> ga.f\nAffineMap([300.0379266750948 0.0; 0.0 -300.041782729805], [101985.0, 2.826915e6])\n\njulia> ga_sub = ga[200:500,200:400,begin:end]\n301x201x3 Array{Union{Missing, UInt8}, 3} with AffineMap([300.0379266750948 0.0; 0.0 -300.041782729805], [161692.54740834387, 2.767206685236769e6]) and CRS PROJCS[\"UTM Zone 18, Northern Hemisphere\",GEOGCS[\"Unknown datum based upon the WGS 84 ellipsoid\",DATUM[\"Not_specified_based_on_WGS_84_spheroid\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-75],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH]]\n\njulia> ga_sub.f\nAffineMap([300.0379266750948 0.0; 0.0 -300.041782729805], [161692.54740834387, 2.767206685236769e6])\n\njulia> plot(ga_sub)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: example plot)","category":"page"},{"location":"#Profile","page":"Home","title":"Profile","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"You can sample the values along a line in a GeoArray with profile(ga, linestring). The linestring can be any geometry that supports GeoInterface.jl.","category":"page"},{"location":"#Alternatives","page":"Home","title":"Alternatives","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GeoArrays.jl was written to quickly save a geospatial Array to disk. Its functionality mimics rasterio in Python. If one requires more features–-such as rasterization or zonal stats–-which also work on NetCDF files, Rasters.jl is a good alternative. Its functionality is more like (rio)xarray in Python.","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Modules = [GeoArrays]","category":"page"},{"location":"#GeoArrays.Center","page":"Home","title":"GeoArrays.Center","text":"Center()\n\nStrategy to use in functions like indices and coords, in which it will use the center of the raster cells to do coordinate conversion.\n\n\n\n\n\n","category":"type"},{"location":"#GeoArrays.GeoArray","page":"Home","title":"GeoArrays.GeoArray","text":"GeoArray{T::NumberOrMissing,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}\n\nA GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world. It's three dimensional and can be seen as a stack (3D) of 2D geospatial rasters (bands), the dimensions are :x, :y, and :bands. The AffineMap and CRS (coordinates) only operate on the :x and :y dimensions.\n\n\n\n\n\n","category":"type"},{"location":"#GeoArrays.GeoArray-Tuple{Any}","page":"Home","title":"GeoArrays.GeoArray","text":"GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing, f::AffineMap, crs::String)\n\nConstruct a GeoArray from any Array and an AffineMap that specifies the coordinates and crs string in WKT format.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.GeoArray-Tuple{Union{AbstractArray{T, 3}, AbstractMatrix{T}} where T, AbstractRange, AbstractRange, Vararg{Any}}","page":"Home","title":"GeoArrays.GeoArray","text":"GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing, x::AbstractRange, y::AbstractRange, args...)\n\nConstruct a GeoArray any Array and it's coordinates from AbstractRanges for each dimension.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.GeoArray-Tuple{Union{AbstractArray{T, 3}, AbstractMatrix{T}} where T, CoordinateTransformations.AffineMap}","page":"Home","title":"GeoArrays.GeoArray","text":"GeoArray(A::AbstractArray{T,3} where T <: NumberOrMissing, f::AffineMap)\n\nConstruct a GeoArray from any Array and an AffineMap that specifies the coordinates. A default CRS will be generated.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.GeoArray-Tuple{Union{AbstractArray{T, 3}, AbstractMatrix{T}} where T}","page":"Home","title":"GeoArrays.GeoArray","text":"GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing)\n\nConstruct a GeoArray from any Array. A default AffineMap and CRS will be generated.\n\nExamples\n\njulia> GeoArray(rand(10,10,1))\n10x10x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.Vertex","page":"Home","title":"GeoArrays.Vertex","text":"Vertex()\n\nStrategy to use in functions like indices and coords, in which it will use the top left vertex of the raster cells to do coordinate conversion.\n\n\n\n\n\n","category":"type"},{"location":"#Base.coalesce-Union{Tuple{T}, Tuple{GeoArray{T, N, A} where {N, A<:AbstractArray{T, N}}, Any}} where T","page":"Home","title":"Base.coalesce","text":"coalesce(ga::GeoArray, v)\n\nReplace all missing values in ga with v and set the GeoArray's eltype to the non-missing type.\n\nExamples\n\njulia> ga = GeoArray(collect([1 missing; 2 3]))\n2x2x1 Base.ReshapedArray{Union{Missing, Int64}, 3, Matrix{Union{Missing, Int64}}, Tuple{}} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS\n\njulia> ga2 = coalesce(ga, 0)\n2x2x1 Array{Int64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS\njulia> ga.A\n2×2×1 Array{Int64, 3}:\n[:, :, 1] =\n 1  0\n 2  3\n\n\n\n\n\n","category":"method"},{"location":"#Base.getindex-Tuple{GeoArray, StaticArraysCore.SVector{2, <:AbstractFloat}}","page":"Home","title":"Base.getindex","text":"getindex(ga::GeoArray, I::SVector{2,<:AbstractFloat})\n\nIndex a GeoArray with AbstractFloats to automatically get the value at that coordinate, using the function indices. A BoundsError is raised if the coordinate falls outside the bounds of the raster.\n\nExamples\n\njulia> ga[3.0,3.0]\n1-element Vector{Float64}:\n 0.5630767850028582\n\n\n\n\n\n","category":"method"},{"location":"#Base.getindex-Union{Tuple{N}, Tuple{T}, Tuple{GeoArray{T, N, A} where A<:AbstractArray{T, N}, AbstractRange, AbstractRange}, Tuple{GeoArray{T, N, A} where A<:AbstractArray{T, N}, AbstractRange, AbstractRange, Union{Colon, Integer, AbstractRange}}} where {T, N}","page":"Home","title":"Base.getindex","text":"getindex(ga::GeoArray, i::AbstractRange, j::AbstractRange, k::Union{Colon,AbstractRange,Integer})\n\nIndex a GeoArray with AbstractRanges to get a cropped GeoArray with the correct AffineMap set.\n\nExamples\n\njulia> ga[2:3,2:3,1]\n2x2x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [1.0, 1.0]) and undefined CRS\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.bbox!-Tuple{GeoArray, NamedTuple{(:min_x, :min_y, :max_x, :max_y)}}","page":"Home","title":"GeoArrays.bbox!","text":"Set geotransform of GeoArray by specifying a bounding box. Note that this only can result in a non-rotated or skewed GeoArray.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.bbox_overlap-Tuple{NamedTuple{(:min_x, :min_y, :max_x, :max_y)}, NamedTuple{(:min_x, :min_y, :max_x, :max_y)}}","page":"Home","title":"GeoArrays.bbox_overlap","text":"Check bbox overlapping\n\nReturn true if two bboxes overlap.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.bboxes-Tuple{GeoArray}","page":"Home","title":"GeoArrays.bboxes","text":"Generate bounding boxes for GeoArray cells.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.compose!-Tuple{GeoArray, CoordinateTransformations.AffineMap}","page":"Home","title":"GeoArrays.compose!","text":"Transform an GeoArray by applying a Transformation.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.coords!-Tuple{Any, AbstractUnitRange, AbstractUnitRange}","page":"Home","title":"GeoArrays.coords!","text":"coords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)\n\nSet AffineMap of GeoArray by specifying the center coordinates for each x, y dimension by a UnitRange.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.coords-Tuple{GeoArray, StaticArraysCore.SVector{2, <:Integer}, GeoArrays.AbstractStrategy}","page":"Home","title":"GeoArrays.coords","text":"coords(ga::GeoArray, p::SVector{2,<:Integer}, strategy::AbstractStrategy=Center())\ncoords(ga::GeoArray, p::Tuple{<:Integer,<:Integer}, strategy::AbstractStrategy=Center())\ncoords(ga::GeoArray, p::CartesianIndex{2}, strategy::AbstractStrategy=Center())\n\nRetrieve coordinates of the cell index by p. See indices for the inverse function.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.crop-Union{Tuple{N}, Tuple{T}, Tuple{GeoArray{T, N, A} where A<:AbstractArray{T, N}, Extents.Extent{(:X, :Y)}}} where {T, N}","page":"Home","title":"GeoArrays.crop","text":"function crop(ga::GeoArray, cbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64,Float64,Float64,Float64}})\n\nCrop input GeoArray by coordinates (box or another GeoArray). If the coordinates range is larger than the GeoArray, only the overlapping part is given in the result.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.enable_online_warp","page":"Home","title":"GeoArrays.enable_online_warp","text":"enable_online_warp(state::Bool=true)\n\nEnable or disable network access for PROJ data, required for warp if no local PROJ data is available. This has the same effect as setting the environement variable PROJ_NETWORK to \"ON\" before starting Julia.\n\n\n\n\n\n","category":"function"},{"location":"#GeoArrays.epsg!-Tuple{GeoArray, Int64}","page":"Home","title":"GeoArrays.epsg!","text":"Set CRS on GeoArray by epsgcode\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.epsg2wkt-Tuple{Int64}","page":"Home","title":"GeoArrays.epsg2wkt","text":"Get the WKT of an Integer EPSG code\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.fill!-Tuple{GeoArray, Any, Any}","page":"Home","title":"GeoArrays.fill!","text":"fill!(ga::GeoArray, solver, band=1)\n\nReplace missing values in GeoArray ga using solver.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.flipud!-Tuple{GeoArray}","page":"Home","title":"GeoArrays.flipud!","text":"Function to flip GeoArray upside down to adjust to GDAL ecosystem.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.gdaltype-Tuple{Any}","page":"Home","title":"GeoArrays.gdaltype","text":"Converts type of Array for one that exists in GDAL.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.get_nodata-Tuple{Ptr{Nothing}}","page":"Home","title":"GeoArrays.get_nodata","text":"Retrieves nodata value from RasterBand.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.indices-Tuple{GeoArray, StaticArraysCore.SVector{2, <:Real}, GeoArrays.AbstractStrategy, RoundingMode}","page":"Home","title":"GeoArrays.indices","text":"indices(ga::GeoArray, p::SVector{2,<:Real}, strategy::AbstractStrategy, rounding::RoundingMode)\n\nRetrieve logical indices of the cell represented by coordinates p. strategy can be used to define whether the coordinates represent the center (Center) or the top left corner (Vertex) of the cell. rounding can be used to define how the coordinates are rounded to the nearest integer index. See coords for the inverse function.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.is_rotated-Tuple{GeoArray}","page":"Home","title":"GeoArrays.is_rotated","text":"Check wether the AffineMap of a GeoArray contains rotations.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.isgeoequal-Tuple{GeoArray, GeoArray}","page":"Home","title":"GeoArrays.isgeoequal","text":"Check whether two GeoArrayss a and b are geographically equal, although not necessarily in content.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.mask_flags-Tuple{Int32}","page":"Home","title":"GeoArrays.mask_flags","text":"Takes bitwise OR-ed set of status flags and returns flags.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.profile-Tuple{Any, Any}","page":"Home","title":"GeoArrays.profile","text":"profile(ga::GeoArray, geom; band=1)\n\nDraw a profile along a geometry and return the values in band as a vector. Geometry should be a GeoInterface compatible LineString.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.proj2wkt-Tuple{AbstractString}","page":"Home","title":"GeoArrays.proj2wkt","text":"Get the WKT of an Proj string\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.read-Tuple{AbstractString}","page":"Home","title":"GeoArrays.read","text":"read(fn::AbstractString; masked::Bool=true, band=nothing)\n\nRead a GeoArray from fn by using GDAL. The nodata values are automatically set to Missing, unless masked is set to false. In that case, reading is lazy, but nodata values have to be converted manually later on. The band argument can be used to only read that band, and is passed to the getindex as the third dimension selector and can be any valid indexer.\n\nIt's possible to read from virtual filesystems, such as S3, or to provide specific driver pre and postfixes to read NetCDF, HDF4 and HDF5.\n\nread(\"/vsicurl/https://github.com/OSGeo/gdal/blob/master/autotest/alg/data/2by2.tif?raw=true\")\nread(\"HDF5:\"/path/to/file.hdf5\":subdataset\")\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.sample!-Tuple{GeoArray, GeoArray}","page":"Home","title":"GeoArrays.sample!","text":"sample!(ga::GeoArray, ga2::GeoArray)\n\nSample values from ga2 to ga.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.str2wkt-Tuple{AbstractString}","page":"Home","title":"GeoArrays.str2wkt","text":"Parse CRS string into WKT.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.straighten-Tuple{Any}","page":"Home","title":"GeoArrays.straighten","text":"straighten(ga::GeoArray)\n\nStraighten a rotated GeoArray, i.e. let its AffineMap only scale the coordinates.\n\n\n\n\n\n","category":"method"},{"location":"#GeoArrays.warp","page":"Home","title":"GeoArrays.warp","text":"warp(ga::GeoArray, options::Dict{String,Any}; dest=\"/vsimem/##292\")\nwarp(ga::GeoArray, like::GeoArray, options::Dict{String,Any}; dest=\"/vsimem/##293\")\n\nwarp uses ArchGDAL.gdalwarp to warp an GeoArray. The options are passed to GDAL's gdalwarp command. See the gdalwarp docs for a complete list of options. Another GeoArray like can be passed as the second argument to warp to use the like's crs, extent and size as the ga crs and resolution. The keyword dest is used to control where the temporary raster is stored. By default it is stored in memory, but can be set to a file path to directly save the warped GeoArray to disk.\n\nwarning: Warning\nIf no local PROJ data is available, (vertically) warping will silently fail.  Use enable_online_warp() to enable (slow) network access to PROJ data. For faster operations, use a utlity like projsync to download the data locally.\n\nExamples\n\njulia> ga = GeoArray(rand(100,100))\njulia> epsg!(ga, 4326)\njulia> ga2 = GeoArrays.warp(ga, Dict(\"t_srs\" => \"EPSG:4326+3855\"))\n\n\n\n\n\n","category":"function"},{"location":"#GeoArrays.write-Tuple{AbstractString, GeoArray}","page":"Home","title":"GeoArrays.write","text":"write(fn::AbstractString, ga::GeoArray; nodata::Union{Nothing,Number}=nothing, shortname::AbstractString=find_shortname(fn), options::Dict{String,String}=Dict{String,String}(), bandnames=nothing)\n\nWrite a GeoArray to fn. nodata is used to set the nodata value. Any Missing values in the GeoArray are converted to this value, otherwise the typemax of the element type of the array is used. The shortname determines the GDAL driver, like \"GTiff\", when unset the filename extension is used to derive this driver. The options argument may be used to pass driver options, such as setting the compression by Dict(\"compression\"=>\"deflate\"). The bandnames keyword argument can be set to a vector or tuple of strings to set  the band descriptions. It should have the same length as the number of bands.\n\n\n\n\n\n","category":"method"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}
