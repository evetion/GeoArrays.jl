function GI.extent(ga::GeoArray)
    bb = bbox(ga)
    Extents.Extent(X=(bb.min_x, bb.max_x), Y=(bb.min_y, bb.max_y))
end

GI.crs(ga::GeoArray) = isempty(GFT.val(crs(ga))) ? nothing : crs(ga)
