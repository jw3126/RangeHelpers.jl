module RangeHelpersTests
using RangeHelpers: range
using RangeHelpers
const RH = RangeHelpers
using Test

@testset "samegrid" begin
    @test samegrid(1:2, 1:2)
    @test samegrid(1:2, 0:-1:-10)
    @test samegrid(Base.OneTo(10), 11.0:1.0:20.0)

    @test !samegrid(1:2, 1.1:2.1)
    @test !samegrid(1:2, 1.1:2.1, rtol=0.02)
    @test samegrid(1:2, 1.1:2.1, rtol=0.101)
    @test samegrid(1:2, 1.1:2.1, rtol=0.101)

    @test samegrid(1:0, 1:0)
    @test samegrid(1:0, 1:10)
    @test !samegrid(1:0, 1.1:10)
    @test samegrid(1:0, 1.1:10, rtol=0.2)
    @test !samegrid(1:0, 1.0:1.1:10)
    @test samegrid(1:0, 1.0:1.1:10, rtol=0.2)
end

@testset "subdivide" begin
    @test subdivide(1.0:2:9.0, 2) == 1:1:9
    @test subdivide(1.0:3, 10) === 1.0:0.1:3.0

    @inferred subdivide(1:3, 2)
    @inferred subdivide(1:3, 2, mode=:centers)
    @test_throws ArgumentError subdivide(1:3, 2, mode=:nonsense)
    @test_throws ArgumentError subdivide(1:3, 0)

    for _ in 1:100
        r = RH.range(start=100*randn(), step=randn(), length=rand(2:100))
        @test subdivide(subdivide(r, 2), 2) == subdivide(r, 4)
        @test subdivide(subdivide(r, 2,mode=:walls), 3,mode=:walls) == subdivide(r, 2*3, mode=:walls)

        @test subdivide(subdivide(r, 2,mode=:centers), 3,mode=:centers) ≈
            subdivide(r, 2*3, mode=:centers)
    end
end

@testset "symrange" begin
    r = @inferred symrange(step=1, length=2)
    @test r === -0.5:1.0:0.5
    r = @inferred symrange(step=1, length=3)
    @test r === -1.0:1.0:1.0

    r = @inferred symrange(center=10f0, step=2, length=3)
    @test r === 8f0:2f0:12f0

    r = symrange(start=around(-4), step=2)
    @test r === -4.0:2.0:4.0

    r = @inferred symrange(start=around(-4.1), step=2, center=1)
    @test r === -4.0:2.0:6.0

    r = @inferred symrange(stop=around(4.1), step=2, center=1)
    @test r === -2.0:2.0:4.0

    r = @inferred symrange(start=above(2), step=-1)
    @test r === 2.0:-1.0:-2.0

    r = @inferred symrange(stop=strictabove(-2), step=-1)
    @test r === 1.5:-1.0:-1.5

    r = @inferred symrange(step=2.5f0, length=106)
    @test eltype(r) === Float32
end

