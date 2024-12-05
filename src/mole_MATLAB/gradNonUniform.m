% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

function G = gradNonUniform(k, ticks)
% Returns a m+1 by m+2 one-dimensional non-uniform mimetic gradient
% operator
%
% Parameters:
%                k : Order of accuracy
%                ticks : Centers' ticks e.g. [0 0.5 1 3 5 7 8 9 9.5 10]
%                        (including the boundaries!)

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
