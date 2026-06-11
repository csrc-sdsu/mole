#=
Julia implementation of the 1D Advection equation with periodic boundary conditions
from MATLAB MOLE example using the Leapfrog Scheme
=#

using Plots
import MOLE: Operators, BCs

function advection_hyperbolic(u0, a, grid, T, k, m, dx)
    #Solves the 1D Advection equation using MOLE Operators
    #=
    INPUTS: 
    u0    : Initial condition
    a     : velocity
    grid  : staggered grid
    T     : final time
    k     : Operator order of accuracy
    m     : number of cells
    OUTPUTS:
    U     : solution
    t     : time interval
    =#
    #CFL condition for explicit schemes
    dt = dx/abs(a);

    #Create stepsize for time with given T
    t  = collect(0.0:dt:T)

    #Use of MOLE Operators
    D  = Operators.div(k,m,dx);
    I  = Operators.interpol(m,0.5);
    
    #Periodic Boundary Conditions imposed on Divergence Operator
    D[1, 2]       = 1/(2*dx);
    D[1, end-1]   = -1/(2*dx);
    D[end, 2]     = 1/(2*dx);
    D[end, end-1] = -1/(2*dx);

    #Premultiply out of time loop (does not change)
    D  = -a*dt*2 *D*I;
    
    #Create an array that holds solution at each time step
    U = zeros(length(t)+2, length(grid))

    #Set initial condition at first time element
    U[1,:] .= u0.(grid)

    #Leapfrog scheme requires two steps, hence we would use Euler's step
    U[2,:] .= U[1,:] + D/2*U[1,:];

    for k in eachindex(t)
        U[k+2,:] .= U[k,:] + D * U[k+1,:];
    end

    return t, U
end

### MAIN LOOP ###

#Domain limits
west = 0;
east = 1;

#velocity
a = 1;

#number of cells
m = 50;

#stepsize
dx = (east - west) / m;

#Simulation time
T = 1;

#Operator's order of accuracy
k = 2;

#1D Staggered grid
xgrid = [west; (west + (dx/2)):dx: (east - (dx/2)); east];

#Initial Condition
u0(x) = sin.(2 * π * x);

t, U = advection_hyperbolic(u0, a, xgrid, T, k, m, dx)

#Output path to store generated plot
path = joinpath(@__DIR__, "output") 

#Creation of animation
animation = Plots.@animate for k in eachindex(t)
    Plots.plot(xgrid, U[k,:];
               label  = "approximated",
               xlabel = "x",
               ylabel = "u(x,t)",
               grid   = true,
               ls     = :dot,
               lw     = 3,
               title  = "1D Advection Equation with Periodic BC t = $(round(t[k], sigdigits=2))",
               legend = :bottomright,
               xlims  = (west, east),
               ylims  = (-1.5, 1.5)
              )
    Plots.plot!(xgrid, sin.(2*π .*(xgrid .- a*t[k]));
               label  = "exact",
              )
end

#Storing animation as gif to output directory
Plots.gif(animation, joinpath(path, "hyperbolic1D.gif"), fps=10)

#Creating plot object for approximation
p1 = plot(xgrid, U[end-2,:]; #Due to length of t and U being off by 2
               label  = "approximated",
               xlabel = "x",
               ylabel = "u(x,t)",
               grid   = true,
               ls     = :dot,
               lw     = 3,
               title  = "1D Advection Equation with Periodic BC t = $(round(t[end], sigdigits=2))",
               legend = :bottomright,
               xlims  = (west, east),
               ylims  = (-1.5, 1.5)
              )
#Mutating plot to include exact solution
plot!(xgrid, sin.(2*π .*(xgrid .- a*t[end]));
              label = "exact",
             )

#Storing png file of last iteration
Plots.png(
    p1,
    joinpath(path, "hyperbolic_end.png")
)


