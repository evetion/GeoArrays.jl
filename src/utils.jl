const shortnames = Dict(
    (".tif", ".tiff") => "GTiff",
    (".img",) => "HFA",
    (".xyz",) => "XYZ",
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
mask_flags(band::ArchGDAL.AbstractRasterBand) = mask_flags(ArchGDAL.GDAL.gdalgetmaskflags(Ptr{Nothing}(band.ptr)))

"""Retrieves nodata value from RasterBand."""
function get_nodata(band::Ptr{Nothing})
    succes_value = Int32(0)
    nodata = ArchGDAL.GDAL.gdalgetrasternodatavalue(band, Ref(succes_value))
    if succes_value == 0
        return nodata
    else
        @warn "Unsuccessful in getting nodata."
        return nothing
    end
end
get_nodata(band::ArchGDAL.AbstractRasterBand) = get_nodata(Ptr{Nothing}(band.ptr))


const gdt_conversion = Dict{DataType,DataType}(
    Int8 => UInt8,
    UInt64 => UInt32,
    Int64 => Int32
)

"""Converts type of Array for one that exists in GDAL."""
function cast_to_gdal(A::Array{<:Real,3})
    type = eltype(A)
    if type in keys(gdt_conversion)
        newtype = gdt_conversion[type]
        @warn "Casting $type to $newtype to fit in GDAL."
        return newtype, convert(Array{newtype}, A)
    else
        error("Can't cast $(eltype(A)) to GDAL.")
    end
end
