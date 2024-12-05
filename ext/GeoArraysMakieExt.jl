module GeoArraysMakieExt
using GeoArrays
using Makie

Makie.plottype(raster::GeoArray) = Makie.Heatmap
Makie.used_attributes(::Type{Makie.Heatmap}, ::GeoArray) = (:band,)

function _convert(t, ga, band)
    GeoArrays.is_rotated(ga) && (ga = GeoArrays.straighten(ga))

    c = collect(GeoArrays.coords(ga, Vertex()))
    x = map(first, c[:, 1])
    y = map(last, c[end, :])
    z = ndims(ga) == 2 ? parent(ga) : @view parent(ga)[:, :, band]
    if eltype(z) <: Complex
        @warn "Plotting real part of Complex GeoArray."
        z = real.(z)
    end
    (x, y, z)
end

Makie.convert_arguments(t::Type{Heatmap}, x::Any, y::Any, ga::GeoArray; band=1) = _convert(t, ga, band)
Makie.convert_arguments(t::Type{Heatmap}, ga::GeoArray; band=1) = _convert(t, ga, band)

end
