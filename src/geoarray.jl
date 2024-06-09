const NumberOrMissing = Union{Number,Union{Missing,Number}}
const MatrixorArray = Union{<:AbstractArray{T,2},<:AbstractArray{T,3}} where {T}

"""
    GeoArray{T::NumberOrMissing,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}

A GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world.
It's three dimensional and can be seen as a stack (3D) of 2D geospatial rasters (bands), the dimensions are :x, :y, and :bands.
The AffineMap and CRS (coordinates) only operate on the :x and :y dimensions.
"""
mutable struct GeoArray{T<:NumberOrMissing,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}
    A::A
    f::CoordinateTransformations.AffineMap{StaticArrays.SMatrix{2,2,Float64,4},StaticArrays.SVector{2,Float64}}
    crs::GFT.WellKnownText{GFT.CRS}
    metadata::Dict{String}
end

"""
    GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing)

Construct a GeoArray from any Array. A default `AffineMap` and `CRS` will be generated.

# Examples
```julia-repl
julia> GeoArray(rand(10,10,1))
10x10x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS
```
"""
GeoArray(A::MatrixorArray where {T<:NumberOrMissing}) = GeoArray(A, geotransform_to_affine(SVector(0.0, 1.0, 0.0, 0.0, 0.0, 1.0)), "", Dict{String,Any}())
"""
    GeoArray(A::AbstractArray{T,3} where T <: NumberOrMissing, f::AffineMap)

Construct a GeoArray from any Array and an `AffineMap` that specifies the coordinates. A default `CRS` will be generated.
"""
GeoArray(A::MatrixorArray where {T<:NumberOrMissing}, f::AffineMap) = GeoArray(A, f, GFT.WellKnownText(GFT.CRS(), ""), Dict{String,Any}())

"""
    GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing, f::AffineMap, crs::String)

Construct a GeoArray from any Array and an `AffineMap` that specifies the coordinates and `crs` string in WKT format.
"""
GeoArray(A) = GeoArray(A, f, GFT.WellKnownText(GFT.CRS(), crs), Dict{String,Any}())
GeoArray(A, f, crs::String, d) = GeoArray(A, f, GFT.WellKnownText(GFT.CRS(), crs), d)
GeoArray(A, f, crs) = GeoArray(A, f, crs, Dict{String,Any}())
GeoArray(A, f::AffineMap{Matrix{Float64},Vector{Float64}}, args...) = GeoArray(A, AffineMap(SMatrix{2,2}(f.linear), SVector{2}(f.translation)), args...)
GeoArray(ga::T, args...) where {T<:GeoArray} = GeoArray(parent(ga), args...)

"""
    GeoArray(A::AbstractArray{T,2|3} where T <: NumberOrMissing, x::AbstractRange, y::AbstractRange, args...)

Construct a GeoArray any Array and it's coordinates from `AbstractRange`s for each dimension.
"""
function GeoArray(A::MatrixorArray where {T<:NumberOrMissing}, x::AbstractRange, y::AbstractRange, args...)
    size(A)[1:2] != (length(x), length(y)) && error("Size of `GeoArray` $(size(A)) does not match size of (x,y): $((length(x), length(y))). Note that this function takes *center coordinates*.")
    f = unitrange_to_affine(x, y)
    GeoArray(A, f, args...)
end

# Behave like an Array
Base.size(ga::GeoArray) = size(ga.A)
_size(ga::GeoArray{T,2}) where {T} = (size(ga.A)..., 1)
_size(ga::GeoArray{T,3}) where {T} = size(ga.A)
Base.IndexStyle(::Type{<:GeoArray}) = IndexCartesian()
Base.similar(ga::GeoArray, t::Type) = GeoArray(similar(parent(ga), t), ga.f, ga.crs, ga.metadata)
function Base.similar(ga::GeoArray, A::MatrixorArray)
    size(ga.A) == size(A) || error(lazy"Size of `GeoArray` $(size(ga.A)) does not match size of `A`: $(size(A)).")
    GeoArray(A, ga.f, ga.crs, ga.metadata)
end
Base.similar(ga::GeoArray, A::GeoArray) = similar(ga, parent(A))
Base.iterate(ga::GeoArray) = iterate(ga.A)
Base.iterate(ga::GeoArray, state) = iterate(ga.A, state)
Base.length(ga::GeoArray) = length(ga.A)
Base.parent(ga::GeoArray) = ga.A
Base.eltype(::Type{GeoArray{T,N}}) where {T,N} = T
Base.show(io::IO, ::MIME"text/plain", ga::GeoArray) = show(io, ga)

function Base.convert(::Type{GeoArray{T}}, ga::GeoArray{X,N}) where {T,N,X}
    A = convert(Array{T,N}, ga.A)
    GeoArray(A, ga.f, ga.crs, ga.metadata)
end
function Base.convert(::Type{GeoArray{T,N}}, ga::GeoArray) where {T,N}
    A = convert(Array{T,N}, ga.A)
    GeoArray(A, ga.f, ga.crs, ga.metadata)
end

