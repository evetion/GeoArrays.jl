function Base.:-(a::GeoArray, b::GeoArray)
    size(a) == size(b) || throw(DimensionMismatch("The sizes of a and b do not match."))
    a.f == b.f || error("The affine information does not match")
    a.crs == b.crs || error("The crs information does not match")
    GeoArray(a.A .- b.A,a.f,a.crs)
end

function Base.:+(a::GeoArray, b::GeoArray)
    size(a) == size(b) || throw(DimensionMismatch("The sizes of a and b do not match."))
    a.f == b.f || error("The affine information does not match")
    a.crs == b.crs || error("The crs information does not match")
    GeoArray(a.A .+ b.A,a.f,a.crs)
end

function Base.:*(a::GeoArray, b::GeoArray)
    size(a) == size(b) || throw(DimensionMismatch("The sizes of a and b do not match."))
    a.f == b.f || error("The affine information does not match")
    a.crs == b.crs || error("The crs information does not match")
    GeoArray(a.A .* b.A,a.f,a.crs)
end

function Base.:/(a::GeoArray, b::GeoArray)
    size(a) == size(b) || throw(DimensionMismatch("The sizes of a and b do not match."))
    a.f == b.f || error("The affine information does not match")
    a.crs == b.crs || error("The crs information does not match")
    GeoArray(a.A ./ b.A,a.f,a.crs)
end
