using MOLE
using Test, LinearAlgebra

#tol = 1e-10

@testset "Testing MOLE operators" begin
    @testset "Testing 1D divergence" begin
        include("testDivergence.jl")
    end

    @testset "Testing 1D gradient" begin
        include("testGradient.jl")
    end

    @testset "Testing 1D laplacian" begin
        include("testLaplacian.jl")
    end
end

# @testset "Testing Divergence for order k=$k" for k=2:2:8
#     m = 2*k+1
#     D = div(k, m, 1/m)
#     field = ones(m+1,1)
#     sol = D*field
#     @test norm(sol) < tol
# end