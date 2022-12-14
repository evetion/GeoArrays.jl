"""Check whether two `GeoArrays`s `a` and `b` are
geographically equal, although not necessarily in content."""
function equals(a::GeoArray, b::GeoArray)
    size(a) == size(b) && a.f == b.f && a.crs == b.crs
end

function Base.:-(a::GeoArray, b::GeoArray)
    equals(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .- b.A, a.f, a.crs)
end

function Base.:+(a::GeoArray, b::GeoArray)
    equals(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .+ b.A, a.f, a.crs)
end

function Base.:*(a::GeoArray, b::GeoArray)
    equals(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .* b.A, a.f, a.crs)
end

function Base.:/(a::GeoArray, b::GeoArray)
    equals(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A ./ b.A, a.f, a.crs)
end

"""
    coalesce(ga::GeoArray, v)

Replace all `missing` values in `ga` with `v` and set the `GeoArray`'s `eltype` to the non-missing type.

# Examples
```julia-repl
julia> ga = GeoArray(collect([1 missing; 2 3]))
2x2x1 Base.ReshapedArray{Union{Missing, Int64}, 3, Matrix{Union{Missing, Int64}}, Tuple{}} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS

julia> ga2 = coalesce(ga, 0)
2x2x1 Array{Int64, 3} with AffineMap([1.0 0.0; 0.0 1.0], [0.0, 0.0]) and undefined CRS
julia> ga.A
2×2×1 Array{Int64, 3}:
[:, :, 1] =
 1  0
 2  3
```
"""
function Base.coalesce(ga::GeoArray{T,A}, v) where {T,A}
    nT = nonmissingtype(T)
    cA = coalesce.(ga.A, nT(v))
    GeoArray(cA, ga.f, ga.crs)
end
