using Test, LinearAlgebra

include("../src/MOLE.jl")
using .MOLE

tol = 1e-10

@testset "Testing Divergence for order k=$k" for k=2:2:8
    m = 2*k+1
    D = MOLE.div(k, m, 1/m)
    field = ones(m+1,1)
    sol = D*field
    @test norm(sol) < tol
end;