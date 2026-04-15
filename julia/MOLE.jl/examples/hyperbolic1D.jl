"""
Julia implementation of the 1D Advection equation with periodic boundary conditions
from MATLAB MOLE example
"""
using Printf
using Plots
import MOLE: Operators, BCs

# Domain limits
west = 0;
east = 1;

a  = 1; #velocity


k  = 2; #Operator's order of accuracy
m  = 50; # number of cells
dx = (east - west) / m;

t  = 1; #Simulation time
dt = dx/abs(a); #CFL condition for explicit schemes

D  = Operators.div(k,m,dx); #1D Mimetic divergence operator
I  = Operators.interpol(m, 0.5); #1D 2nd order interpolator

# 1D Staggered grid
grid = [west west+dx/2: dx : east-dx/2 east];

# Initial Condition
U = sin(2*π*grid)';

#Periodic Boundary Condition imposed on the divergence operator
D[1, 2]       = 1/(2*dx);
D[1, end-1]   = -1/(2*dx);
D[end, 1]     = -1/(2*dx);
D[end, end-1] = -1/(2*dx);

#Premultiply out of the time loop (since it does not change)
D = -a*dt*2*D*I;

#=
        We could have also defined 
        D = -a*dt*2*I*D
        if the grid was defined as:
        grid = west : dx :east (nodal)
=#

U2 = U + D/2*U #Compute one step using Euler's method


#Time integration loop
for i in 1: t/dt
    #Plot approximation
    plot(grid, U2, label="Approximated")
    #Plot exact solution
    plot!(grid, sin.(2*π*(grid - a*i*dt)), label="exact")
    #Plot attributes
    title!("1D Advection Equation with Periodic BC");
    xlabel!("x");
    ylabel!("u(x,t)");
    axis!([west east -1.5 1.5]);
    sleep(0.04);
    U3 = U + D*U2; #Compute next step using leapfrog scheme
    U  = U2;
    U2 = U3;
end


