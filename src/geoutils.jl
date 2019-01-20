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


function wkt2epsg(wkt::AbstractString)
    println(wkt)
    if isempty(wkt)
        return nothing # no projection
    else
        srs = GDAL.newspatialreference(C_NULL)
        epsgcodes = GDAL.getauthoritycode(srs, C_NULL)
        epsg = parse(Int, epsgcodes)
        return epsg
    end
end

function bbox(ga::GeoArray)
    min = ga.f(SVector(0,0))
    max = ga.f(SVector(size(ga)[1:2]))
    (min_x=min[1], min_y=min[2], max_x=max[1], max_y=max[2])
end