Base.BroadcastStyle(::Type{<:GeoArray}) = Broadcast.ArrayStyle{GeoArray}()
function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{GeoArray}}, ::Type{ElType}) where {ElType}
    ga = find_ga(bc)
    GeoArray(similar(Array{ElType}, axes(bc)), ga.f, ga.crs, ga.metadata)
end

find_ga(bc::Base.Broadcast.Broadcasted) = find_ga(bc.args)
find_ga(bc::Base.Broadcast.Extruded) = find_ga(bc.x)
find_ga(args::Tuple) = find_ga(find_ga(args[1]), Base.tail(args))
find_ga(x) = x
find_ga(::Tuple{}) = nothing
find_ga(a::GeoArray, rest) = a
find_ga(::Any, rest) = find_ga(rest)

function Base.show(io::IO, ga::GeoArray)
    crs = GFT.val(ga.crs)
    wkt = isempty(crs) ? "undefined CRS" : "CRS $crs"
    print(io, "$(join(size(ga), "x")) $(typeof(ga.A)) with $(ga.f) and $(wkt)")
end

# Getindex
"""
    getindex(ga::GeoArray, i::AbstractRange, j::AbstractRange, k::Union{Colon,AbstractRange,Integer})

Index a GeoArray with `AbstractRange`s to get a cropped GeoArray with the correct `AffineMap` set.

# Examples
```julia-repl
julia> ga[2:3,2:3,1]
2x2x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [1.0, 1.0]) and undefined CRS
```
"""
function Base.getindex(ga::GeoArray{T,N}, i::AbstractRange, j::AbstractRange, k::Union{Colon,AbstractRange,Integer}=Colon()) where {T,N}
    A = N == 2 ? getindex(ga.A, i, j) : getindex(ga.A, i, j, k)
    x, y = first(i) - 1, first(j) - 1
    t = ga.f(SVector(x, y))
    l = ga.f.linear * SMatrix{2,2}([step(i) 0; 0 step(j)])
    GeoArray(A, AffineMap(l, t), crs(ga), ga.metadata)
end
function Base.getindex(ga::GeoArray{T,N}, i::Colon, j::Colon, k::Union{Colon,AbstractRange,Integer}=Colon()) where {T,N}
    A = N == 2 ? getindex(ga.A, i, j) : getindex(ga.A, i, j, k)
    GeoArray(A, ga.f, ga.crs, ga.metadata)
end

Base.getindex(ga::GeoArray{T,3}, i::AbstractRange, j::AbstractRange) where {T} = Base.getindex(ga, i, j, :)

Base.getindex(ga::GeoArray, I::Vararg{Integer,2}) = getindex(ga.A, I...)
Base.getindex(ga::GeoArray, I::Vararg{Integer,3}) = getindex(ga.A, I...)
function Base.getindex(ga::GeoArray{T,2}, I::Vararg{Integer,3}) where {T}
    I[3] != 1 && throw(BoundsError(ga, I))
    getindex(ga.A, I[1], I[2])
end

# Getindex and setindex! with floats
"""
    getindex(ga::GeoArray, I::SVector{2,<:AbstractFloat})

Index a GeoArray with `AbstractFloat`s to automatically get the value at that coordinate, using the function `indices`.
A `BoundsError` is raised if the coordinate falls outside the bounds of the raster.

# Examples
```julia-repl
julia> ga[3.0,3.0]
1-element Vector{Float64}:
 0.5630767850028582
```
"""
function Base.getindex(ga::GeoArray, I::SVector{2,<:AbstractFloat})
    i = indices(ga, I, Center())
    ga[i, :]
end
Base.getindex(ga::GeoArray, I::Vararg{AbstractFloat,2}) = getindex(ga, SVector{2}(I))

function Base.setindex!(ga::GeoArray{T,3}, v, I::SVector{2,AbstractFloat}) where {T}
    i = indices(ga, I, Center(), RoundNearestTiesUp)
    ga.A[i, :] .= v
end
function Base.setindex!(ga::GeoArray{T,2}, v, I::SVector{2,AbstractFloat}) where {T}
    i = indices(ga, I, Center(), RoundNearestTiesUp)
    ga.A[i] = v
end
Base.setindex!(ga::GeoArray, v, I::Vararg{AbstractFloat,2}) = setindex!(ga, v, SVector{2}(I))
Base.setindex!(ga::GeoArray, v, I::Vararg{Union{<:Integer,<:AbstractRange{<:Integer}},2}) = setindex!(ga.A, v, I...)
Base.setindex!(ga::GeoArray, v, I::Vararg{Union{<:Integer,<:AbstractRange{<:Integer}},3}) = setindex!(ga.A, v, I...)

# Coordinates and indices
abstract type AbstractStrategy end
"""
    Center()

Strategy to use in functions like `indices` and `coords`, in which
it will use the center of the raster cells to do coordinate conversion.
"""
struct Center <: AbstractStrategy
    offset::Float64
    Center() = new(0.5)
