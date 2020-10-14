module RangeHelpers

export strictbelow, below, around, above, strictabove

@enum Direction strictbelow below around above strictabove

struct Approach{V}
    value::V
    direction::Direction
end

function direction_string(direction::Direction)
    if direction === strictbelow
        "strictbelow"
    elseif direction === below
        "below"
    elseif direction === around
        "around"
    elseif direction === above
        "above"
    elseif direction === strictabove
        "strictabove"
    else
        msg = """
        Unreachable direction = $direction
        """
        error(msg)
    end
end

function Base.show(io::IO, o::Approach)
    direction = o.direction
    print(io, direction_string(direction), "(", o.value, ")")
end

(direction::Direction)(value) = Approach(value, direction)
function Direction(s::Symbol)
    if s === :strictabove
        strictbelow
    elseif s === :below
        below
    elseif s === :around
        around
    elseif s === :above
        above
    elseif s === :strictabove
        strictabove
    else
        msg = """
        Unknown direction $s
        Possible directions are $(instances(Direction))
        """
        throw(ArgumentError(msg))
    end
end

function opposite(direction::Direction)::Direction
    if direction === strictbelow
        strictabove
    elseif direction === below
        above
    elseif direction === around
        around
    elseif direction === above
        below
    elseif direction === strictabove
        strictbelow
    else
        msg = """
        Unreachable direction = $direction
        """
        error(msg)
    end
end

function int(value, direction)::Int
    if direction === strictbelow
        candidate = floor(Int, value)
        candidate < value ? candidate : candidate - 1
    elseif direction === below
        floor(Int, value)
    elseif direction === around
        round(Int, value)
    elseif direction === above
        ceil(Int, value)
    elseif direction === strictabove
        candidate = ceil(Int, value)
        candidate > value ? candidate : candidate + 1
    else
        msg = """
        Unreachable direction = $direction
        """
        error(msg)
    end
end

"""
    range(start, stop; length, step)
    range(start; stop, length, step)
    range(;start, stop, length, step)

Construct a range from the arguments. Three arguments must be given.

```jldoctest
julia> using RangeHelpers

julia> using RangeHelpers: range

julia> range(start=1, stop=3, length=3)
1.0:1.0:3.0

julia> range(start=1, stop=3.1, step=around(1))
1.0:1.05:3.1

julia> range(start=1, stop=around(3.1), step=1)
1:1:3

julia> range(start=1, stop=above(3.1), step=1)
1:1:4

julia> range(start=1, stop=above(3.0), step=1)
1:1:3

julia> range(start=around(0.9), stop=3.0, step=1)
1.0:1.0:3.0

julia> range(start=strictbelow(1.0), stop=3.0, step=1)
0.0:1.0:3.0
```
See also the docs of `Base.range`.
"""
function range end

function range(start; stop=nothing, length=nothing, step=nothing)
    range1(start, stop, step, length)
end

function range(start, stop; length=nothing, step=nothing)
    range1(start, stop, step, length)
end

function range(;start=nothing, stop=nothing, length=nothing, step=nothing)
    range0(start, stop, step, length)
end

function range0(start::Nothing, stop, step, length)
    start = stop - (length-1) * step
    range(start, stop=stop, length=length::Integer)
end

function range0(start, stop, step, length)
    range(start, stop=stop, step=step, length=length)
end

range1(start, stop, step, length) = Base.range(start, stop=stop, step=step, length=length)
range1(start, stop, step, length::Nothing) = Base.range(start, stop=stop, step=step)
range1(start::Approach, stop, step, length::Nothing) = range2(start, stop, step)
range1(start, stop::Approach, step, length::Nothing) = range2(start, stop, step)
range1(start, stop, step::Approach, length::Nothing) = range2(start, stop, step)

function range2(start::Approach, stop, step)
    flength = floatlength(start, stop, step)
    dir = if step >= 0
        opposite(start.direction)
    else
        start.direction
    end
    length = int(flength, dir)
    range(step=step, stop=stop, length=length)
end

function range2(start, stop::Approach, step)
    flength = floatlength(start, stop, step)
    dir = if step >= 0
        stop.direction
    else
        opposite(stop.direction)
    end
    length = int(flength, dir)
    range(start=start, step=step, length=length)
end

function range2(start, stop, step::Approach)
    flength = floatlength(start, stop, step)
    dir = if step.value >= 0
        opposite(step.direction)
    else
        step.direction
    end
    length = int(flength, dir)
    range(start=start, stop=stop, length=length)
end

value(x) = x
value(x::Approach) = x.value

function floatlength(start, stop, step)
    1 + (value(stop) - value(start)) / value(step)
end

end#moduel
