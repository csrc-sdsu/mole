using MOLE
using Test, LinearAlgebra
import MOLE: Operators

@testset "Testing MOLE operators" begin
    @testset "Testing 1D divergence" begin
        include("Operators/divergence.jl")
    end

    @testset "Testing 1D gradient" begin
        include("Operators/gradient.jl")
    end

    @testset "Testing 1D laplacian" begin
        include("Operators/laplacian.jl")
    end
end