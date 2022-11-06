using GeoStatsBase

"""Interpolate missing values in GeoArray."""
function fill!(ga::GeoArray, solver::T, band=1) where {T<:EstimationSolver}
    # Irregular grid
    # TODO Use unstructured GeoStats method
    if is_rotated(ga)
        error("Can't interpolate warped grid yet.")

        # Regular grid
    else
        data = @view ga.A[:, :, band]
        problemdata = georef(
            (; band=data),
            origin=Tuple(ga.f.translation),
            spacing=(abs(ga.f.linear[1]), abs(ga.f.linear[4]))
        )
    end
    domain = LinearIndices(size(data))[ismissing.(data)]
    problem = EstimationProblem(problemdata, view(problemdata.domain, domain), :band)
    solution = solve(problem, solver)

    data[domain] .= solution[:band]
    ga
end

@deprecate interpolate!(ga::GeoArray, solver::T, band=1) where {T<:EstimationSolver} fill!(ga, solver, band)
