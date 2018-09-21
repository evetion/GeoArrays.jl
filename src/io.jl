function read(fn::AbstractString)
    # GDAL specific init
    GDAL.allregister()

    dataset = ArchGDAL.unsafe_read(fn)
    A = ArchGDAL.read(dataset)
    am = get_affine_map(dataset)

    # nodata masking
    A = Array{Union{Missing, eltype(A)}}(A)
    mask = falses(size(A))
    for i = 1:size(A)[end]
        band = ArchGDAL.getband(dataset, i)
        maskflags = mask_flags(band)

        # All values are valid, skip masking
        if :GMF_ALL_VALID in maskflags
            @info "No masking"
            continue
        end
        # Mask is valid for all bands
        if :GMF_PER_DATASET in maskflags
            @info "Mask for each band"
            maskband = ArchGDAL.getmaskband(band)
            m = ArchGDAL.read(maskband) .== 0
            for ii in 1:n+1
                mask[:,:,ii] = m
            end
            break
        end
        # Alpha layer
        if :GMF_ALPHA in maskflags
            @warn "Dataset has band $i with an Alpha band, which is unsupported for now."
            continue
        end
        # Nodata values
        if :GMF_NODATA in maskflags
            @info "Flag NODATA"
            nodata = eltype(A)(get_nodata(band))
            mask[:, :, i] = A[:,:,i] .== nodata
        end
    end
    A[mask] .= missing

    # crs
    wkt = ArchGDAL.getproj(dataset)
    epsg = wkt2epsg(wkt)

    # GDAL specific cleanup
    ArchGDAL.destroy(dataset)
    GDAL.destroydrivermanager()

    GeoArray(A, am, epsg)
end
