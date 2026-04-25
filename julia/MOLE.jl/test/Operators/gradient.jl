tol = 1e-10

@testset "Testing non periodic 1-D gradient for order k=$k" for k=2:2:8
    m = 2*k+1
    G = Operators.grad(k, m, 1/m)
    field = ones(m+2, 1)
    sol = G*field
    @test norm(sol) < tol
end

@testset "Testing periodic 1-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    dx = 1.0 / (m - 1)
    dc = (0.0, 0.0)
    nc = (0.0, 0.0)
    G = Operators.grad(k, m, dx, dc=dc, nc=dc)
    field = ones(m, 1)
    sol = G * field
    @test norm(sol) < tol
end

@testset "Testing non uniform 1-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    ticks = sort(rand(m + 2))
    G = Operators.grad(k, ticks)
    field = ones(m + 2, 1)
    sol = G * field
    @test norm(sol) < tol
end

@testset "Testing non periodic 2-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    G = Operators.grad(k, m, dx, n, dy)
    field = ones((m + 2) * (n + 2), 1)
    sol = G * field
    @test norm(sol) < tol
end

@testset "Testing periodic 2-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    dc = (0.0, 0.0, 0.0, 0.0)
    nc = (0.0, 0.0, 0.0, 0.0)
    G = Operators.grad(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(m * n, 1)
    sol = G * field
    @test norm(sol) < tol
end

@testset "Testing mixed periodicity 2-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    dx = 1.0 / m
    dy = 1.0 / n
    dc = (0.0, 0.0, 1.0, 1.0)
    nc = (0.0, 0.0, 1.0, 1.0)
    G = Operators.grad(k, m, dx, n, dy, dc=dc, nc=nc)
    field = ones(m * (n + 2), 1)
    sol = G * field
    @test norm(sol) < tol
end

@testset "Testing non uniform 2-D gradient for order k=$k" for k=2:2:8
    m = 2 * k + 1
    n = m + 1
    xticks = sort(rand(m + 2))
    yticks = sort(rand(n + 2))
    G = Operators.grad(k, xticks, yticks)
    field = ones((m + 2) * (n + 2), 1)
    sol = G * field
    @test norm(sol) < tol
end