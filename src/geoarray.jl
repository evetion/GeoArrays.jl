const RealOrMissing = Union{Number,Union{Missing,Number}}

"""
    GeoArray{T::RealOrMissing,A<:AbstractArray{T,3}} <: AbstractArray{T,3}

A GeoArray is an AbstractArray, an AffineMap for calculating coordinates based on the axes and a CRS definition to interpret these coordinates into in the real world.
It's three dimensional and can be seen as a stack (3D) of 2D geospatial rasters (bands), the dimensions are :x, :y, and :bands.
The AffineMap and CRS (coordinates) only operate on the :x and :y dimensions.
"""
mutable struct GeoArray{T<:RealOrMissing,A<:AbstractArray{T,3}} <: AbstractArray{T,3}
    A::A
    f::CoordinateTransformations.AffineMap{StaticArrays.SMatrix{2,2,Float64,4},StaticArrays.SVector{2,Float64}}
    crs::GFT.WellKnownText{GFT.CRS}
end

"""
    GeoArray(A::AbstractArray{T,3} where T <: RealOrMissing)

Construct a GeoArray from any Array. A default `AffineMap` and `CRS` will be generated.

# Examples
```julia-repl
julia> GeoArray(rand(10,10,1))
10x10x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS
```
"""
GeoArray(A::AbstractArray{T,3} where {T<:RealOrMissing}) = GeoArray(A, geotransform_to_affine(SVector(0.0, 1.0, 0.0, 0.0, 0.0, 1.0)), "")
"""
    GeoArray(A::AbstractArray{T,3} where T <: RealOrMissing, f::AffineMap)

Construct a GeoArray from any Array and an `AffineMap` that specifies the coordinates. A default `CRS` will be generated.
"""
GeoArray(A::AbstractArray{T,3} where {T<:RealOrMissing}, f::AffineMap) = GeoArray(A, f, GFT.WellKnownText(GFT.CRS(), ""))

"""
    GeoArray(A::AbstractArray{T,3} where T <: RealOrMissing, f::AffineMap, crs::String)

Construct a GeoArray from any Array and an `AffineMap` that specifies the coordinates and `crs` string in WKT format.
"""
GeoArray(A::AbstractArray{T,3} where {T<:RealOrMissing}, f::AffineMap, crs::String) = GeoArray(A, f, GFT.WellKnownText(GFT.CRS(), crs))

GeoArray(A::AbstractArray{T,3} where {T<:RealOrMissing}, f::AffineMap{Matrix{Float64},Vector{Float64}}, crs::GFT.WellKnownText{GFT.CRS}) = GeoArray(A, AffineMap(SMatrix{2,2}(f.linear), SVector{2}(f.translation)), crs)

"""
    GeoArray(A::AbstractArray{T,2} where T <: RealOrMissing)

Construct a GeoArray from any Matrix, a third singleton dimension will be added automatically.

# Examples
```julia-repl
julia> GeoArray(rand(10,10))
10x10x1 Array{Float64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS
```
"""
GeoArray(A::AbstractArray{T,2} where {T<:RealOrMissing}, args...) = GeoArray(reshape(A, size(A)..., 1), args...)

"""
    GeoArray(A::AbstractArray{T,3} where T <: RealOrMissing, x::AbstractRange, y::AbstractRange, args...)

Construct a GeoArray any Array and it's coordinates from `AbstractRange`s for each dimension.
"""
function GeoArray(A::AbstractArray{T,3} where {T<:RealOrMissing}, x::AbstractRange, y::AbstractRange, args...)
    size(A)[1:2] != (length(x), length(y)) && error("Size of `GeoArray` $(size(A)) does not match size of (x,y): $((length(x), length(y))). Note that this function takes *center coordinates*.")
    f = unitrange_to_affine(x, y)
    GeoArray(A, f, args...)
end

# Behave like an Array
Base.size(ga::GeoArray) = size(ga.A)
Base.IndexStyle(::Type{<:GeoArray}) = IndexCartesian()
Base.similar(ga::GeoArray, t::Type) = GeoArray(similar(ga.A, t), ga.f, ga.crs)
Base.iterate(ga::GeoArray) = iterate(ga.A)
Base.iterate(ga::GeoArray, state) = iterate(ga.A, state)
Base.length(ga::GeoArray) = length(ga.A)
Base.parent(ga::GeoArray) = ga.A
Base.eltype(::Type{GeoArray{T}}) where {T} = T
Base.show(io::IO, ::MIME"text/plain", ga::GeoArray) = show(io, ga)

