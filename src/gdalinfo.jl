"""
get detailed GDAL information

## return
- `file`     : 
- `range`    : [lon_min, lon_max, lat_min, lat_max]
- `cellsize` : [cellsize_x, cellsize_y]
- `lon`      : longitudes with the length of nlon
- `lat`      : latitudes with the length of nlat
- `dim`      : [width, height]
- `ntime`    : length of time
"""
function gdalinfo(file::AbstractString) 
    ds = ArchGDAL.read(file)
    gt = AG.getgeotransform(ds)
    # band = AG.getband(ds, 1)
    w, h = AG.width(ds), AG.height(ds)
    dx, dy = gt[2], -gt[end]
    x0 = gt[1] #+ dx/2
    x1 = x0 + w* dx
    y1 = gt[4] #- dy/2
    y0 = y1 - h*dy
    range = box(x0, y0, x1, y1)
    
    lon = x0 + dx/2 : dx: x1
    lat = reverse(y0 + dy/2 : dy: y1)
    nband = ArchGDAL.nraster(ds)
    
    Dict(
        "file"     => basename(file),
        "bbox"    => bbox, 
        "cellsize" => [dx, dy], 
        "lon"      => lon,
        "lat"      => lat,
        "dim"      => [w, h],
        "nbands"    => nband)
end

gdal_open(file::AbstractString) = ArchGDAL.read(file)

function nband(file::AbstractString)
    # ArchGDAL.unsafe_read(file) do ds
    ArchGDAL.read(file) do ds
        ArchGDAL.nraster(ds)
    end
end
nratser = nband

export gdalinfo, nband, gdal_open
