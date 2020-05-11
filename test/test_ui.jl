module TestUI

using Base.Iterators: partition
using SplittablesBase: halve
using SplittablesBase.Implementations: shape
using Test

macro expect(T, ex)
    quote
        local err
        err = try
            $(esc(ex))
            nothing
        catch err
            err isa $(esc(T)) || rethrow()
            Some(err)
        end
        err === nothing && error("exception not thrown")
        something(err)
    end
end

@testset "zip" begin
    err = @expect ArgumentError halve(zip(1:3, 1:4))
    msg = sprint(showerror, err)
    @test occursin("`halve(zip(...))` requires collections with identical `size`", msg)

    err = @expect MethodError halve(zip(1:3, "abc"))
    @test err.f === shape
end

end  # module
