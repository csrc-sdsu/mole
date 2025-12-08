"""
A Julia script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators.
"""

using Plots
using MOLE

# Domain limits
west = 0.0
east = 1.0

k = 6 # operator order of accuracy
m = 2*k + 1 # minimum number of cells to attain desired accuracy
dx = (east-west)/m # step length

L = lap(k,m,dx)

# Impose Robin boundary condition on laplacian operator
a = 1.0
b = 1.0
L = L + robinBC(k,m,dx,a,b)

# 1D staggered grid
grid = [west; (west+(dx/2)):dx:(east-(dx/2)); east]

# RHS
U = exp.(grid)
U[1] = 0
U[end] = 2*exp(1)

U = L\U

# Plot result
p = scatter(grid, U, label="Approximated")
plot!(p, grid, exp.(grid), label="Analytical")
plot!(p, xlabel="x", ylabel="u(x)", title="Poisson's equation with Robin BC")
display(p)
println("Press Enter to close the plot and exit.")
readline()