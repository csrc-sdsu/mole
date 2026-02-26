tol = 1e-10

@testset "Testing laplacian for order k=$k" for k=2:2:8
    m = 2*k+1
    L = MOLE.lap(k, m, 1/m)
    field = ones(m+2, 1)
    sol = L*field
    @test norm(sol) < tol
end;