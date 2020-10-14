using RangeHelpers: range
using RangeHelpers
using Test
using Documenter

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
for dir in instances(RangeHelpers.Direction)
    start = 2.1
    stop = dir(0)
    step = -1
    r = range(start, stop, step=step)
    println("@test range($start, $stop, step=$step) === $r")
end

Documenter.doctest(RangeHelpers)
