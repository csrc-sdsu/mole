"""
A Julia script that solves the 1D Poisson's equation with Robin boundary
conditions using mimetic operators.

u_xx = e^x

0 < x < 1

Robin Boundary Conditions:
u(0) - u_x(0) = 0
u(1) + u_x(1) = 2 e

Exact Solution:
u(x) = e^x
"""

using Plots
import MOLE: Operators, BCs

# Domain limits
west = 0.0
east = 1.0

k = 6 # operator order of accuracy
m = 2*k + 1 # minimum number of cells to attain desired accuracy
dx = (east-west)/m # step length

path = joinpath(@__DIR__, "output") # Output path to store generated plots
mkpath(path)

L = Operators.lap(k,m,dx)

# Impose Robin boundary condition on laplacian operator
a = 1.0
b = 1.0
L = L + BCs.robinBC(k,m,dx,a,b)

# 1D staggered grid
grid = [west; (west+(dx/2)):dx:(east-(dx/2)); east]

# RHS
U = exp.(grid)
U[1] = 0
U[end] = 2*exp(1)

U = L\U

# Plot result
p = Plots.scatter(grid, U, label="Approximated", show = false)
plot!(p, grid, exp.(grid), label="Analytical", show = false)
plot!(
    p,
    xlabel="x",
    ylabel="u(x)",
    title="Poisson's equation with Robin BC",
    show = false
)
Plots.png(p, joinpath(path, "elliptic1D_output.png"))
