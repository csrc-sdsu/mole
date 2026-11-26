#=
This example uses MOLE to solve the 1D advection-reaction-dispersion
equation based on the C++ MOLE transport1D example:
https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc/html/final-22.html
=#

using Plots
import MOLE: Operators

# Operator order of accuracy
k = 2

# Spatial domain
a = 0.0
b = 130.0
m = 26
dx = (b - a) / m

# 1D staggered grid
xgrid = [a; (a + dx / 2):dx:(b - dx / 2); b]

# Time parameters
t = 4.0
iter = 208
dt = t / iter

# Physical parameters
dis = 5.0   # Dispersivity [m]
vel = 15.0  # Pore-water flow velocity [m/year]
R = 2.5     # Retardation
C0 = 1.0    # Displacing solution concentration [mmol/kgw]

# Construct 1D mimetic operators
G = Operators.grad(k, m, dx)
D = Operators.div(k, m, dx)
I = Operators.interpol(m, 0.5)

# Allocate fields
C = zeros(m + 2)
V = fill(vel, m + 1)

# Initial condition
C[1] = C0

# Hydrodynamic dispersion coefficient [m^2/year]
dis *= vel

# Account for retardation
dt /= R

# Time integration
for i in 0:iter
    C .+= dt .* (D * (dis .* (G * C)) - D * (V .* (I * C)))

    # Right boundary condition (reflection)
    C[m + 2] = C[m + 1]
end

println(C)
path = joinpath(@__DIR__, "output")
mkpath(path)

p = plot(
    xgrid,
    C;
    label = "concentration",
    xlabel = "Distance [m]",
    ylabel = "Concentration [mmol/kgw]",
    grid = true,
    lw = 2,
    title = "1D Advection-Reaction-Dispersion",
)

png(p, joinpath(path, "transport1D.png"))