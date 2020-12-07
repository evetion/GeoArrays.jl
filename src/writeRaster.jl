writeRaster(ga::GeoArray, fn::AbstractString; nodata = nothing) = write!(fn, ga, nodata)

function writeRaster(arr::AbstractArray{T,2}, bbox::box, fn::AbstractString; nodata = nothing) where T <: Real
    ga = GeoArray(arr)
    bbox!(ga, bbox)
    epsg!(ga, 4326)  # in WGS84
    writeRaster(ga, fn, nodata)
end

function writeRaster(arr::AbstractArray{T,3}, bbox::box, fn::AbstractString; nodata = nothing) where T <: Real
    ga = GeoArray(arr)
    bbox!(ga, bbox)
    epsg!(ga, 4326)  # in WGS84
    writeRaster(ga, fn, nodata)
end
