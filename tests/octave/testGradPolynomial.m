function testGradPolynomial ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-11;
%!  x1 = 0;
%!  x2 = 1;
%!
%!  for k = ks
%!    m = 2 * k + 1;
%!    dx = (x2 - x1) / m;
%!
%!    G = grad (k, m, dx);
%!
%!    sfield = [x1, x1 + dx/2:dx:x2 - dx/2, x2]';
%!    vfield = (x1:dx:x2)';
%!
%!    approx = G * sfield .^ k;
%!    analytic = k * vfield .^ (k - 1);
%!
%!    err = approx - analytic;
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("1D gradient test failed for k = %d", k));
%!  endfor


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-11;
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
%!    G = grad2D (k, m, dx, n, dy);
%!
%!    % Staggered grid components.
%!    nodes_x = (x1:dx:x2)';
%!    nodes_y = (y1:dy:y2)';
%!    centers_x = (x1 + dx/2:dx:x2 - dx/2)';
%!    centers_y = (y1 + dy/2:dy:y2 - dy/2)';
%!
%!    % Vector field locations.
%!    [~, vfield_x] = meshgrid (centers_y, nodes_x);
%!    vfield_x = reshape (vfield_x, [], 1);
%!
%!    [vfield_y, ~] = meshgrid (nodes_y, centers_x);
%!    vfield_y = reshape (vfield_y, [], 1);
%!
%!    % Scalar field locations.
%!    [sfield_y, sfield_x] = meshgrid ( ...
%!        [y1, centers_y', y2]', ...
%!        [x1, centers_x', x2]');
%!
%!    sfield_x = reshape (sfield_x, [], 1);
%!    sfield_y = reshape (sfield_y, [], 1);
%!
%!    approx = G * (sfield_x .^ k + sfield_y .^ k);
%!
%!    analytic_x = k * vfield_x .^ (k - 1);
%!    analytic_y = k * vfield_y .^ (k - 1);
%!    analytic_combined = [analytic_x; analytic_y];
%!
%!    err = approx - analytic_combined;
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("2D gradient test failed for k = %d", k));
%!  endfor


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-11;
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
%!    G = grad3D (k, m, dx, n, dy, o, dz);
%!
%!    % Staggered grid components.
%!    nodes_x = (x1:dx:x2)';
%!    nodes_y = (y1:dy:y2)';
%!    nodes_z = (z1:dz:z2)';
%!
%!    centers_x = (x1 + dx/2:dx:x2 - dx/2)';
%!    centers_y = (y1 + dy/2:dy:y2 - dy/2)';
%!    centers_z = (z1 + dz/2:dz:z2 - dz/2)';
%!
%!    % Vector field locations.
%!    [~, vfield_x, ~] = ...
%!        meshgrid (centers_y, nodes_x, centers_z);
%!    vfield_x = reshape (vfield_x, [], 1);
%!
%!    [vfield_y, ~, ~] = ...
%!        meshgrid (nodes_y, centers_x, centers_z);
%!    vfield_y = reshape (vfield_y, [], 1);
%!
%!    [~, ~, vfield_z] = ...
%!        meshgrid (centers_y, centers_x, nodes_z);
%!    vfield_z = reshape (vfield_z, [], 1);
%!
%!    % Scalar field locations.
%!    [sfield_y, sfield_x, sfield_z] = meshgrid ( ...
%!        [y1, centers_y', y2]', ...
%!        [x1, centers_x', x2]', ...
%!        [z1, centers_z', z2]');
%!
%!    sfield_x = reshape (sfield_x, [], 1);
%!    sfield_y = reshape (sfield_y, [], 1);
%!    sfield_z = reshape (sfield_z, [], 1);
%!
%!    approx = G * ( ...
%!        sfield_x .^ k + ...
%!        sfield_y .^ k + ...
%!        sfield_z .^ k);
%!
%!    analytic_x = k * vfield_x .^ (k - 1);
%!    analytic_y = k * vfield_y .^ (k - 1);
%!    analytic_z = k * vfield_z .^ (k - 1);
%!    analytic_combined = [analytic_x; analytic_y; analytic_z];
%!
%!    err = approx - analytic_combined;
%!
%!    assert (norm (err) < tol, ...
%!            sprintf ("3D gradient test failed for k = %d", k));
%!  endfor
