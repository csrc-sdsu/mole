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

function KG = tensorGrad2D(K, G)
% Returns a two-dimensional flux operator
%
% Parameters:
%                K : Tensor (e.g. diffusion tensor)
%                G : 2D mimetic gradient operator

    rowsGx = find(G(:, 2), 1)-1;
    rowsGy = size(G, 1)-rowsGx;
    
    Gx = G(1:rowsGx, :);
    Gy = G(rowsGx+1:end, :);
    
    if size(K, 1) ~= 2
        Kxx = spdiags(cell2mat(K(1)), 0, rowsGx, rowsGx);
        Kyy = spdiags(cell2mat(K(2)), 0, rowsGy, rowsGy);
        %Kxy = spdiags(cell2mat(K(3)), 0, rowsGy, rowsGy);
        %Kyx = spdiags(cell2mat(K(4)), 0, rowsGx, rowsGx);
    else
        Kxx = K(1, 1);
        Kyy = K(2, 2);
        %Kxy = K(1, 2);
        %Kyx = K(2, 1);
    end
    
    % The following line and lines [17, 18, 22, 23] are commented 
    % because Gx and Gy will have incompatible sizes unless m == n 
    % OR if G is a nodal operator.
    %KG = [Kxx*Gx + Kxy*Gy; Kyx*Gx + Kyy*Gy];
    KG = [Kxx*Gx; Kyy*Gy];
end
