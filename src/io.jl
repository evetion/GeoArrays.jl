"""
    read(fn::AbstractString; masked::Bool=true, band=nothing)

Read a GeoArray from `fn` by using GDAL. The nodata values are automatically set to `Missing`,
unless `masked` is set to `false`. In that case, reading is lazy, but nodata values have to be
converted manually later on. The `band` argument can be used to only read that band, and is passed
to the `getindex` as the third dimension selector and can be any valid indexer.

It's possible to read from virtual filesystems, such as S3, or to provide specific driver
pre and postfixes to read NetCDF, HDF4 and HDF5.

    read("/vsicurl/https://github.com/OSGeo/gdal/blob/master/autotest/alg/data/2by2.tif?raw=true")
    read("HDF5:"/path/to/file.hdf5":subdataset")
"""
function read(fn::AbstractString; masked::Bool=true, band=nothing)
    startswith(fn, "/vsi") || occursin(":", fn) || isfile(fn) || error("File not found.")
    GeoArray(ArchGDAL.readraster(fn), masked, band)
end

function GeoArray(ds::ArchGDAL.Dataset)
    dataset = ArchGDAL.RasterDataset(ds)
    GeoArray(dataset)
end

function GeoArray(dataset::ArchGDAL.RasterDataset, masked=true, band=nothing)
    am = get_affine_map(dataset.ds)
    wkt = ArchGDAL.getproj(dataset)

    # Not yet in type
    metadata = getmetadata(dataset)

    if isnothing(band)
        bands = 1:size(dataset)[end]
    else
        bands = band:band
    end

    # nodata masking
    if masked
        mask = falses((size(dataset)[1:2]..., length(bands)))
        for (i, b) ∈ enumerate(bands)
            band = ArchGDAL.getband(dataset, b)
            maskflags = mask_flags(band)

            # All values are valid, skip masking
            if :GMF_ALL_VALID in maskflags
                @debug "No masking"
                continue
                # Mask is valid for all bands
            elseif :GMF_PER_DATASET in maskflags
                @debug "Mask for each band"
                maskband = ArchGDAL.getmaskband(band)
                m = ArchGDAL.read(maskband) .== 0
                mask[:, :, i] = m
                # Alpha layer
            elseif :GMF_ALPHA in maskflags
                @warn "Dataset has band $i with an Alpha band, which is unsupported for now."
                continue
                # Nodata values
            elseif :GMF_NODATA in maskflags
                @debug "Flag NODATA"
                nodata = get_nodata(band)
                mask[:, :, i] = dataset[:, :, b] .== nodata
            else
                @warn "Unknown/unsupported mask."
            end
        end
    end

    if !isnothing(band)
        dataset = dataset[:, :, bands]
    end

    if masked && any(mask)
        dataset = Array{Union{Missing,eltype(dataset)}}(dataset)
        dataset[mask] .= missing
    end

    GeoArray(dataset, am, wkt, metadata)
end

"""

    write(fn::AbstractString, ga::GeoArray; nodata::Union{Nothing,Number}=nothing, shortname::AbstractString=find_shortname(fn), options::Dict{String,String}=Dict{String,String}())

Write a GeoArray to `fn`. `nodata` is used to set the nodata value. Any `Missing` values in the GeoArray are converted to this value, otherwise the `typemax` of the element type
of the array is used. The shortname determines the GDAL driver, like "GTiff", when unset the filename extension is used to derive this driver. The `options` argument may be used
to pass driver options, such as setting the compression by `Dict("compression"=>"deflate")`.
"""
function write(fn::AbstractString, ga::GeoArray; nodata::Union{Nothing,Number}=nothing, shortname::AbstractString=find_shortname(fn), options::Dict{String,String}=Dict{String,String}())

    driver = ArchGDAL.getdriver(shortname)
    cancreate = ArchGDAL.metadataitem(driver, ArchGDAL.GDAL.GDAL_DCAP_CREATE) == "YES"
    cancopy = ArchGDAL.metadataitem(driver, ArchGDAL.GDAL.GDAL_DCAP_CREATECOPY) == "YES"

    if cancreate
        w, h, b = size(ga)
        data, dtype, nodata = prep(ga, nodata)

        ArchGDAL.create(fn, driver=driver, width=w, height=h, nbands=b, dtype=dtype, options=stringlist(options)) do dataset
            for i = 1:b
                band = ArchGDAL.getband(dataset, i)
                ArchGDAL.write!(band, data[:, :, i])
                !isnothing(nodata) && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
            end

            # Set geotransform and crs
            gt = affine_to_geotransform(ga.f)
            ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, gt)
            ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, GFT.val(ga.crs))
            setmetadata(dataset, ga.metadata)

        end
    elseif cancopy
        dataset = ArchGDAL.Dataset(ga::GeoArray)
        ArchGDAL.copy(dataset, filename=fn, driver=driver, options=stringlist(options))
    else
        @error "Cannot create file with $shortname driver."
    end
    fn
end


write!(args...) = write(args...)
write(fn, ga, nodata=nothing, shortname=find_shortname(fn), options=Dict{String,String}()) = write(fn, ga; nodata=nodata, shortname=shortname, options=options)


function ArchGDAL.Dataset(ga::GeoArray)
    w, h, b = size(ga)

    data, dtype, nodata = prep(ga)

    dataset = ArchGDAL.create(string("/vsimem/$(gensym())"), driver=ArchGDAL.getdriver("MEM"), width=w, height=h, nbands=b, dtype=dtype)
    for i = 1:b
        band = ArchGDAL.getband(dataset, i)
        ArchGDAL.write!(band, data[:, :, i])
        !isnothing(nodata) && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
    end

    # Set geotransform and crs
    gt = affine_to_geotransform(ga.f)
    ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, gt)
    ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, GFT.val(ga.crs))
    setmetadata(dataset, ga.metadata)
    return dataset
end

ArchGDAL.RasterDataset(ga::GeoArray) = ArchGDAL.RasterDataset(ArchGDAL.Dataset(ga))


function prep(ga, nodata=nothing)
    need_nodata = false
    need_convert = false

    dtype = eltype(ga)

    # Check whether we need to replace missing
    if isa(dtype, Union) && dtype.a == Missing
        dtype = dtype.b
        dtype <: Complex && error("Nodata is not supported with complex numbers, please use `coalesce` to replace missing values with a valid value.")
        need_nodata = true
    end

    # Check whether we need to convert to a supported type
    # hasmethod doesn't work :(
    try
        convert(ArchGDAL.GDALDataType, dtype)
    catch
        dtype = gdaltype(dtype)
        need_convert = true
    end

    if need_nodata
        data = Array{dtype}(undef, size(ga.A))
        m = ismissing.(ga.A)
        isnothing(nodata) && (nodata = typemax(dtype))
        data[m] .= nodata
        data[.!m] .= ga.A[.!m]
    elseif need_convert
        data = Array{dtype}(ga.A)
    else
        data = ga.A
    end
    data, dtype, nodata
end
