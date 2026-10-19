function testLapPolynomial ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-10;
%!  x1 = 0;
%!  x2 = 1;
%!
%!  for k = ks
%!    m = 2 * k + 1;
%!    dx = (x2 - x1) / m;
%!
%!    L = lap (k, m, dx);
%!
%!    sfield = [x1, x1 + dx/2:dx:x2 - dx/2, x2]';
%!
%!    approx = L * sfield .^ k;
%!    analytic = k * (k - 1) * sfield .^ (k - 2);
%!
%!    % Ignore boundary points.
%!    err = approx (2:end-1) - analytic (2:end-1);
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("1D Laplacian test failed for k = %d", k));
%!  endfor


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-10;
%!  x1 = 0;
%!  x2 = 1;
%!  y1 = 0;
%!  y2 = 1;
%!
%!  for k = ks
%!    m = 2 * k + 1;
%!    dx = (x2 - x1) / m;
%!    n = m + 2;
%!    dy = (y2 - y1) / n;
%!
%!    L = lap2D (k, m, dx, n, dy);
%!
%!    centers_x = (x1 + dx/2:dx:x2 - dx/2)';
%!    centers_y = (y1 + dy/2:dy:y2 - dy/2)';
%!
%!    [sfield_y, sfield_x] = meshgrid ( ...
%!        [y1, centers_y', y2]', ...
%!        [x1, centers_x', x2]');
%!
%!    sfield_x = reshape (sfield_x, [], 1);
%!    sfield_y = reshape (sfield_y, [], 1);
%!
%!    approx = L * (sfield_x .^ k + sfield_y .^ k);
%!
%!    analytic = ...
%!        k * (k - 1) * sfield_x .^ (k - 2) + ...
%!        k * (k - 1) * sfield_y .^ (k - 2);
%!
%!    analytic = reshape (analytic, m + 2, n + 2);
%!
%!    analytic_int = zeros (m + 2, n + 2);
%!    analytic_int (2:end-1, 2:end-1) = ...
%!        analytic (2:end-1, 2:end-1);
%!
%!    analytic_int = reshape (analytic_int, [], 1);
%!    err = approx - analytic_int;
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("2D Laplacian test failed for k = %d", k));
%!  endfor


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-10;
%!  x1 = 0;
%!  x2 = 1;
%!  y1 = 0;
%!  y2 = 1;
%!  z1 = 0;
%!  z2 = 1;
%!
%!  for k = ks
%!    m = 2 * k + 1;
%!    dx = (x2 - x1) / m;
%!    n = m + 2;
%!    dy = (y2 - y1) / n;
%!    o = n + 2;
%!    dz = (z2 - z1) / o;
%!
%!    L = lap3D (k, m, dx, n, dy, o, dz);
%!
%!    centers_x = (x1 + dx/2:dx:x2 - dx/2)';
%!    centers_y = (y1 + dy/2:dy:y2 - dy/2)';
%!    centers_z = (z1 + dz/2:dz:z2 - dz/2)';
%!
%!    [sfield_y, sfield_x, sfield_z] = meshgrid ( ...
%!        [y1, centers_y', y2]', ...
%!        [x1, centers_x', x2]', ...
%!        [z1, centers_z', z2]');
%!
%!    sfield_x = reshape (sfield_x, [], 1);
%!    sfield_y = reshape (sfield_y, [], 1);
%!    sfield_z = reshape (sfield_z, [], 1);
%!
%!    approx = L * ( ...
%!        sfield_x .^ k + ...
%!        sfield_y .^ k + ...
%!        sfield_z .^ k);
%!
%!    analytic = ...
%!        k * (k - 1) * sfield_x .^ (k - 2) + ...
%!        k * (k - 1) * sfield_y .^ (k - 2) + ...
%!        k * (k - 1) * sfield_z .^ (k - 2);
%!
%!    analytic = reshape (analytic, m + 2, n + 2, o + 2);
%!
%!    analytic_int = zeros (m + 2, n + 2, o + 2);
%!    analytic_int (2:end-1, 2:end-1, 2:end-1) = ...
%!        analytic (2:end-1, 2:end-1, 2:end-1);
%!
%!    analytic_int = reshape (analytic_int, [], 1);
%!    err = approx - analytic_int;
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("3D Laplacian test failed for k = %d", k));
%!  endfor
