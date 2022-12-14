function get_affine_map(ds::ArchGDAL.IDataset)
    # ArchGDAL fails hard on datasets without
    # an affinemap. GDAL documents that on fail
    # a default affinemap should be returned.
    local gt
    try
        gt = ArchGDAL.getgeotransform(ds)
    catch y
        @warn y.msg
        gt = [0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
    end
    geotransform_to_affine(gt)
end

function geotransform_to_affine(gt::SVector{6,<:AbstractFloat})
    # See https://lists.osgeo.org/pipermail/gdal-dev/2011-July/029449.html
    # for an explanation of the geotransform format
    AffineMap(SMatrix{2,2}([gt[2] gt[3]; gt[5] gt[6]]), SVector{2}([gt[1], gt[4]]))
end
geotransform_to_affine(A::Vector{<:AbstractFloat}) = geotransform_to_affine(SVector{6}(A))

function affine_to_geotransform(am::AffineMap)
    l = am.linear
    t = am.translation
    (length(l) == 4 && length(t) == 2) || error("AffineMap has wrong dimensions.")
    [t[1], l[1], l[3], t[2], l[2], l[4]]
end

"""Check wether the AffineMap of a GeoArray contains rotations."""
function is_rotated(ga::GeoArray)
    ga.f.linear[2] != 0.0 || ga.f.linear[3] != 0.0
end

function bbox(ga::GeoArray)
    i, j, _ = size(ga)
    if is_rotated(ga)
        ax, ay = ga.f(SVector(0, 0))
        bx, by = ga.f(SVector(i, 0))
        cx, cy = ga.f(SVector(0, j))
        dx, dy = ga.f(SVector(i, j))
        (min_x=min(ax, bx, cx, dx), min_y=min(ay, by, cy, dy), max_x=max(ax, bx, cx, dx), max_y=max(ay, by, cy, dy))
    else
        ax, ay = ga.f(SVector(0, 0))
        bx, by = ga.f(SVector(i, j))
        (min_x=min(ax, bx), min_y=min(ay, by), max_x=max(ax, bx), max_y=max(ay, by))
    end
end

function unitrange_to_affine(x::StepRangeLen, y::StepRangeLen)
    δx, δy = float(step(x)), float(step(y))
    AffineMap(
        SMatrix{2,2}(δx, 0.0, 0.0, δy),
        SVector(x[1] - δx / 2, y[1] - δy / 2)
    )
end

function bbox_to_affine(size::Tuple{Integer,Integer}, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y)})
    AffineMap(
        SMatrix{2,2}(float(bbox.max_x - bbox.min_x) / size[1], 0, 0, float(bbox.max_y - bbox.min_y) / size[2]),
        SVector(float(bbox.min_x), float(bbox.min_y))
    )
end

"""Set geotransform of `GeoArray` by specifying a bounding box.
Note that this only can result in a non-rotated or skewed `GeoArray`."""
function bbox!(ga::GeoArray, bbox::NamedTuple{(:min_x, :min_y, :max_x, :max_y)})
    ga.f = bbox_to_affine(size(ga)[1:2], bbox)
    ga
end

"""Generate bounding boxes for GeoArray cells."""
function bboxes(ga::GeoArray)
    c = coords(ga, Vertex())
    m, n = size(c)
    cellbounds = Matrix{NamedTuple}(undef, (m - 1, n - 1))
    for j in 1:n-1, i in 1:m-1
        v = c[i:i+1, j:j+1]
        minx, maxx = extrema(first.(v))
        miny, maxy = extrema(last.(v))
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

