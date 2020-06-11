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

const RECURSION_LIMIT = Ref(1000)

struct RecursionLimitError <: Exception
    f
    args::Tuple
    kwargs::NamedTuple
end

RecursionLimitError(f, args) = RecursionLimitError(f, args, NamedTuple())

function Base.showerror(io::IO, err::RecursionLimitError)
    println(io, "RecursionLimitError")
    print(io, "f = ", err.f)
    for (i, a) in enumerate(err.args)
        println(io)
        print(io, "args[$i] = ")
        show(io, "text/plain", a)
    end
    for (k, v) in pairs(err.kwargs)
        println(io)
        print(io, "kargs.$k = ")
        show(io, "text/plain", v)
    end
end

"""
    recursive_vcat(splittable_iterator, [amount]; recursion_limit)

Recursively call `halve` and `vcat`.  This should be equivalent to
`collect(splittable_iterator)` for ordered iterators.

The second argument is used for computing the length of an iterator.
By default [`amount`](@ref) is used.  If `length` is defined, passing
`length` should also work.
"""
recursive_vcat(data, _len = amount; recursion_limit = RECURSION_LIMIT[]) = recursive_vcat(
    data,
    _len,
    0,
    recursion_limit,
    RecursionLimitError(recursive_vcat, (data, _len), (recursion_limit = recursion_limit,)),
)

function recursive_vcat(data, _len, recursions, limit, err)
    recursions += 1
    recursions > limit && throw(err)
    _len(data) < 2 && return vec(collect(data))
    left, right = halve(data)
    @debug "recursive_vcat(data, $length)" _len(left) _len(right) data left right
    return vcat(
        recursive_vcat(left, _len, recursions, limit, err),
        recursive_vcat(right, _len, recursions, limit, err),
    )
end

function test_recursive_halving(x)
    @debug "Testing _recursive halving_: $(getlabel(x))"
    @testset "recursive halving" begin
        if Base.IteratorSize(getdata(x)) isa Union{Base.HasLength,Base.HasShape}
            @test isequal(recursive_vcat(getdata(x), length), vec(collect(getdata(x))))
        end
        @test isequal(recursive_vcat(getdata(x)), vec(collect(getdata(x))))
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
    SplittablesTesting.test_unordered(examples)

See [`test_ordered`](@ref Main.SplittablesTesting.test_ordered).
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

const _PUBLIC_API = [
    # A list of public APIs to be picked by SplittablesTesting.jl
    :test_ordered,
    :test_unordered,
]
