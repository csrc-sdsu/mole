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

pa = heatmap(xc, yc, ua, title = "Approximate Solution", xlabel = "X", ylabel = "Y", colorbar_title = "u(x,y)", aspect_ratio = :equal)
display(pa)
println("Press Enter to close the plot and open the next.")
readline()

pe = heatmap(xc, yc, ue, title = "Exact Solution", xlabel = "X", ylabel = "Y", colorbar_title = "u(x,y)", aspect_ratio = :equal)
display(pe)
println("Press Enter to close the plot and exit.")
readline()