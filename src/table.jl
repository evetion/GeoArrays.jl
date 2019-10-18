using Tables

Tables.istable(::Type{<:GeoArray}) = true
Tables.rowaccess(::Type{<:GeoArray}) = true

struct GeoArrayIterator
    ga::GeoArray
end

function Tables.rows(ga::GeoArray)
    GeoArrayIterator(ga)
end

function Tables.schema(gai::GeoArrayIterator)
    Tables.Schema((:x, :y, :bands), (Float64, Float64, Vector{eltype(gai.ga)}))
end

function Base.iterate(gai::GeoArrayIterator, element=1)
   if element > length(gai)
       return nothing
   end
   i = Tuple(CartesianIndices(size(gai.ga)[1:2])[element])
   x, y = coords(gai.ga, SVector(i))
   data = gai.ga[i]
   return ((x=x, y=y, data=data), element+1)
end

Base.length(gai::GeoArrayIterator) = length(gai.ga[:,:,1])
Base.eltype(gai::GeoArrayIterator) = NamedTuple
