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

@testset "validation tests" begin
    @testset "makeGrid from existing Grid" begin
        grid = makeGrid(m = 4, dx = 0.25)
        grid2 = makeGrid(grid)

        @test grid2.dim == 1
        @test grid2.topology == :uniform
        @test grid2.m == 4
        @test grid2.dx == 0.25
    end

    @testset "partial grids" begin
        grid1 = makeGrid(m = 10; allowPartial = true)
        @test grid1.dim == 1
        @test grid1.topology == :uniform

        grid2 = makeGrid(m = 10, n = 20; allowPartial = true)
        @test grid2.dim == 2
        @test grid2.topology == :uniform

        grid3 = makeGrid(m = 10, n = 20, o = 30; allowPartial = true)
        @test grid3.dim == 3
        @test grid3.topology == :uniform
    end

    @testset "missing uniform spacing errors" begin
        @test_throws ArgumentError makeGrid(m = 4; allowPartial = false)
        @test_throws ArgumentError makeGrid(m = 4, n = 4, dx = 0.1; allowPartial = false)
        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            o = 4,
            dx = 0.1,
            dy = 0.1;
            allowPartial = false,
        )
    end

    @testset "invalid dimensions and spacings" begin
        @test_throws ArgumentError makeGrid(m = 0, dx = 0.1)
        @test_throws ArgumentError makeGrid(m = -4, dx = 0.1)
        @test_throws ArgumentError makeGrid(m = 4, dx = 0.0)
        @test_throws ArgumentError makeGrid(m = 4, dx = -0.1)

        @test_throws ArgumentError makeGrid(m = 4, n = 0, dx = 0.1, dy = 0.1)
        @test_throws ArgumentError makeGrid(m = 4, n = 4, dx = 0.1, dy = 0.0)

        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            o = 0,
            dx = 0.1,
            dy = 0.1,
            dz = 0.1,
        )
        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            o = 4,
            dx = 0.1,
            dy = 0.1,
            dz = 0.0,
        )
    end

    @testset "invalid dim" begin
        @test_throws ArgumentError validateGrid(Dict(:dim => 4); allowPartial = true)
    end

    @testset "topology inference" begin
        grid = validateGrid(Dict(:x => [0.0, 0.5, 1.0]); allowPartial = true)
        @test grid.topology == :nonuniform

        X = zeros(3, 4)
        Y = zeros(3, 4)
        grid2 = validateGrid(Dict(:m => 2, :n => 3, :nodes => (; X, Y)))
        @test grid2.topology == :curvilinear
    end

    @testset "boundary condition edge cases" begin
        @test_throws ArgumentError makeGrid(m = 4, dx = 0.1, dc = [1.0, 1.0])
        @test_throws ArgumentError makeGrid(m = 4, dx = 0.1, nc = [1.0, 1.0])

        @test_throws ArgumentError makeGrid(
            m = 4,
            dx = 0.1,
            dc = [1.0, 1.0, 1.0],
            nc = [1.0, 1.0, 1.0],
        )

        @test_throws ArgumentError makeGrid(
            m = 4,
            dx = 0.1,
            dc = ones(2, 1),
            nc = ones(2, 1),
        )

        grid = makeGrid(m = 4, dx = 0.1, dc = [1.0], nc = [0.0])
        @test grid.bc.dc == [1.0, 1.0]
        @test grid.bc.nc == [0.0, 0.0]
        @test grid.bc.isPeriodic == [false]

        grid2 = makeGrid(
            m = 4,
            n = 4,
            dx = 0.1,
            dy = 0.1,
            bc = Dict(:dc => [0.0, 0.0, 1.0, 1.0], :nc => [0.0, 0.0, 1.0, 1.0]),
        )
        @test grid2.bc.isPeriodic == [true, false]
    end

    @testset "curvilinear validation errors" begin
        bad_nodes_missing_y = (; X = zeros(5, 5))
        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            topology = :curvilinear,
            nodes = bad_nodes_missing_y,
        )

        bad_nodes_wrong_x_size = (; X = zeros(4, 5), Y = zeros(5, 5))
        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            topology = :curvilinear,
            nodes = bad_nodes_wrong_x_size,
        )

        bad_nodes_wrong_y_size = (; X = zeros(5, 5), Y = zeros(5, 4))
        @test_throws ArgumentError makeGrid(
            m = 4,
            n = 4,
            topology = :curvilinear,
            nodes = bad_nodes_wrong_y_size,
        )
    end
end
