using RangeHelpers: range
using RangeHelpers
using Test

@testset "Explict" begin
    @test range(strictbelow(1), 3.1, step = 2) ≈ -0.9:2.0:3.1
    @test range(below(1), 3.1, step = 2) ≈ -0.9:2.0:3.1
    @test range(around(1), 3.1, step = 2) === 1.1:2.0:3.1
    @test range(above(1), 3.1, step = 2) === 1.1:2.0:3.1
    @test range(strictabove(1), 3.1, step = 2) === 1.1:2.0:3.1

    @test range(1, strictbelow(3.1), step = 2) === 1:2:3
    @test range(1, below(3.1), step = 2)       === 1:2:3
    @test range(1, around(3.1), step = 2)      === 1:2:3
    @test range(1, above(3.1), step = 2)       === 1:2:5
    @test range(1, strictabove(3.1), step = 2) === 1:2:5

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
    end
end

for dir in instances(Direction)
    start = 1
    stop = 3
    step = dir(1)
    r = range(start, stop, step=step)
    println("range($start, $stop, step=$step) === $r")

end

