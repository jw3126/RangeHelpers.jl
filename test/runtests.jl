module RangeHelpersTests
using RangeHelpers: range
using RangeHelpers
const RH = RangeHelpers
using Test

using Test
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
end

@testset "prolong" begin
    @testset "pre post" begin
        @inferred prolong(1:2, pre=1)
        @inferred prolong(1:2, pre=-1)
        @inferred prolong(1:2, post=2)
        @inferred prolong(1:2, post=-1)

        @test prolong(1:2, pre=1) == 0:2
        @test_broken prolong(1:2, pre=1) === 0:2
        @test prolong(1:2, pre=-1) == 2:2
        @test_broken prolong(1:2, pre=-1) === 2:2
        @test prolong(1:2, post=2) == 1:4
        @test_broken prolong(1:2, post=2) === 1:4
        @test prolong(1:2, post=-1) == 1:1
        @test_broken prolong(1:2, post=-1) === 1:1
        @test prolong(1:3, pre=1, post=-2) == 0:1
        @test_broken prolong(1:3, pre=1, post=-2) === 0:1

        @test prolong(1:1, pre=1, post=-1) == 0:0
        @test_broken prolong(1:1, pre=1, post=-1) === 0:0
        @test prolong(1:1, pre=-1, post=1) == 2:2

        @test prolong(0:0, start=around(1), stop=around(2)) == 1:2
        @test_broken prolong(0:0, start=around(1), stop=around(2)) === 1:2

        @test prolong(0:0, start=strictabove(10), stop=strictbelow(15)) == 11:14
        @test prolong(1e9:1e10, start=strictabove(10), stop=strictbelow(15)) == 11:14
        @test prolong(1e9:1e10, start=below(10), stop=strictbelow(15)) == 10:14
        @test prolong(1e9:1e10, start=below(10), stop=around(15.1)) == 10:15
    end
    @testset "anchorrange" begin
        @inferred anchorrange(15.5, start=above(11), step=2, stop=below(15))
        @test anchorrange(15.5, start=above(11), step=2, stop=below(15)) === 11.5:2.0:13.5
    end

    @testset "start" begin
        @inferred prolong(1:10, start=around(5))
        @test prolong(1:10, start=around(5)) == 5:10
        @test_broken prolong(1:10, start=around(5)) === 5:10

        @test prolong(1:10, start=below(-2)) == -2:10
        @test_broken prolong(1:10, start=below(-2)) === -2:10
    end

    @testset "stop" begin
        @inferred prolong(1:10, stop=around(5))
        @test prolong(1:10, stop=around(5)) == 1:5
        @test prolong(1:10.0, stop=around(5)) === 1:5.0
        @test_broken prolong(1:10, stop=around(5)) === 1:5
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
        @test range(around(1), 3.1, step = 2) === 1.1:2.0:3.1
        @test range(above(1), 3.1, step = 2) === 1.1:2.0:3.1
        @test range(strictabove(1), 3.1, step = 2) === 1.1:2.0:3.1

        @test range(strictbelow(2), 0, step=-1) === 1.0:-1.0:0.0
        @test range(below(2), 0, step=-1) === 2.0:-1.0:0.0
        @test range(around(2), 0, step=-1) === 2.0:-1.0:0.0
        @test range(above(2), 0, step=-1) === 2.0:-1.0:0.0
        @test range(strictabove(2), 0, step=-1) === 3.0:-1.0:0.0

        @test range(strictbelow(2.1), 0, step=-1) === 2.0:-1.0:0.0
        @test range(below(2.1), 0, step=-1) === 2.0:-1.0:0.0
        @test range(around(2.1), 0, step=-1) === 2.0:-1.0:0.0
        @test range(above(2.1), 0, step=-1) === 3.0:-1.0:0.0
        @test range(strictabove(2.1), 0, step=-1) === 3.0:-1.0:0.0
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
end

@testset "doctest" begin
    import Documenter
    Documenter.doctest(RangeHelpers)
end


end#module
