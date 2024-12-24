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

function I = interpol(m, c)
% Returns a m+1 by m+2 one-dimensional interpolator of 2nd-order
%
% Parameters:
%               m : Number of cells
%               c : Left interpolation coeff.

    % Assertions:
    assert(m >= 4, 'm >= 4');
    assert(c >= 0 && c <= 1, '0 <= c <= 1');

    % Dimensions of I:
    n_rows = m+1;
    n_cols = m+2;
    
    I = sparse(n_rows, n_cols);
    
    I(1, 1) = 1;
    I(end, end) = 1;
    
    % Average between two continuous cells
    avg = [c 1-c];
    
    j = 2;
    for i = 2 : n_rows - 1
        I(i, j:j+2-1) = avg;
        j = j + 1;
    end
end
