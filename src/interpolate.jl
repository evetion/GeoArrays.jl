"""
    fill!(ga::GeoArray, solver, band=1)

Replace missing values in GeoArray `ga` using `solver`.
"""
function fill!(::GeoArray, solver, band=1; kwargs...)
    error("fill! using $solver is not implemented yet. Please use an `GeoStatsModel` from the GeoStats.jl ecosystem.")
end