end
"""
    Vertex()

Strategy to use in functions like `indices` and `coords`, in which
it will use the top left vertex of the raster cells to do coordinate conversion.
"""
struct Vertex <: AbstractStrategy
    offset::Float64
    Vertex() = new(1.0)
end

"""
    coords(ga::GeoArray, p::SVector{2,<:Integer}, strategy::AbstractStrategy=Center())
    coords(ga::GeoArray, p::Tuple{<:Integer,<:Integer}, strategy::AbstractStrategy=Center())
    coords(ga::GeoArray, p::CartesianIndex{2}, strategy::AbstractStrategy=Center())

Retrieve coordinates of the cell index by `p`.
See `indices` for the inverse function.
"""
function coords(ga::GeoArray, p::SVector{2,<:Integer}, strategy::AbstractStrategy)
    SVector{2}(ga.f(p .- strategy.offset))
end
coords(ga::GeoArray, p::Vector{<:Integer}, strategy::AbstractStrategy=Center()) = coords(ga, SVector{2}(p), strategy)
coords(ga::GeoArray, p::Tuple{<:Integer,<:Integer}, strategy::AbstractStrategy=Center()) = coords(ga, SVector{2}(p), strategy)
coords(ga::GeoArray, p::CartesianIndex{2}, strategy::AbstractStrategy=Center()) = coords(ga, SVector{2}(p.I), strategy)

"""
    indices(ga::GeoArray, p::SVector{2,<:Real}, strategy::AbstractStrategy, rounding::RoundingMode)

Retrieve logical indices of the cell represented by coordinates `p`.
`strategy` can be used to define whether the coordinates represent the center (`Center`) or the top left corner (`Vertex`) of the cell.
`rounding` can be used to define how the coordinates are rounded to the nearest integer index.
See `coords` for the inverse function.
"""
function indices(ga::GeoArray, p::SVector{2,<:Real}, strategy::AbstractStrategy, rounding::RoundingMode)
    CartesianIndex(Tuple(round.(Int, inv(ga.f)(p) .+ strategy.offset, rounding)))
end
indices(ga::GeoArray, p::AbstractVector{<:Real}, strategy::AbstractStrategy=Center(), rounding::RoundingMode=RoundNearestTiesUp) = indices(ga, SVector{2}(p), strategy, rounding)
indices(ga::GeoArray, p::Tuple{<:Real,<:Real}, strategy::AbstractStrategy=Center(), rounding::RoundingMode=RoundNearestTiesUp) = indices(ga, SVector{2}(p), strategy, rounding)


# Generate coordinates for complete GeoArray
function coords(ga::GeoArray, strategy::AbstractStrategy=Center())
    (ui, uj) = size(ga)
    extra = typeof(strategy) == Center ? 0 : 1
    (coords(ga, SVector{2}(i, j), strategy) for i in 1:ui+extra, j in 1:uj+extra)
end

# Generate coordinates for one dimension of a GeoArray
function coords(ga::GeoArray, dim::Symbol, strategy::AbstractStrategy=Center())
    if is_rotated(ga)
        error("This method cannot be used for a rotated GeoArray")
    end
    extra = typeof(strategy) == Center ? 0 : 1
    if dim == :x
        ui = size(ga, 1)
        ci = [coords(ga, SVector{2}(i, 1), strategy)[1] for i in 1:ui+extra]
    elseif dim == :y
        uj = size(ga, 2)
        ci = [coords(ga, SVector{2}(1, j), strategy)[2] for j in 1:uj+extra]
    else
        error("Use :x or :y as second argument")
    end
    return ci
end

function ranges(ga::GeoArray, strategy::AbstractStrategy=Center())
    extra = typeof(strategy) == Center ? 0 : 1
    lx, ly = coords(ga, (1, 1), strategy)
    hx, hy = coords(ga, size(ga)[1:2] .+ extra, strategy)
    range(lx, hx, length=size(ga)[1] + extra), range(ly, hy, length=size(ga)[2] + extra)
end

"""
    coords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)

Set AffineMap of `GeoArray` by specifying the *center coordinates* for each `x`, `y` dimension by a `UnitRange`.
"""
function coords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)
    size(ga)[1:2] != (length(x), length(y)) && error("Size of `GeoArray` $(size(ga)) does not match size of (x,y): $((length(x), length(y))). Note that this function takes *center coordinates*.")
    ga.f = unitrange_to_affine(x, y)
    ga
end

DataAPI.metadatasupport(::Type{GeoArray}) = (read=true, write=true)
DataAPI.metadatakeys(ga) = keys(metadata(ga))
function DataAPI.metadata(ga::GeoArray, k, default; style=false)
    get(metadata(ga), k, default)
end
function DataAPI.metadata(ga::GeoArray; style=false)
    metadata(ga)
end
function DataAPI.metadata!(ga::GeoArray, key::AbstractString, value::AbstractString; style::Symbol=:default, domain::Union{Nothing,AbstractString}=nothing)
    d = isnothing(domain) ? "ROOT" : domain
    metadata(ga)[d][key] = value
end
function DataAPI.emptymetadata!(ga::GeoArray)
    ga.metadata = Dict{String,Any}()
end
