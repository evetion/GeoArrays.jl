# using NetCDF
function ncread(file::String, varname::String, bbox::box, bands = nothing)
    fid = NetCDF.open(file)
    ndim = length(fid.dim)
    lon = NetCDF.ncread(file, "lon")
    lat = NetCDF.ncread(file, "lat")

    Lon = (@. (lon >= bbox[1]) & (lon <= bbox[3])) |> findall
    Lat = (@. (lat >= bbox[2]) & (lat <= bbox[4])) |> findall

    start = [Lon[1], Lat[1]];
    count = [length(Lon), length(Lat)];
    
    if (ndim > 2)
        start = [start,  1];
        count = [count, -1];
        # if bands === nothing; bands = 
        # need to further test to add the function of bands
    end
    # println(start, count)
    NetCDF.ncread(file, varname, start, count)
end


export ncread
