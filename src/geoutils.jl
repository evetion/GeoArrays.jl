function get_affine_map(ds::ArchGDAL.Dataset)
    # See https://lists.osgeo.org/pipermail/gdal-dev/2011-July/029449.html
    # for an explanation of the geotransform format
    gt = ArchGDAL.getgeotransform(ds)
    AffineMap([gt[2] gt[3]; gt[5] gt[6]], [gt[1], gt[4]])
end
