# SplittablesBase: a simple API for parallel computation on collections

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/SplittablesBase.jl/dev)
[![GitHub Actions](https://github.com/tkf/SplittablesBase.jl/workflows/Run%20tests/badge.svg)](https://github.com/tkf/SplittablesBase.jl/actions?query=workflow%3A%22Run+tests%22)

SplittablesBase.jl defines a simple API `halve(collection)` for
splitting given `collection` roughly in half.  This is the basis of
parallel algorithms like reduction and sorting.  Custom containers can
support many parallel algorithms by simply defining a single function.

SplittablesBase.jl also defines an experimental simple test utility
function `SplittablesBase.Testing.test(examples)` where some
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
* `Iterators.partition`
* `Iterators.product`
* `Iterators.enumerate`

## Packages using SplittablesBase.jl

* [Transducers.jl](https://github.com/tkf/Transducers.jl) (planned)
* [ThreadsX.jl](https://github.com/tkf/ThreadsX.jl) (planned)

## See also

* [`Spliterator<T> trySplit()` (Java)](https://docs.oracle.com/en/java/javase/13/docs/api/java.base/java/util/Spliterator.html)
