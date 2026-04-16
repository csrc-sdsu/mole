"""
A Julia script that solves the 2D Laplace's equation with Dirichlet boundary
conditions using mimetic operators. This example uses addScalarBC.

u_xx + u_yy = 0

0 < x < pi
0 < y < pi

Boundary Conditions:
u(0,  y) = cos(y)
u(pi, y) = e^pi cos(y)
u(x,  0) = e^x
u(x, pi) = -e^x

Exact Solution:
u(x, y) = e^x cos(y)
"""

using LinearAlgebra
using SparseArrays
using Plots

import MOLE: Operators, BCs

# Parameters
k = 2       # Order of accuracy
m = 99      # Number of cells in x-direction
n = m + 2   # Number of cells in y-direction
dx = pi / m # Step size in x-direction
dy = pi / n # Step size in y-direction

path = joinpath(@__DIR__, "output") # Output path to store generated plots
mkpath(path)

# Grid
xc = [0; (dx / 2.0) : dx : (pi - dx / 2.0); pi]
yc = [0; (dy / 2.0) : dy : (pi - dy / 2.0); pi]
X = ones(1, n + 2) .* xc
Y = yc' .* ones(m + 2, 1)

# Exact Solution
ue = exp.(X) .* cos.(Y)

# Boundary Conditions
dc = (1.0, 1.0, 1.0, 1.0)
nc = (0.0, 0.0, 0.0, 0.0)
v = (vec(ue[1,2:end-1]'), vec(ue[end,2:end-1]'), vec(ue[:,1]), vec(ue[:, end]))
bc = BCs.ScalarBC2D(dc, nc, v)

# Operator
A = - Operators.lap(k, m, dx, n, dy, dc=dc, nc=nc)

# RHS
b = zeros(m + 2, n + 2)
b = vec(b)

# Apply BCs
A0, b0 = BCs.addScalarBC!(sparse(A), b, bc, k, m, dx, n, dy)

# Approximate Solution
ua = A0 \ b0
ua = Matrix(reshape(ua, m + 2, n + 2))

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
    joinpath(path, "elliptic2DXDYD_approximate.png")
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
    joinpath(path, "elliptic2DXDYD_exact.png")
)

max_err = maximum(abs, ue - ua)
println("Maximum error: $max_err")
rel_err = 100 * max_err ./ (maximum(ue) - minimum(ue))
println("Relative error: $rel_err")