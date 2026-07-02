using MOLE.Grids

@testset "validateGrid uniform 1D" begin
    grid = validateGrid(Dict(:m => 3, :dx => 0.1))

    @test grid.dim == 1
    @test grid.topology == :uniform
    @test grid.bc.hasData == false
    @test grid.bc.isPeriodic == [false]
    @test length(grid.nodes.X) == 4
    @test length(grid.centers.X) == 5
    @test length(grid.faces.X) == 4
end

@testset "validateGrid uniform 2D" begin
    grid = validateGrid(Dict(:m => 2, :n => 4, :dx => 0.5, :dy => 0.25))

    @test grid.dim == 2
    @test grid.topology == :uniform

    @test size(grid.nodes.X) == (3, 5)
    @test size(grid.nodes.Y) == (3, 5)

    @test size(grid.centers.X) == (4, 6)
    @test size(grid.centers.Y) == (4, 6)

    @test size(grid.faces.u.X) == (3, 4)
    @test size(grid.faces.u.Y) == (3, 4)

    @test size(grid.faces.v.X) == (2, 5)
    @test size(grid.faces.v.Y) == (2, 5)
end

@testset "validateGrid uniform 3D" begin
    grid =
        validateGrid(Dict(:m => 2, :n => 3, :o => 4, :dx => 0.5, :dy => 0.25, :dz => 0.1))

    @test grid.dim == 3
    @test grid.topology == :uniform

    @test size(grid.nodes.X) == (3, 4, 5)
    @test size(grid.centers.X) == (4, 5, 6)

    @test size(grid.faces.u.X) == (3, 3, 4)
    @test size(grid.faces.v.X) == (2, 4, 4)
    @test size(grid.faces.w.X) == (2, 3, 5)
end

@testset "boundary normalization" begin
    grid = makeGrid(m = 4, dx = 0.25, dc = 0.0, nc = 0.0)

    @test grid.topology == :periodic
    @test grid.bc.hasData
    @test grid.bc.dc == [0.0, 0.0]
    @test grid.bc.nc == [0.0, 0.0]
    @test grid.bc.isPeriodic == [true]

    grid2 = makeGrid(
        m = 4,
        n = 5,
        dx = 0.25,
        dy = 0.2,
        bc = (dc = [0.0, 0.0, 1.0, 1.0], nc = [0.0, 0.0, 1.0, 1.0]),
    )

    @test grid2.topology == :periodic
    @test grid2.bc.isPeriodic == [true, false]
end

@testset "curvilinear 2D" begin
    m = 2
    n = 3

    x = collect(0:m)
    y = collect(0:n)

    X = repeat(reshape(x, :, 1), 1, n + 1)
    Y = repeat(reshape(y, 1, :), m + 1, 1)

    grid = makeGrid(m = m, n = n, topology = :curvilinear, nodes = (; X, Y))

    @test grid.dim == 2
    @test grid.topology == :curvilinear

    @test size(grid.nodes.X) == (3, 4)
    @test size(grid.faces.u.X) == (3, 3)
    @test size(grid.faces.v.X) == (2, 4)
    @test size(grid.centers.X) == (2, 3)

    @test grid.centers.X[1, 1] == 0.5
    @test grid.centers.Y[1, 1] == 0.5
end

@testset "validation errors" begin
    @test_throws ArgumentError validateGrid(Dict(:dx => 0.1); allowPartial = false)
    @test_throws ArgumentError validateGrid(
        Dict(:m => 4, :n => 4, :topology => :curvilinear);
        allowPartial = false,
    )

    bad_nodes = (; X = zeros(2, 2), Y = zeros(2, 2))
    @test_throws ArgumentError makeGrid(
        m = 4,
        n = 4,
        topology = :curvilinear,
        nodes = bad_nodes,
    )
end
