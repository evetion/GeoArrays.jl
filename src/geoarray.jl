
struct GeoArray{T, N} <: AbstractArray{T, N}
    A::Array{Union{Missing, T}, N}
    f::AffineMap
    crs::Int
end

Base.size(ga::GeoArray) = size(ga.A)
Base.IndexStyle(::Type{T}) where {T<:GeoArray} = IndexCartesian()
# Base.getindex(ga::GeoArray, i::Int) = getindex(ga.A, i)
Base.getindex(ga::GeoArray, I::Vararg{Int, 2}) = getindex(ga.A, I...)
Base.getindex(ga::GeoArray, I::Vararg{Int, 3}) = getindex(ga.A, I...)
