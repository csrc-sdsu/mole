function testGradient ()
endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!
%!  addpath (genpath ("../../src/octave"));
%!
%!  ks = [2, 4, 6, 8];
%!  tol = 1e-10;
%!
%!  for k = ks
%!    m = 2*k + 1;
%!    dx = 1/m;
%!
%!    G = grad (k, m, dx);
%!    field = ones (m + 2, 1);
%!    sol = G * field;
%!
%!    assert (norm (sol) < tol, ...
%!            sprintf ("Nullity test failed for k = %d", k));
%!  endfor
