function Q = weightsQ2D(m, n, d)
% Returns the (m+2)(n+2) weights of Q in 2-D
%
% Parameters:
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%                d : Step size (assuming d = dx = dy)
%
% Only works for 2nd-order 2-D Mimetic divergence operator
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Q = d*ones((m+2)*(n+2), 1);
end
