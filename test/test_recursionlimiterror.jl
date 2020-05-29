module TestRecursionLimitError

using SplittablesBase
using SplittablesBase.Testing: RecursionLimitError
using Test

struct BrokenSplittable end

Base.iterate(::BrokenSplittable, n = 1) = n > 3 ? nothing : (n, n + 1)
Base.eltype(::Type{BrokenSplittable}) = Int
Base.length(::BrokenSplittable) = 3

# Invalid definition:
SplittablesBase.halve(::BrokenSplittable) = (BrokenSplittable(), ())

@testset begin
    # Make sure it's OK as an iterable:
    @test collect(BrokenSplittable()) == 1:3

    err = try
        SplittablesBase.Testing.recursive_vcat(BrokenSplittable())
        nothing
    catch err
        err
    end
    @test err isa RecursionLimitError
    msg = sprint(showerror, err)
    @debug "Testing an error from `recursive_vcat(BrokenSplittable())`" Text(msg)
    @test occursin("RecursionLimitError", msg)
    @test occursin("BrokenSplittable", msg)
end

@testset "smoke tests" begin
    @test sprint(showerror, RecursionLimitError(identity, ())) isa AbstractString
    @test sprint(showerror, RecursionLimitError(identity, (1,))) isa AbstractString
    @test sprint(showerror, RecursionLimitError(identity, (), (a = 1,))) isa AbstractString
    @test sprint(showerror, RecursionLimitError(identity, (1,), (a = 1,))) isa
          AbstractString
end

end  # module
