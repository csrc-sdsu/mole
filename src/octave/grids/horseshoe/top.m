% PURPOSE
% Define the top boundary curve for the horseshoe grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the top boundary of the
% horseshoe domain for a given parameter value s.
% The curve is defined using a trigonometric parameterization:
%   X = 4*cos(pi/2*(1-2*s))
%   Y = 2*sin(pi/2*(1-2*s))
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
    X = 4*cos(pi/2*(1-2*s));
    Y = 2*sin(pi/2*(1-2*s));
    XY = [X Y];
end