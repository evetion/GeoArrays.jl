function resample(x::AbstractArray{T,2}, fact::Integer=10, fun::Function=first) where {T <: Real}
    nrow, ncol = size(x)
    nrow2 = fld(nrow, fact)
    ncol2 = fld(ncol, fact)
    
    # type = ifelse(fun in [first, last], T, Float32) 
    out = zeros(T, nrow2, ncol2)
    
    @inbounds for i in 1:nrow2
        indx = (i-1)*fact + 1 : i*fact
        @inbounds for j in 1:ncol2
            indy = (j-1)*fact + 1 : j*fact
            # out[i, j] = fun(x[indx, indy])
            out[i, j] = fun(view(x, indx, indy));
        end
    end
    out
end

function resample(x::Array{T,3}, fact::Integer=10, fun::Function=first) where {T <: Real}
    nrow, ncol, ntime = size(x)
    nrow2 = fld(nrow, fact)
    ncol2 = fld(ncol, fact)

    out = zeros(T, nrow2, ncol2, ntime)
    @inbounds for i in 1:ntime
        # out[:, :, i] = resample(view(x, :, :, i), fact, fun)
        out[:, :, i] = resample(@view(x[:, :, i]), fact, fun)
    end
    out
end

function resample(x::GeoArray, fact::Integer=10, fun::Function=first)
    # reconstruct the a.f
    GeoArray(resample(x.A, fact, fun), a.f, a.crs)
end

export resample
