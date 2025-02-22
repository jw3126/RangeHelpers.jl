module RangeHelpers

using LinearAlgebra: norm

export strictbelow, below, around, above, strictabove
export prolong
export anchorrange
export symrange
export asrange
export binwalls, bincenters
export subdivide
export searchsortedat
export samegrid
export indexof

# Use README as docstring
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
    #read(path, String)
end RangeHelpers


################################################################################
##### range
################################################################################
@enum Direction strictbelow below around above strictabove
###
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

preprocess(start,step,stop) = preprocess(start),preprocess(step),preprocess(stop)

preprocess(x) = x

preprocess(fx::Base.Fix2{typeof(==)}) = fx.x

function preprocess(fx::Base.Fix2{F,T}) where {F,T}
    d = direction_pred(fx.f)
    return Approach{T}(fx.x,d)
end

direction_pred(f::typeof(<)) = strictbelow
direction_pred(f::typeof(≤)) = below
direction_pred(f::typeof(>)) = strictabove
direction_pred(f::typeof(≥)) = above

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
    _start,_step,_stop = preprocess(start,step,stop)
    range0(_start, _step, _stop, length)
end

function range(start; stop=nothing, length=nothing, step=nothing)
    _start,_step,_stop = preprocess(start,step,stop)
    range1(_start, _step, _stop, length)
end

function range(start, stop; length=nothing, step=nothing)
    _start,_step,_stop = preprocess(start,step,stop)
    range1(_start, _step, _stop, length)
end

function range0(start::Nothing, step, stop, length)
    start = stop - (length-1) * step
    range(start, stop=stop, length=length::Integer)
end

function range0(start, step, stop, length)
    range(start, stop=stop, step=step, length=length)
end
module HandleUnitStep
    # Low level range methods, that allow remembering whether a range is a unit range
    struct One end

    # extensions
    first(x) = Base.first(x)
    first(x::Base.OneTo) = One()

    step(r::AbstractUnitRange) = One()
    step(r) = Base.step(r)

    *(x::Any, y::Any) = Base.:(*)(x,y)
    *(x::Any, y::One) = x
    *(x::One, y::Any) = y
    *(x::One, y::One) = One()
    val(::One) = true
    val(x)     = x

    start_step_stop(start::Any, step::Any, stop)      = start:step:stop
    start_step_stop(start::Any, step::One, stop)      = start:stop
    start_step_stop(start::One, step::One, stop) = Base.OneTo(stop)

    start_step_length(start::Any, step::Any, length) = Base.range(start, step=step, length=length)
    start_step_length(start::One, step::Any, length) = Base.range(val(start), step=step, length=length)
    start_step_length(start::One, step::One, length) = Base.OneTo(length)
    start_step_length(start::Any, step::One, length) = begin
        stop = start + oneunit(start)*(length-1)
        ret  = start_step_stop(start, step, stop)
        if Base.length(ret) != length
            msg = """
            Bug, please open an issue at https://github.com/jw3126/RangeHelpers.jl
            start_step_length(start, step, length)
            start = $(start)
            step = $(step)
            stop = $(stop)
            length = $(length)
            ret = $(ret)
            """
            error(msg)
        end
        return ret
    end
    function step_stop_length(step,stop,length)
        start = stop - (oneunit(stop)*step)*(length-1)
        ret = start_step_stop(start, step, stop)
        if Base.length(ret) == length
            ret
        else
            Base.range(;step,stop,length)
        end
    end
    start_stop_length(start::Any, stop, length) = Base.range(start, stop=stop, length=length)
    start_stop_length(start::One, stop, length) = Base.range(val(start) , stop=stop, length=length)
end #module HandleUnitStep
const HUS = HandleUnitStep

module HandleApproach
    function start_step_stop end
end
const HAP = HandleApproach


range1(start, step, stop, length)          = Base.range(start, stop=stop, step=step, length=length)
range1(start, step, stop, length::Nothing) = HUS.start_step_stop(start, step, stop)

