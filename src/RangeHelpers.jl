module RangeHelpers

export strictbelow, below, around, above, strictabove
export prolong
export anchorrange
export symrange
export asrange
export binwalls, bincenters

# Use README as docstring
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end RangeHelpers

################################################################################
##### range
################################################################################
@enum Direction strictbelow below around above strictabove

(direction::Direction)(value) = Approach(value, direction)
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

struct Approach{V}
    value::V
    direction::Direction
end

function Base.show(io::IO, o::Approach)
    direction = o.direction
    print(io, direction_string(direction), "(", o.value, ")")
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

```jldoctest range
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

function range(;start=nothing, stop=nothing, length=nothing, step=nothing)
    range0(start, stop, step, length)
end

function range(start; stop=nothing, length=nothing, step=nothing)
    range1(start, stop, step, length)
end

function range(start, stop; length=nothing, step=nothing)
    range1(start, stop, step, length)
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

################################################################################
##### prolong
################################################################################
"""
    prolong(r::AbstractRange;start=nothing, stop=nothing, pre=nothing, post=nothing)

Prolong an existing range `r` according to the arguments:

```jldoctest
julia> using RangeHelpers

julia> r = 1.0:0.5:3.0
1.0:0.5:3.0

julia> prolong(r, stop=around(4))
1.0:0.5:4.0

julia> prolong(r, pre=1)
0.5:0.5:3.0

julia> prolong(r, pre=1, post=2)
0.5:0.5:4.0

julia> prolong(r, start=below(0.4), stop=around(4.1))
0.0:0.5:4.0
```
"""
function prolong(r::AbstractRange;start=nothing, stop=nothing, pre=nothing, post=nothing)
    r2 = prolong_start_stop(r, start, stop)
    r3 = prolong_pre_post(r2, pre, post)
    return r3
end

function prolong_start_stop(r, start::Nothing, stop::Nothing)
    r
end
function prolong_start_stop(r, start::Approach, stop::Nothing)
    range(start, step=Base.step(r), stop=last(r))
end
function prolong_start_stop(r, start::Nothing, stop::Approach)
    range(first(r), stop=stop, step=Base.step(r))
end
function prolong_start_stop(r, start::Approach, stop::Approach)
    anchor = first(r)
    flength = floatlength(anchor, stop, step(r))
    dir = step(r) >= 0 ? stop.direction : opposite(stop.direction)
    len1 = int(flength, dir)
    stop1 = anchor + (len1-1) * step(r)
    return range(start=start, step=step(r), stop=stop1)
end

prolong_pre_post(r, pre::Nothing, post::Nothing) = r
function prolong_pre_post(r, pre::Integer, post::Nothing)
    len = length(r) + pre
    range(stop=last(r), step=Base.step(r), length=len)
end
function prolong_pre_post(r, pre::Nothing, post::Integer)
    len = length(r) + post
    range(start=first(r), step=Base.step(r), length=len)
end
function prolong_pre_post(r, pre, post)
    len = length(r) + pre + post
    start = first(r) - pre*step(r)
    range(start=start, step=Base.step(r), length=len)
end

################################################################################
##### anchorrange
################################################################################
"""

    anchorrange(anchor; step, start, stop, pre, post)

Return a range, that approximately has `anchor` on its grid.

```jldoctest
julia> using RangeHelpers

julia> anchorrange(15.5, start=above(11), step=2, stop=below(15))
11.5:2.0:13.5
```
"""
function anchorrange(anchor; step, kw...)
    r0 = anchor:step:anchor
    return prolong(r0; kw...)
end

################################################################################
##### symrange
################################################################################

"""
    symrange(;center=0, step, length, start, stop)

Construct a range, that is symmetric around center.

```jldoctest
julia> using RangeHelpers

julia> symrange(length=2, step=1)
-0.5:1.0:0.5

julia> symrange(length=3, step=1)
-1.0:1.0:1.0

julia> symrange(length=3, step=1, center=4)
3.0:1.0:5.0

julia> symrange(start=around(-4.1), step=2)
-4.0:2.0:4.0

