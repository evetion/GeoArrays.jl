using Downloads
const testdatadir = joinpath(dirname(@__FILE__), "data")

REPO_URL = "https://github.com/yeesian/ArchGDALDatasets/blob/master/"
REPO_URL2 = "https://github.com/OSGeo/gdal/blob/master/autotest/gdrivers/data/"

remotefiles = [
    "data/A.tif",
    "data/utmsmall.tif",
    "gdalworkshop/world.tif",
    "ospy/data4/aster.img",
    # "ospy/data4/aster.rrd",
    "ospy/data5/aster.img",
    # "ospy/data5/aster.rrd",
    "ospy/data5/doq1.img",
    # "ospy/data5/doq1.rrd",
    "ospy/data5/doq2.img",
    # "ospy/data5/doq2.rrd",
    "pyrasterio/example.tif",
    "pyrasterio/example2.tif",
    "pyrasterio/example3.tif",
    "pyrasterio/float_nan.tif",
    "pyrasterio/float.tif",
    "pyrasterio/RGB.byte.tif",
    "pyrasterio/shade.tif"
]
remotefiles2 = [
    "netcdf/sentinel5p_fake.nc"
    "hdf5/recursive_groups.h5"
]

for f in remotefiles
    # create the directories if they don't exist
    currfile = joinpath(testdatadir, f)
    currdir = dirname(currfile)
    isdir(currdir) || mkpath(currdir)
    # download the file
    isfile(currfile) || Downloads.download(REPO_URL * f * "?raw=true", currfile)
end

for f in remotefiles2
    # create the directories if they don't exist
    currfile = joinpath(testdatadir, f)
    currdir = dirname(currfile)
    isdir(currdir) || mkpath(currdir)
    # download the file
    isfile(currfile) || Downloads.download(REPO_URL2 * f * "?raw=true", currfile)
end
