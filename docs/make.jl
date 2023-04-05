using NetUptime
using Documenter

DocMeta.setdocmeta!(NetUptime, :DocTestSetup, :(using NetUptime); recursive=true)

makedocs(;
    modules=[NetUptime],
    authors="Steve Kelly <kd2cca@gmail.com> and contributors",
    repo="https://github.com/sjkelly/NetUptime.jl/blob/{commit}{path}#{line}",
    sitename="NetUptime.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sjkelly.github.io/NetUptime.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/sjkelly/NetUptime.jl",
)
