% PURPOSE
% Define the right boundary curve for the swan grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the right boundary of the
% swan domain for a given parameter value s.
% The boundary is defined by:
%   X = 1 + 2*s - 2*s^2
%   Y = s
% The output XY is a 1x2 vector [X Y].
%
% SYNTAX
% XY = right(s)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
function XY = right(s)
    X = 1+2*s-2*s^2;
    Y = s;
    XY = [X Y];
end