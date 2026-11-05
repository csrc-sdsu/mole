function [passed, total] = testMakeGrid()
% PURPOSE
% Test curvilinear grid construction from supplied nodal coordinates.
% SYNTAX
% [passed, total] = testMakeGrid()
% DESCRIPTION
% Constructs a sheared grid from a parameter structure, revalidates it, and
% checks its coordinates against the affine map x = xi + eta/4, y = eta.
% Returns successful and executed BIST case counts with verbose output.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    grid_test_setup();
    [passed, total] = test(mfilename('fullpath'), 'verbose');
end

%!test
%! # Construct and revalidate a curvilinear grid from supplied nodes.
%! m = 3; n = 4;
%! [Xi, Eta] = ndgrid(0:m, 0:n);
%! p = struct('m', m, 'n', n, 'topology', 'curvilinear');
%! p.nodes = struct('X', Xi + Eta/4, 'Y', Eta);
%! g = makeGrid(p);
%! g = validate_clean(g);
%! assert(g.dim, 2);
%! assert(g.topology, 'curvilinear');
%! assert(g.nodes.X, p.nodes.X);
%! assert(g.nodes.Y, p.nodes.Y);
%! [XiC, EtaC] = ndgrid(0.5:m-0.5, 0.5:n-0.5);
%! assert(g.centers.X, XiC + EtaC/4);
%! assert(g.centers.Y, EtaC);
%! [XiU, EtaU] = ndgrid(0:m, 0.5:n-0.5);
%! assert(g.faces.u.X, XiU + EtaU/4);
%! assert(g.faces.u.Y, EtaU);
%! [XiV, EtaV] = ndgrid(0.5:m-0.5, 0:n);
%! assert(g.faces.v.X, XiV + EtaV/4);
%! assert(g.faces.v.Y, EtaV);

