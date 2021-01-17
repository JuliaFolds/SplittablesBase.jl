# SplittablesBase: a simple API for parallel computation on collections

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/SplittablesBase.jl/dev)
[![GitHub Actions](https://github.com/JuliaFolds/SplittablesBase.jl/workflows/Run%20tests/badge.svg)](https://github.com/JuliaFolds/SplittablesBase.jl/actions?query=workflow%3A%22Run+tests%22)

SplittablesBase.jl defines a simple set of APIs:

* `halve(collection)`: splitting given `collection` roughly in half.
* `amount(collection)`: an "approximation" of `length`.

These are the basis of parallel algorithms that can be derived from
`reduce`.  Custom containers can support many parallel algorithms by
simply defining these functions.

[SplittablesTesting.jl](https://github.com/JuliaFolds/SplittablesTesting.jl)
provides simple test utility functions
`SplittablesTesting.test_ordered(examples)` and
`SplittablesTesting.test_unordered(examples)` that run some
automatable tests with each example container in `examples`.

See more in the
[documentation](https://juliafolds.github.io/SplittablesBase.jl/dev).

## Supported collections

`halve` methods for following collections in `Base` are implemented in
SplittablesBase.jl:

* `AbstractArray`
* `AbstractString`
* `Dict`
* `keys(::Dict)`
* `values(::Dict)`
* `Set`
* `Tuple`
* `NamedTuple`
* `zip`
* `pairs`
* `Base.Generator`
* `Iterators.filter`
* `Iterators.flatten`
* `Iterators.partition`
* `Iterators.product`
* `Iterators.enumerate`
* `Iterators.reverse`
* `skipmissing`

## Packages using SplittablesBase.jl

* [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl)
* [FLoops.jl](https://github.com/JuliaFolds/FLoops.jl)
* [ThreadsX.jl](https://github.com/tkf/ThreadsX.jl)

## See also

* [`Spliterator<T> trySplit()` (Java)](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/Spliterator.html)
