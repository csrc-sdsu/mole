using LinearAlgebra
using SparseArrays
using Plots

import MOLE: Operators, BCs

# Parameters
k = 2               # Order of accuracy
nu = 0.1            # Diffusion coefficient
m = 40              # Number of cells in x-direction
n = 50              # Number of cells in y-direction
dx = 2.0 / m        # Step size in x-direction
dy = 2.0 / n        # Step size in y-direction
t = 3.0             # Final time
method = "implicit" # Method of Euler time integration
dt = 0.0            # Step size in time
if method == "explicit"; dt = 0.001; else; dt = 0.01; end

# Grid
xc = [0; (dx / 2.0) : dx : (2.0 - dx / 2.0); 2.0]
yc = [0; (dy / 2.0) : dy : (2.0 - dy / 2.0); 2.0]

# Initial Conditions
u = zeros(m + 2, n + 2)
for i = 1:m
    for j = 1:n
        if ((1.0 ≤ yc[j]) && (yc[j] ≤ 1.5) && (1.0 ≤ xc[i]) && (xc[i] ≤ 1.5))
            u[i, j] = 2.0
        end
    end
end
u = Matrix(reshape(u, :, 1))

# Boundary Conditions
dc = (1.0, 1.0, 1.0, 1.0)
nc = (0.0, 0.0, 0.0, 0.0)
v = (vec(zeros(n, 1)), vec(zeros(n, 1)), vec(zeros(m + 2, 1)), vec(zeros(m + 2, 1)))
bc = BCs.ScalarBC2D(dc, nc, v)

# Operator
L = Operators.lap(k, m, dx, n, dy, dc=dc, nc=nc)
if method == "explicit"
    L = nu * dt .* sparse(L) .+ sparse(Matrix(I, size(L)))
else
    L = sparse(Matrix(I, size(L))) .- nu * dt .* sparse(L)
end

for it = 0:(t/dt)
    heatmap(xc, yc, u,
        size = (800, 600),
        xlabel = "x",
        ylabel = "y",
        title = "$method\n2-D Diffusion with ν = $nu -- time (t) = $(it*dt)",
        xlims = (0, 2),
        ylims = (0, 2),
        clims = (0, 2),
        colorbar = true,
        colorbar_title = "u(x,y)"
    )
    display(current())

    global u = reshape(u', :, 1)

    if method == "explicit"
        global u = L * u
    else
        global u = L \ u
    end

    global u = reshape(u, n + 2, m + 2)'
end

println("Press Enter to close the plot and exit.")
readline()