"""
    fill!(ga::GeoArray, solver, band=1)

Replace missing values in GeoArray `ga` using `solver`.
"""
function fill!(::GeoArray, solver, band)
    error("fill! using $solver is not implemented yet. Please use an `EstimationSolver` from the GeoStats.jl ecosystem.")
end