julia> symrange(start=around(-4.1), step=2, center=1)
-4.0:2.0:6.0

julia> symrange(stop=around(4.1), step=2, center=1)
-2.0:2.0:4.0
```
"""
function symrange(;center=0, start=nothing, step=nothing, stop=nothing, length=nothing)
    _symrange(center, start, step, stop, length)
end

function _symrange(center, start, step, stop, length)
    msg = """
    Cannot construct symmetric range from arguments:
    center = $center
    start = $start
    step = $step
    stop = $stop
    length = $length
    """
    throw(ArgumentError(msg))
end

function _symrange(center, start::Nothing, step, stop::Nothing, length)
    c = float(something(center, zero(step)))
    if isodd(length)
        hl = Int((length - 1)/2)
        anchorrange(c, pre=hl, post=hl, step=step)
    else
        hl = length ÷ 2
        walls = anchorrange(c, pre=hl, post=hl, step=step)
        bincenters(walls)
    end
end

function _symrange(center, start::Approach, step, stop::Nothing, length::Nothing)
    r = range(step=step/2, start=start, stop=center)
    s = if last(r) == center
        first(r)
    else
        last(r)
    end
    return range(start=s, step=step, stop=around(2*center-s))
end

function _symrange(center, start::Nothing, step, stop::Approach, length::Nothing)
    r = range(step=step/2, stop=stop, start=center)
    s = if first(r) == center
        last(r)
    else
        first(r)
    end
    return range(stop=s, step=step, start=around(2*center-s))
end

################################################################################
##### asrange
################################################################################

"""
    asrange(itr; check=true, atol, rtol)::AbstractRange

Convert `itr` into a range, optionally validating the result.
```jldoctest
julia> using RangeHelpers

julia> asrange([1,2,3])
1.0:1.0:3.0

julia> asrange([1,2,3])
1.0:1.0:3.0

julia> asrange(1:3)
1:3

julia> asrange([1,2,4])
ERROR: ArgumentError: Cannot construct range from `itr`
itr = [1, 2, 4]
[...]

julia> asrange([1,2,4], atol=10)
1.0:1.5:4.0
```
"""
function asrange end

asrange(r::AbstractRange; kw...) = r
function asrange(itr; check=true, kw...)
    start= first(itr)
    stop = last(itr)
    len = length(itr)
    ret = Base.range(start, stop=stop,length=len)
    if check
        if !isapprox(ret, itr; kw...)
            msg = """
            Cannot construct range from `itr`
            itr = $(itr)
            """
            throw(ArgumentError(msg))
        end
    end
    ret
end

################################################################################
##### bincenters, binwalls
################################################################################
"""
    binwalls(r::AbstractRange; first=true, last=true)::AbstractRange

If `r` is interpreted as a collection of bin centers, `binwalls` returns the bin boundaries.

```jldoctest
julia> using RangeHelpers: binwalls

julia> binwalls(0.0:2.0:10.0)
-1.0:2.0:11.0

julia> binwalls(0.0:2.0:10.0, first=false)
1.0:2.0:11.0

julia> binwalls(0.0:2.0:10.0, last=false)
-1.0:2.0:9.0
```
See also [`bincenters`](@ref).
"""
function binwalls(r::AbstractRange; first=true, last=true)::AbstractRange
    h = (1//2) * step(r)
    start = if first
        Base.first(r) - h
    else
        Base.first(r) + h
    end
    stop = if last
        Base.last(r) + h
    else
        Base.last(r) - h
    end
    len = length(r) + first + last - 1
    return Base.range(start, stop=stop, length = len)
end

"""
    bincenters(r::AbstractRange)::AbstractRange

If `r` is interpreted as a collection of bin boundaries, `bincenters` returns the bin centers.
```jldoctest
julia> using RangeHelpers: bincenters

julia> bincenters(1:10.0)
1.5:1.0:9.5
```
See also [`binwalls`](@ref).
"""
function bincenters(r::AbstractRange)::AbstractRange
    return binwalls(r, first=false, last=false)
end

end #module
