function testBCConsistency ()
endfunction


%!test
%!  % 1D Boundary Conditions Consistency Test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 4;
%!  m = 50;
%!  dx = 0.314;
%!
%!  % Dirichlet-Dirichlet Boundary Conditions
%!  RBC = robinBC (k, m, dx, 1, 0);
%!  MBC = mixedBC (k, m, dx, "Dirichlet", 1, "Dirichlet", 1);
%!
%!  assert (isequal (RBC (1), MBC (1)), ...
%!          "1D Dirichlet BCs do not match at west boundary");
%!  assert (isequal (RBC (end), MBC (end)), ...
%!          "1D Dirichlet BCs do not match at east boundary");
%!
%!  % Neumann-Neumann Boundary Conditions
%!  RBC = robinBC (k, m, dx, 0, 2);
%!  MBC = mixedBC (k, m, dx, "Neumann", 2, "Neumann", 2);
%!
%!  assert (isequal (RBC (1, :), MBC (1, :)), ...
%!          "1D Neumann BCs do not match at west boundary");
%!  assert (isequal (RBC (end, :), MBC (end, :)), ...
%!          "1D Neumann BCs do not match at east boundary");
%!
%!  % Robin-Robin Boundary Conditions
%!  RBC = robinBC (k, m, dx, 3, 4);
%!  MBC = mixedBC (k, m, dx, "Robin", [3, 4], ...
%!                 "Robin", [3, 4]);
%!
%!  assert (isequal (RBC (1, :), MBC (1, :)), ...
%!          "1D Robin BCs do not match at west boundary");
%!  assert (isequal (RBC (end, :), MBC (end, :)), ...
%!          "1D Robin BCs do not match at east boundary");
%!
%!  % Mixed Robin Boundary Conditions
%!  RBC2 = robinBC (k, m, dx, 5, 6);
%!  MBC = mixedBC (k, m, dx, "Robin", [3, 4], ...
%!                 "Robin", [5, 6]);
%!
%!  assert (isequal (RBC (1, :), MBC (1, :)), ...
%!          "1D mixed Robin BCs do not match at west boundary");
%!  assert (isequal (RBC2 (end, :), MBC (end, :)), ...
%!          "1D mixed Robin BCs do not match at east boundary");


%!test
%!  % 2D Boundary Conditions Consistency Test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 4;
%!  m = 50;
%!  n = 73;
%!  dx = 0.314;
%!  dy = 0.123;
%!
%!  RBC = robinBC2D (k, m, dx, n, dy, 3, 4);
%!
%!  MBC = mixedBC2D ( ...
%!      k, m, dx, n, dy, ...
%!      "Robin", [3, 4], ...
%!      "Robin", [3, 4], ...
%!      "Robin", [3, 4], ...
%!      "Robin", [3, 4]);
%!
%!  assert (isequal (RBC, MBC), ...
%!          "2D Robin BCs are not consistent");


%!test
%!  % 3D Boundary Conditions Consistency Test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 4;
%!  m = 50;
%!  n = 73;
%!  o = 18;
%!  dx = 0.314;
%!  dy = 0.123;
%!  dz = 0.198;
%!
%!  RBC = robinBC3D (k, m, dx, n, dy, o, dz, 6, 7);
%!
%!  MBC = mixedBC3D ( ...
%!      k, m, dx, n, dy, o, dz, ...
%!      "Robin", [6, 7], ...
%!      "Robin", [6, 7], ...
%!      "Robin", [6, 7], ...
%!      "Robin", [6, 7], ...
%!      "Robin", [6, 7], ...
%!      "Robin", [6, 7]);
%!
%!  assert (isequal (RBC, MBC), ...
%!          "3D Robin BCs are not consistent");
