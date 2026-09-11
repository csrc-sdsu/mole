function Y = hmean(X)
% PURPOSE
% Returns the harmonic mean for every two pairs in a column vector
% And, Y(1) = X(1), Y(end) = X(end)
%
% DESCRIPTION
% Parameters:
%                X : Column vector
%
% SYNTAX
% Y = hmean(X)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Y = [X(1); 2*X(1:end-1).*X(2:end)./(X(1:end-1)+X(2:end)); X(end)];
end
