#=
Solve the 1D Inviscid Burgers' equation
Upwind Scheme is used and the equation is written in conservative form.
Initial condition: exp(-x^2/50)
=#

using Plots
import MOLE: Operators, BCs


function upwind_burgers(u0, xgrid, T, k, m, dx)
#Solves Burgers equation using MOLE Operators
    #=
    INPUTS:
    u0    : Initial condition
    xgrid : staggered grid
    T     : final time
    k     : Operator order of accuarcy
    m     : number of cells
    OUTPUTS:
    U     : solution
    t     : time interval
    =#
    #CFL Condition for explicit schemes
    dt = dx;    
    
    #Create stepsize for time with given T
    t  = collect(0.0:dt:T) 
    
    #Use of MOLE Operators
    D  = Operators.div(k, m, dx)
    I  = Operators.interpol(m, 1.0)
    
    #Premultiply out of time loop (does not change)
    D  = -dt/2*D*I
    
    #Create an array that holds solution at each time step
    U  = zeros(length(t)+1,length(xgrid))
    
    #Set initial condition at first time element
    U[1,:] .= u0.(xgrid)
   
    for k in eachindex(t)
        U[k+1,:] .= U[k,:] + D * U[k,:].^2;
    end

    return t, U

end

### MAIN LOOP ###

#Domain limits
west = -15;
east = 15;

#number of cells
m = 300;

#stepsize
dx = (east - west)/m;

#Simulation time
T = 13

#Operator's order of accuracy
k = 2;

# 1D Staggered grid
xgrid = [west; (west + (dx/2)):dx: (east - (dx/2)); east];

# Initial Condition
u0(x) = exp.(-(x.^2)/50);
 
t, U = upwind_burgers(u0, xgrid, T, k, m, dx)

path = joinpath(@__DIR__, "output") # Output path to store generated plots
mkpath(path)


animation = Plots.@animate for k in eachindex(t)
    Plots.plot(xgrid, U[k,:];
         label  = "approximated",
         xlabel = "x",
         ylabel = "u(x,t)",
         grid   = true,
         title  = "1D Inviscid Burgers' Equation t = $(round(t[k]; digits=3))",
         legend = :topleft
        )
end


Plots.gif(animation, joinpath(path,"burgers1D.gif"), fps=10)

Plots.png(
    Plots.plot(xgrid, U[end,:];
         label  = "approximated",
         xlabel = "x",
         ylabel = "u(x,t)",
         grid   = true,
         title  = "1D Inviscid Burgers' Equation t = $(round(t[end]; digits=3))",
         legend = :topleft
        ),
    joinpath(path,"burgers_end.png"),
)

