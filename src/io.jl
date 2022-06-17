"""

    read(fn::AbstractString; masked::Bool=true, band=nothing)

Read a GeoArray from `fn` by using GDAL. The nodata values are automatically set to `Missing`,
unless `masked` is set to `false`. In that case, reading is lazy, but nodata values have to be
converted manually later on. The `band` argument can be used to only read that band, and is passed
to the `getindex` as the third dimension selector and can be any valid indexer.
"""
function read(fn::AbstractString; masked::Bool=true, band=nothing)
    isfile(fn) || error("File not found.")
    # dataset = ArchGDAL.unsafe_read(fn)
    dataset = ArchGDAL.readraster(fn)
    am = get_affine_map(dataset.ds)
    wkt = ArchGDAL.getproj(dataset)

    # Not yet in type
    # meta = getmetadata(dataset)

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

    GeoArray(dataset, am, wkt)
end

"""

    write(fn::AbstractString, ga::GeoArray; nodata::Union{Nothing,Real}=nothing, shortname::AbstractString=find_shortname(fn), options::Dict{String,String}=Dict{String,String}())

Write a GeoArray to `fn`. `nodata` is used to set the nodata value. Any `Missing` values in the GeoArray are converted to this value, otherwise the `typemax` of the element type
of the array is used. The shortname determines the GDAL driver, like "GTiff", when unset the filename extension is used to derive this driver. The `options` argument may be used
to pass driver options, such as setting the compression by `Dict("compression"=>"deflate")`.
"""
function write(fn::AbstractString, ga::GeoArray; nodata::Union{Nothing,Real}=nothing, shortname::AbstractString=find_shortname(fn), options::Dict{String,String}=Dict{String,String}())
    w, h, b = size(ga)
    dtype = eltype(ga)
    data = copy(ga.A)
    use_nodata = false

    # Slice data and replace missing by nodata
    if isa(dtype, Union) && dtype.a == Missing
        dtype = dtype.b
        try
            convert(ArchGDAL.GDALDataType, dtype)
            nothing
        catch
            dtype, data = cast_to_gdal(data)
        end
        nodata === nothing && (nodata = typemax(dtype))
        m = ismissing.(data)
        data[m] .= nodata
        data = Array{dtype}(data)
        use_nodata = true
    end

    try
        convert(ArchGDAL.GDALDataType, dtype)
        nothing
    catch
        dtype, data = cast_to_gdal(data)
    end

    driver = ArchGDAL.getdriver(shortname)
    cancreate = ArchGDAL.metadataitem(driver, ArchGDAL.GDAL.GDAL_DCAP_CREATE) == "YES"
    cancopy = ArchGDAL.metadataitem(driver, ArchGDAL.GDAL.GDAL_DCAP_CREATECOPY) == "YES"

    if cancreate
        ArchGDAL.create(fn, driver=driver, width=w, height=h, nbands=b, dtype=dtype, options=stringlist(options)) do dataset
            for i = 1:b
                band = ArchGDAL.getband(dataset, i)
                ArchGDAL.write!(band, data[:, :, i])
                use_nodata && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
            end

            # Set geotransform and crs
            gt = affine_to_geotransform(ga.f)
            ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, gt)
            ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, GFT.val(ga.crs))

        end
    elseif cancopy
        ArchGDAL.create(string("/vsimem/$(gensym())"), driver=ArchGDAL.getdriver("MEM"), width=w, height=h, nbands=b, dtype=dtype) do dataset
            for i = 1:b
                band = ArchGDAL.getband(dataset, i)
                ArchGDAL.write!(band, data[:, :, i])
                use_nodata && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
            end

            # Set geotransform and crs
            gt = affine_to_geotransform(ga.f)
            ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, gt)
            ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, GFT.val(ga.crs))

            ArchGDAL.copy(dataset, filename=fn, driver=driver, options=stringlist(options))
        end
    else
        @error "Cannot create file with $shortname driver."
    end
    fn
end

write!(args...) = write(args...)
write(fn, ga, nodata=nothing, shortname=find_shortname(fn), options=Dict{String,String}()) = write(fn, ga; nodata=nodata, shortname=shortname, options=options)
