tol = 1e-10

@testset "Testing non periodic 1-D divergence for order k=$k" for k=2:2:8
    m = 2*k+1
    D = Operators.div(k, m, 1/m)
    field = ones(m+1,1)
    sol = D*field
    @test norm(sol) < tol
end

@testset "Testing periodic 1-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    dx = 1.0 / (m - 1)
    dc = (0.0, 0.0)
    nc = (0.0, 0.0)
    D = Operators.div(k, m, dx, dc=dc, nc=nc)
    field = ones(m, 1)
    sol = D * field
    @test norm(sol) < tol
end

@testset "Testing non uniform 1-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    ticks = sort(rand(m + 1))
    D = Operators.div(k, ticks)
    field = ones(m + 1, 1)
    sol = D * field
    @test norm(sol) < tol
end

@testset "Testing non periodic 2-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    D = Operators.div(k, m, dx, n, dy)
    field = ones((m + 1) * n + m * (n + 1), 1)
    sol = D * field
    @test norm(sol) < tol
end

@testset "Testing periodic 2-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / (m - 1)
    dy = 1.0 / (n - 1)
    dc = (0.0, 0.0, 0.0, 0.0)
    nc = (0.0, 0.0, 0.0, 0.0)
    D = Operators.div(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(2*m*n, 1)
    sol = D * field
    @test norm(sol) < tol
end

@testset "Testing mixed periodicity 2-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / (m - 1)
    dy = 1.0 / n
    dc = (0.0, 0.0, 1.0, 1.0)
    nc = (0.0, 0.0, 0.0, 0.0)
    D = Operators.div(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(m*n + m*(n+1), 1)
    sol = D * field
    @test norm(sol) < tol
end

@testset "Testing non uniform 2-D divergence for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    xticks = sort(rand(m + 1))
    yticks = sort(rand(n + 1))
    D = Operators.div(k, xticks, yticks)
    field = ones((m + 1) * n + m * (n + 1), 1)
    sol = D * field
    @test norm(sol) < tol
end