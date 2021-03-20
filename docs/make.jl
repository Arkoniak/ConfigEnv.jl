using DotEnv2
using Documenter

DocMeta.setdocmeta!(DotEnv2, :DocTestSetup, :(using DotEnv2); recursive=true)

makedocs(;
    modules=[DotEnv2],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/DotEnv2.jl/blob/{commit}{path}#{line}",
    sitename="DotEnv2.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/DotEnv2.jl",
        siteurl="https://github.com/Arkoniak/DotEnv2.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/DotEnv2.jl",
)
