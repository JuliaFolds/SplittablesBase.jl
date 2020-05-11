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

(2) `halve` must shorten the collection.  More precisely, if
`length(collection) > 1`, both `length(left) < length(collection)` and
`length(right) < length(collection)` must hold.

Furthermore, whenever implementable with cheap operations,
`length(left)` should be close to `length(collection) ÷ 2` as much as
possible.

# Limitation

* `halve` on `zip` of iterators with unequal lengths does not satisfy
  the "`vcat` law".
