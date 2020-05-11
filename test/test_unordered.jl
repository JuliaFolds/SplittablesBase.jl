module TestUnordered

import SplittablesBase

raw_examples = """
Dict{Symbol,Int}()
Dict(:a => 1)
Dict(:a => 1, :b => 2)
Dict(:a => 1, :b => 2, :c => 3)
Dict(:a => 1, :b => 2, :c => 3, :d => 4)
Dict(:a => 1, :b => 2, :c => 3, :d => 4, :e => 5)
Dict(zip('a':'z', 1:26))
"""

# An array of `(label = ..., data = ...)`
examples = map(split(raw_examples, "\n", keepempty = false)) do code
    (label = code, data = Base.include_string(@__MODULE__, code))
end

SplittablesBase.Testing.test_unordered(examples)

end  # module
