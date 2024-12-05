% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function P = weightsP(k, m, dx)
% Returns the m+1 weights of P
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size

    G = grad(k, m, dx);
    
    b = [-1; zeros(m, 1); 1]; % RHS
    
    P = G'\b;
end
