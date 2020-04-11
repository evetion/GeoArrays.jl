mutable struct GeoArray{T<:Union{Real, Union{Missing, Real}}} <: AbstractArray{T, 3}
    A::AbstractArray{T, 3}
    f::AffineMap
    crs::AbstractString
end
GeoArray(A::AbstractArray{T, 3} where T<:Union{Real, Union{Missing, Real}}) = GeoArray(A, geotransform_to_affine(SVector(0.,1.,0.,0.,0.,1.)), "")
GeoArray(A::AbstractArray{T, 2} where T<:Union{Real, Union{Missing, Real}}) = GeoArray(reshape(A, size(A)..., 1), geotransform_to_affine(SVector(0.,1.,0.,0.,0.,1.)), "")

Base.size(ga::GeoArray) = size(ga.A)
Base.IndexStyle(::Type{T}) where {T<:GeoArray} = IndexLinear()
Base.getindex(ga::GeoArray, i::Int) = getindex(ga.A, i)
Base.getindex(ga::GeoArray, I::Vararg{Int, 2}) = getindex(ga.A, I..., :)
Base.getindex(ga::GeoArray, I::Vararg{Int, 3}) = getindex(ga.A, I...)
Base.iterate(ga::GeoArray) = iterate(ga.A)
Base.length(ga::GeoArray) = length(ga.A)
Base.parent(ga::GeoArray) = ga.A
# Base.map(f, ga::GeoArray) = GeoArray(map(f, ga.A), ga.f, ga.crs)
# Base.convert(::Type{Array{T, 3}}, A::GeoArray{T}) where {T} = convert(Array{T,3}, ga.A)
Base.eltype(::Type{GeoArray{T}}) where {T} = T

function Base.show(io::IO, ga::GeoArray)
    print(io, "$(join(size(ga), "x")) $(typeof(ga.A)) with $(ga.f) and WKT $(ga.crs)")
end
function Base.show(ga::GeoArray)
    print("$(join(size(ga), "x")) $(typeof(ga.A)) with $(ga.f) and WKT $(ga.crs)")
end

# Generate upper left coordinates for specic index
function coords(ga::GeoArray, p::SVector{2, Int})
    ga.f(p.-1)
end
coords(ga::GeoArray, p::Vector{Int}) = coords(ga, SVector{2}(p))

# Generate center coordinates for specific index
function centercoords(ga::GeoArray, p::SVector{2, Int})
    ga.f(p.-0.5)
end
centercoords(ga::GeoArray, p::Vector{Int}) = centercoords(ga, SVector{2}(p))

# Convert coordinates back to indices
function indices(ga::GeoArray, p::SVector{2, Float64})
    map(x->round(Int, x), inv(ga.f)(p)::SVector{2, Float64}).+1
end
indices(ga::GeoArray, p::Vector{Float64}) = indices(ga, SVector{2}(p))
indices(ga::GeoArray, p::Tuple{Float64, Float64}) = indices(ga, SVector{2}(p))

# Overload indexing directly into GeoArray
# TODO This could be used for interpolation instead
function Base.getindex(ga::GeoArray, I::SVector{2, Float64})
    (i, j) = indices(ga, I)
    return ga[i, j, :]
end
Base.getindex(ga::GeoArray, I::Vararg{Float64, 2}) = Base.getindex(ga, SVector{2}(I))

# Generate coordinates for complete GeoArray
function coords(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [coords(ga, SVector{2}(i,j)) for i in 1:ui+1, j in 1:uj+1]
end
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

# Generate coordinates for one dimension of a GeoArray
function coords(ga::GeoArray, dim::Symbol)
    if is_rotated(ga)
        error("This method cannot be used for a rotated GeoArray")
    end
    if dim==:x
        ui = size(ga,1)
        ci = [coords(ga, SVector{2}(i,1))[1] for i in 1:ui+1]
    elseif dim==:y
        uj = size(ga,2)
        ci = [coords(ga, SVector{2}(1,j))[2] for j in 1:uj+1]
    else
        error("Use :x or :y as second argument")
    end
    return ci
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
