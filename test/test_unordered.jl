module TestUnordered

import SplittablesBase

raw_examples = dict_examples = """
Dict{Symbol,Int}()
Dict(:a => 1)
Dict(:a => 1, :b => 2)
Dict(:a => 1, :b => 2, :c => 3)
Dict(:a => 1, :b => 2, :c => 3, :d => 4)
Dict(:a => 1, :b => 2, :c => 3, :d => 4, :e => 5)
Dict(zip('a':'z', 1:26))
"""

function wrapdict(f)
    lines = map(split(dict_examples, "\n", keepempty = false)) do code
        "$f($code)"
    end
    return join(lines, "\n") * "\n"
end

raw_examples *= wrapdict("keys") * wrapdict("values")

raw_examples *= """
Set(1:0)
Set(1:1)
Set(1:2)
Set(1:3)
Set(1:4)
Set(1:5)
Set(1:100)
"""

# An array of `(label = ..., data = ...)`
examples = map(split(raw_examples, "\n", keepempty = false)) do code
    (label = code, data = Base.include_string(@__MODULE__, code))
end

SplittablesBase.Testing.test_unordered(examples)

end  # module
