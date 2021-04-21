using ConfigEnv
using Documenter

DocMeta.setdocmeta!(ConfigEnv, :DocTestSetup, :(using ConfigEnv); recursive=true)

makedocs(;
    modules=[ConfigEnv],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/ConfigEnv.jl/blob/{commit}{path}#{line}",
    sitename="ConfigEnv.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/ConfigEnv.jl",
        siteurl="https://github.com/Arkoniak/ConfigEnv.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Usage" => "usage.md"
        "Examples" => "scenarios.md"
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/ConfigEnv.jl",
)