range1(start::Approach, step, stop, length::Nothing) = HAP.start_step_stop(start,step,stop)
range1(start, step::Approach, stop, length::Nothing) = HAP.start_step_stop(start,step,stop)
range1(start, step, stop::Approach, length::Nothing) = HAP.start_step_stop(start,step,stop)

function HAP.start_step_stop(start::Approach, step, stop)
    flength = floatlength(start, stop, step)
    _step = HUS.val(step)
    dir = if _step >= zero(_step)
        opposite(start.direction)
    else
        start.direction
    end
    length = int(flength, dir)
    ret = HUS.step_stop_length(step, stop, length)
end

function HAP.start_step_stop(start, step, stop::Approach)
    flength = floatlength(start, stop, step)
    _step = HUS.val(step)
    dir = if _step >= zero(_step)
        stop.direction
    else
        opposite(stop.direction)
    end
    length = int(flength, dir)
    ret = HUS.start_step_length(start, step, length)
    #@show start step stop length ret
end

function HAP.start_step_stop(start, step::Approach, stop)
    flength = floatlength(start, stop, step)
    dir = if step.value >= zero(step.value)
        opposite(step.direction)
    else
        step.direction
    end
    length = int(flength, dir)
    ret = HUS.start_stop_length(start, stop, length)
    @assert start == first(ret)
    @assert stop == last(ret)
    #@show ret start step stop typeof(start) typeof(step) typeof(stop)
    ret
end

value(x) = x
value(x::Approach) = x.value

floatlength(start, stop, step) = _floatlength(HUS.val(start), HUS.val(stop), HUS.val(step))
function _floatlength(start, stop, step)
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
    _start,_,_stop = preprocess(start,nothing,stop)
    r2 = prolong_start_stop(r, _start, _stop)
    r3 = prolong_pre_post(r2, pre, post)
    return r3
end

function prolong_start_stop(r, start::Nothing, stop::Nothing)
    r
end
function prolong_start_stop(r, start::Approach, stop::Nothing)
    range(start, step=HUS.step(r), stop=last(r))
end
function prolong_start_stop(r, start::Nothing, stop::Approach)
    HAP.start_step_stop(HUS.first(r), HUS.step(r), stop)
end
function prolong_start_stop(r, start::Approach, stop::Approach)
    anchor = first(r)
    flength = floatlength(anchor, stop, step(r))
    dir = step(r) >= zero(step(r)) ? stop.direction : opposite(stop.direction)
    len1 = int(flength, dir)
    stop1 = anchor + (len1-1) * step(r)
    return HAP.start_step_stop(start, HUS.step(r), stop1)
end

prolong_pre_post(r, pre::Nothing, post::Nothing) = r
function prolong_pre_post(r, pre::Integer, post::Nothing)
    len = length(r) + pre
    HUS.step_stop_length(HUS.step(r), last(r), len)
end
function prolong_pre_post(r, pre::Nothing, post::Integer)
    len = length(r) + post
    HUS.start_step_length(HUS.first(r), HUS.step(r), len)
end
function prolong_pre_post(r, pre, post)
    len = length(r) + pre + post
    start = first(r) - pre*step(r)
    HUS.start_step_length(start, HUS.step(r), len)
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
    _step = preprocess(step)
    r0 = anchor:_step:anchor
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
    _start, _step, _stop = preprocess(start,step,stop)
    _symrange(center, _start, _step, _stop, length)
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
    c = float(center*one(step))
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
    r = HAP.start_step_stop(start, step/2, center)
    start_ = if last(r) == center
        first(r)
    else
        last(r)
    end
    stop_ = around(2*center-start_)
    return HAP.start_step_stop(start_, step, stop_)
end

function _symrange(center, start::Nothing, step, stop::Approach, length::Nothing)
    r = HAP.start_step_stop(center, step/2, stop)
    stop_ = if first(r) == center
        last(r)
    else
        first(r)
    end
    start_ = around(2*center-stop_)
    return HAP.start_step_stop(start_, step, stop_)
end

################################################################################
##### asrange
################################################################################

