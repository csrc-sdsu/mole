"""
A Julia script that solves the 2D Poisson's equation with Dirichlet boundary
conditions in the y-direction and periodic boundary conditions in the
x-direction using mimetic operators. This example uses addScalarBC.

- (u_xx + u_yy) = 2 sin(2 pi x) (1 + 2 pi^2 y (1 - y))

0 < x < 1
0 < y < 1

Boundary Conditions:
u(x, 0) = 0
u(x, 1) = 0
u(0, y) = u(1, y)

Exact Solution:
u(x, y) = y (1 - y) sin(2 pi x)
"""

using LinearAlgebra
using SparseArrays
using Plots

import MOLE: Operators, BCs

# Parameters
k = 2        # Order of accuracy
m = 20       # Number of cells in x-direction
n = m + 1    # Number of cells in y-direction
dx = 1.0 / m # Step size in x-direction
dy = 1.0 / n # Step size in y-direction

path = joinpath(@__DIR__, "output") # Output path to store generated plots
mkpath(path)

# Grid
xc = (dx / 2.0) : dx : (1.0 - dx / 2.0)
yc = [0; (dy / 2.0) : dy : (1.0 - dy / 2.0); 1.0]
X = ones(1, n + 2) .* xc
Y = yc' .* ones(m, 1)

# Exact Solution
ue = Y .* (1.0 .- Y) .* sin.(2.0 * pi .* X)

# Boundary Conditions
dc = (0.0, 0.0, 1.0, 1.0)
nc = (0.0, 0.0, 0.0, 0.0)
v = ([0.0], [0.0], vec(zeros(m, 1)), vec(zeros(m, 1)))
bc = BCs.ScalarBC2D(dc, nc, v)

# Operator
A = - Operators.lap(k, m, dx, n, dy, dc=dc, nc=nc)

# RHS
b = 2.0 * sin.(2.0 * pi .* X) .* (1.0 .+ 2.0 * pi^2 .* Y .* (1.0 .- Y))
b = vec(b)

# Apply BCs
A0, b0 = BCs.addScalarBC!(sparse(A), b, bc, k, m, dx, n, dy)

# Approximate Solution
ua = A0 \ b0
ua = Matrix(reshape(ua, m, n + 2))

Plots.png(
    Plots.heatmap(
        xc, 
        yc, 
        ua, 
        title = "Approximate Solution", 
        xlabel = "X", 
        ylabel = "Y", 
        colorbar_title = "u(x,y)", 
        aspect_ratio = :equal,
        colormap = :jet1,
        show = false
    ),
    joinpath(path, "elliptic2DXPYD_approximate.png")
)

Plots.png(
    Plots.heatmap(
        xc, 
        yc, 
        ue, 
        title = "Exact Solution", 
        xlabel = "X", 
        ylabel = "Y", 
        colorbar_title = "u(x,y)", 
        aspect_ratio = :equal,
        colormap = :jet1,
        show = false
    ),
    joinpath(path, "elliptic2DXPYD_exact.png")
)

max_err = maximum(abs, ue - ua)
println("Maximum error: $max_err")
rel_err = 100 * max_err ./ (maximum(ue) - minimum(ue))
println("Realative error: $rel_err")