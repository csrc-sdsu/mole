using Test, LinearAlgebra

include("../src/MOLE.jl")
using .MOLE

tol = 1e-10

@testset "Testing Gradient for order k=$k" for k=2:2:8
    m = 2*k+1
    G = MOLE.grad(k, m, 1/m)
    field = ones(m+2, 1)
    sol = G*field
    @test norm(sol) < tol
end;