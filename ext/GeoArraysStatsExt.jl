module GeoArraysStatsExt

using GeoArrays, GeoStatsModels, GeoStatsTransforms

"""
    fill!(ga::GeoArray, solver::GeoStatsModels.GeoStatsModel, band=1; kwargs...)

Replace missing values in GeoArray `ga` using `solver` from the GeoStats ecosystem.

Keyword arguments are forwarded to `GeoStatsTransforms.Interpolate` (e.g. `point`, `prob`).
"""
function GeoArrays.fill!(ga::GeoArray, solver::T, band=1; kwargs...) where {T<:GeoStatsModels.GeoStatsModel}
    GeoArrays.is_rotated(ga) && error("Can't interpolate rotated GeoArrays yet. Please make an issue.")

    data = @view ga.A[:, :, band]
    any(ismissing, data) || return ga

    dims = size(ga)[1:2]
    origin = Tuple(ga.f.translation)
    spacing = (abs(ga.f.linear[1]), abs(ga.f.linear[4]))
    max_pt = origin .+ dims .* spacing

    domain = GeoStatsModels.CartesianGrid(origin, max_pt; dims=dims)
    problemdata = GeoStatsModels.georef((; z=vec(data)), domain)

    # Drop missing values and interpolate onto the full domain
    interp = problemdata |> GeoStatsTransforms.DropMissing(:z) |> GeoStatsTransforms.Interpolate(domain; model=solver, kwargs...)
    data .= reshape(getproperty(interp, :z), size(data))
    ga
end

@deprecate interpolate!(ga::GeoArray, solver::T, band=1; kwargs...) where {T<:GeoStatsModels.GeoStatsModel} fill!(ga, solver, band; kwargs...)

end
