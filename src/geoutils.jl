function get_affine_map(ds::ArchGDAL.Dataset)
    # See https://lists.osgeo.org/pipermail/gdal-dev/2011-July/029449.html
    # for an explanation of the geotransform format
    gt = ArchGDAL.getgeotransform(ds)
    AffineMap([gt[2] gt[3]; gt[5] gt[6]], [gt[1], gt[4]])
end

const GMF = Dict(
    :GMF_ALL_VALID => 0x01,
    :GMF_PER_DATASET => 0x02,
    :GMF_ALPHA => 0x04,
    :GMF_NODATA => 0x08,
    )

"""Takes bitwise OR-ed set of status flags and returns flags."""
function mask_flags(flags::Int32)
    (f.first for f in GMF if (flags & f.second) == f.second)
end
mask_flags(band::ArchGDAL.RasterBand) = mask_flags(GDAL.C.GDALGetMaskFlags(Ptr{Nothing}(band.ptr)))

"""Retrieves nodata value from RasterBand."""
function get_nodata(band::Ptr{Nothing})
    succes_value = Int32(0)
    nodata = GDAL.C.GDALGetRasterNoDataValue(band, Ref(succes_value))
    if succes_value == 0
        return nodata
    else
        @warn "Unsuccessful in getting nodata."
        println(nodata)
        return nothing
    end
end
get_nodata(band::ArchGDAL.RasterBand) = get_nodata(Ptr{Nothing}(band.ptr))

function wkt2epsg(wkt::String)
    if isempty(wkt)
        return nothing # no projection
    else
        srs = GDAL.newspatialreference(C_NULL)
        GDAL.importfromwkt(srs, [wkt])
        epsg = parse(Int, GDAL.getauthoritycode(srs, C_NULL))
        return epsg
    end
end
