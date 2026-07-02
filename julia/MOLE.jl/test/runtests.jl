using MOLE
using Test, LinearAlgebra, SparseArrays
import MOLE: Operators, BCs, Grids

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

    @testset "Testing interpol" begin
        include("Operators/interpol.jl")
    end
end

@testset "Testing Boundary Conditions" begin

    @testset "Test addScalarBC" begin
        include("BCs/scalarBC.jl")
    end
end

@testset "Testing Grids" begin
    include("Grids/make_grid.jl")
    include("Grids/validate_grid.jl")
end
