baremodule SplittablesBase

function halve end

module Implementations
import ..SplittablesBase: SplittablesBase, halve
using Setfield: @set
include("implementations.jl")
end  # module

module Testing
using Test: @test, @testset
using ..SplittablesBase: halve
include("testing.jl")
end  # module

end # module
