# SplittablesBase: a simple API for parallel computation on collections

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/SplittablesBase.jl/dev)
[![GitHub Actions](https://github.com/tkf/SplittablesBase.jl/workflows/Run%20tests/badge.svg)](https://github.com/tkf/SplittablesBase.jl/actions?query=workflow%3A%22Run+tests%22)

SplittablesBase.jl defines a simple set of APIs:

* `halve(collection)`: splitting given `collection` roughly in half.
* `amount(collection)`: an "approximation" of `length`.

These are the basis of parallel algorithms that can be derived from
`reduce`.  Custom containers can support many parallel algorithms by
simply defining these functions.

SplittablesBase.jl also defines an experimental simple test utility
functions `SplittablesBase.Testing.test_ordered(examples)` and
`SplittablesBase.Testing.test_unordered(examples)` where some
automatable tests are run against each example container in
`examples`.  This utility function is planned to be moved out to a
separate package.

See more in the
[documentation](https://tkf.github.io/SplittablesBase.jl/dev).

## Supported collections

`halve` methods for following collections in `Base` are implemented in
SplittablesBase.jl:

* `AbstractArray`
* `AbstractString`
* `Tuple`
* `NamedTuple`
* `zip`
* `Base.Generator`
* `Iterators.filter`
* `Iterators.flatten`
* `Iterators.product`
* `Iterators.enumerate`

## Packages using SplittablesBase.jl

* [Transducers.jl](https://github.com/tkf/Transducers.jl)
* [ThreadsX.jl](https://github.com/tkf/ThreadsX.jl)

## See also

* [`Spliterator<T> trySplit()` (Java)](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/Spliterator.html)
