include("divergence.jl")
include("gradient.jl")

function lap(k::Int, m::Int, dx)
    D = div(k,m,dx)
    G = grad(k,m,dx)

    L = D*G;
end