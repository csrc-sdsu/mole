% PURPOSE
% Define the top boundary curve for the chevron grid as a parametric map.
%
% DESCRIPTION
% This helper returns the (x,y) coordinates on the top boundary of the
% chevron domain for a given parameter value s. The x-coordinate is
% X = s. The y-coordinate is piecewise:
%   for s <= 0.5 : Y = 1 - s
%   for s >  0.5 : Y = s
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
    if s <= 0.5
        Y = 1-s;
    elseif s > 0.5
        Y = s;
    end
    XY = [X Y];
end