function Base.show(io::IO, ga::GeoArray)
    crs = GFT.val(ga.crs)
    wkt = length(crs) == 0 ? "undefined CRS" : "CRS $crs"
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
function Base.getindex(ga::GeoArray, i::AbstractRange, j::AbstractRange, k::Union{Colon,AbstractRange,Integer})
    A = getindex(ga.A, i, j, k)
    x, y = first(i) - 1, first(j) - 1
    t = ga.f(SVector(x, y))
    l = ga.f.linear * SMatrix{2,2}([step(i) 0; 0 step(j)])
    GeoArray(A, AffineMap(l, t), ga.crs)
end
Base.getindex(ga::GeoArray, i::AbstractRange, j::AbstractRange) = Base.getindex(ga, i, j, :)

Base.getindex(ga::GeoArray, I::Vararg{<:Integer,2}) = getindex(ga.A, I..., :)
Base.getindex(ga::GeoArray, I::Vararg{<:Integer,3}) = getindex(ga.A, I...)

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
    (i, j) = indices(ga, I, Center())
    ga[i, j, :]
end
Base.getindex(ga::GeoArray, I::Vararg{<:AbstractFloat,2}) = getindex(ga, SVector{2}(I))

function Base.setindex!(ga::GeoArray, v, I::SVector{2,AbstractFloat})
    i, j = indices(ga, I, Center())
    ga.A[i, j, :] .= v
end
Base.setindex!(ga::GeoArray, v, I::Vararg{<:AbstractFloat,2}) = setindex!(ga, v, SVector{2}(I))
Base.setindex!(ga::GeoArray, v, I::Vararg{Union{<:Integer,<:AbstractRange{<:Integer}},2}) = setindex!(ga.A, v, I..., :)
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
    coords(ga::GeoArray, p::SVector{2,<:Integer}, strategy::AbstractStrategy)

Retrieve coordinates of the cell index by `p`.
See `indices` for the inverse function.
"""
function coords(ga::GeoArray, p::SVector{2,<:Integer}, strategy::AbstractStrategy)
    SVector{2}(ga.f(p .- strategy.offset))
end
coords(ga::GeoArray, p::Vector{<:Integer}, strategy::AbstractStrategy=Center()) = coords(ga, SVector{2}(p), strategy)
coords(ga::GeoArray, p::Tuple{<:Integer,<:Integer}, strategy::AbstractStrategy=Center()) = coords(ga, SVector{2}(p), strategy)

"""
    indices(ga::GeoArray, p::SVector{2,<:Real}, strategy::AbstractStrategy)

Retrieve logical indices of the cell represented by coordinates `p`.
`strategy` can be used to define whether the coordinates represent the center (`Center`) or the top left corner (`Vertex`) of the cell.
See `coords` for the inverse function.
"""
function indices(ga::GeoArray, p::SVector{2,<:Real}, strategy::AbstractStrategy)
    round.(Int, inv(ga.f)(p) .+ strategy.offset)::SVector{2,Int}
end
indices(ga::GeoArray, p::Vector{<:Real}, strategy::AbstractStrategy=Center()) = indices(ga, SVector{2}(p), strategy)
indices(ga::GeoArray, p::Tuple{<:Real,<:Real}, strategy::AbstractStrategy=Center()) = indices(ga, SVector{2}(p), strategy)


# Generate coordinates for complete GeoArray
function coords(ga::GeoArray, strategy::AbstractStrategy=Center())
    (ui, uj) = size(ga)[1:2]
    extra = typeof(strategy) == Center ? 0 : 1
    [coords(ga, SVector{2}(i, j), strategy) for i in 1:ui+extra, j in 1:uj+extra]::Matrix{SVector{2,Float64}}
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

"""
    coords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)

Set AffineMap of `GeoArray` by specifying the *center coordinates* for each `x`, `y` dimension by a `UnitRange`.
"""
function coords!(ga, x::AbstractUnitRange, y::AbstractUnitRange)
    size(ga)[1:2] != (length(x), length(y)) && error("Size of `GeoArray` $(size(ga)) does not match size of (x,y): $((length(x), length(y))). Note that this function takes *center coordinates*.")
    ga.f = unitrange_to_affine(x, y)
    ga
end
