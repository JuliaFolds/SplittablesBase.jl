    SplittablesBase.amount(collection) :: Int

Return the number of elements in `collection` or rough "estimate" of
it.

# Examples
```jldoctest
julia> using SplittablesBase: amount

julia> amount([1, 2, 3, 4])
4

julia> amount("aえ𝑖∅υ")
12

julia> length("aえ𝑖∅υ")  # != `amount`
5
```

Note that `amount` on strings is not equal to `length` because the
latter cannot be computed in O(1) time.

# Implementation

Implementations of `amount` on a collection must satisfy the following
laws.

(1) Any empty collection must have zero `amount`.

(2) Any operation that increments `length` on collection must
increments `amount`.

Ideally, the time-complexity of `amount` should be O(1).
