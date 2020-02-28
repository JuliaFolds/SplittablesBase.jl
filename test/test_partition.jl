module TestPartition

using Base.Iterators: partition
using SplittablesBase: halve
using Test

@testset "left is always complete" begin
    @testset for len in 1:10, p in 1:len
        left, = halve(partition(1:len, p))
        @test unique(map(length, left)) == [p]
    end
end

end  # module
