using GeoStatsBase

"""Interpolate missing values in GeoArray."""
function fill!(ga::GeoArray, solver::T, band=1) where {T<:EstimationSolver}
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
