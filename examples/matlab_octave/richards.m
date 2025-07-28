% Solves the highly nonlinear Richard's equation in 1D using the mixed form 
% approach and Newton's method to find the roots F(x) = 0

function richards
 
    clc
    close all

    addpath('../../src/matlab_octave');

    % Spatial and temporal discretization
    k = 4;
    m = 60;
    a = 0;
    b = 40;
    dx = (b-a)/m;
    t = 360; 
    dt = 1;
    n = t/dt;
    
    % Problem's parameters (from Michael Celia's paper on Unsaturated Flow)
    alpha = 1.611e+6;
    theta_s = 0.287;
    theta_r = 0.075;
    theta_g = theta_s - theta_r;
    beta = 3.96;
    K_s = 0.00944;
    A = 1.175e+6;
    gamma = 4.74;
    ic = -61.5;
    bot_bc = -20;
    top_bc = -61.5;

    % Get mimetic operators
    D = div(k, m, dx);
    G = grad(k, m, dx);
    I = interpol(m, 0.5);

    K_psi = @(psi) (K_s.* A)./(A + abs(psi).^gamma);

    theta_psi = @(psi) ((alpha.*theta_g)./(alpha + abs(psi).^beta)) + theta_r;

    psi_init = ones(m, 1)*ic;
    psi_old = [ic; psi_init; ic];

    %v = VideoWriter('richards1D_Corbino.avi', 'Uncompressed AVI');
    %v.FrameRate = 30;
    %open(v);
    
    ff = figure(1);

    % Time integration loop
    for i = 1 : n
        
        init_guess = ones(m,1)*ic;
        func = @F;
        
        % Find the roots using Newton's method
        sol = fsolve( @(psi) func(psi), init_guess );
        
        psi_old = [bot_bc; sol; top_bc];
        
        % Plot results
        plot([0 dx/2:dx:b-dx/2 b], psi_old, 'b');
        title(['Richards Eqn. (Mixed form) solved with MOLE,' ' Time = '...
              num2str(dt*i)])
        axis([0 40 -70 -10])
        xlabel('Depth')
        ylabel('Pressure head')
        set(gcf, 'color', 'w')
        legend('U')
        drawnow
        
        %M(k) = getframe(gcf);
    end
    
    %writeVideo(v, M)
    %close(v)
    
    function fval = F(psi)
        psi_new = [bot_bc;psi;top_bc];
        K = I * K_psi(psi_new);
        
        theta_t = (theta_psi(psi_new) - theta_psi(psi_old)) / dt;
        
        d1 = - D * diag(K) * G * psi_new;
        d1 = [bot_bc ; d1(2:end-1) ; top_bc];
        
        Dz = + D * K;
        Dz = [bot_bc ; Dz(2:end-1) ; top_bc];
        
        fval = theta_t  + d1 + Dz;
        fval = fval(2:end-1);
    end
end
