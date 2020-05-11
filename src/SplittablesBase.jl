baremodule SplittablesBase

function halve end
function amount end

module Implementations
import ..SplittablesBase: SplittablesBase, amount, halve
using Base: KeySet, ValueIterator
using Setfield: @set
include("implementations.jl")
end  # module

module Testing
using Test: @test, @testset
using ..SplittablesBase: amount, halve
include("testing.jl")
end  # module

end # module
