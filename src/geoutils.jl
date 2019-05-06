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

# "Get the WKT of an Integer EPSG code"
# function epsg2wkt(epsg::Nullable{Int})
#     if isnull(epsg)
#         return "" # missing projections are represented as empty strings
#     else
#         epsgcode = get(epsg)
#         srs = GDAL.newspatialreference(C_NULL)
#         GDAL.importfromepsg(srs, epsgcode)
#         wkt_ptr = Ref(Cstring(C_NULL))
#         GDAL.exporttowkt(srs, wkt_ptr)
#         return unsafe_string(wkt_ptr[])
#     end
# end

# epsg2wkt(epsg::Integer) = epsg2wkt(Nullable{Int}(epsg))
#
# """For EPSG strings like "4326" or "EPSG:4326" """
# function epsg2wkt(epsg::String)
#     if isempty(epsg)
#         return ""
#     end
#     i = findlast(epsg, ':') + 1 # also works if : is not there
#     epsgcode = Nullable{Int}(parse(Int, epsg[i:end]))
#     epsg2wkt(epsgcode)
# end
#
# function wkt2epsg(wkt::AbstractString)
#     if isempty(wkt)
#         return nothing # no projection
#     else
#         srs = GDAL.newspatialreference(C_NULL)
#         epsgcodes = GDAL.getauthoritycode(srs, C_NULL)
#         epsg = parse(Int, epsgcodes)
#         return epsg
#     end
# end

function bbox(ga::GeoArray)
    ax, ay = ga.f(SVector(0,0))
    bx, by = ga.f(SVector(size(ga)[1:2]))
    (min_x=min(ax, bx), min_y=min(ay, by), max_x=max(ax, bx), max_y=max(ay, by))
end

# Placeholder for setting bbox
function bbox!(ga::GeoArray, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64, Float64, Float64, Float64}})
    nothing
end

# Placeholder for EPSG functionality
function epsg!(ga::GeoArray, epsg::Int)
    nothing
end

# Extend CoordinateTransformations
CoordinateTransformations.compose(ga::GeoArray, t2::AffineMap) = CoordinateTransformations.compose(ga.f, t2)
CoordinateTransformations.compose(ga::GeoArray, t2::LinearMap) = CoordinateTransformations.compose(ga.f, t2)
CoordinateTransformations.compose(ga::GeoArray, t2::Translation) = CoordinateTransformations.compose(ga.f, t2)

"""Transform an GeoArray by applying a Transformation."""
function compose!(ga::GeoArray, t2::AffineMap)
    ga.f = compose(ga, t2)
end
function compose!(ga::GeoArray, t2::LinearMap)
    ga.f = compose(ga, t2)
end
function compose!(ga::GeoArray, t2::Translation)
    ga.f = compose(ga, t2)
end
