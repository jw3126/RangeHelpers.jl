using RangeHelpers
using Documenter

makedocs(;
    modules=[RangeHelpers],
    authors="Jan Weidner <jw3126@gmail.com> and contributors",
    repo="https://github.com/jw3126/RangeHelpers.jl/blob/{commit}{path}#L{line}",
    sitename="RangeHelpers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jw3126.github.io/RangeHelpers.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jw3126/RangeHelpers.jl",
)
