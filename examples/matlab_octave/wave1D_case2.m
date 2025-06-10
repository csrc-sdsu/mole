% Solves the 1D Wave equation with MDM and position Verlet algorithm

clc
close all

addpath('../../src/matlab_octave')

% Spatial discretization
k = 4;         % Order of accuracy (spatial)
m = 101;       % Number of cells
a = 1;         % Left boundary
b = 4;         % Right boundary
dx = (b-a)/m;  % Step length

verlet = 1;    % If verlet = 0 then it uses 4th order accurate for time (FR)

xgrid = [a a+dx/2 : dx : b-dx/2 b];

% Mimetic operator (Laplacian)
L = lap(k, m, dx);

% Wave propagation speed
c = 100;  % (T/p) Tension over density

% "Force" function
F = @(x) (c^2)*L*x;  % c^2 DivGrad x

% Simulation time
TIME = 0.06;

% Temporal discretization based on CFL condition
dt = dx/(2*c); % dt = h on Young's paper

% Initial condition
ICU = @(x) sin(pi*x).*(x>2).*(x<3);      % Initial position of particles
ICV = @(x) zeros(m+1, 1);                % Initial velocity of particles

uold = ICU(xgrid');
vold = ICV(xgrid);
vold = [vold; vold(end)];

theta = 1/(2-2^(1/3)); % From Peter Young's paper

%v = VideoWriter('1D_Wave_Corbino.avi', 'Uncompressed AVI');
%v.FrameRate = 24;
%open(v);

% Time integration loop
for t = 0 : TIME/dt
    % Apply "position Verlet" algorithm -----------------------------------
    if verlet
        uold = uold + 0.5*dt*vold;
        vnew = vold + dt*F(uold);
        unew = uold + 0.5*dt*vnew;
    % Apply "Forest-Ruth" algorithm ---------------------------------------
    else
        unew = uold + theta*0.5*dt*vold;
        vnew = vold + theta*dt*F(unew);
        unew = unew + (1-theta)*0.5*dt*vnew;
        vnew = vnew + (1-2*theta)*dt*F(unew);
        unew = unew + (1-theta)*0.5*dt*vnew;
        vnew = vnew + theta*dt*F(unew);
        unew = unew + theta*0.5*dt*vnew;
    end
    
    uold = unew;
    vold = vnew;
    
    drawnow
    
    % Plot results
    plot(xgrid, unew, 'LineWidth', 2)
    title(['1D Wave equation t = ' num2str(dt*t)])
    xlabel('x')
    ylabel('u(x)')
    axis([a b -1.5 1.5])
    xticks([1, 2.5, 4])
    xticklabels({'0', '0.5', '1'})
    set(gcf, 'color', 'w')
    grid on
    
    %M(t+1) = getframe(gcf);
end

%writeVideo(v, M)
%close(v)
