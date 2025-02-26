% https://www.sciencedirect.com/science/article/pii/0022247X78902172?via%3Dihub
function [X, Y] = ttm(grid_name, m, n, iters, plot_grid)
% Returns X and Y which are both m by n matrices that contains the physical
% coordinates
%
% Parameters:
%        grid_name : String with the name of the grid folder
%                m : Number of nodes along the horizontal axis
%                n : Number of nodes along the vertical axis
%        plot_grid : If defined -> grid will be plotted
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    assert(m > 4 && n > 4, 'm and n must be greater than 4')
    
    addpath(['grids/' grid_name])
    
    % Error tolerance for iterative method
    tol = 10^-6;
    
    % Preallocation
    X = zeros(m, n);
    Y = zeros(m, n);
    alpha = zeros(m, n);
    beta = zeros(m, n);
    gamma = zeros(m, n);
    
    % BCs
    for i = 1 : m
        xi = (i-1)/(m-1);
        XY = top(xi);
        X(i, end) = XY(1);
        Y(i, end) = XY(2);
        XY = bottom(xi);
        X(i, 1) = XY(1);
        Y(i, 1) = XY(2);
    end
    for j = 1 : n
        eta = (j-1)/(n-1);
        XY = left(eta);
        X(1, j) = XY(1);
        Y(1, j) = XY(2);
        XY = right(eta);
        X(end, j) = XY(1);
        Y(end, j) = XY(2);
    end
    
    newX = X;
    newY = Y;
    
    errX = zeros(1, iters);
    errY = zeros(1, iters);
    
    % SOR
    for t = 1 : iters
        i = 2 : m-1;
        j = 2 : n-1;
        
        alpha(i, j) = 0.25*((X(i, j+1)-X(i, j-1)).^2+(Y(i, j+1)-Y(i, j-1)).^2);
        beta(i, j) = 0.0625*((X(i+1, j)-X(i-1, j)).*(X(i, j+1)-X(i, j-1))+(Y(i+1, j)...
           -Y(i-1, j)).*(Y(i, j+1)-Y(i, j-1)));
        gamma(i, j) = 0.25*((X(i+1, j)-X(i-1, j)).^2+(Y(i+1, j)-Y(i-1, j)).^2);
        
        newX(i, j) = ((-0.5)./(alpha(i, j)+gamma(i, j)+1e-10)).*(2*beta(i, j)...
            .*(X(i+1, j+1)-X(i-1, j+1)-X(i+1, j-1)+X(i-1, j-1))-alpha(i, j)...
            .*(X(i+1, j)+X(i-1, j))-gamma(i, j).*(X(i, j+1)+X(i, j-1)));
        newY(i, j) = ((-0.5)./(alpha(i, j)+gamma(i, j)+1e-10)).*(2*beta(i, j)...
            .*(Y(i+1, j+1)-Y(i-1, j+1)-Y(i+1, j-1)+Y(i-1, j-1))-alpha(i, j)...
            .*(Y(i+1, j)+Y(i-1, j))-gamma(i, j).*(Y(i, j+1)+Y(i, j-1)));
        
        errX(1, t) = max(max(abs(newX-X)));
        errY(1, t) = max(max(abs(newY-Y)));
        
        % Update
        X = newX;
        Y = newY;
        
        if errX(t) < tol && errY(t) < tol
            break
        end
    end
    
    if plot_grid
        figure
        mesh(X, Y, zeros(m, n), 'Marker', '.', 'MarkerSize', 10, 'EdgeColor', 'b')
        title(['Physical grid. m = ' num2str(m) ', n = ' num2str(n)])
        set(gcf, 'color', 'w')
        axis equal
        axis off
        view([0 90])
    end
end