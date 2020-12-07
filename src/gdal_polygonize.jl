# file = "clusterIds_temporal-(perc_50%,1980-2015).tif"
# x = GeoArrays.read(file);
function gdal_polygonize(raster_file, band = 1, out_file = "out.shp"; 
    fieldname = "grid", nodata = NaN)

    layername = "out"
    ds_raster = GDAL.gdalopen(raster_file, GDAL.GA_ReadOnly)
    band = GDAL.gdalgetrasterband(ds_raster, band)

    # if !isnan(nodata); GDAL.gdalsetrasternodatavalue(band, nodata); end
    # dst_ds = GDAL.ogr_dr_createdatasource(drv, dst_filename, C_NULL)
    drive = GDAL.gdalgetdriverbyname("ESRI Shapefile")
    ds_shp = GDAL.gdalcreate(drive, out_file, 0, 0, 0, GDAL.GDT_Unknown, C_NULL)
    
    REF = GDAL.osrnewspatialreference(C_NULL)
    GDAL.osrimportfromepsg(REF, 4326)
    # REF = C_NULL
    # REF = "WGS_1984"
    layer = GDAL.gdaldatasetcreatelayer(ds_shp, layername, REF, GDAL.wkbPolygon, C_NULL)
    
    fielddefn = GDAL.ogr_fld_create(fieldname, GDAL.OFTInteger)
    field = GDAL.ogr_l_createfield(layer, fielddefn, GDAL.TRUE)

    GDAL.gdalpolygonize(
        band,   # band
        C_NULL, # mask
        layer, field, 
        C_NULL, C_NULL, C_NULL)    
    GDAL.gdalclose(ds_shp)
    GDAL.gdalclose(ds_raster)
end

function gdalsetrasternodatavalue()
end


export gdal_polygonize
