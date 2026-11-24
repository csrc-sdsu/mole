function testEnergy ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  % Parameters
%!  k = 4;
%!  a = -5;
%!  b = 5;
%!  m = 500;
%!  grid = linspace (a, b, m);
%!  dx = grid (2) - grid (1);
%!  tol = 1e-6;
%!
%!  % Laplacian
%!  L = lap (k, m - 2, dx);
%!
%!  % Transform the grid
%!  grid = arrayfun (@(x) x^2, grid);
%!
%!  % Potential matrix
%!  V = spdiags (grid', 0, m, m);
%!
%!  % Hamiltonian
%!  H = -0.5 * L + V;
%!
%!  % Eigenvalue computation
%!  eigval = eig (full (H));
%!  eigval = sort (eigval);
%!
%!  % Expected eigenvalue ratios
%!  expected = [1, 3, 5, 7, 9];
%!
%!  for i = 1:length (expected)
%!    error_value = abs (real (eigval (i) / eigval (1)) ...
%!                       - expected (i));
%!
%!    assert (error_value < tol, ...
%!            sprintf ("Energy test failed for k = %d", k));
%!  endfor
