# # Generate upper left coordinates for specic index
# function coords(ga::GeoArray, p::SVector{2, Int})
#     ga.f(p.-1)
# end
# coords(ga::GeoArray, p::Vector{Int}) = coords(ga, SVector{2}(p))

# # Generate coordinates for complete GeoArray
# function coords(ga::GeoArray)
#     (ui, uj) = size(ga)[1:2]
#     ci = [coords(ga, SVector{2}(i,j)) for i in 1:ui+1, j in 1:uj+1]
# end
# function coords2(ga::GeoArray, p::SVector{2, Int}, mid::Vector{Int} = [1, 1])
#     ga.f(p .- 1 + mid./2) 
# end
# coords2(ga::GeoArray, p::Vector{Int}, mid::Vector{Int} = [1, 1]) = coords2(ga, SVector{2}(p), mid)

# function coords2(ga::GeoArray, mid::Vector{Int} = [1, 1])
#     (ui, uj) = size(ga)[1:2]    
#     ci = [coords2(ga, SVector{2}(i,j), mid) for i in 1:ui, j in 1:uj]
# end    

# # Generate coordinates for one dimension of a GeoArray
# function coords(ga::GeoArray, dim::Symbol)
#     if is_rotated(ga)
#         error("This method cannot be used for a rotated GeoArray")
#     end
#     if dim==:x
#         ui = size(ga,1)
#         ci = [coords(ga, SVector{2}(i,1))[1] for i in 1:ui+1]
#     elseif dim==:y
#         uj = size(ga,2)
#         ci = [coords(ga, SVector{2}(1,j))[2] for j in 1:uj+1]
#     else
#         error("Use :x or :y as second argument")
#     end
#     return ci
# end

function meshgrid(x::AbstractArray{T,1}, y::AbstractArray{T,1}) where T <: Real 
    X = x .* ones(1, length(y))
    Y = ones(length(x)) .* y'
    X, Y
end

function coords_xy(ga::GeoArray, mid::Vector{Int} = [1, 1])
    if length(mid) == 1; mid = [mid, mid]; end
    
    cellsize_x = ga.f.linear[1]
    cellsize_y = abs(ga.f.linear[4])
    cellsize_y2 = ga.f.linear[4]
    
    mid = [1, 1]
    delta = [cellsize_x, cellsize_y]/2 .* mid
    
    x = range[1] + delta[1]:cellsize_x:range[3]
    y = range[2] + delta[2]:cellsize_y:range[4]
    if cellsize_y2 < 0; y = reverse(y); end

    x, y
end

function coords_xy(bbox::box, cellsize::T) where {T <: Real}
    lon = bbox.xmin + cellsize/2 : cellsize : bbox.xmax
    lat = reverse(bbox.ymin + cellsize/2 : cellsize : bbox.ymax)
    lon, lat # return
end

coords_x(ga::GeoArray, mid::Int = 1) = coords_xy(ga, mid)[1]
coords_y(ga::GeoArray, mid::Int = 1) = coords_xy(ga, mid)[2]

function coords(ga::GeoArray, mid::Vector{Int} = [1, 1])
    x, y = coords_xy(ga, mid)
    meshgrid(x, y)
end


export meshgrid, coords, coords_xy, coords_x, coords_y
