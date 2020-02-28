# Load docstring from markdown files:
for (name, path) in [
    :test => joinpath(@__DIR__, "test.md"),
]
    try
        include_dependency(path)
        str = read(path, String)
        @eval @doc $str $name
    catch err
        @error "Failed to import docstring for $name" exception = (err, catch_backtrace())
    end
end

function getlabel(x)
    i, example = x
    if example isa NamedTuple
        return example.label
    else
        return "$i"
    end
end

function getdata(x)
    i, example = x
    if example isa NamedTuple
        return example.data
    else
        return example
    end
end

function recursive_vcat(data)
    length(data) < 2 && return vec(collect(data))
    left, right = halve(data)
    return vcat(recursive_vcat(left), recursive_vcat(right))
end

function test(examples)
    @testset "$(getlabel(x))" for x in enumerate(examples)
        @testset "vcat" begin
            data = getdata(x)
            left, right = halve(getdata(x))
            @test isequal(
                vcat(vec(collect(left)), vec(collect(right))),
                vec(collect(getdata(x))),
            )
        end
        @testset "recursive halving" begin
            @test isequal(recursive_vcat(getdata(x)), vec(collect(getdata(x))))
        end
    end
end
