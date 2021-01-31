module TestWithOffset

using Base: HasEltype, HasLength, HasShape, IteratorEltype, IteratorSize
using SplittablesBase.Implementations: WithOffset
using Test

@testset "eltype" begin
    @test IteratorEltype(WithOffset(1:2, 0)) isa HasEltype
    @test eltype(WithOffset(1:2, Int128(0))) === Int128
end

@testset "size" begin
    xs = eachindex("abc")
    @test IteratorSize(WithOffset(xs, 1)) isa HasLength
    @test length(WithOffset(xs, 1)) == 3
    @test collect(WithOffset(xs, 1)) == xs .+ 1
end

@testset "size" begin
    xs = reshape(1:6, 2, 3)
    @test IteratorSize(WithOffset(xs, 0)) isa HasShape
    @test size(WithOffset(xs, 1)) == (2, 3)
    @test length(WithOffset(xs, 1)) == 6
    @test collect(WithOffset(xs, 1)) == xs .+ 1
end

end  # module
