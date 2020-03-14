using GeoStatsBase

"""Interpolate missing values in GeoArray."""
function interpolate!(ga::GeoArray, solver::T, band=1, symbol=:z) where T<:AbstractSolver
    # Irregular grid
    # TODO Use unstructured GeoStats method
    if is_rotated(ga)
        error("Can't interpolate warped grid yet.")

    # Regular grid
    else
        problemdata = RegularGridData(Dict(symbol=>ga.A[:,:,band]), Tuple(ga.f.translation), (abs(ga.f.linear[1]), abs(ga.f.linear[4])))
        problemdomain = RegularGrid(size(ga.A)[1:2], Tuple(ga.f.translation), (abs(ga.f.linear[1]), abs(ga.f.linear[4])))
    end

    problem = EstimationProblem(problemdata, problemdomain, symbol, mapper=CopyMapper())
    solution = solve(problem, solver)

    ga.A[:, :, band] .= solution[symbol][:mean]
    ga
end
