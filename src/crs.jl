"Get the WKT of an Integer EPSG code"
function epsg2wkt(epsgcode::Int)
    srs = GDAL.newspatialreference(C_NULL)
    GDAL.importfromepsg(srs, epsgcode)
    wkt_ptr = Ref(Cstring(C_NULL))
    GDAL.exporttowkt(srs, wkt_ptr)
    return unsafe_string(wkt_ptr[])
end

"Get the WKT of an Proj string"
function proj2wkt(projstring::AbstractString)
    srs = GDAL.newspatialreference(C_NULL)
    GDAL.importfromproj4(srs, projstring)
    wkt_ptr = Ref(Cstring(C_NULL))
    GDAL.exporttowkt(srs, wkt_ptr)
    return unsafe_string(wkt_ptr[])
end

function wkt2wkt(wktstring::AbstractString)
    srs = GDAL.newspatialreference(C_NULL)
    GDAL.importfromwkt(srs, [wktstring])
    wkt_ptr = Ref(Cstring(C_NULL))
    GDAL.exporttowkt(srs, wkt_ptr)
    return unsafe_string(wkt_ptr[])
end

"""Parse CRS string into WKT."""
function str2wkt(crs_string::AbstractString)
    if startswith(crs_string, "+proj=")
        return proj2wkt(crs_string)
    elseif startswith(crs_string, "EPSG:")
        epsg_code = parse(Int, crs_string[findlast("EPSG:", crs_string).stop+1:end])
        return epsg2wkt(epsg_code)
    else
        # Fallback method to validate string
        wkt =  wkt2wkt(crs_string)
        length(wkt) == 0 && throw(ArgumentError("Invalid projection."))
        return wkt
    end
end

"Set CRS on GeoArray by epsgcode"
function epsg!(ga::GeoArray, epsgcode::Int)
    ga.crs = epsg2wkt(epsgcode)
    ga
end
function epsg!(ga::GeoArray, projection_string::AbstractString)
    ga.crs = str2wkt(projection_string)
    ga
end
