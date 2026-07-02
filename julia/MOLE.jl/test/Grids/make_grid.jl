using MOLE.Grids

@testset "makeGrid" begin
    grid = makeGrid(m = 4, dx = 0.25)

    @test grid isa Grid
    @test grid.dim == 1
    @test grid.topology == :uniform
    @test grid.m == 4
    @test grid.dx == 0.25
    @test grid.nodes.X == [0.0, 0.25, 0.5, 0.75, 1.0]

    grid2 = makeGrid(m = 2, n = 3, dx = 0.5, dy = 0.25)

    @test grid2.dim == 2
    @test grid2.topology == :uniform
    @test size(grid2.nodes.X) == (3, 4)
    @test size(grid2.nodes.Y) == (3, 4)
    @test size(grid2.centers.X) == (4, 5)
    @test size(grid2.faces.u.X) == (3, 3)
    @test size(grid2.faces.v.X) == (2, 4)
end
