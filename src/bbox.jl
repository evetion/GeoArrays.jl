struct box
    x_min::Float64
    y_min::Float64
    x_max::Float64
    y_max::Float64
end

function bbox(ga::GeoArray)
    ax, ay = ga.f(SVector(0,0))
    bx, by = ga.f(SVector(size(ga)[1:2]))
    # (min_x=min(ax, bx), min_y=min(ay, by), max_x=max(ax, bx), max_y=max(ay, by))
    box(min(ax, bx), min(ay, by), max(ax, bx), max(ay, by))
end

function bbox_to_affine(size::Tuple{Integer, Integer}, bbox::box)
    AffineMap(
        SMatrix{2,2}((bbox.max_x - bbox.min_x) / size[1], 0, 0, -(bbox.max_y - bbox.min_y)/size[2]),
        SVector(bbox.min_x, bbox.max_y)
        )
end

function bbox_to_affine(size::Tuple{Integer, Integer}, bbox::box)
    AffineMap(
        SMatrix{2,2}((bbox.max_x - bbox.min_x) / size[1], 0, 0, -(bbox.max_y - bbox.min_y)/size[2]),
        SVector(bbox.min_x, bbox.max_y)
        )
end


"""Set geotransform of `GeoArray` by specifying a bounding box.
Note that this only can result in a non-rotated or skewed `GeoArray`."""
function bbox!(ga::GeoArray, bbox::box)
    ga.f = bbox_to_affine(size(ga)[1:2], bbox)
    ga
end

"""Generate bounding boxes for GeoArray cells."""
function bboxes(ga::GeoArray)
    c = coords(ga)::Array{StaticArrays.SArray{Tuple{2},Float64,1,2},2}
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

export box
