# Load docstring from markdown files:
for (name, path) in [
    :SplittablesBase => joinpath(dirname(@__DIR__), "README.md"),
    :halve => joinpath(@__DIR__, "halve.md"),
    :amount => joinpath(@__DIR__, "amount.md"),
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

tail(xs) = _tail(xs...)
_tail(_, args...) = args

"""
    arguments(xs)

An "inverse" of a factory function.  It returns a tuple s.t.

```
args == arguments(f(args...))
```

where `f` is `zip`, `Base.Generator`, `Iterators.filter`, etc.
"""
function arguments end

if isdefined(Iterators, :Zip1)  # VERSION < v"1.1-"
    arguments(xs::Iterators.Zip1) = (xs.a,)
    arguments(xs::Iterators.Zip2) = (xs.a, xs.b)
    arguments(xs::Iterators.Zip) = (xs.a, arguments(xs.z)...)
else
    arguments(xs::Iterators.Zip) = xs.is
end
if isdefined(Iterators, :AbstractZipIterator)  # VERSION < v"1.1-"
    const _Zip = Iterators.AbstractZipIterator
else
    const _Zip = Iterators.Zip
end

arguments(xs::Base.Generator) = (xs.f, xs.iter)
arguments(xs::Iterators.Filter) = (xs.flt, xs.itr)
arguments(xs::Iterators.Flatten) = (xs.it,)
arguments(xs::Iterators.PartitionIterator) = (xs.c, xs.n)
arguments(xs::Base.SkipMissing) = (xs.x,)

safelength(xs) =
    Base.IteratorSize(xs) isa Union{Base.HasLength,Base.HasShape} ? length(xs) : nothing

amount(xs) = length(xs)
amount(xs::AbstractString) = lastindex(xs) - firstindex(xs) + 1
amount(xs::Base.EachStringIndex) = amount(xs.s)

struct WithOffset{Iter,Offset}
    iter::Iter
    offset::Offset
end

withoffset(iter, offset) = WithOffset(iter, offset)
withoffset(iter::WithOffset, offset) = WithOffset(iter.iter, iter.offset + offset)

_shift(wo, ::Nothing) = nothing
_shift(wo, (i, s)) = (convert(eltype(wo), wo.offset + i), s)
Base.iterate(wo::WithOffset) = _shift(wo, iterate(wo.iter))
Base.iterate(wo::WithOffset, s) = _shift(wo, iterate(wo.iter, s))

Base.IteratorEltype(::Type{<:WithOffset{Iter}}) where {Iter} =
    Base.IteratorEltype(Iter)
Base.IteratorSize(::Type{<:WithOffset{Iter}}) where {Iter} =
    Base.IteratorSize(Iter)
Base.eltype(::Type{WithOffset{Iter,Offset}}) where {Iter,Offset} =
    promote_type(eltype(Iter), Offset)
Base.length(wo::WithOffset) = length(wo.iter)
Base.size(wo::WithOffset) = size(wo.iter)
amount(wo::WithOffset) = amount(wo.offset)

function halve(xs::AbstractVector)
    mid = length(xs) ÷ 2
    left = @view xs[firstindex(xs):firstindex(xs)-1+mid]
    right = @view xs[firstindex(xs)+mid:end]
    return (left, right)
end

function halve(xs::AbstractArray)
    i = something(findlast(x -> x > 1, size(xs)), 1)
    mid = size(xs, i) ÷ 2
    leftranges = ntuple(ndims(xs)) do j
        if i == j
            firstindex(xs, j):firstindex(xs, j) + mid - 1
        else
            firstindex(xs, j):lastindex(xs, j)
        end
    end
    rightranges = ntuple(ndims(xs)) do j
        if i == j
            firstindex(xs, j) + mid:lastindex(xs, j)
        else
            firstindex(xs, j):lastindex(xs, j)
        end
    end
    return (view(xs, leftranges...), view(xs, rightranges...))
end

halve(xs::AbstractArray{<:Any,0}) = ((), xs)

# A view wrapper returned from `halve` on `Dict`, `keys`, `values`, and `Set`.
struct DictView{D,F}
    dict::D
    firstslot::Int
    lastslot::Int
    f::F  # identity, first, or last
end

DictView(xs::DictView, i::Int, j::Int) = DictView(xs.dict, i, j, xs.f)

Base.IteratorEltype(::Type{<:DictView{D}}) where {D} = Base.IteratorEltype(D)
Base.IteratorSize(::Type{<:DictView}) = Base.SizeUnknown()

Base.eltype(::Type{<:DictView{D,typeof(identity)}}) where {D} = eltype(D)
Base.eltype(::Type{<:DictView{D,typeof(first)}}) where {D} = keytype(D)
Base.eltype(::Type{<:DictView{D,typeof(last)}}) where {D} = valtype(D)

const DictWrapper = Union{Set,KeySet,ValueIterator}
const DictLike = Union{Dict,DictView,DictWrapper}

DictView(xs::AbstractDict, i::Int, j::Int) = DictView(xs, i, j, identity)
DictView(xs::Union{KeySet,Set}, i::Int, j::Int) = DictView(xs.dict, i, j, first)
DictView(xs::ValueIterator, i::Int, j::Int) = DictView(xs.dict, i, j, last)

# Note: this relies on the implementation detail of `iterate(::Dict)`.
@inline function Base.iterate(xs::DictView, i = xs.firstslot)
    i <= xs.lastslot || return nothing
    y = iterate(xs.dict, i)
    y === nothing && return nothing
    x, j = y
    # If `j` is `xs.lastslot + 1` or smaller, it means the current element is
    # within the range of this `DictView`:
    j <= xs.lastslot + 1 && return xs.f(x), j
    # Otherwise, we need to stop:
    return nothing
end

function Base.length(xs::DictView)
    n = 0
    for _ in xs
        n += 1
    end
    return n
end

firstslot(xs::Dict) = xs.idxfloor
lastslot(xs::Dict) = lastindex(xs.slots)

firstslot(xs::DictView) = xs.firstslot
lastslot(xs::DictView) = xs.lastslot

firstslot(xs::DictWrapper) = firstslot(xs.dict)
lastslot(xs::DictWrapper) = lastslot(xs.dict)

amount(xs::DictLike) = lastslot(xs) - firstslot(xs) + 1

function halve(xs::DictLike)
    i1 = firstslot(xs)
    i3 = lastslot(xs)
    i2 = (i3 - i1 + 1) ÷ 2 + i1
    left = DictView(xs, i1, i2 - 1)
    right = DictView(xs, i2, i3)
    return (left, right)
end

function halve(xs::Iterators.Pairs)
    left, right = halve(keys(xs))
    return Iterators.Pairs(values(xs), left), Iterators.Pairs(values(xs), right)
end

function halve(xs::AbstractString)
    offset = firstindex(xs) - 1
    mid = thisind(xs, (lastindex(xs) - offset) ÷ 2 + offset)
    left = SubString(xs, firstindex(xs):mid)
    right = SubString(xs, nextind(xs, mid):lastindex(xs))
    return (left, right)
end

function halve(xs::Base.EachStringIndex)
    offset = firstindex(xs.s) - 1
    mid = thisind(xs.s, (lastindex(xs.s) - offset) ÷ 2 + offset)
    mid2 = nextind(xs.s, mid)
    left = eachindex(SubString(xs.s, firstindex(xs.s):mid))
    right = withoffset(eachindex(SubString(xs.s, mid2:lastindex(xs.s))), mid2 - 1)
    return (left, right)
end

function halve(xs::WithOffset{<:Base.EachStringIndex})
    left, right = halve(xs.iter)
    return withoffset(left, xs.offset), withoffset(right, xs.offset)
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

amount(xs::Base.Generator) = amount(arguments(xs)[2])

function halve(xs::Base.Generator)
    f, coll = arguments(xs)
    left, right = halve(coll)
    return Base.Generator(f, left), Base.Generator(f, right)
end

amount(xs::Iterators.Filter) = amount(arguments(xs)[2])

function halve(xs::Iterators.Filter)
    f, coll = arguments(xs)
    left, right = halve(coll)
    return Iterators.filter(f, left), Iterators.filter(f, right)
end

amount(xs::Iterators.Flatten) = amount(arguments(xs)[1])

function halve(xs::Iterators.Flatten)
    coll, = arguments(xs)
    left, right = halve(coll)
    return Iterators.flatten(left), Iterators.flatten(right)
    # return _flatten(left), _flatten(right)
end

# Is this better?
# _flatten(xs) = safelength(xs) == 1 ? first(xs) : Iterators.flatten(xs)

shape(xs::Union{AbstractArray,Broadcast.Broadcasted}) = size(xs)
shape(xs::Base.Generator) = size(arguments(xs)[2])
shape(xs::Union{NamedTuple,Tuple}) = (length(xs),)

# Make sure that `halve` on the collections give consistent result.
checkshape(xs::_Zip) = length(arguments(xs)) == 1 || shape(xs)
function shape(xs::_Zip)
    args = arguments(xs)
    length(args) == 0 && throw(ArgumentError("empty `zip` does not have `size`."))
    sizes = map(shape, args)
    if !all(==(sizes[1]), tail(sizes))
        throw(ArgumentError("`halve(zip(...))` requires collections with identical `size`"))
    end
    return sizes[1]
end

function halve(xs::_Zip)
    checkshape(xs)
    lefts, rights = _unzip(map(halve, arguments(xs)))
    return zip(lefts...), zip(rights...)
end

shape(xs::Iterators.ProductIterator) = map(length, xs.iterators)

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

function shape(xs::Iterators.PartitionIterator)
    coll, = arguments(xs)
    shape(coll)  # make sure it has a shape
    return (length(xs),)
end

function halve(xs::Iterators.PartitionIterator)
    coll, n = arguments(xs)
    m = n * cld(div(length(coll), n), 2)
    offset = firstindex(coll) - 1
    return (
        Iterators.partition(view(coll, offset .+ (1:m)), n),
        Iterators.partition(view(coll, offset .+ (m+1:length(coll))), n),
    )
end

shape(xs::Iterators.Enumerate) = shape(xs.itr)

function halve(xs::Iterators.Enumerate)
    left, right = halve(xs.itr)
    return enumerate(left), zip(reshape(length(left)+1:length(xs), size(right)), right)
end

function halve(xs::Iterators.Reverse)
    left, right = halve(xs.itr)
    return Iterators.reverse(right), Iterators.reverse(left)
end

amount(xs::Base.SkipMissing) = amount(arguments(xs)[1])

function halve(xs::Base.SkipMissing)
    coll, = arguments(xs)
    left, right = halve(coll)
    return skipmissing(left), skipmissing(right)
end
