% PURPOSE
% Define the bottom boundary curve for the horseshoe grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the bottom boundary of the
% horseshoe domain for a given parameter value s.
% The curve is defined using trigonometric parameterization:
%   X = 2*cos(pi/2*(1-2*s))
%   Y =   sin(pi/2*(1-2*s))
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
    X = 2*cos(pi/2*(1-2*s));
    Y = sin(pi/2*(1-2*s));
    XY = [X Y];
end