@testset "prolong" begin
    @testset "pre post" begin
        @inferred prolong(1:2, pre=1)
        @inferred prolong(1:2, pre=-1)
        @inferred prolong(1:2, post=2)
        @inferred prolong(1:2, post=-1)
        @inferred prolong(1:1:2, post=-1)

        @test prolong(1:1:2, pre=1) == 0:1:2
        @test prolong(1:1:2, pre=1) === 0:1:2
        @test prolong(1:2, pre=1) == 0:2
        @test prolong(1:2, pre=1) === 0:2
        @test prolong(1:2, pre=-1) == 2:2
        @test prolong(1:2, pre=-1) == 2:2
        @test prolong(1:2, pre=-1) === 2:2
        @test prolong(1:2, post=2) === 1:4
        @test prolong(1:2, post=-1) === 1:1
        @test prolong(1:3, pre=1, post=-2) === 0:1

        @test prolong(1:1, pre=1, post=-1) === 0:0
        @test prolong(1:1, pre=-1, post=1) == 2:2

        @test prolong(0:0, start=around(1), stop=around(2)) == 1:2
        @test prolong(0:0, start=around(1), stop=around(2)) === 1:2

        @test prolong(0:0, start=strictabove(10), stop=strictbelow(15)) == 11:14
        @test prolong(1e9:1e10, start=strictabove(10), stop=strictbelow(15)) == 11:14
        @test prolong(1e9:1e10, start=below(10), stop=strictbelow(15)) == 10:14
        @test prolong(1e9:1e10, start=below(10), stop=around(15.1)) == 10:15

        @test prolong(Base.OneTo(3), post=2) == Base.OneTo(5)
        @test prolong(Base.OneTo(3), post=2) === Base.OneTo(5)
        @test prolong(Base.OneTo(3), stop=around(2)) === Base.OneTo(2)
    end

    @testset "anchorrange" begin
        @inferred anchorrange(15.5, start=above(11), step=2, stop=below(15))
        @test anchorrange(15.5, start=above(11), step=2, stop=below(15)) === 11.5:2.0:13.5
    end

    @testset "start" begin
        @inferred prolong(1:10, start=around(5))
        @test prolong(1:10, start=around(5)) == 5:10
        @test prolong(1:10, start=around(5)) === 5:10

        @test prolong(1:10, start=below(-2)) == -2:10
        @test prolong(1:10, start=below(-2)) === -2:10
    end

    @testset "stop" begin
        @inferred prolong(1:10, stop=around(5))
        @test prolong(1:10, stop=around(5)) == 1:5
        @test prolong(1:10.0, stop=around(5)) === 1:5.0
        @test prolong(1:10, stop=around(5)) == 1:5
    end

end

@testset "Explict" begin
    @inferred range(1,2,length=2)
    @inferred range(start=1,stop=2,length=2)
    @inferred range(start=1,stop=2,step=0.1)
    @inferred range(stop=2,step=0.1, length=3)
    @inferred range(start=2,step=0.1, length=3)

    @testset "no directions" begin
        @test range(1, 2, length = 2) === 1.0:1.0:2.0
        @test range(1, 2, step = 0.5) == [1, 1.5, 2]
        @test range(1, stop = 2, step = 0.5) === 1.0:0.5:2.0
        @test range(start=1, stop = 2, step = 0.5) === 1.0:0.5:2.0
    end

    @testset "start" begin
        @test range(strictbelow(1), 3.1, step = 2) ≈ -0.9:2.0:3.1
        @test range(below(1), 3.1, step = 2) ≈ -0.9:2.0:3.1
        @test range(around(1), 3.1, step = 2)                     === 1.1:2.0:3.1
        @test range(above(1), 3.1, step = 2)                      === 1.1:2.0:3.1
        @test range(strictabove(1), 3.1, step = 2)                === 1.1:2.0:3.1

        @test range(strictbelow(2), 0, step=-1)                   === 1:-1:0
        @test range(below(2), 0, step=-1)                         === 2:-1:0
        @test range(around(2), 0, step=-1)                        === 2:-1:0
        @test range(above(2), 0, step=-1)                         === 2:-1:0
        @test range(strictabove(2), 0, step=-1)                   === 3:-1:0

        @test range(strictbelow(2.1), 0, step=-1)                 === 2:-1:0
        @test range(below(2.1), 0, step=-1)                       === 2:-1:0
        @test range(around(2.1), 0, step=-1)                      === 2:-1:0
        @test range(above(2.1), 0, step=-1)                       === 3:-1:0
        @test range(strictabove(2.1), 0, step=-1)                 === 3:-1:0
    end

    @testset "stop" begin
        @test range(1, strictbelow(3.1), step = 2) === 1:2:3
        @test range(1, below(3.1), step = 2)       === 1:2:3
        @test range(1, around(3.1), step = 2)      === 1:2:3
        @test range(1, above(3.1), step = 2)       === 1:2:5
        @test range(1, strictabove(3.1), step = 2) === 1:2:5

        @test range(2, strictbelow(0), step=-1) === 2:-1:-1
        @test range(2, below(0), step=-1) === 2:-1:0
        @test range(2, around(0), step=-1) === 2:-1:0
        @test range(2, above(0), step=-1) === 2:-1:0
        @test range(2, strictabove(0), step=-1) === 2:-1:1

        @test range(2.1, strictbelow(0), step=-1) === 2.1:-1.0:-0.9
        @test range(2.1, below(0), step=-1) === 2.1:-1.0:-0.9
        @test range(2.1, around(0), step=-1) === 2.1:-1.0:0.1
        @test range(2.1, above(0), step=-1) === 2.1:-1.0:0.1
        @test range(2.1, strictabove(0), step=-1) === 2.1:-1.0:0.1
    end

    @testset "step" begin
        @test range(1, 3.1, step = strictbelow(2)) === 1.0:1.05:3.1
        @test range(1, 3.1, step = below(2))       === 1.0:1.05:3.1
        @test range(1, 3.1, step = around(2))      === 1.0:2.1:3.1
        @test range(1, 3.1, step = above(2))       === 1.0:2.1:3.1
        @test range(1, 3.1, step = strictabove(2)) === 1.0:2.1:3.1

        @test range(1, 3, step=strictbelow(1)) === range(1, 3, length=4)
        @test range(1, 3, step=below(1)) === 1.0:1.0:3.0
        @test range(1, 3, step=around(1)) === 1.0:1.0:3.0
        @test range(1, 3, step=above(1)) === 1.0:1.0:3.0
        @test range(1, 3, step=strictabove(1)) === 1.0:2.0:3.0

        @test_throws ArgumentError range(1,2,step=strictabove(1))

        @test range(2, 0, step=strictbelow(-1)) === 2.0:-2.0:0.0
        @test range(2, 0, step=below(-1)) === 2.0:-1.0:0.0
        @test range(2, 0, step=around(-1)) === 2.0:-1.0:0.0
        @test range(2, 0, step=above(-1)) === 2.0:-1.0:0.0
        @test range(2, 0, step=strictabove(-1)) === range(2, stop=0, length=4)
    end
