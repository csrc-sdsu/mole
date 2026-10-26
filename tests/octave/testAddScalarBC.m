function testAddScalarBC ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 2;
%!  dx = 0.1;
%!  m = 8;
%!  tol = 1e-10;
%!
%!  A = rand (m + 2);
%!  b = rand (m + 2, 1);
%!  v = [7; 8];
%!
%!  % No boundary conditions
%!  dc0 = [0; 0];
%!  nc0 = [0; 0];
%!  [A0, b0] = addScalarBC1D (A, b, k, m, dx, dc0, nc0, v);
%!
%!  assert (isequal (A0, A), ...
%!          "Matrix A with no boundary conditions does not match");
%!  assert (isequal (b0, b), ...
%!          "Vector b with no boundary conditions does not match");
%!
%!  % Boundary conditions
%!  dc1 = [2; 3];
%!  nc1 = [4; 5];
%!  [A1, b1] = addScalarBC1D (A, b, k, m, dx, dc1, nc1, v);
%!
%!  A_ref = A;
%!  b_ref = b;
%!  A_ref (1, :) = 0;
%!  A_ref (end, :) = 0;
%!  b_ref (1) = 0;
%!  b_ref (end) = 0;
%!
%!  G = grad (k, m, dx);
%!
%!  Al = zeros (m + 2);
%!  Al (1, 1) = dc1 (1);
%!  Bl = zeros (m + 2, m + 1);
%!  Bl (1, 1) = -nc1 (1);
%!
%!  Ar = zeros (m + 2);
%!  Ar (end, end) = dc1 (2);
%!  Br = zeros (m + 2, m + 1);
%!  Br (end, end) = nc1 (2);
%!
%!  A_ref = A_ref + (Al + Bl * G) + (Ar + Br * G);
%!  b_ref (1) = v (1);
%!  b_ref (end) = v (2);
%!
%!  assert (all (abs (A1(:) - A_ref(:)) <= tol), ...
%!          "Matrix A with boundary conditions does not match");
%!  assert (all (abs (b1(:) - b_ref(:)) <= tol), ...
%!          "Vector b with boundary conditions does not match");


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 2;
%!  dx = 0.1;
%!  dy = 0.1;
%!  m = 8;
%!  n = m + 2;
%!  tol = 1e-10;
%!
%!  A = rand ((m + 2) * (n + 2));
%!  b = rand ((m + 2) * (n + 2), 1);
%!
%!  bclr = 4 * ones (n, 1);
%!  bcbt = 5 * ones (m + 2, 1);
%!  v = {bclr; bclr; bcbt; bcbt};
%!
%!  % No boundary conditions
%!  dc0 = [0; 0; 0; 0];
%!  nc0 = [0; 0; 0; 0];
%!
%!  [A0, b0] = addScalarBC2D ( ...
%!      A, b, k, m, dx, n, dy, dc0, nc0, v);
%!
%!  assert (isequal (A0, A), ...
%!          "Matrix A with no boundary conditions does not match");
%!  assert (isequal (b0, b), ...
%!          "Vector b with no boundary conditions does not match");
%!
%!  % Boundary conditions
%!  A = rand ((m + 2) * (n + 2));
%!  b = rand ((m + 2) * (n + 2), 1);
%!
%!  dc1 = [2; 3; 4; 5];
%!  nc1 = [6; 7; 8; 9];
%!
%!  [A1, b1] = addScalarBC2D ( ...
%!      A, b, k, m, dx, n, dy, dc1, nc1, v);
%!
%!  A_ref = A;
%!  b_ref = b;
%!
%!  Gx = grad (k, m, dx);
%!  In = eye (n + 2);
%!  In (1, 1) = 0;
%!  In (end, end) = 0;
%!
%!  Al = zeros (m + 2, m + 2);
%!  Al (1, 1) = dc1 (1);
%!  Bl = zeros (m + 2, m + 1);
%!  Bl (1, 1) = -nc1 (1);
%!
%!  Ar = zeros (m + 2, m + 2);
%!  Ar (end, end) = dc1 (2);
%!  Br = zeros (m + 2, m + 1);
%!  Br (end, end) = nc1 (2);
%!
%!  Al = Al + Bl * Gx;
%!  Ar = Ar + Br * Gx;
%!  Abclr = kron (In, Al + Ar);
%!  [bcrowslr, ~, ~] = find (Abclr);
%!
%!  Gy = grad (k, n, dy);
%!  Im = eye (m + 2);
%!
%!  Ab = zeros (n + 2, n + 2);
%!  Ab (1, 1) = dc1 (3);
%!  Bb = zeros (n + 2, n + 1);
%!  Bb (1, 1) = -nc1 (3);
%!
%!  At = zeros (n + 2, n + 2);
%!  At (end, end) = dc1 (4);
%!  Bt = zeros (n + 2, n + 1);
%!  Bt (end, end) = nc1 (4);
%!
%!  Ab = Ab + Bb * Gy;
%!  At = At + Bt * Gy;
%!  Abcbt = kron (Ab + At, Im);
%!  [bcrowsbt, ~, ~] = find (Abcbt);
%!
%!  bcrows = unique ([bcrowslr; bcrowsbt]);
%!  A_ref (bcrows, :) = 0;
%!  A_ref = A_ref + Abclr + Abcbt;
%!
%!  b_ref = reshape (b_ref, m + 2, n + 2);
%!  b_ref (1, 2:n+1) = bclr;
%!  b_ref (end, 2:n+1) = bclr;
%!  b_ref (1:m+2, 1) = bcbt;
%!  b_ref (1:m+2, end) = bcbt;
%!  b_ref = reshape (b_ref, [], 1);
%!
%!  assert (all (abs (A1(:) - A_ref(:)) <= tol), ...
%!          "Matrix A with boundary conditions does not match");
%!  assert (all (abs (b1(:) - b_ref(:)) <= tol), ...
%!          "Vector b with boundary conditions does not match");


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"));
%!
%!  k = 2;
%!  dx = 0.1;
%!  dy = 0.1;
%!  dz = 0.1;
%!  m = 8;
%!  n = m + 2;
%!  o = n + 2;
%!  tol = 1e-10;
%!
%!  A = rand ((m + 2) * (n + 2) * (o + 2));
%!  b = rand ((m + 2) * (n + 2) * (o + 2), 1);
%!
%!  bclr = 4 * ones (n * o, 1);
%!  bcbt = 5 * ones ((m + 2) * o, 1);
%!  bcfz = 6 * ones ((m + 2) * (n + 2), 1);
%!
%!  v = {bclr; bclr; bcbt; bcbt; bcfz; bcfz};
%!
%!  % No boundary conditions
%!  dc0 = zeros (6, 1);
%!  nc0 = zeros (6, 1);
%!
%!  [A0, b0] = addScalarBC3D ( ...
%!      A, b, k, m, dx, n, dy, o, dz, dc0, nc0, v);
%!
%!  assert (isequal (A0, A), ...
%!          "Matrix A with no boundary conditions does not match");
%!  assert (isequal (b0, b), ...
%!          "Vector b with no boundary conditions does not match");
%!
%!  % Boundary conditions
%!  A = rand ((m + 2) * (n + 2) * (o + 2));
%!  b = rand ((m + 2) * (n + 2) * (o + 2), 1);
%!
%!  dc1 = [2; 3; 4; 5; 6; 7];
%!  nc1 = [8; 9; 10; 11; 12; 13];
%!
%!  [A1, b1] = addScalarBC3D ( ...
%!      A, b, k, m, dx, n, dy, o, dz, dc1, nc1, v);
%!
%!  A_ref = A;
%!  b_ref = b;
%!
%!  Gx = grad (k, m, dx);
%!  Gy = grad (k, n, dy);
%!  Gz = grad (k, o, dz);
%!
%!  Im = eye (m + 2);
%!
%!  In = eye (n + 2);
%!  In (1, 1) = 0;
%!  In (end, end) = 0;
%!
%!  Io = eye (o + 2);
%!  Io (1, 1) = 0;
%!  Io (end, end) = 0;
%!
%!  Al = zeros (m + 2, m + 2);
%!  Al (1, 1) = dc1 (1);
%!  Bl = zeros (m + 2, m + 1);
%!  Bl (1, 1) = -nc1 (1);
%!
%!  Ar = zeros (m + 2, m + 2);
%!  Ar (end, end) = dc1 (2);
%!  Br = zeros (m + 2, m + 1);
%!  Br (end, end) = nc1 (2);
%!
%!  Al = Al + Bl * Gx;
%!  Ar = Ar + Br * Gx;
%!  Abclr = kron (kron (Io, In), Al + Ar);
%!  [bcrowslr, ~, ~] = find (Abclr);
%!
%!  Ab = zeros (n + 2, n + 2);
%!  Ab (1, 1) = dc1 (3);
%!  Bb = zeros (n + 2, n + 1);
%!  Bb (1, 1) = -nc1 (3);
%!
%!  At = zeros (n + 2, n + 2);
%!  At (end, end) = dc1 (4);
%!  Bt = zeros (n + 2, n + 1);
%!  Bt (end, end) = nc1 (4);
%!
%!  Ab = Ab + Bb * Gy;
%!  At = At + Bt * Gy;
%!  Abcbt = kron (kron (Io, Ab + At), Im);
%!  [bcrowsbt, ~, ~] = find (Abcbt);
%!
%!  Af = zeros (o + 2, o + 2);
%!  Af (1, 1) = dc1 (5);
%!  Bf = zeros (o + 2, o + 1);
%!  Bf (1, 1) = -nc1 (5);
%!
%!  Az = zeros (o + 2, o + 2);
%!  Az (end, end) = dc1 (6);
%!  Bz = zeros (o + 2, o + 1);
%!  Bz (end, end) = nc1 (6);
%!
%!  Af = Af + Bf * Gz;
%!  Az = Az + Bz * Gz;
%!
%!  In (1, 1) = 1;
%!  In (end, end) = 1;
%!
%!  Abcfz = kron (kron (Af + Az, In), Im);
%!  [bcrowsfz, ~, ~] = find (Abcfz);
%!
%!  bcrows = unique ([bcrowslr; bcrowsbt; bcrowsfz]);
%!  A_ref (bcrows, :) = 0;
%!  A_ref = A_ref + Abclr + Abcbt + Abcfz;
%!
%!  b_ref (1:(m + 2) * (n + 2)) = bcfz;
%!  b_ref (end - (m + 2) * (n + 2) + 1:end) = bcfz;
%!
%!  b_ref = reshape (b_ref, m + 2, n + 2, o + 2);
%!
%!  for i = 1:o
%!    b_ref (1, 2:n+1, i+1) = ...
%!        bclr ((i-1) * n + 1:i * n);
%!    b_ref (end, 2:n+1, i+1) = ...
%!        bclr ((i-1) * n + 1:i * n);
%!
%!    b_ref (1:m+2, 1, i+1) = ...
%!        bcbt ((i-1) * (m+2) + 1:i * (m+2));
%!    b_ref (1:m+2, end, i+1) = ...
%!        bcbt ((i-1) * (m+2) + 1:i * (m+2));
%!  endfor
%!
%!  b_ref = reshape (b_ref, [], 1);
%!
%!  assert (all (abs (A1(:) - A_ref(:)) <= tol), ...
%!          "Matrix A with boundary conditions does not match");
%!  assert (all (abs (b1(:) - b_ref(:)) <= tol), ...
%!          "Vector b with boundary conditions does not match");
