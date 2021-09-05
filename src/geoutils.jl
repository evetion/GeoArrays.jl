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
    ax, ay = ga.f(SVector(0,0))
    bx, by = ga.f(SVector(size(ga)[1:2]))
    (min_x=min(ax, bx), min_y=min(ay, by), max_x=max(ax, bx), max_y=max(ay, by))
end

function unitrange_to_affine(x::StepRangeLen, y::StepRangeLen)
    δx, δy = step(x), step(y)
    AffineMap(
        SMatrix{2,2}(δx, 0, 0, δy),
        SVector(x[1] - δx/2, y[1] - δy/2)
    )
end

function bbox_to_affine(size::Tuple{Integer, Integer}, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64, Float64, Float64, Float64}})
    AffineMap(
        SMatrix{2,2}((bbox.max_x - bbox.min_x) / size[1], 0, 0, (bbox.max_y - bbox.min_y)/size[2]),
        SVector(bbox.min_x, bbox.min_y)
        )
end

"""Set geotransform of `GeoArray` by specifying a bounding box.
Note that this only can result in a non-rotated or skewed `GeoArray`."""
function bbox!(ga::GeoArray, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y),Tuple{Float64, Float64, Float64, Float64}})
    ga.f = bbox_to_affine(size(ga)[1:2], bbox)
    ga
end

"""Generate bounding boxes for GeoArray cells."""
function bboxes(ga::GeoArray)
    c = coords(ga, Vertex())::Array{StaticArrays.SArray{Tuple{2},Float64,1,2},2}
    m, n = size(c)
    cellbounds = Matrix{NamedTuple}(undef, (m-1, n-1))
    for j = 1:n-1, i = 1:m-1
        v = c[i:i+1, j:j+1]
        minx, maxx = extrema(first.(v))::Tuple{Float64, Float64}
        miny, maxy = extrema(last.(v))::Tuple{Float64, Float64}
        cellbounds[i, j] = (min_x=minx, max_x=maxx, min_y=miny, max_y=maxy)
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
