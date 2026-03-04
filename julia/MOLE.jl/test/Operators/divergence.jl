@testset "Testing divergence for order k=$k" for k=2:2:8
    tol = 1e-10
    m = 2*k+1
    D = Operators.div(k, m, 1/m)
    field = ones(m+1,1)
    sol = D*field
    @test norm(sol) < tol
end