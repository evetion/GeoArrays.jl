# Generate center coordinates for specific index
function centercoords(ga::GeoArray, p::SVector{2, Int})
    ga.f(p.-0.5)
end
centercoords(ga::GeoArray, p::Vector{Int}) = centercoords(ga, SVector{2}(p))

function centercoords(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [centercoords(ga, SVector{2}(i,j)) for i in 1:ui, j in 1:uj]
end
function centercoordsnotmissing(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [centercoords(ga, SVector{2}(i,j)) for i in 1:ui, j in 1:uj if ~ismissing(ga.A[i, j])]
end
function centercoordsmissing(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [centercoords(ga, SVector{2}(i,j)) for i in 1:ui, j in 1:uj if ismissing(ga.A[i, j])]
end
function indexmissing(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [[i,j] for i in 1:ui, j in 1:uj if ismissing(ga.A[i, j])]
end

function centercoords(ga::GeoArray, dim::Symbol)
    if is_rotated(ga)
        error("This method cannot be used for a rotated GeoArray")
    end
    if dim==:x
        ui = size(ga,1)
        ci = [centercoords(ga, SVector{2}(i,1))[1] for i in 1:ui]
    elseif dim==:y
        uj = size(ga,2)
        ci = [centercoords(ga, SVector{2}(1,j))[2] for j in 1:uj]
    else
        error("Use :x or :y as second argument")
    end
    return ci
end


"""Set AffineMap of `GeoArray` by specifying the *center coordinates* for each x, y dimension by a `UnitRange`."""
function centercoords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)
    size(ga)[1:2] != (length(x), length(y)) && error("Size of `GeoArray` $(size(ga)) does not match size of (x,y): $((length(x),length(y))). Note that this function takes *center coordinates*.")
    ga.f = unitrange_to_affine(x, y)
    ga
end
