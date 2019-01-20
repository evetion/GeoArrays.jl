const gdt_lookup = Dict{DataType, GDAL.GDALDataType}(
    UInt8 => GDAL.GDT_Byte,
    UInt16 => GDAL.GDT_UInt16,
    Int16 => GDAL.GDT_Int16,
    UInt32 => GDAL.GDT_UInt32,
    Int32 => GDAL.GDT_Int32,
    Float32 => GDAL.GDT_Float32,
    Float64 => GDAL.GDT_Float64
)

function read(fn::AbstractString)
    # GDAL specific init
    GDAL.allregister()

    isfile(fn) || error("File not found.")
    dataset = ArchGDAL.unsafe_read(fn)
    A = ArchGDAL.read(dataset)
    am = get_affine_map(dataset)

    # nodata masking
    # A = Array{Union{Missing, eltype(A)}}(A)
    mask = falses(size(A))
    for i = 1:size(A)[end]
        band = ArchGDAL.getband(dataset, i)
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
            mask[:,:,i] = m
        # Alpha layer
        elseif :GMF_ALPHA in maskflags
            @warn "Dataset has band $i with an Alpha band, which is unsupported for now."
            continue
        # Nodata values
        elseif :GMF_NODATA in maskflags
            @debug "Flag NODATA"
            nodata = get_nodata(band)
            mask[:, :, i] = A[:,:,i] .== nodata
        else
            @warn "Unknown/unsupported mask."
        end
    end

    if any(mask)
        A = Array{Union{Missing, eltype(A)}}(A)
        A[mask] .= missing
    end

    # crs
    wkt = ArchGDAL.getproj(dataset)

    # GDAL specific cleanup
    ArchGDAL.destroy(dataset)
    GDAL.destroydrivermanager()
    GeoArray(A, am, wkt)
end

function write!(fn::AbstractString, ga::GeoArray, nodata=nothing)
    GDAL.allregister()
    shortname = find_shortname(fn)
    w, h, b = size(ga)
    dtype = eltype(ga)
    data = copy(ga.A)
    use_nodata = false

    # Slice data and replace missing by nodata
    if isa(dtype, Union) && dtype.a == Missing
        dtype = dtype.b
        nodata == nothing && (nodata = typemax(dtype))
        m = ismissing.(data)
        data[m] .= nodata
        data = Array{dtype}(data)
        use_nodata = true
    end

    ArchGDAL.create(fn, shortname, width=w, height=h, nbands=b, dtype=dtype) do dataset
        for i=1:b
            band = ArchGDAL.getband(dataset, i)
            ArchGDAL.write!(band, data[:,:,i])
            use_nodata && GDAL.setrasternodatavalue(band.ptr, nodata)
        end

        # Set geotransform and crs
        gt = affine_to_geotransform(ga.f)
        GDAL.setgeotransform(dataset.ptr, gt)
        GDAL.setprojection(dataset.ptr, ga.crs)

    end
    # GDAL specific cleanup
    GDAL.destroydrivermanager()
end
