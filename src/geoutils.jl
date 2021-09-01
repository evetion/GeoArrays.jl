function get_affine_map(ds::ArchGDAL.IDataset)
    # ArchGDAL fails hard on datasets without
    # an affinemap. GDAL documents that on fail
    # a default affinemap should be returned.
    try
        global gt = ArchGDAL.getgeotransform(ds)
    catch y
        @warn y.msg
        global gt = [0.,1.,0.,0.,0.,1.]
    end
    geotransform_to_affine(SVector{6,Float64}(gt))
end

function geotransform_to_affine(gt::SVector{6,Float64})
    # See https://lists.osgeo.org/pipermail/gdal-dev/2011-July/029449.html
    # for an explanation of the geotransform format
    AffineMap(SMatrix{2,2}([gt[2] gt[3]; gt[5] gt[6]]), SVector{2}([gt[1], gt[4]]))
end
geotransform_to_affine(A::Vector{Float64}) = geotransform_to_affine(SVector{6}(A))

function affine_to_geotransform(am::AffineMap{SArray{Tuple{2,2},Float64,2,4},SArray{Tuple{2},Float64,1,2}})
    l = am.linear
    t = am.translation
    [t[1], l[1], l[3], t[2], l[2], l[4]]
end

function affine_to_geotransform(am::AffineMap{Array{Float64,2},Array{Float64,1}})
    l = am.linear
    t = am.translation
    (length(l) != 4 || length(t) != 2) || error("AffineMap has wrong dimensions.")
    [t[1], l[1], l[3], t[2], l[2], l[4]]
end

"""Check wether the AffineMap of a GeoArray contains rotations."""
function is_rotated(ga::GeoArray)
    ga.f.linear[2] != 0. || ga.f.linear[3] != 0.
end

function bbox(ga::GeoArray)
    ax, ay = ga.f(SVector(0, 0))
    bx, by = ga.f(SVector(size(ga)[1:2]))
    (min_x = min(ax, bx), min_y = min(ay, by), max_x = max(ax, bx), max_y = max(ay, by))
end

function unitrange_to_affine(x::StepRangeLen, y::StepRangeLen)
    δx, δy = step(x), step(y)
    AffineMap(
        SMatrix{2,2}(δx, 0, 0, δy),
        SVector(x[1] - δx / 2, y[1] - δy / 2)
    )
end

function bbox_to_affine(size::Tuple{Integer,Integer}, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64,Float64,Float64,Float64}})
    AffineMap(
        SMatrix{2,2}((bbox.max_x - bbox.min_x) / size[1], 0, 0, (bbox.max_y - bbox.min_y) / size[2]),
        SVector(bbox.min_x, bbox.min_y)
        )
end

"""Set geotransform of `GeoArray` by specifying a bounding box.
Note that this only can result in a non-rotated or skewed `GeoArray`."""
function bbox!(ga::GeoArray, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64,Float64,Float64,Float64}})
    ga.f = bbox_to_affine(size(ga)[1:2], bbox)
    ga
end

"""Generate bounding boxes for GeoArray cells."""
function bboxes(ga::GeoArray)
    c = coords(ga)::Array{StaticArrays.SArray{Tuple{2},Float64,1,2},2}
    m, n = size(c)
    cellbounds = Matrix{NamedTuple}(undef, (m - 1, n - 1))
    for j in 1:n - 1, i in 1:m - 1
        v = c[i:i + 1, j:j + 1]
        minx, maxx = extrema(first.(v))::Tuple{Float64,Float64}
        miny, maxy = extrema(last.(v))::Tuple{Float64,Float64}
        cellbounds[i, j] = (min_x = minx, max_x = maxx, min_y = miny, max_y = maxy)
    end
    cellbounds
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

"""Function to flip GeoArray upside down to adjust to GDAL ecosystem."""
function flipud!(ga::GeoArray)
    # Flip data upside down
    ga.A = reverse(ga.A, dims=2)

    # Find new corner coordinates
    ux, uy = ga.f(SVector{2}([0, size(ga)[2]]))

    # Define y mirror and compose
    lm = LinearMap(SMatrix{2,2}([1.0 0.0; 0.0 -1.0]))
    am = compose(ga.f, lm)  # AffineMap
    translate = SVector{2}([ux, uy])
    f = AffineMap(am.linear, translate)

    ga.f = f
    ga
end

"""Check bbox overlapping

Return true if two bboxes overlap.
"""
function bbox_overlap(
    bbox_a::NamedTuple{(:min_x, :min_y, :max_x, :max_y)},
    bbox_b::NamedTuple{(:min_x, :min_y, :max_x, :max_y)})
    # TODO Define type

    # Check if bboxes are valid
    if (bbox_a.min_x >= bbox_a.max_x) ||
        (bbox_a.min_y >= bbox_a.max_y)
        error("Invalid bbox ", bbox_a)
    end
    if (bbox_b.min_x >= bbox_b.max_x) ||
        (bbox_b.min_y >= bbox_b.max_y)
        error("Invalid bbox ", bbox_b)
    end

    # Check if bboxes overlap
    if (bbox_a.max_x < bbox_b.min_x) ||
        (bbox_a.max_y < bbox_b.min_y) ||
        (bbox_a.min_x > bbox_b.max_x) ||
        (bbox_a.min_y > bbox_b.max_y)
        return false
    else
        return true
    end
end

"""
    function crop(ga::GeoArray, cbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64,Float64,Float64,Float64}})

Crop input GeoArray by coordinates (box or another GeoArray). If the coordinates range is larger than the GeoArray, only the overlapping part is given in the result. 
"""
function crop(ga::GeoArray, cbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y)})
    # TODO Define type
    # Check if ga and cbox overlap
    if !bbox_overlap(bbox(ga), cbox)
        error("GeoArray and crop box do not overlap")
    end
    # Check extent and get bbox indices
    ga_x, ga_y, = size(ga)
    i_min_x, i_min_y = indices(ga, [cbox.min_x, cbox.max_y])
    i_max_x, i_max_y = indices(ga, [cbox.max_x, cbox.min_y])

    # bbox is larger
    i_max_x -= 1
    i_max_y -= 1

    # Determine indices for crop area
    i_min_x = max(i_min_x, 1)
    i_max_x = min(i_max_x, ga_x)
    i_min_y = max(i_min_y, 1)
    i_max_y = min(i_max_y, ga_y)

    # Subset and return GeoArray
    return ga[i_min_x:i_max_x,i_min_y:i_max_y,begin:end]
end

function crop(ga::GeoArray, cga::GeoArray)
    # Check if ga and crop ga CRS are the same
    if ga.crs != cga.crs
        error("GeoArrays have different CRS")
    end

    # Crop
    return crop(ga, bbox(cga))
end
