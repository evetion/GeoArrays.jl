const shortnames = Dict(
    (".tif", ".tiff") => "GTiff"
)

function find_shortname(fn::AbstractString)
    _, ext = splitext(fn)
    for (k, v) in shortnames
        if ext in k
            return v
        end
    end
    error("Cannot determine GDAL Driver for $fn")
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
mask_flags(band::ArchGDAL.AbstractRasterBand) = mask_flags(GDAL.gdalgetmaskflags(Ptr{Nothing}(band.ptr)))

"""Retrieves nodata value from RasterBand."""
function get_nodata(band::Ptr{Nothing})
    succes_value = Int32(0)
    nodata = GDAL.gdalgetrasternodatavalue(band, Ref(succes_value))
    if succes_value == 0
        return nodata
    else
        @warn "Unsuccessful in getting nodata."
        return nothing
    end
end
get_nodata(band::ArchGDAL.AbstractRasterBand) = get_nodata(Ptr{Nothing}(band.ptr))
