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

function unitrange_to_affine(x::StepRangeLen, y::StepRangeLen)
    δx, δy = step(x), step(y)
    AffineMap(
        SMatrix{2,2}(δx, 0, 0, δy),
        SVector(x[1] - δx/2, y[1] - δy/2)
    )
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
