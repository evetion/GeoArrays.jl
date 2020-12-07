using GeoArrays
using ArchGDAL

infile = "N:/DATA/3h metrology data/Data_forcing_01dy_010deg/nc/lrad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_198301-198312.nc"
r = GeoArrays.read(infile)

dataset = ArchGDAL.unsafe_read(infile)
A = ArchGDAL.read(dataset)
