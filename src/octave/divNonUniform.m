function D = divNonUniform(k, ticks)
% PURPOSE
% Returns a m+2 by m+1 one-dimensional non-uniform mimetic divergence
% operator
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                ticks : Edges' ticks e.g. [0 0.1 0.15 0.2 0.3 0.4 0.45]
%
% SYNTAX
% D = divNonUniform(k, ticks)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % Get uniform operator without scaling
    D = div(k, length(ticks)-1, 1);
    
    [m, ~] = size(D);
    
    % Compute the Jacobian using the uniform operator and the ticks
    if size(ticks, 1) == 1
        J = spdiags((D*ticks').^-1, 0, m, m);
    else
        J = spdiags((D*ticks).^-1, 0, m, m);
    end
    
    % This is the non-uniform operator
    D = J*D;
end
