# Load docstring from markdown files:
for (name, path) in [:test_ordered => joinpath(@__DIR__, "test_ordered.md")]
    try
        include_dependency(path)
        str = read(path, String)
        @eval @doc $str $name
    catch err
        @error "Failed to import docstring for $name" exception = (err, catch_backtrace())
    end
end

function getlabel(x)
    i, example = x
    if example isa NamedTuple
        return example.label
    else
        return "$i"
    end
end

function getdata(x)
    i, example = x
    if example isa NamedTuple
        return example.data
    else
        return example
    end
end

function recursive_vcat(data, _len = length)
    _len(data) < 2 && return vec(collect(data))
    left, right = halve(data)
    return vcat(recursive_vcat(left, _len), recursive_vcat(right, _len))
end

function test_recursive_halving(x)
    @debug "Testing _recursive halving_: $(getlabel(x))"
    @testset "recursive halving" begin
        if Base.IteratorSize(getdata(x)) isa Union{Base.HasLength,Base.HasShape}
            @test isequal(recursive_vcat(getdata(x)), vec(collect(getdata(x))))
        end
        @test isequal(recursive_vcat(getdata(x), amount), vec(collect(getdata(x))))
    end
end

function test_ordered(examples)
    @testset "$(getlabel(x))" for x in enumerate(examples)
        @debug "Testing `vcat`: $(getlabel(x))"
        @testset "vcat" begin
            data = getdata(x)
            left, right = halve(getdata(x))
            @test isequal(
                vcat(vec(collect(left)), vec(collect(right))),
                vec(collect(getdata(x))),
            )
        end
        test_recursive_halving(x)
    end
end

@deprecate test test_ordered false

function countmap(xs)
    counts = Dict{Any,Int}()
    for x in xs
        counts[x] = get(counts, x, 0) + 1
    end
    return counts
end

"""
    test_unordered(examples)

See [`test_ordered`](@ref).
"""
function test_unordered(examples)
    @testset "$(getlabel(x))" for x in enumerate(examples)
        @testset "concatenation" begin
            data = getdata(x)
            left, right = halve(getdata(x))
            @test isequal(
                countmap(collect(data)),
                merge(+, countmap(collect(left)), countmap(collect(right))),
            )
        end
        test_recursive_halving(x)
    end
end
