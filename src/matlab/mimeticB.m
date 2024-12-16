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

function B = mimeticB(k, m)
% Returns a m+2 by m+1 one-dimensional mimetic boundary operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells

    Q = sparse(diag(weightsQ(k, m, 1)));
    D = div(k, m, 1);
    G = grad(k, m, 1);
    P = sparse(diag(weightsP(k, m, 1)));
    
    B = Q*D + G'*P;
end
