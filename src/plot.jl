# @recipe f(::Type{GeoArray}, ga::GeoArray) = ga.A

@recipe function f(ga::GeoArray)
    yflip --> true
    aspect_ratio --> 1
    seriestype := :heatmap

    coords = centercoords(ga)
    x = map(x->x[2], coords[end, :])
    y = map(x->x[1], coords[:, 1])

    # TODO Plots can't handle missing
    data = ga[:,:,1]  # only first layer for now
    dtype = eltype(ga).b
    m = ismissing.(data)
    data[m] .= typemax(dtype)
    z = Array{dtype}(data)

    x, y, z
end
