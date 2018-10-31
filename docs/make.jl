push!(LOAD_PATH,"../src/")
using Documenter, GeoRasters

makedocs(sitename="GeoRasters.jl")

deploydocs(
    repo = "github.com/evetion/GeoRasters.jl.git",
)
