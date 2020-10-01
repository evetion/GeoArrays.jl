using GeoStatsBase

"""Interpolate missing values in GeoArray."""
function interpolate!(ga::GeoArray, solver::T, band=1, symbol=:z) where T <: AbstractSolver
    # Irregular grid
    # TODO Use unstructured GeoStats method
    if is_rotated(ga)
        error("Can't interpolate warped grid yet.")

    # Regular grid
    else
        rg = RegularGrid(size(ga.A)[1:2], Tuple(ga.f.translation), (abs(ga.f.linear[1]), abs(ga.f.linear[4])))
        problemdata = georef(NamedTuple{(symbol,)}((ga.A[:,:,band],)), rg)
    end

    problem = EstimationProblem(problemdata, rg, symbol, mapper=CopyMapper())
    solution = solve(problem, solver)

    ga.A[:, :, band] .= reshape(solution[symbol][:mean], size(ga.A)[1:2])
    ga
end
