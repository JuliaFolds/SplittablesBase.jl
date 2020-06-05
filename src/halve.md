    SplittablesBase.halve(collection) -> (left, right)

Split `collection` (roughly) in half.

# Examples
```jldoctest
julia> using SplittablesBase: halve

julia> halve([1, 2, 3, 4])
([1, 2], [3, 4])
```

# Implementation

Implementations of `halve` on custom collections must satisfy the
following laws.

(1) If the original collection is ordered, concatenating the
sub-collections returned by `halve` must create a collection that is
equivalent to the original collection.  More precisely,

```julia
isequal(
    vec(collect(collection)),
    vcat(vec(collect(left)), vec(collect(right))),
)
```

must hold.

Similar relationship must hold for unordered collections; i.e., taking
union of left and right collections as multiset must create a
collection that is equivalent to the original collection as a
multiset:

```julia
using StatsBase: countmap
isequal(
    countmap(collect(collection)),
    merge(+, countmap(collect(left)), countmap(collect(right))),
)
```

(2) `halve` must eventually shorten the collection.  More precisely,
the following function must terminate:

```julia
function recursive_halve(collection)
    length(collection) <= 1 && return
    left, right = halve(collection)
    recursive_halve(left)
    recursive_halve(right)
end
```

Furthermore, whenever implementable with cheap operations,
`length(left)` should be close to `length(collection) ÷ 2` as much as
possible.
