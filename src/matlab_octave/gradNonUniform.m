function G = gradNonUniform(k, ticks)
% Returns a m+1 by m+2 one-dimensional non-uniform mimetic gradient
% operator
%
% Parameters:
%                k : Order of accuracy
%                ticks : Centers' ticks e.g. [0 0.5 1 3 5 7 8 9 9.5 10]
%                        (including the boundaries!)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % Get uniform operator without scaling
    G = grad(k, length(ticks)-2, 1);
    
    [m, ~] = size(G);
    
    % Compute the Jacobian using the uniform operator and the ticks
    if size(ticks, 1) == 1
        J = spdiags((G*ticks').^-1, 0, m, m);
    else
        J = spdiags((G*ticks).^-1, 0, m, m);
    end
    
    % This is the non-uniform operator
    G = J*G;
end
