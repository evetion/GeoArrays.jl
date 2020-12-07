function readGDAL(file::String, options...)
    ArchGDAL.read(file) do dataset
        ArchGDAL.read(dataset, options...)
    end
end

# read multiple tiff files and cbind
function readGDAL(files::Array{String,1}, options)
    # bands = collect(bands)
    # bands = collect(Int32, bands)
    res = map(file -> readGDAL(file, options...), files)
    vcat(res...)
end
