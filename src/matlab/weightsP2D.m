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

function P = weightsP2D(k, m, dx, n, dy)
% Returns the 2mn+m+n weights of P in 2-D
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis

    Im = speye(m);
    In = speye(n);
    
    Pm = diag(weightsP(k, m, dx));
    Pn = diag(weightsP(k, n, dy));
    
    P = [diag(kron(In, Pm)); diag(kron(Pn, Im))];
end
