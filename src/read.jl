function read(fn::AbstractString, bands = nothing)
    isfile(fn) || error("File not found.")
    dataset = ArchGDAL.unsafe_read(fn)

    if bands === nothing
        nbands = ArchGDAL.nraster(dataset)
        bands = 1:nbands
    end
    A = ArchGDAL.read(dataset, bands)
    am = get_affine_map(dataset)

    # nodata masking
    # A = Array{Union{Missing, eltype(A)}}(A)
    mask = falses(size(A))
    
    for i = bands
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
        A = Array{Union{Missing,eltype(A)}}(A)
        A[mask] .= missing
    end

    # crs
    wkt = ArchGDAL.getproj(dataset)

    ArchGDAL.destroy(dataset)
    GeoArray(A, am, wkt)
end

