module GeoArraysStatsExt

using GeoArrays, GeoStatsBase

"""
    fill!(ga::GeoArray, solver::EstimationSolver, band=1)

Replace missing values in GeoArray `ga` using `solver` from the GeoStats ecosystem.
"""
function GeoArrays.fill!(ga::GeoArray, solver::T, band=1) where {T<:EstimationSolver}
    data = @view ga.A[:, :, band]
    m = ismissing.(data)
    sum(m) == 0 && return ga
    cds = collect(coords(ga))
    problemdata = GeoStatsBase.georef(
        (; band=@view data[.!m]),
        @view cds[.!m]
    )
    problem = EstimationProblem(problemdata, GeoStatsBase.PointSet(cds[m]), :band)
    solution = solve(problem, solver)

    data[m] .= getproperty(solution, :band)
    ga
end

@deprecate interpolate!(ga::GeoArray, solver::T, band=1) where {T<:EstimationSolver} fill!(ga, solver, band)

end
