using RecipesBase

@recipe function f(ga::GeoArray; band=1)
    xflip --> false
    yflip --> false
    aspect_ratio --> 1
    seriestype := :heatmap
    color := :viridis

    is_rotated(ga) && (ga = straighten(ga))

    # Subsample large images
    pw, ph = get(plotattributes, :size, (600, 400))
    ss = get(plotattributes, :scalefactor, 2)
    w, h = size(ga)
    sw, sh = max(1, round(Int, w / (pw * ss), RoundDown)), max(1, round(Int, h / (ph * ss), RoundDown))
    @debug "Using scalefactor $sw x $sh to subsample GeoArray"
    ga = sw > 1 || sh > 1 ? ga[begin:sw:end, begin:sh:end] : ga

    c = GeoArrays.coords(ga, Vertex())
    x = map(first, c[:, 1])
    y = map(last, c[end, :])
    z = ga.A[:, :, band]'
    if eltype(z) <: Complex
        @warn "Plotting real part of Complex GeoArray."
        z = real.(z)
    end

    # Can't use x/yflip as x/y coords
    # have to be sorted for Plots
    if ga.f.linear[1] < 0
        z = reverse(z, dims=2)
        reverse!(x)
    end
    if ga.f.linear[4] < 0
        z = reverse(z, dims=1)
        reverse!(y)
    end

    xlims --> (extrema(x))
    ylims --> (extrema(y))

    x, y, z
end
