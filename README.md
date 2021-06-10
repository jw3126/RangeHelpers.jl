# RangeHelpers

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jw3126.github.io/RangeHelpers.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jw3126.github.io/RangeHelpers.jl/dev)
[![Build Status](https://github.com/jw3126/RangeHelpers.jl/workflows/CI/badge.svg)](https://github.com/jw3126/RangeHelpers.jl/actions)
[![Build Status](https://travis-ci.com/jw3126/RangeHelpers.jl.svg?branch=master)](https://travis-ci.com/jw3126/RangeHelpers.jl)
[![Coverage](https://codecov.io/gh/jw3126/RangeHelpers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jw3126/RangeHelpers.jl)

Ever needed a range with startpoint 10, endpoint 121.7 and a step of 25?
Well that is mathematically not possible, so you need to compromise.
There are lots of options, you could relax the startpoint, endpoint or step. In the past doing this was annoying and prone to off-by-one-errors:
```julia
range(10, length=ceil(Int, (121.7-10)/25), stop=121.7);
```
[RangeHelpers.jl](https://github.com/jw3126/RangeHelpers.jl) aims to solve this and related range constructions once and for all:
```julia
julia> import RangeHelpers as RH

julia> RH.range(start=10, stop=121.7, step=RH.around(25)) # compromise on step
10.0:27.925:121.7

julia> RH.range(start=10, stop=121.7, step=RH.below(25))  # compromise step at most 25
10.0:22.34:121.7

julia> RH.range(start=10, stop=RH.above(121.7), step=25)  # exact step, but allow bigger endpoint
10:25:135
```

# More examples
```julia
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
