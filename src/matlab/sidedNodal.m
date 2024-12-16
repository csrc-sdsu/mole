% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF). 
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

function S = sidedNodal(m, dx, type)
% Returns a m+1 by m+1 one-dimensional sided approximation for uniformly
% spaced data points. This function is handy for advective terms.
%
% Parameters:
%                m : Number of cells
%               dx : Step size
%             type : 'backward', 'forward' or 'centered'

    switch type
        case 'backward'
            S = spdiags([-ones(m+1, 1) ones(m+1, 1)], [-1 0], m+1, m+1);
            S(1, end-1) = -1;
            S = S/dx;
        case 'forward'
            S = spdiags([-ones(m+1, 1) ones(m+1, 1)], [0 1], m+1, m+1);
            S(end, 2) = 1;
            S = S/dx;
        otherwise % 'centered'
            S = spdiags([-ones(m+1, 1) zeros(m+1, 1) ones(m+1, 1)], [-1 0 1], m+1, m+1);
            S(1, end-1) = -1;
            S(end, 2) = 1;
            S = S/(2*dx);
    end
end
