
%! test
%! # validateGridCurvLinear
%! g = struct();
%! g.m = m - 1;   % cell count = node count - 1
%! g.n = n - 1;
%! g.type = 'curvilinear';
%! g.nodes.X = X';   % (m+1) × (n+1) node array, transposed to ndgrid layout
%! g.nodes.Y = Y';
%! g = validateGrid(g);