% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function Q = weightsQ2D(m, n, d)
% Returns the (m+2)(n+2) weights of Q in 2-D
%
% Parameters:
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%                d : Step size (assuming d = dx = dy)
%
% Only works for 2nd-order 2-D Mimetic divergence operator

    Q = d*ones((m+2)*(n+2), 1);
end
