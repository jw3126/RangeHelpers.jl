# RangeHelpers

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jw3126.github.io/RangeHelpers.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jw3126.github.io/RangeHelpers.jl/dev)
[![Build Status](https://github.com/jw3126/RangeHelpers.jl/workflows/CI/badge.svg)](https://github.com/jw3126/RangeHelpers.jl/actions)
[![Build Status](https://travis-ci.com/jw3126/RangeHelpers.jl.svg?branch=master)](https://travis-ci.com/jw3126/RangeHelpers.jl)
[![Coverage](https://codecov.io/gh/jw3126/RangeHelpers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jw3126/RangeHelpers.jl)

# Usage

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
```
