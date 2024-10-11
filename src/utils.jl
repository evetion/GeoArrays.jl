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
    ArchGDAL.extensiondriver(fn)
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
    Int64 => Int32,
    Bool => UInt8,
)

"""Converts type of Array for one that exists in GDAL."""
function gdaltype(type)
    if type in keys(gdt_conversion)
        newtype = gdt_conversion[type]
        @warn "Casting $type to $newtype to fit in GDAL."
        return newtype
    else
        error("Can't cast $(type) to GDAL.")
    end
end

function getmetadata(ds::ArchGDAL.RasterDataset, domain::AbstractString)
    a = ArchGDAL.metadata(ds.ds, domain=domain)
    k, v = zip(split.(a, "=")...)
    Dict(Pair.(collect(k), collect(v))...)
end

function getmetadata(ds::ArchGDAL.RasterDataset)
    domains = ArchGDAL.metadatadomainlist(ds.ds)
    values = getmetadata.(Ref(ds), domains)
    # replace!(domains, "" => "ROOT")
    Dict(Pair.(domains, values))
end

function setmetadata(ds::ArchGDAL.AbstractDataset, d::Dict{String})
    for (domain, dict) in d
        for (k, v) in dict
            ArchGDAL.GDAL.gdalsetmetadataitem(ds, k, v, domain)
        end
    end
end

function stringlist(dict::Dict{String})
    sv = Vector{String}()
    for (k, v) in pairs(dict)
        push!(sv, replace(uppercase(string(k)), "COMPRESSION"=>"COMPRESS", "COMPRESSED"=>"COMPRESS") * "=" * string(v))
    end
    return sv
end

function warpstringlist(dict::Dict{String})
    sv = Vector{String}()
    for (k, v) in pairs(dict)
        if v isa Dict
            for option in stringlist(v)
                push!(sv, keystring(k))
                push!(sv, option)
            end
        else
            push!(sv, keystring(k))
            isempty(v) ? nothing : append!(sv, valuestring(v))
        end
    end
    return sv
end
keystring(s) = startswith(s, "-") ? s : string("-", s)
valuestring(s) = (string(s),)
valuestring(s::Tuple) = string.(s)
valuestring(s::Vector) = string.(s)
