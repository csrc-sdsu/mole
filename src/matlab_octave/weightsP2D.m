function P = weightsP2D(k, m, dx, n, dy)
% Returns the 2mn+m+n weights of P in 2-D
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Im = speye(m);
    In = speye(n);
    
    Pm = diag(weightsP(k, m, dx));
    Pn = diag(weightsP(k, n, dy));
    
    P = [diag(kron(In, Pm)); diag(kron(Pn, Im))];
end
