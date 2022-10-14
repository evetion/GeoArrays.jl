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

function Base.coalesce(ga::GeoArray{T,A}, v) where {T,A}
    nT = nonmissingtype(T)
    cA = coalesce.(ga.A, nT(v))
    GeoArray(cA, ga.f, ga.crs)
end
