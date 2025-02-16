GI.extent(ga::GeoArray) = bbox(ga)
GI.crs(ga::GeoArray) = isempty(GFT.val(crs(ga))) ? nothing : crs(ga)
GI.israster(::Type{GeoArray}) = true
GI.crstrait(ga::GeoArray) = _crstrait(GI.crs(ga))

_crstrait(::Nothing) = GI.UnknownTrait()
function _crstrait(crs)
    acrs = ArchGDAL.importCRS(crs)
    Bool(ArchGDAL.GDAL.osrisgeographic(acrs.ptr)) && return GI.GeographicTrait()
    Bool(ArchGDAL.GDAL.osrisprojected(acrs.ptr)) && return GI.ProjectedTrait()
    @error "Unknown CRS type, please report this issue for the given crs/file"
    return GI.UnknownTrait()
end