end

@testset "inferred" begin
    @inferred range(strictbelow(1), 3.1, step = 2)
    @inferred range(1, above(3.1), step = 2)
    @inferred range(1, 3.1, step = around(2))
end

# useful for creating test cases
#for dir in instances(RangeHelpers.Direction)
#    start = 2.1
#    stop = dir(0)
#    step = -1
#    r = range(start, stop, step=step)
#    println("@test range($start, $stop, step=$step) === $r")
#end

@testset "asrange" begin
    @inferred asrange([1,2,3])
    @test asrange([1,2,3]) isa AbstractRange
    @test asrange([1,2,3]) === 1:1:3
    @test asrange(1:3) === 1:3
    @test_throws ArgumentError asrange([1,2,4])
    @test asrange([1]) == range(1,stop=1,length=1)
end

@testset "binwalls, bincenters" begin
    for _ in 1:100
        start = 10randn()
        stop=10randn()
        len=rand(3:100)
        r = range(start, stop=stop, length=len)
        w = RH.binwalls(r)
        @test r ≈ RH.bincenters(RH.binwalls(r))
        @test r ≈ RH.binwalls(RH.bincenters(r))
    end
    @test RH.binwalls(1:4) == [0.5, 1.5, 2.5, 3.5, 4.5]
    @test RH.binwalls(1:4, first=false, last=true) == [1.5,2.5,3.5, 4.5]
    @test RH.bincenters(1:2:9) == [2,4,6,8]
    @inferred RH.bincenters(1:3)
    @inferred RH.binwalls(1:3)

    @test_throws ArgumentError bincenters(Int[])
    @test bincenters([1]) == Float64[]
    @test bincenters([10,20]) ≈ Float64[15]
    @test eltype(bincenters(Float32[1])) === Float32
    @test eltype(bincenters(Float64[1])) === Float64
    @test bincenters([0,1,2,4]) ≈ [0.5, 1.5, 3]
end

