using CoordinateTransformations
# using StaticArrays

struct GeoArray{T, N} <: AbstractArray{Union{Missing, T}, N}
    A::Array{Union{Missing, T}, N}
    f::AffineMap
    crs::Union{Int, Nothing}
end

Base.size(ga::GeoArray) = size(ga.A)
Base.IndexStyle(::Type{T}) where {T<:GeoArray} = IndexLinear()
Base.getindex(ga::GeoArray, i::Int) = getindex(ga.A, i)
Base.getindex(ga::GeoArray, I::Vararg{Int, 2}) = getindex(ga.A, I..., 1)
Base.getindex(ga::GeoArray, I::Vararg{Int, 3}) = getindex(ga.A, I...)
Base.iterate(ga::GeoArray) = iterate(ga.A)
Base.length(ga::GeoArray) = length(ga.A)
Base.parent(ga::GeoArray) = ga.A
# Base.map(f, ga::GeoArray) = GeoArray(map(f, ga.A), ga.f, ga.crs)
# Base.convert(::Type{Array{T, 3}}, A::GeoArray{T}) where {T} = convert(Array{T,3}, ga.A)
Base.eltype(::Type{GeoArray{T}}) where {T} = Union{Missing, T}

function Base.show(io::IO, ga::GeoArray)
    print(io, "$(join(size(ga), "x")) $(typeof(ga.A)) with $(ga.f) and WKID $(ga.crs)")
end

function Base.show(ga::GeoArray)
    print("$(join(size(ga), "x")) $(typeof(ga.A)) with $(ga.f) and WKID $(ga.crs)")
end

function coords(ga::GeoArray, p::Vector{Int64})
    ga.f(p.-1)
end

function coords(ga::GeoArray, p::Vector{Float64})
    map(Int64, inv(ga.f)(p).+1)
end