"""
    asrange(itr; check=true, atol, rtol)::AbstractRange

Convert `itr` into a range, optionally validating the result.
```jldoctest
julia> using RangeHelpers

julia> asrange([1,2,3.0])
1.0:1.0:3.0

julia> asrange([1,2,3])
1:1:3

julia> asrange(1:3)
1:3

julia> asrange([1,2,4.0])
ERROR: ArgumentError: Cannot construct range from `itr`
itr = [1.0, 2.0, 4.0]
[...]

julia> asrange([1,2,4.0], atol=10)
1.0:1.5:4.0
```
"""
function asrange end

asrange(r::AbstractRange; kw...) = r
function asrange(itr; kw...)
    start = first(itr)
    stop  = last(itr)
    len = length(itr)
    ret = Base.range(start, stop=stop,length=len)
    validate_asrange(ret, itr; kw...)
end
function validate_asrange(ret, itr; check=true, kw...)
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

function asrange(arr::AbstractArray{<:Integer}; kw...)
    start = first(arr)
    if length(arr) > 1
        step = arr[firstindex(arr)+1] - start
    else
        step = oneunit(start)
    end
    len = length(arr)
    ret = Base.range(start, step=step, length=len)
    validate_asrange(ret, arr; kw...)
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
    len2 = max(len, 2)
    ret = Base.range(start, stop=stop, length = len2)
    T = typeof(ret)
    if len == len2
        ret
    elseif isempty(r)
        convert(T, Base.range(start, step=step(r), length = 0))
    else
        convert(T, Base.range(start, step=step(r), length = len))
    end::T
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

if isdefined(Base, :require_one_based_indexing)
    using Base: require_one_based_indexing
else
    function require_one_based_indexing(v)
        (firstindex(v) == one(eltype(v))) || throw(ArgumentError("First index must be one."))
    end
end
function bincenters(v::AbstractVector)
    if isempty(v)
        throw(ArgumentError("Cannot compute bincenters of empty vector."))
    end
    require_one_based_indexing(v)
    T = float(eltype(v))
    ret = similar(v, T, length(v)-1)
    half = T(1/2)
    for i in 1:length(ret)
        @inbounds m = half*(T(v[i]) + T(v[i+1]))
        @inbounds ret[i] = m
    end
    return ret
end

################################################################################
##### subdivide
################################################################################
const ALLOWED_subdivide_modes = (:walls, :centers)

"""
    subdivide(r::AbstractRange, factor::Integer, mode=:walls)

Create a range with smaller step from `r`. Possible values for mode are $(ALLOWED_subdivide_modes).

```jldoctest
julia> using RangeHelpers

julia> r = 1:3.0
1.0:1.0:3.0

julia> subdivide(r, 2)
1.0:0.5:3.0

julia> subdivide(r, 4)
1.0:0.25:3.0

julia> subdivide(r, 2, mode=:walls)
1.0:0.5:3.0

julia> subdivide(r, 2, mode=:centers)
0.75:0.5:3.25

julia> subdivide(r, 10, mode=:centers)
0.55:0.1:3.45
```
"""
function subdivide(r::AbstractRange, factor::Integer; mode=:walls)
    if factor < 1
        msg = """
        factor >= 1 must hold. Got:
        factor = $factor
        """
        throw(ArgumentError(msg))
    end
    if !(mode in ALLOWED_subdivide_modes)
        msg = """
        The mode must be one of $(ALLOWED_subdivide_modes). Got:
        mode = $mode
        """
        throw(ArgumentError(msg))
    end
    h = (factor - 1)/(2*factor) * step(r)
    if mode === :walls
        h = zero(h)
        len = factor*(length(r) - 1) + 1
    elseif mode === :centers
        len = factor*length(r)
    else
        error("Unreachable mode = $mode")
    end
    start = first(r) - h
    stop = last(r) + h
    return Base.range(start, stop=stop, length=len)
end

