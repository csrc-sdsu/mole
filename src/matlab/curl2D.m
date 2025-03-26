function C = curl2D(k, m, dx, n, dy, west, east, south, north, U, V)
% Returns a two-dimensional mimetic curl operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%      west, east,
%     south, north : west, east, south, north limits
%                U : Vector space function acting on x-direction
%                    U(X,Y) must be defined as function handle
%                V : Vector space function acting on y-direction
%                    V(X,Y) must be defined as function handle
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------


% Arguments validation
    assert(isa(U, 'function_handle') && isa(V, 'function_handle'), ...
           'U and V must be defined as function handle');
    assert(nargin(U) == 2 && nargin(V) == 2, ...
           'U and V must be defined as 2D vector functions');
    assert(west < east && south < north , 'west < east, south < north');

% Variables initialization
    F = sparse(2*m*n+m+n, 1);
    xaxis = west : (dx/2) : east;
    yaxis = south : (dy/2) : north;

% Linearizing F as function of U and V: F = V_x - U_y
    f = 1;
    for j = 2 : 2 : 2*n+1
        for i = 1 : 2 : 2*m+1
            F(f) = V(xaxis(i), yaxis(j));  % F in the x direction (V_x)
            f = f + 1;
        end
    end

    for j = 1 : 2 : 2*n+1
        for i = 2 : 2 : 2*m+1
            F(f) = -U(xaxis(i), yaxis(j));  % F in the y direction (-U_y)
            f = f + 1;
        end
    end

    C = div2D(k, m, dx, n, dy)*F;  % Mimetic curl as C = Div2D*F
    C = reshape(C, m+2, n+2);      % Reshaping C as matrix
    C = C(2:end-1, 2:end-1);       % Removing boundaries
end
