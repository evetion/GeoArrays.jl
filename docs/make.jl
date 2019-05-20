push!(LOAD_PATH,"../src/")
using Documenter, GeoArrays

makedocs(sitename="GeoArrays.jl")

deploydocs(
    repo = "github.com/evetion/GeoArrays.jl.git",
)
