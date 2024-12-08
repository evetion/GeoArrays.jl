module GeoArraysStatsExt

using GeoArrays, GeoStatsModels, GeoStatsTransforms

"""
    fill!(ga::GeoArray, solver::GeoStatsModels.GeoStatsModel, band=1, kwargs...)

Replace missing values in GeoArray `ga` using `solver` from the GeoStats ecosystem.
"""
function GeoArrays.fill!(ga::GeoArray, solver::T, band=1; kwargs...) where {T<:GeoStatsModels.GeoStatsModel}
    GeoArrays.is_rotated(ga) && error("Can't interpolate rotated GeoArrays yet. Please make an issue.")

    data = @view ga.A[:, :, band]
    any(ismissing, data) || return ga

    domain = GeoStatsModels.CartesianGrid(size(ga)[1:2], Tuple(ga.f.translation), (abs(ga.f.linear[1]), abs(ga.f.linear[4])))
    problemdata = GeoStatsModels.georef((; z=vec(data)), domain)
    interp = problemdata |> GeoStatsTransforms.InterpolateMissing(:z => solver; kwargs...)
    data .= reshape(getproperty(interp, :z), size(data))
    ga
end

@deprecate interpolate!(ga::GeoArray, solver::T, band=1; kwargs...) where {T<:GeoStatsModels.GeoStatsModel} fill!(ga, solver, band; kwargs...)

end
