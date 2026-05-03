#=
Solve the 1D Inviscid Burgers' equation
Upwind Scheme is used and the equation is written in conservative form.
Initial condition: exp(-x^2/50)
=#

using Trapz
using Plots
import MOLE: Operators, BCs

#Domain limits
west = -15;
east = 15;

k  = 2; #Operator's order of accuracy
m  = 300; #Number of cells
dx = (east - west)/m;

t  = 10; #Simulation time
dt = dx; #CFL condition for explicit schemes

D  = Operators.div(k,m,dx) #1D Mimetic divergence operator
I  = Operators.interpol(m,1.0) #1D interpolator

#Use I = Operators.interpol(m,0) (downwind) if the fluid propagates to the left

#1D Staggered grid
xgrid = [west; (west+(dx/2)):dx: (east-(dx/2)); east];

#Initial Condition
U = exp.(-(xgrid.^2)/50);

#Premultiply out of the time loop (since it does not change)
D = -dt/2*D*I;

vx = range(west,east, length=k+m)
#Time integration loop
for i in 0: t/dt
    #Check for area conservation
    trapz(vx,U) 
    #Plot approximation
    plot(xgrid, U, label="Approximated", lw=2)
    #Plot attributes
    title!("1D Inviscid Burgers' Equation t = $(round(i*dt, sigdigits=2))");
    xlabel!("x");
    ylabel!("u(x,t)");
    plot!(legend=:topleft)
    sleep(0.01)
    U2 = U + D * U.^2;
    global U = U2;
    gui()
end
