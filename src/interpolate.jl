using GeoStatsDevTools

"""Interpolate missing values in GeoArray."""
function interpolate!(ga::GeoArray, solver::T, band=1) where T<:AbstractSolver
    # If not regular
    # xy = Array(hcat(centercoordsnotmissing(ga)...))
    #v = collect(skipmissing(ga.A))
    #problemdata = PointSetData(Dict(:data=>v), xy)

    # Regular
    # TODO Fix actual origin/spacing
    problemdata = RegularGridData(Dict(:z=>ga.A[:,:,band]), (0.,0.), (1.,1.))

    xy_missing = Array(hcat(GeoRasters.centercoordsmissing(ga)...))
    problemdomain = PointSet(xy_missing)

    problem = EstimationProblem(problemdata, problemdomain, :z)
    solution = solve(problem, solver)

    ga.A[ismissing.(ga.A)] .= solution[:z][:mean]
    ga
end

# see https://github.com/juliohm/GeoStats.jl/issues/37
z = Array{Float64}(rand(10, 10))
z[2,2] = NaN
z[3,3] = NaN

z = Array{Union{Missing, Float64}}(rand(10, 10))
z[2,2] = missing
z[3,3] = missing


problemdata = RegularGridData(Dict(:z=>z), (0.,0.), (1.,1.))
problemdomain = PointSet([1.5 2.5; 1.5 2.5])  # center coords of two missing values
problem = EstimationProblem(problemdata, problemdomain, :z)
solve(problem, Kriging())
