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

function Y = hmean(X)
% Returns the harmonic mean for every two pairs in a column vector
% And, Y(1) = X(1), Y(end) = X(end)
%
% Parameters:
%                X : Column vector

    Y = [X(1); 2*X(1:end-1).*X(2:end)./(X(1:end-1)+X(2:end)); X(end)];
end
