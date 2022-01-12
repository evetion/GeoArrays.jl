const testdatadir = joinpath(dirname(@__FILE__), "data")

REPO_URL = "https://github.com/yeesian/ArchGDALDatasets/blob/master/"

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

for f in remotefiles
    # create the directories if they don't exist
    currfile = joinpath(testdatadir, f)
    currdir = dirname(currfile)
    isdir(currdir) || mkpath(currdir)
    # download the file
    isfile(currfile) || download(REPO_URL * f * "?raw=true", currfile)
end
