module TestHalve

import SplittablesBase
using Base.Iterators: partition, product
using OffsetArrays: OffsetArray

raw_examples = """
1:10
1:11
[1:10;]
[1:11;]
reshape(1:6, 2, 3)
adjoint(reshape(1:6, 2, 3))
transpose(reshape(1:6, 2, 3))
permutedims(reshape(1:6, 2, 3))
permutedims(reshape(1:24, 2, 3, 4), (1, 2, 3))
permutedims(reshape(1:24, 2, 3, 4), (1, 3, 2))
permutedims(reshape(1:24, 2, 3, 4), (2, 1, 3))
permutedims(reshape(1:24, 2, 3, 4), (2, 3, 1))
permutedims(reshape(1:24, 2, 3, 4), (3, 1, 2))
permutedims(reshape(1:24, 2, 3, 4), (3, 2, 1))
OffsetArray(1:15, -1)
OffsetArray(reshape(1:15, 3, 5), -1:1, 0:4)
pairs(1:10)
pairs(1:11)
pairs(reshape(1:6, 2, 3))
pairs(adjoint(reshape(1:6, 2, 3)))
"abcde"
"abcdef"
"αβγδϵ"
"αβγδϵζ"
"あいうえお"
"あいうえおか"
"aいυe𝒐"
"aいυe𝒐か"
eachindex("abcde")
eachindex("abcdef")
eachindex("αβγδϵ")
eachindex("αβγδϵζ")
eachindex("あいうえお")
eachindex("あいうえおか")
eachindex("aいυe𝒐")
eachindex("aいυe𝒐か")
(1, 2, 3, 4, 5)
(1, 2, 3, 4, 5, 6)
(a=1, b=2, c=3, d=4, e=5)
(a=1, b=2, c=3, d=4, e=5, f=6)
zip(1:3, (11, 22, 33), (a=1, b=2, c=3))
(x^2 for x in 1:5)
(x^2 for x in 1:6)
(x^2 for x in 1:5 if isodd(x))
(x^2 for x in 1:6 if isodd(x))
Iterators.filter(isodd, 1:5)
Iterators.filter(isodd, 1:6)
Iterators.flatten([1:3, 4:5])
product(1:3, 1:4)
product(1:3, 1:4, 1:5)
product(pairs(1:10), pairs(1:11))
product(1:3, pairs(1:11), (1, 2), (a=1, b=2))
partition(1:10, 1)
partition(1:10, 2)
partition(1:10, 3)
partition(1:10, 4)
enumerate([11, 22, 33, 44])
enumerate([11, 22, 33, 44, 55])
enumerate(Iterators.product(1:3, 'a':'b'))
zip(1:3, partition(1:10, 4))
zip("αβγ")
zip(enumerate([11, 22, 33, 44]), 'a':'d')
zip(enumerate([11, 22, 33, 44, 55]), 'a':'e')
zip(Iterators.product(1:3, 'a':'b'), ones(3, 2))
Iterators.reverse(1:10)
Iterators.reverse(zip(1:3, 'a':'c'))
skipmissing([1, 2, missing, 4])
skipmissing([1, 2, missing, 4, 5])
"""

# An array of `(label = ..., data = ...)`
examples = map(split(raw_examples, "\n", keepempty = false)) do code
    (label = code, data = Base.include_string(@__MODULE__, code))
end

SplittablesBase.Testing.test_ordered(examples)

end  # module
