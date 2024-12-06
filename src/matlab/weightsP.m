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
