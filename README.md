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
julia> Base.range(10, step=25, length=round(Int, (121.7-10)/25)); # is it correct??
```
[RangeHelpers.jl](https://github.com/jw3126/RangeHelpers.jl) aims to solve range construction headaches once and for all:
```julia
julia> using RangeHelpers: range

julia> using RangeHelpers

julia> range(start=10, stop=121.7, step=around(25)) # compromise on step
10.0:27.925:121.7

julia> range(start=10, stop=121.7, step=below(25))  # compromise step at most 25
10.0:22.34:121.7

julia> range(start=10, stop=above(121.7), step=25)  # exact step, but allow bigger endpoint
10:25:135

julia> anchorrange(42, start=around(10), step=25, stop=around(121.7)) # make sure 42 is on the grid
17:25:117
```
See [the documentation](https://jw3126.github.io/RangeHelpers.jl/dev/) for even more ways to make ranges.
