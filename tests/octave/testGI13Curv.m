function testGI13Curv ()
endfunction

%!function [X, Y, Z, xc, yc, zc] = sineGrid (N, amp)
%!  [a, b, c] = meshgrid ( ...
%!      linspace (0, 1, N), ...
%!      linspace (0, 1, N), ...
%!      linspace (0, 1, N));
%!
%!  X = a + amp * sin (2 * pi * b);
%!  Y = b + amp * sin (2 * pi * a);
%!  Z = c + 0.5 * amp * sin (2 * pi * a) .* sin (2 * pi * b);
%!
%!  s = linspace (0, 1, N);
%!  s = [0, s(1:end-1) + 0.5 / (N - 1), 1];
%!
%!  [p, q, t] = meshgrid (s, s, s);
%!
%!  xc = p + amp * sin (2 * pi * q);
%!  yc = q + amp * sin (2 * pi * p);
%!  zc = t + 0.5 * amp * sin (2 * pi * p) .* sin (2 * pi * q);
%!endfunction

%!test
%!  % Check the explicit GI13 index map.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  m = 4;
%!  n = 3;
%!  o = 3;
%!
%!  [I, J, K] = ndgrid (1:m, 1:n+1, 1:o);
%!  v = I(:) + 100 * J(:) + 10000 * K(:);
%!
%!  A = GI13 (speye (m * (n + 1) * o), m, n, o, "Gn");
%!  W = reshape (A * v, m + 1, n, o);
%!
%!  bad = 0;
%!
%!  for k = 1:o
%!    for j = 1:n
%!      for i = 1:m+1
%!        val = W (i, j, k);
%!
%!        if (val == 0)
%!          continue;
%!        endif
%!
%!        kk = floor (val / 10000);
%!
%!        if (kk != k)
%!          bad = bad + 1;
%!        endif
%!      endfor
%!    endfor
%!  endfor
%!
%!  assert (bad == 0, ...
%!          sprintf ("%d of %d GI13 outputs read from the wrong zeta-plane", ...
%!                   bad, (m + 1) * n * o));


%!test
%!  % Check shapes and preservation of constant fields.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  m = 5;
%!  n = 4;
%!  o = 3;
%!
%!  %ty = {"Gn", "Gc", "Ge", "Gcy", "Gee", "Gnn"};
%!  ty = {'Gn', 'Gc', 'Ge', 'Gcy', 'Gee', 'Gnn'};
%!
%!  src = [ ...
%!      m * (n + 1) * o, ...
%!      m * n * (o + 1), ...
%!      (m + 1) * n * o, ...
%!      m * n * (o + 1), ...
%!      (m + 1) * n * o, ...
%!      m * (n + 1) * o];
%!
%!  tgt = [ ...
%!      (m + 1) * n * o, ...
%!      (m + 1) * n * o, ...
%!      m * (n + 1) * o, ...
%!      m * (n + 1) * o, ...
%!      m * n * (o + 1), ...
%!      m * n * (o + 1)];
%!
%!  for i = 1:numel (ty)
%!    clear GI13;
%!    A = GI13 (speye (src (i)), m, n, o, ty{i});
%!
%!    expectedSize = [tgt(i), src(i)];
%!    actualSize = size (A);
%!
%    fprintf ("GI13 type: %s\n", ty{i});
%    fprintf ("GI13 file: %s\n", which ("GI13"));
%    fprintf ("Actual size:   [%d %d]\n", actualSize);
%    fprintf ("Expected size: [%d %d]\n", expectedSize);
%!
%!    assert (all (actualSize == expectedSize), ...
%!            sprintf ("GI13 %s has the wrong shape", ty{i}));
%!
%!    assert (max (abs (A * ones (src(i), 1) - 1)) < 1e-12, ...
%!            sprintf ("GI13 %s does not preserve a constant", ty{i}));
%!  endfor

%!test
%!  % Check exactness on a Cartesian grid.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  for N = [11, 17, 25]
%!    [X, Y, Z, xc, yc, zc] = sineGrid (N, 0.0);
%!
%!    f = reshape ( ...
%!        permute (xc.^2 + yc.^2 + zc.^2, [2, 1, 3]), ...
%!        [], 1);
%!
%!    L = div3DCurv (2, X, Y, Z) * grad3DCurv (2, X, Y, Z);
%!
%!    v = reshape (L * f, N + 1, N + 1, N + 1);
%!    d = v (3:end-2, 3:end-2, 3:end-2);
%!    d = d(:) - 6;
%!
%!    assert (sqrt (mean (d.^2)) < 1e-9, ...
%!            sprintf ("Cartesian L = D*G is not exact at N = %d", N));
%!  endfor


%!test
%!  % Check the gradient of a linear field on a curvilinear grid.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  N = 21;
%!
%!  for amp = [0.05, 0.10]
%!    [X, Y, Z, xc, yc, zc] = sineGrid (N, amp);
%!
%!    f = reshape ( ...
%!        permute (xc + 2 * yc + 3 * zc, [2, 1, 3]), ...
%!        [], 1);
%!
%!    T = grad3DCurv (2, X, Y, Z) * f;
%!
%!    gx = T (1:N * (N - 1) * (N - 1)) - 1;
%!
%!    assert (sqrt (mean (gx.^2)) < 0.05, ...
%!            sprintf ( ...
%!                "Gradient of a linear field is badly wrong at amp = %g", ...
%!                amp));
%!  endfor


%!test
%!  % Check convergence on a curvilinear grid.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  amp = 0.10;
%!  Ns = [13, 21, 33];
%!  errs = zeros (size (Ns));
%!
%!  for i = 1:numel (Ns)
%!    N = Ns (i);
%!    [X, Y, Z, xc, yc, zc] = sineGrid (N, amp);
%!
%!    f = reshape ( ...
%!        permute (xc.^2 + yc.^2 + zc.^2, [2, 1, 3]), ...
%!        [], 1);
%!
%!    T = grad3DCurv (2, X, Y, Z) * f;
%!
%!    cx = linspace (0, 1, N);
%!    cx = cx (1:end-1) + 0.5 / (N - 1);
%!
%!    [aa, bb, ~] = meshgrid (linspace (0, 1, N), cx, cx);
%!    xf = aa + amp * sin (2 * pi * bb);
%!
%!    gx = T (1:N * (N - 1) * (N - 1));
%!    exact_gx = reshape ( ...
%!        permute (2 * xf, [2, 1, 3]), ...
%!        [], 1);
%!
%!    errs (i) = sqrt (mean ((gx - exact_gx).^2));
%!  endfor
%!
%!  p = log (errs (1) / errs (end)) / ...
%!      log ((Ns (end) - 1) / (Ns (1) - 1));
%!
%!  assert (p > 1.5, ...
%!          sprintf ( ...
%!              "Observed gradient convergence order %.2f is too low", p));