################################################################################
##### searchsortedat
################################################################################
"""
    searchsortedat(coll, x)

Return the index of a sorted collection `coll` whose corresponding
element is closest to `x`. If `coll` is not sorted, `searchsortedat` might
silently return a wrong result.

```jldoctest
julia> using RangeHelpers

julia> searchsortedat(100:100:1000, around(200))
2

julia> searchsortedat(100:100:1000, around(249))
2

julia> searchsortedat(100:100:1000, around(251))
3

julia> searchsortedat(100:100:1000, below(251))
2

julia> searchsortedat(100:100:1000, above(249))
3

julia> searchsortedat(100:100:1000, 300)
3

julia> searchsortedat(100:100:1000, 301)
ERROR: ArgumentError: coll does not contain x:
coll = 100:100:1000
x = 301
Try `searchsortedat(coll, around(x))`
```
"""
function searchsortedat(coll, app::Approach)
    # TODO support same keywords as searchsorted and friends
    dir = app.direction
    x = app.value
    if dir === strictbelow
        i = searchsortedfirst(coll, x)
        return i - 1
    elseif dir === below
        return searchsortedlast(coll, x)
    elseif dir === around
        ilo = searchsortedlast(coll, x)
        if ilo < firstindex(coll)
            return firstindex(coll)
        end
        ihi = min(ilo+1, lastindex(coll))
        if norm(coll[ilo] - x) < norm(coll[ihi] - x)
            return ilo
        else
            return ihi
        end
    elseif dir === above
        return searchsortedfirst(coll, x)
    elseif dir === strictabove
        i = searchsortedlast(coll, x)
        return i+1
    else
        msg = "Unreachable direction = $dir"
        error(msg)
    end
end
function searchsortedat(coll, x::Base.Fix2)
    searchsortedat(coll, preprocess(x))
end

function searchsortedat(coll, x)
    inds = searchsorted(coll, x)
    if isempty(inds)
        msg = """
        coll does not contain x:
        coll = $coll
        x = $x
        Try `searchsortedat(coll, around(x))`
        """
        throw(ArgumentError(msg))
    else
        first(inds)
    end
end

function element_with_largest_norm(r::AbstractRange)::eltype(r)
    x1 = first(r)
    isempty(r) && return x1
    x2 = last(r)
    if norm(x2) > norm(x1)
        return x2
    else
        return x1
    end
end

"""

    samegrid(r1::AbstractRange, r2::AbstractRange; atol=0, rtol=0, kw...)::Bool

Check if `r1` and `r2` are defined on the same grid. That is if there exist equal prolongations
of `r1` and `r1`.
```jldoctest
julia> using RangeHelpers: samegrid

julia> samegrid(1:10, 11:12)
true

julia> samegrid(1:10, 11:1.1:12)
false

julia> samegrid(1:10, 1:0)
true

julia> samegrid(1:10, 0.1:0)
false

julia> samegrid(1:10, 5:-1:3)
true

julia> samegrid(1:10, 4.1:1:5, rtol=0.2)
true

```
"""
function samegrid(r1::AbstractRange, r2::AbstractRange; atol=0, rtol=0, kw...)::Bool
    astep1 = abs(step(r1))
    astep2 = abs(step(r2))
    if !isapprox(astep1, astep2; atol=atol, rtol=rtol, kw...)
        return false
    end
    dx = (1//2)*astep1 + (1//2)*astep2
    s1 = element_with_largest_norm(r1)
    s2 = element_with_largest_norm(r2)
    n = round(Int, (s2-s1)/ dx)
    s1_shifted = s1 + n * dx
    return isapprox(s1_shifted, s2; atol=atol, rtol=rtol, kw...)
end


################################################################################
#### indexof
################################################################################
"""
    i = indexof(r::AbstractRange, x)

Return `i` such that `r[i] == x` or throw an error if that is not possible.
"""
function indexof(r::AbstractRange, x)
    i_real = ((x - first(r)) / step(r)) + firstindex(r)
    I = eltype(eachindex(r))
    i = round(I, i_real)
    @boundscheck begin
        checkbounds(r, i)
        if r[i] != x
            msg = """
            Element not in range
            r = $r
            x = $x
            """
            throw(ArgumentError(msg))
        end
    end
    return i
end


end #module
