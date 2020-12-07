# file = "clusterIds_temporal-(perc_50%,1980-2015).tif"
# x = GeoArrays.read(file);

# ds_raster = GDAL.gdalopen(raster_file, GDAL.GA_ReadOnly)
# band = GDAL.gdalgetrasterband(ds, band)
# GDAL.gdalsetrasternodatavalue(band.ptr, -1)
file = "OUTPUT/clusterIds_temporal-(perc_20%,1980-2015).tif"
@time x = GeoArrays.read(file, 1:1)
# @time gdal_polygonize(file, 1, "OUTPUT/shp_UrbanSpatioTemporalCluster/urban.shp"; fieldname = "urbanId")
