# TODO Catch only Real and Union of Missing, Real?
struct GeoArray{T} <: AbstractArray{T, 3}
    A::AbstractArray{T, 3}
    f::AffineMap
    crs::AbstractString
end
GeoArray(A::AbstractArray) = GeoArray(A, geotransform_to_affine(SVector(0.,1.,0.,0.,0.,1.)), "")

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
function coords(ga::GeoArray, p::SVector{2, Int64})
    ga.f(p.-1)
end
coords(ga::GeoArray, p::Vector{Int64}) = coords(ga, SVector{2}(p))

# Generate center coordinates for specific index
function centercoords(ga::GeoArray, p::SVector{2, Int64})
    ga.f(p.-0.5)
end
centercoords(ga::GeoArray, p::Vector{Int64}) = centercoords(ga, SVector{2}(p))

# Convert coordinates back to indices
function indices(ga::GeoArray, p::SVector{2, Float64})
    map(x->round(Int64, x), inv(ga.f)(p)::SVector{2, Float64}).+1
end
indices(ga::GeoArray, p::Vector{Float64}) = indices(ga, SVector{2}(p))
indices(ga::GeoArray, p::Tuple{Float64, Float64}) = indices(ga, SVector{2}(p))

# Overload indexing directly into GeoRaster
# TODO This could be used for interpolation instead
function Base.getindex(ga::GeoArray, I::SVector{2, Float64})
    (i, j) = indices(ga, I)
    return ga[i, j, :]
end
Base.getindex(ga::GeoArray, I::Vararg{Float64, 2}) = Base.getindex(ga, SVector{2}(I))

# Generate coordinates for complete GeoRaster
function coords(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [coords(ga, SVector{2}(i,j)) for i in 0:ui, j in 0:uj]
end
function centercoords(ga::GeoArray)
    (ui, uj) = size(ga)[1:2]
    ci = [centercoords(ga, SVector{2}(i,j)) for i in 0:ui-1, j in 0:uj-1]
end
