# Load docstring from markdown files:
for (name, path) in [
    :SplittablesBase => joinpath(dirname(@__DIR__), "README.md"),
    :halve => joinpath(@__DIR__, "halve.md"),
]
    try
        include_dependency(path)
        str = read(path, String)
        @eval @doc $str $name
    catch err
        @error "Failed to import docstring for $name" exception = (err, catch_backtrace())
    end
end

"""
    _unzip(xs::Tuple)

# Examples
```jldoctest; setup = :(using SplittablesBase.Implementations: _unzip)
julia> _unzip(((1, 2, 3), (4, 5, 6)))
((1, 4), (2, 5), (3, 6))
```
"""
_unzip(xs::Tuple{Vararg{NTuple{N,Any}}}) where {N} = ntuple(i -> map(x -> x[i], xs), N)

if isdefined(Iterators, :Zip1)  # VERSION < v"1.1-"
    arguments(xs::Iterators.Zip1) = (xs.a,)
    arguments(xs::Iterators.Zip2) = (xs.a, xs.b)
    arguments(xs::Iterators.Zip) = (xs.a, arguments(xs.z)...)
else
    arguments(xs::Iterators.Zip) = xs.is
end

function halve(xs::AbstractArray)
    # TODO: support "slow" arrays
    mid = length(xs) ÷ 2
    left = @view xs[firstindex(xs):firstindex(xs)-1+mid]
    right = @view xs[firstindex(xs)+mid:end]
    return (left, right)
end

function halve(xs::AbstractString)
    offset = firstindex(xs) - 1
    mid = thisind(xs, (lastindex(xs) - offset) ÷ 2 + offset)
    left = SubString(xs, firstindex(xs):mid)
    right = SubString(xs, nextind(xs, mid):lastindex(xs))
    return (left, right)
end

@generated function halve(xs::NTuple{N,Any}) where {N}
    m = N ÷ 2
    quote
        (($([:(xs[$i]) for i in 1:m]...),), ($([:(xs[$i]) for i in m+1:N]...),))
    end
end

@inline function halve(xs::NamedTuple{names}) where {names}
    lnames, rnames = halve(names)
    return NamedTuple{lnames}(xs), NamedTuple{rnames}(xs)
end

function halve(xs::Iterators.Zip)
    lefts, rights = _unzip(map(halve, arguments(xs)))
    return zip(lefts...), zip(rights...)
end

function halve(product::Iterators.ProductIterator)
    i = findlast(x -> length(x) > 1, product.iterators)
    if i === nothing
        # It doesn't matter which "dimension" is used.
        left, right = halve(product.iterators[1])
    else
        left, right = halve(product.iterators[i])
    end
    return (@set(product.iterators[i] = left), @set(product.iterators[i] = right))
end

function halve(xs::Iterators.PartitionIterator)
    coll = xs.c
    n = xs.n
    m = n * cld(div(length(coll), n), 2)
    offset = firstindex(coll) - 1
    return (
        Iterators.partition(view(coll, offset .+ (1:m)), n),
        Iterators.partition(view(coll, offset .+ (m+1:length(coll))), n),
    )
end

function halve(xs::Iterators.Enumerate)
    left, right = halve(xs.itr)
    return enumerate(left), zip(length(left)+1:length(xs), right)
end
