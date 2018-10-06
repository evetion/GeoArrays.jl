function get_affine_map(ds::ArchGDAL.Dataset)
    # ArchGDAL fails hard on datasets without
    # an affinemap. GDAL documents that on fail
    # a default affinemap should be returned.
    try
        global gt = ArchGDAL.getgeotransform(ds)
    catch y
        @warn y.msg
        global gt = [0.,1.,0.,0.,0.,1.]
    end
    geotransform_to_affine(SVector{6, Float64}(gt))
end
function geotransform_to_affine(gt::SVector{6, Float64})
    # See https://lists.osgeo.org/pipermail/gdal-dev/2011-July/029449.html
    # for an explanation of the geotransform format
    AffineMap(SMatrix{2,2}([gt[2] gt[3]; gt[5] gt[6]]), SVector{2}([gt[1], gt[4]]))
end
geotransform_to_affine(A::Vector{Float64}) = geotransform_to_affine(SVector{6}(A))

function affine_to_geotransform(am::AffineMap{SArray{Tuple{2,2},Float64,2,4},SArray{Tuple{2},Float64,1,2}})
    l = am.linear
    t = am.translation
    [t[1], l[1], l[2], t[2], l[3], l[4]]
end
function affine_to_geotransform(am::AffineMap{Array{Float64,2},Array{Float64,1}})
    l = am.linear
    t = am.translation
    (length(l) != 4 || length(t) != 2) || error("AffineMap has wrong dimensions.")
    [t[1], l[1], l[2], t[2], l[3], l[4]]
end


function smiley()
    a = falses(200,200)
    sin(1)
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

function wkt2epsg(wkt::AbstractString)
    println(wkt)
    if isempty(wkt)
        return nothing # no projection
    else
        srs = GDAL.newspatialreference(C_NULL)
        println(GDAL.importfromwkt(srs, [wkt]))
        println(srs)
        epsgcodes = GDAL.getauthoritycode(srs, C_NULL)
        println(epsgcodes)
        epsg = parse(Int, epsgcodes)
        return epsg
    end
end
