using GeoStatsBase
using GeoStatsDevTools

"""Interpolate missing values in GeoArray."""
function interpolate!(ga::GeoArray, solver::T, band=1) where T<:AbstractSolver
    # If not regular
    # xy = Array(hcat(centercoordsnotmissing(ga)...))
    #v = collect(skipmissing(ga.A))
    #problemdata = PointSetData(Dict(:data=>v), xy)

    # Regular
    problemdata = RegularGridData(Dict(:z=>ga.A[:,:,band]), Tuple(ga.f.translation), (ga.f.linear[1],ga.f.linear[4]))
    xy_missing = Array(hcat(GeoRasters.centercoordsmissing(ga)...))
    problemdomain = PointSet(xy_missing)

    problem = EstimationProblem(problemdata, problemdomain, :z)
    solution = solve(problem, solver)

    ga.A[ismissing.(ga.A)] .= solution[:z][:mean]
    ga
end
