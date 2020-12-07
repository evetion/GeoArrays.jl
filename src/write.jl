function write!(fn::AbstractString, ga::GeoArray, nodata = nothing, shortname = find_shortname(fn))
    options = String[]
    w, h, b = size(ga)
    dtype = eltype(ga)
    data = copy(ga.A)
    use_nodata = false

    # Set compression options for GeoTIFFs
    shortname == "GTiff" && (options = ["COMPRESS=DEFLATE","TILED=YES"])

    # Slice data and replace missing by nodata
    if isa(dtype, Union) && dtype.a == Missing
        dtype = dtype.b
        if dtype ∉ keys(ArchGDAL._GDALTYPE)
            dtype, data = cast_to_gdal(data)
        end
        nodata === nothing && (nodata = typemax(dtype))
        m = ismissing.(data)
        data[m] .= nodata
        data = Array{dtype}(data)
        use_nodata = true
    end

    if dtype ∉ keys(ArchGDAL._GDALTYPE)
        dtype, data = cast_to_gdal(data)
    end

    ArchGDAL.create(fn, driver = ArchGDAL.getdriver(shortname), width = w, height = h, nbands = b, dtype = dtype, options = options) do dataset
        for i = 1:b
            band = ArchGDAL.getband(dataset, i)
            ArchGDAL.write!(band, data[:,:,i])
            # use_nodata && 
            nodata !== nothing && ArchGDAL.GDAL.gdalsetrasternodatavalue(band.ptr, nodata)
        end

        # Set geotransform and crs
        gt = affine_to_geotransform(ga.f)
        ArchGDAL.GDAL.gdalsetgeotransform(dataset.ptr, gt)
        ArchGDAL.GDAL.gdalsetprojection(dataset.ptr, GFT.val(ga.crs))

    end
    fn
end
