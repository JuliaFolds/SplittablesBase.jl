    SplittablesTesting.test_ordered(examples)
    SplittablesTesting.test_unordered(examples)

Run interface tests on each test case in `examples`.

`examples` is an iterator where each element is either:

1. A container to be tested.

2. A `NamedTuple` with following keys

   * `:label`: A label used for `Test.@testcase`.
   * `:data`: A container to be tested.

# Examples
```julia
julia> using SplittablesBase

julia> SplittablesBase.Testing.test_ordered([
           (label = "First Test", data = 1:5),
           (label = "Second Test", data = (a = 1, b = 2, c = 3)),
           zip(1:3, 4:6),
       ]);
Test Summary: | Pass  Total
First Test    |    2      2
Test Summary: | Pass  Total
Second Test   |    2      2
Test Summary: | Pass  Total
3             |    2      2
```
