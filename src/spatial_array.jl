## fix for heatmap visualization
function spatial_array(x::AbstractArray{T,2}) where { T <: Real}
    flipud(transpose(x))
end

flipud(x::AbstractArray{T, 2}) = x[end:-1:1, :]
flipud(x::AbstractArray{T, 3}) = x[end:-1:1, :, :]

fliplr(x::AbstractArray{T, 2}) = x[:, end:-1:1]
fliplr(x::AbstractArray{T, 3}) = x[:, end:-1:1, :]

"""Function to flip GeoArray upside down to adjust to GDAL ecosystem."""
function flipud!(ga::GeoArray)
    # Flip data upside down
    ga.A = reverse(ga.A, dims=2)

    # Find new corner coordinates
    ux, uy = ga.f(SVector{2}([0, size(ga)[2]]))

    # Define y mirror and compose
    lm = LinearMap(SMatrix{2,2}([1.0 0.0; 0.0 -1.0]))
    am = compose(ga.f, lm)  # AffineMap
    translate = SVector{2}([ux, uy])
    f = AffineMap(am.linear, translate)

    ga.f = f
    ga
end
