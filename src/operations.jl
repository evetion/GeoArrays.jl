"""Check whether two `GeoArrays`s `a` and `b` are
geographically equal, although not necessarily in content."""
function Base.isequal(a::GeoArray, b::GeoArray)
    size(a) == size(b) && a.f ≈ b.f && a.crs == b.crs
end

function Base.:-(a::GeoArray, b::GeoArray)
    isequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .- b.A, a.f, a.crs, a.metadata)
end

function Base.:+(a::GeoArray, b::GeoArray)
    isequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .+ b.A, a.f, a.crs, a.metadata)
end

function Base.:*(a::GeoArray, b::GeoArray)
    isequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .* b.A, a.f, a.crs, a.metadata)
end

function Base.:/(a::GeoArray, b::GeoArray)
    isequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A ./ b.A, a.f, a.crs, a.metadata)
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
    GeoArray(cA, ga.f, ga.crs, ga.metadata)
end

"""
	warp(ga::GeoArray, resolution::Real;
			   crs::GeoFormat=crs(A),
			   method::String="near")
`warp` uses `ArchGDAL.gdalwarp` to warp an `GeoArray`.

## Arguments
- `A`: The `GeoArray` to warp.
- `resolution`: A `Number` specifying the resolution for the output. If the keyword argument `crs` (described below) is specified, `resolution` must be in units of the `crs`.

## Keyword Arguments
- `crs`: A `GeoFormatTypes.GeoFormat` specifying an output crs (`A` with be reprojected to `crs` in addition to being warpd). Defaults to `crs(A)`
- `method`: A `String` specifying the method to use for resampling. Defaults to `"near"` (nearest neighbor resampling). See [resampling method](https://gdal.org/programs/gdalwarp.html#cmdoption-gdalwarp-r) in the gdalwarp docs for a complete list of possible values.
"""
function warp(ga::GeoArray, options::Dict{String}, dest="/vsimem/$(gensym())")
    dataset = ArchGDAL.Dataset(ga)
    noptions = Dict{String,Any}()
    warpdefaults!(noptions)
    merge!(noptions, options)
    ArchGDAL.gdalwarp([dataset], warpstringlist(options); dest
    ) do warped
        GeoArray(warped)
    end
end

function warp(ga::GeoArray, gao::GeoArray, options::Dict{String}=Dict{String,Any}(), dest="/vsimem/$(gensym())")
    noptions = warpoptions(gao)
    warpdefaults!(noptions)
    merge!(noptions, options)
    warp(ga, noptions, dest)
end

function warpoptions(ga::GeoArray)::Dict{String,Any}
    options = Dict{String,Any}(
        "te" => values(GeoArrays.bbox(ga)),
        "ts" => size(ga)[1:2],)

    srs = GFT.val(crs(ga))
    isempty(srs) ? nothing : options["t_srs"] = srs
    return options
end

function warpdefaults!(d::Dict)
    get!(d, "wo", Dict("NUM_THREADS" => string(Threads.nthreads)))
end
