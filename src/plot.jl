using RecipesBase

@recipe function f(ga::GeoArray)
    xflip --> false
    yflip --> true
    aspect_ratio --> 1
    seriestype := :heatmap
    color := :deep

    coords = centercoords(ga)
    x = map(x->x[1], coords[:, 1])
    y = map(x->x[2], coords[end, :])

    xlims --> (minimum(x), maximum(x))
    ylims --> (minimum(y), maximum(y))

    z = ga[:,:,1]'  # only first layer for now

    # Slice data and replace missing by nodata
    dtype = eltype(ga)
    if isa(dtype, Union) && dtype.a == Missing
        dtype = dtype.b
        nodata = typemax(dtype)
        m = ismissing.(data)
        data[m] .= nodata
        z = Array{dtype}(data)
        use_nodata = true
    end

    x, y, z
end
