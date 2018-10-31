GeoArray(A::Array{<:Color{<:Real,3}}) = GeoArray(Array{Union{Missing, eltype(A)}}(A), geotransform_to_affine([0.,1.,0.,0.,0.,1.]), "")
