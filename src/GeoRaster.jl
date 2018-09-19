module GeoRasters

using GDAL
using ArchGDAL
using CoordinateTransformations

include("geoutils.jl")
include("geoarray.jl")


function read(fn::AbstractString)
    # GDAL specific init
    GDAL.allregister()

    dataset = ArchGDAL.unsafe_read(fn)
    A = ArchGDAL.read(dataset)
    am = get_affine_map(dataset)

    # nodata masking
    A = Array{Union{Missing, eltype(A)}}(A)
    mask = Array{UInt8}(size(A))
    for i in 1:ArchGDAL.nlayer(dataset) + 1
        m = ArchGDAL.read(ArchGDAL.getmaskband(ArchGDAL.getband(dataset, i)))
        mask[:,:,i] = m
    end
    A[mask .== 0] .= missing

    # GDAL specific cleanup
    ArchGDAL.destroy(dataset)
    GDAL.destroydrivermanager()

    GeoArray(A, am, 4326)
end

end
