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

function I = GI1(M, m, n, type)
    if strcmp(type, 'Gn')
        I = speye(n);
        I1 = speye(m+1, m);
        I1(end, end) = 1;
        I = kron(I, I1);
        I = [I sparse(size(I, 1), m)];
        I = I*M;
    else
        I = speye(n+1, n);
        I(end, end) = 1;
        I1 = speye(m, m+1);
        I = kron(I, I1);
        I = I*M;
    end
end