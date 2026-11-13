function G = gradPeriodic(k, grid, errorObj = MOLE_errors())
% PURPOSE
% Returns a grid.m by grid.m+2 one-dimensional mimetic gradient operator
% when the boundary condition is periodic
%
% DESCRIPTION
% Parameters:
%                k    : Order of accuracy
%                grid : Grid object with attributes m number of cells and 
%                       dx step size 
%
% SYNTAX
% G = gradPeriodic(k, grid)
% G = gradPeriodic(k, grid, errorObj)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % Assertions:
    % NEED TO ASK ABOUT THE ERROR USED THE MESSAGE IS NOT EXPLICIT ABOUT ALL INVALID ARGS THEY ARE FOR GRID CREATION !!
    if k < 2 || mod(k, 2) != 0 || k > 8
        params = sprintf('Order of accuracy k must be greater than 2 and even but k: %s was  given.', mat2str(k));
        errorObj.log_error('MOLE_ERR_INVALID_ARGS', 'grad', true, params);

    end
    if grid.m < 2*k
        params = sprintf('grid.m and k must meet m >= %s for k = %s',num2str(2*k), mat2str(k));
        errorObj.log_error('MOLE_ERR_INVALID_ARGS', 'grad', true, params);
    end
    m = grid.m;
    dx = grid.dx;
    % constructing circulant matrix
    V = sparse(1, m); % vector of values for circulant matrix
    idx = repmat(-1,m, m); % matrix of indices for circulant matrix
    idx(:,1) = 1:m;
    idx = cumsum(idx, 2);
    idx = rem(idx+m, m) + 1;

    switch k
        case 2
            V(2:3) = [1, -1];

        case 4
            V(1:4) = [-1/24, 9/8, -9/8, 1/24];

        case 6
            V(1:5) = [-25/384, 75/64, -75/64, 25/384, -3/640]; V(end) = 3/640;

        case 8
            V(1:6) = [-245/3072, 1225/1024, -1225/1024, 245/3072, -49/5120, 5/7168]; V(end-1) = -5/7168; V(end) = 49/5120;
    end

    % G constructed as a circulant matrix
    G = V(idx);
    G = (1/dx).*G;
end