"""Check bbox overlapping

Return true if two bboxes overlap.
"""
function bbox_overlap(
    bbox_a::NamedTuple{(:min_x, :min_y, :max_x, :max_y)},
    bbox_b::NamedTuple{(:min_x, :min_y, :max_x, :max_y)})

    # Check if bboxes are valid
    if (bbox_a.min_x >= bbox_a.max_x) ||
       (bbox_a.min_y >= bbox_a.max_y)
        error("Invalid bbox (min >= max)", bbox_a)
    end
    if (bbox_b.min_x >= bbox_b.max_x) ||
       (bbox_b.min_y >= bbox_b.max_y)
        error("Invalid bbox (min >= max)", bbox_b)
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
    # Check if ga and cbox overlap
    if !bbox_overlap(bbox(ga), cbox)
        error("GeoArray and crop box do not overlap")
    end
    # Check extent and get bbox indices
    ga_x, ga_y, = size(ga)
    i_min_x, i_min_y = indices(ga, [cbox.min_x, cbox.max_y])
    i_max_x, i_max_y = indices(ga, [cbox.max_x, cbox.min_y])

    # Determine indices for crop area
    i_min_x = max(i_min_x, 1)
    i_max_x = min(i_max_x, ga_x)
    i_min_y = max(i_min_y, 1)
    i_max_y = min(i_max_y, ga_y)

    # Subset and return GeoArray
    return ga[i_min_x:i_max_x, i_min_y:i_max_y, :]
end

function crop(ga::GeoArray, cga::GeoArray)
    # Check if ga and crop ga CRS are the same
    if ga.crs != cga.crs
        error("GeoArrays have different CRS")
    end

    # Crop
    return crop(ga, bbox(cga))
end

"""
    sample!(ga::GeoArray, ga2::GeoArray)

Sample values from ga2 to ga.
"""
function sample!(ga::GeoArray, ga2::GeoArray)
    if ga.crs != ga2.crs
        error("GeoArrays have different CRS")
    end
    wo, ho, zo = size(ga)
    w, h = size(ga2)[1:2]

    # Compose AffineMap that translates from logical coordinates
    # in `ga` to logical coordinates in `ga2`
    x = inv(ga2.f) ∘ ga.f

    for io in 1:wo, jo in 1:ho
        i, j = round.(Int, x((io, jo)) .+ 0.5)
        if (1 <= i <= w) && (1 <= j <= h)
            # Loop over bands
            for z in 1:zo
                ga[io, jo, z] = ga2[i, j, z]
            end
        end
    end

    ga
end

function _sizeof(ga::GeoArray, bbox)
    x = bbox.max_x - bbox.min_x
    y = bbox.max_y - bbox.min_y
    abs.(round.(Int, (x / ga.f.linear[1], y / ga.f.linear[4], size(ga)[3])))
end

"""
    straighten(ga::GeoArray)

Straighten a rotated GeoArray, i.e. let its AffineMap only scale the coordinates.
"""
function straighten(ga)
    is_rotated(ga) || return ga

    dtype = eltype(ga)
    if !(isa(dtype, Union) && dtype.a == Missing)
        dtype = Union{Missing,dtype}
    end

    A = Array{dtype}(undef, _sizeof(ga, bbox(ga)))
    Base.fill!(A, missing)
    gar = GeoArray(A)

    bbox!(gar, bbox(ga))
    gar.crs = ga.crs
    GeoArrays.sample!(gar, ga)
    gar
end

"""
    profile(ga::GeoArray, geom; band=1)

Draw a profile along a geometry and return the values in `band` as a vector.
Geometry should be a GeoInterface compatible LineString.
"""
function profile(ga, geom; band=1)
    values = Vector{eltype(ga)}()
    GI.isgeometry(geom) || error("`geom` is not a geometry")
    GI.geomtrait(geom) == GI.LineStringTrait() || error("`geom` is not a LineString")

    for (a, b) in partition(GI.coordinates(geom), 2, 1)
        profile!(values, ga, a, b, band)
    end
    values
end

function profile!(values, ga, a, b, band)
    i0, j0 = GeoArrays.indices(ga, a)
    i1, j1 = GeoArrays.indices(ga, b)

    δx = i1 - i0
    δy = j1 - j0
    δe = abs(δy / δx)
    er = 0.0

    j = j0
    ystep = δy > 0 ? 1 : -1
    xstep = i0 < i1 ? 1 : -1
    for i in i0:xstep:i1
        push!(values, ga[i, j, band])
        er += δe
        if er > 0.5
            j += ystep
            er -= 1.0
        end
    end
end
