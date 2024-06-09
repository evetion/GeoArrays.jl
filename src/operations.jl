"""Check whether two `GeoArrays`s `a` and `b` are
geographically equal, although not necessarily in content."""
function isgeoequal(a::GeoArray, b::GeoArray)
    size(a) == size(b) && a.f ≈ b.f && a.crs == b.crs
end

function Base.:-(a::GeoArray, b::GeoArray)
    isgeoequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .- b.A, a.f, a.crs, a.metadata)
end

function Base.:+(a::GeoArray, b::GeoArray)
    isgeoequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .+ b.A, a.f, a.crs, a.metadata)
end

function Base.:*(a::GeoArray, b::GeoArray)
    isgeoequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
    GeoArray(a.A .* b.A, a.f, a.crs, a.metadata)
end

function Base.:/(a::GeoArray, b::GeoArray)
    isgeoequal(a, b) || throw(DimensionMismatch("Can't operate on non-geographic-equal `GeoArray`s"))
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
function Base.coalesce(ga::GeoArray{T}, v) where {T}
    nT = nonmissingtype(T)
    cA = coalesce.(ga.A, nT(v))
    GeoArray(cA, ga.f, ga.crs, ga.metadata)
end

"""
	warp(ga::GeoArray, options::Dict{String,Any}; dest="/vsimem/$(gensym())")
	warp(ga::GeoArray, like::GeoArray, options::Dict{String,Any}; dest="/vsimem/$(gensym())")

`warp` uses `ArchGDAL.gdalwarp` to warp an `GeoArray`. The `options` are passed to GDAL's `gdalwarp` command. See the [gdalwarp docs](https://gdal.org/programs/gdalwarp.html) for a complete list of options.
Another GeoArray `like` can be passed as the second argument to `warp` to use the `like`'s `crs`, `extent` and `size` as the `ga` crs and resolution.
The keyword `dest` is used to control where the temporary raster is stored. By default it is stored in memory, but can be set to a file path to directly save the warped GeoArray to disk.

!!! warning
    If no local PROJ data is available, (vertically) warping will silently fail. 
    Use `enable_online_warp()` to enable (slow) network access to PROJ data.
    For faster operations, use a utlity like `projsync` to download the data locally.

# Examples
```julia-repl
julia> ga = GeoArray(rand(100,100))
julia> epsg!(ga, 4326)
julia> ga2 = GeoArrays.warp(ga, Dict("t_srs" => "EPSG:4326+3855"))
```
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

function warp(ga::GeoArray, like::GeoArray, options::Dict{String}=Dict{String,Any}(), dest="/vsimem/$(gensym())")
    noptions = warpoptions(like)
    warpdefaults!(noptions)
    merge!(noptions, options)
    warp(ga, noptions, dest)
end

"""
    enable_online_warp(state::Bool=true)

Enable or disable network access for PROJ data, required for `warp` if no local PROJ data is available.
This has the same effect as setting the environement variable PROJ_NETWORK to "ON" *before* starting Julia.
"""
function enable_online_warp(state::Bool=true)
    ArchGDAL.GDAL.osrsetprojenablenetwork(state)
    return nothing
end

function warpoptions(ga::GeoArray)::Dict{String,Any}
    options = Dict{String,Any}(
        "te" => values(_convert(NamedTuple, GeoArrays.bbox(ga))),
        "ts" => size(ga)[1:2],)

    srs = GFT.val(crs(ga))
    isempty(srs) ? nothing : options["t_srs"] = srs
    return options
end

function warpdefaults!(d::Dict)
    get!(d, "wo", Dict("NUM_THREADS" => string(Threads.nthreads)))
    get!(d, "multi", "")
end