@testset "searchsortedat" begin
    @test RH.searchsortedat(10:10:30, RH.around(-100)) === 1
    @test RH.searchsortedat(10:10:30, RH.around(5)) === 1
    @test RH.searchsortedat(10:10:30, RH.around(10)) === 1
    @test RH.searchsortedat(10:10:30, RH.around(14)) === 1
    @test RH.searchsortedat(10:10:30, RH.around(14.99999999)) === 1
    @test RH.searchsortedat(10:10:30, RH.around(15.00000001)) === 2
    @test RH.searchsortedat(10:10:30, RH.around(16.0)) === 2
    @test RH.searchsortedat(10:10:30, RH.around(20.0)) === 2
    @test RH.searchsortedat(10:10:30, RH.around(24.0)) === 2
    @test RH.searchsortedat(10:10:30, RH.around(26.0)) === 3
    @test RH.searchsortedat(10:10:30, RH.around(30)) === 3
    @test RH.searchsortedat(10:10:30, RH.around(50)) === 3
    if VERSION >= v"1.6"
        @test RH.searchsortedat(10:10:30, RH.around(-Inf)) === 1
        @test RH.searchsortedat(10:10:30, RH.around(Inf)) === 3
    end

    for _ in 1:100
        r = sort!(randn(rand(2:10)))
        x = randn()
        isbe = RH.searchsortedat(r, RH.strictbelow(x))
        ibe  = RH.searchsortedat(r, RH.below(x))
        iar  = RH.searchsortedat(r, RH.around(x))
        iab  = RH.searchsortedat(r, RH.above(x))
        isab = RH.searchsortedat(r, RH.strictabove(x))
        @test iar-1 <= isbe == ibe <= iar <= iab == isab <= isbe + 1
        @test_throws ArgumentError RH.searchsortedat(r, x)
        @test iar in eachindex(r)
        if ibe < firstindex(r)
            @test x < first(r)
        else
            @test r[ibe] < x
        end
        if iab > lastindex(r)
            @test x > last(r)
        else
            @test r[iab] > x
        end

        i = rand(eachindex(r))
        x = r[i]
        @test RH.searchsortedat(r, RH.strictbelow(x)) == i-1
        @test RH.searchsortedat(r, RH.below(x)) == i
        @test RH.searchsortedat(r, RH.around(x)) == i
        @test RH.searchsortedat(r, RH.above(x)) == i
        @test RH.searchsortedat(r, RH.strictabove(x)) == i+1
        @test RH.searchsortedat(r, x) == i
    end
    @inferred RH.searchsortedat(10:10:30, RH.around(4))
    @inferred RH.searchsortedat(10:10:30, RH.around(4.4))
    @inferred RH.searchsortedat(collect(10:10:30), RH.around(4.4))

    # double points
    coll = [1,1,1]
    @test RH.searchsortedat(coll, strictabove(1)) === 4
    @test RH.searchsortedat(coll, strictabove(0)) === 1
    @test RH.searchsortedat(coll, strictbelow(1)) === 0
    @test RH.searchsortedat(coll, strictbelow(2)) === 3
    coll = [0,1,1,1,2]
    @test RH.searchsortedat(coll, strictabove(1)) === 5
    @test RH.searchsortedat(coll, strictbelow(1)) === 1
end
@testset "indexof" begin
    @test RH.indexof(1:10, 3) == 3
    @test RH.indexof(1:10, 3.0) == 3
    @test RH.indexof(1:10, 1) == 1
    @test RH.indexof(1:10, 10) == 10
    @test_throws Exception RH.indexof(1:10, 9.9999)
    @test_throws BoundsError RH.indexof(1:10, 0)
    @test_throws BoundsError RH.indexof(1:10, 11)
    
    @inferred RH.indexof(1:10, 3) == 3
    @inferred RH.indexof(1:10, 3.0) == 3
    @inferred RH.indexof(1:1.0:10.0, 3.0) == 3
    
    for _ in 1:100
        r = range(
            start = 100randn(),
            length = rand(2:1000),
            step = 10randn(),
        )
        i = rand(eachindex(r))
        x = r[i]
        @test RH.indexof(r, x) == i
        @test_throws Exception RH.indexof(r, x + rand()*step(r))
    end
end


@testset "doctest" begin
    import Documenter
    Documenter.doctest(RangeHelpers)
end


end#module
