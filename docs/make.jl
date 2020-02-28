using Documenter, SplittablesBase

makedocs(;
    modules=[SplittablesBase],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/SplittablesBase.jl/blob/{commit}{path}#L{line}",
    sitename="SplittablesBase.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
)

deploydocs(;
    repo="github.com/tkf/SplittablesBase.jl",
)
