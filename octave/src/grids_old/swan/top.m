% PURPOSE
% Define the top boundary curve for the swan grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the top boundary of the
% swan domain for a given parameter value s.
% The boundary is defined by:
%   X = s
%   Y = 1 - 3*s + 3*s^2
% The output XY is a 1x2 vector [X Y].
%
% SYNTAX
% XY = top(s)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
function XY = top(s)
    X = s;
    Y = 1-3*s+3*s^2;
    XY = [X Y];
end