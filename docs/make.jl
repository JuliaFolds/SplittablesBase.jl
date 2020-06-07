using Documenter, SplittablesBase, SplittablesTesting

makedocs(;
    modules=[SplittablesBase, SplittablesTesting],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/JuliaFolds/SplittablesBase.jl/blob/{commit}{path}#L{line}",
    sitename="SplittablesBase.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
)

deploydocs(;
    repo="github.com/JuliaFolds/SplittablesBase.jl",
    push_preview=true,
)
