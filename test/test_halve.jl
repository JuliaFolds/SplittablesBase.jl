module TestHalve

import SplittablesBase
using Base.Iterators: partition, product

raw_examples = """
1:10
1:11
[1:10;]
[1:11;]
"abcde"
"abcdef"
"αβγδϵ"
"αβγδϵζ"
"あいうえお"
"あいうえおか"
"aいυe𝒐"
"aいυe𝒐か"
(1, 2, 3, 4, 5)
(1, 2, 3, 4, 5, 6)
(a=1, b=2, c=3, d=4, e=5)
(a=1, b=2, c=3, d=4, e=5, f=6)
zip(1:3, (11, 22, 33), (a=1, b=2, c=3))
product(1:3, 1:4)
product(1:3, 1:4, 1:5)
product(1:3, (1, 2), (a=1, b=2))
partition(1:10, 1)
partition(1:10, 2)
partition(1:10, 3)
partition(1:10, 4)
enumerate([11, 22, 33, 44])
enumerate([11, 22, 33, 44, 55])
zip(1:3, partition(1:10, 4), "αβγ")
"""

# An array of `(label = ..., data = ...)`
examples = map(split(raw_examples, "\n", keepempty = false)) do code
    (label = code, data = Base.include_string(@__MODULE__, code))
end

SplittablesBase.Testing.test(examples)

end  # module
