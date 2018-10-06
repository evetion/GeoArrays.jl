const shortnames = Dict(
    (".tif", ".tiff") => "GTiff"
)

function find_shortname(fn::AbstractString)
    _, ext = splitext(fn)
    for (k, v) in shortnames
        if ext in k
            return v
        end
    end
    error("Cannot determine GDAL Driver for $fn")
end
