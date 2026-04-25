tol = 1e-10

@testset "Testing non periodic 1-D laplacian for order k=$k" for k=2:2:8
    m = 2*k+1
    L = Operators.lap(k, m, 1/m)
    field = ones(m+2, 1)
    sol = L*field
    @test norm(sol) < tol
end

@testset "Testing periodic 1-D laplacian for order k=$k" for k=2:2:8
    m = 2 * k + 1
    dx = 1.0 / m
    dc = (0.0, 0.0)
    nc = (0.0, 0.0)
    L = Operators.lap(k, m, dx, dc=dc, nc=nc)
    field = ones(m, 1)
    sol = L * field
    @test norm(sol) < tol
end

@testset "Testing non periodic 2-D laplacian for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    L = Operators.lap(k, m, dx, n, dy)
    field = ones((m + 2) * (n + 2), 1)
    sol = L * field
    @test norm(sol) < tol
end

@testset "Testing periodic 2-D laplacian for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    dc = (0.0, 0.0, 0.0, 0.0)
    nc = (0.0, 0.0, 0.0, 0.0)
    L = Operators.lap(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(m * n, 1)
    sol = L * field
    @test norm(sol) < tol
end

@testset "Testing mixed periodicity 2-D laplacian for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    dc = (0.0, 0.0, 1.0, 1.0)
    nc = (0.0, 0.0, 0.0, 0.0)
    L = Operators.lap(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(m * (n + 2), 1)
    sol = L * field
    @test norm(sol) < tol
end