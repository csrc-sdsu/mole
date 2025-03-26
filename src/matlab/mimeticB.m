function B = mimeticB(k, m)
% Returns a m+2 by m+1 one-dimensional mimetic boundary operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Q = sparse(diag(weightsQ(k, m, 1)));
    D = div(k, m, 1);
    G = grad(k, m, 1);
    P = sparse(diag(weightsP(k, m, 1)));
    
    B = Q*D + G'*P;
end
