using RangeHelpers: range
using RangeHelpers
using Test

@testset "Explict" begin

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

