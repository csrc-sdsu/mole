% PURPOSE
% Define the bottom boundary curve for the swan grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the bottom boundary of the
% swan domain for a given parameter value s.
% The x-coordinate is X = s and the y-coordinate is fixed at Y = 0.
% The output XY is a 1x2 vector [X Y].
%
% SYNTAX
% XY = bottom(s)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
function XY = bottom(s)
    X = s;
    Y = 0;
    XY = [X Y];
end