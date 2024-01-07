push!(LOAD_PATH, "../src/")
using Documenter, GeoArrays, GeoStatsBase

cl = joinpath(@__DIR__, "src/CHANGELOG.md")
isfile(cl) || cp(joinpath(@__DIR__, "../CHANGELOG.md"), cl)

makedocs(
    modules=[GeoArrays],
    authors="Maarten Pronk <git@evetion.nl> and contributors",
    repo="https://github.com/evetion/GeoArrays.jl/blob/{commit}{path}#L{line}",
    sitename="GeoArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://evetion.github.io/GeoArrays.jl",
        assets=String[],
        repolink="https://github.com/evetion/GeoArrays.jl"
    ),
    pages=[
        "Home" => "index.md",
        "Changelog" => "CHANGELOG.md",
    ]
)

deploydocs(
    repo="github.com/evetion/GeoArrays.jl",
)
