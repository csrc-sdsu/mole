function testPoissonAccuracy ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  west = 0;
%!  east = 1;
%!
%!  ks = [2, 4, 6];
%!  grid_sizes = [20, 40];
%!
%!  for k = ks
%!    errors = zeros (size (grid_sizes));
%!
%!    for i = 1:numel (grid_sizes)
%!      m = grid_sizes (i);
%!      dx = (east - west) / m;
%!
%!      % Mimetic Laplacian operator.
%!      L = lap (k, m, dx);
%!
%!      % Impose Robin boundary conditions.
%!      a = 1;
%!      b = 1;
%!      L = L + robinBC (k, m, dx, a, b);
%!
%!      % One-dimensional staggered grid.
%!      grid = [ ...
%!          west, ...
%!          west + dx/2:dx:east - dx/2, ...
%!          east];
%!
%!      % Right-hand side.
%!      U = exp (grid)';
%!      U (1) = 0;
%!      U (end) = 2 * exp (1);
%!
%!      % Solve the linear system.
%!      computed_solution = L \ U;
%!
%!      % Compute the maximum error.
%!      analytical_solution = exp (grid);
%!      errors (i) = max ( ...
%!          abs (computed_solution' - analytical_solution));
%!    endfor
%!
%!    % Compute the observed order of accuracy.
%!    order = zeros (numel (errors) - 1, 1);
%!
%!    for i = 1:numel (errors) - 1
%!      order (i) = log2 (errors (i) / errors (i + 1));
%!
%!      assert (order (i) > k - 0.5, ...
%!              sprintf ("Poisson accuracy test failed for k = %d", k));
%!    endfor
%!  endfor
