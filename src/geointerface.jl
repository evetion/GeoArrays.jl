GI.extent(ga::GeoArray) = bbox(ga)
GI.crs(ga::GeoArray) = isempty(GFT.val(crs(ga))) ? nothing : crs(ga)
