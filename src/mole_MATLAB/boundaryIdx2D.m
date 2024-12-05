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

function idx = boundaryIdx2D(m, n)
% Returns the indices of the nodes that lie on the boundary of a 2D nodal
% grid
%
% Parameters:
%           m : Number of nodes along x-axis
%           n : Number of nodes along y-axis

 

    idx = zeros(2*m+2*(n-2), 1);
    
    mn = m*n;
    
    idx(1:m) = 1:m;
    idx(end-m+1:end) = mn-m+1:mn;
    
    k = m+1;
    for i = m+1:m:mn-m
        idx(k) = i;
        idx(k+1) = i+m-1;
        k = k+2;
    end
end
