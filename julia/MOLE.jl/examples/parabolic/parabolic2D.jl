"""
A Julia script that solves the 2D heat equation with Dirichlet boundary
conditions using mimetic operators. This example uses addScalarBC.

u_t = nu (u_xx + u_yy)

0 < x < 2
0 < y < 2
0 < t < 3

Boundary Conditions:
u(x, 0) = 0
u(x, 2) = 0
u(0, y) = 0
u(2, y) = 0

Initial Condition:
u(x, y) = 2 if (1 <= x <= 1.5 and 1 <= y <= 1.5) else 0

Exact Solution:
Unknown
"""

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

if method == "explicit"
    dt = 0.001 # Step size in time
else
    dt = 0.01  # Step size in time
end


path = joinpath(@__DIR__, "output") # Output path to store generated plots
mkpath(path)

# Grid
xc = [0; (dx / 2.0):dx:(2.0 - dx / 2.0); 2.0]
yc = [0; (dy / 2.0):dy:(2.0 - dy / 2.0); 2.0]

# Initial Conditions
u = zeros(m + 2, n + 2)
for i in 1:m
    for j in 1:n
        if ((1.0 ≤ yc[j]) && (yc[j] ≤ 1.5) && (1.0 ≤ xc[i]) && (xc[i] ≤ 1.5))
            u[i, j] = 2.0
        end
    end
end
u = vec(reshape(u, :, 1))

# Boundary Conditions
dc = (1.0, 1.0, 1.0, 1.0)
nc = (0.0, 0.0, 0.0, 0.0)
v = (vec(zeros(n, 1)),
    vec(zeros(n, 1)),
    vec(zeros(m + 2, 1)),
    vec(zeros(m + 2, 1)),
)
bc = BCs.ScalarBC2D(dc, nc, v)

# Operator
L = Operators.lap(k, m, dx, n, dy, dc = dc, nc = nc)
if method == "explicit"
    L = nu * dt .* sparse(L) .+ sparse(Matrix(I, size(L)))
else
    L = sparse(Matrix(I, size(L))) .- nu * dt .* sparse(L)
end
L, u = BCs.addScalarBC!(L, u, bc, k, m, dx, n, dy)

function time_step(L, u, t, dt, method)

    num_it = ceil(Int, t / dt)
    sol = zeros(length(u), 1 + num_it)

    for it in 0:num_it
        sol[:, it + 1] = u

        if method == "explicit"
            u = L * u
        else
            u = L \ u
        end
    end

    sol
end

sol = time_step(L, u, t, dt, method)

anim = Plots.@animate for i in 1:length(sol[1, :])
    it = i - 1
    ua = reshape(sol[:, i], n + 2, m + 2)'
    Plots.heatmap(xc, yc, ua,
        size = (800, 600),
        xlabel = "x",
        ylabel = "y",
        title = "$method\n2-D Diffusion with ν = $nu -- time (t) = $(it*dt)",
        xlims = (0, 2),
        ylims = (0, 2),
        colorbar = true,
        colorbar_title = "u(x,y)",
        colormap = :jet1,
        show = false,
    )
end
Plots.gif(anim, joinpath(path, "parabolic2D.gif"), fps = ceil(Int, 1 / dt))
