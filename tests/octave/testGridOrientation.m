function testGridOrientation ()
endfunction


%!function [X, Y] = sineGrid (N, amp)
%!  [X, Y] = meshgrid (linspace (0, 1, N), linspace (0, 1, N));
%!  X = X + amp * sin (2 * pi * Y);
%!  Y = Y + amp * sin (2 * pi * X);
%!endfunction


%!function assertWarningId (f, expectedId)
%!  lastwarn ("");
%!  f ();
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, expectedId), ...
%!          sprintf ("Expected warning %s, received %s", ...
%!                   expectedId, warningId));
%!endfunction


%!function assertNoWarning (f)
%!  lastwarn ("");
%!  f ();
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (isempty (warningMessage) && isempty (warningId), ...
%!          "An unexpected warning was generated");
%!endfunction


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y] = sineGrid (21, 0.10);
%!  assertNoWarning (@() jacobian2D (2, X, Y));


%!test
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y] = sineGrid (21, 0.10);
%!  assertWarningId (@() jacobian2D (2, X.', Y.'), ...
%!                   "jacobian2D:leftHandedGrid");


%!test
%!  % gridGen adds grid curve directories relative to src/octave.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  origDir = pwd ();
%!  cleanupDir = onCleanup (@() cd (origDir));
%!
%!  srcDir = fullfile (pwd (), "..", "..", "src", "octave");
%!  addpath (srcDir, "-begin");
%!  cd (srcDir);
%!
%!  [X, Y] = gridGen ("TFI", "chevron", 39, 99, false);
%!
%!  assert (! isempty (strfind (which ("right"), "chevron")), ...
%!          "The chevron curve functions are not on the path");
%!
%!  assertWarningId (@() jacobian2D (2, X, Y), ...
%!                   "jacobian2D:leftHandedGrid");
%!
%!  assertNoWarning (@() jacobian2D (2, X.', Y.'));


%!test
%!  % The two orientations have identical absolute Jacobian magnitudes.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y] = sineGrid (21, 0.10);
%!
%!  warning ("off", "jacobian2D:leftHandedGrid");
%!  restoreWarn = onCleanup ( ...
%!      @() warning ("on", "jacobian2D:leftHandedGrid"));
%!
%!  a = sort (abs (nonzeros (jacobian2D (2, X, Y))));
%!  b = sort (abs (nonzeros (jacobian2D (2, X.', Y.'))));
%!
%!  assert (all (abs (a - b) <= 1e-12), ...
%!          "Jacobian magnitudes differ between orientations");


%!test
%!  % A folded mesh has mixed-sign Jacobians.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y] = meshgrid (linspace (0, 1, 15), ...
%!                     linspace (0, 1, 15));
%!
%!  X (6:10, 6:10) = X (6:10, 6:10) - 0.45;
%!
%!  assertWarningId (@() jacobian2D (2, X, Y), ...
%!                   "jacobian2D:tangledGrid");


%!test
%!  % Warnings propagate through grad2DCurv and div2DCurv.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y] = sineGrid (21, 0.10);
%!
%!  assertWarningId (@() grad2DCurv (2, X.', Y.'), ...
%!                   "jacobian2D:leftHandedGrid");
%!
%!  assertWarningId (@() div2DCurv (2, X.', Y.'), ...
%!                   "jacobian2D:leftHandedGrid");


%!test
%!  % Check the five-argument jacobian2D path.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  N = 21;
%!  dc = [1; 1; 1; 1];
%!  nc = [0; 0; 0; 0];
%!
%!  s = linspace (0, 1, N);
%!  s = [0, s(1:end-1) + 0.5 / (N - 1), 1];
%!
%!  [X, Y] = meshgrid (s, s);
%!  X = X + 0.08 * sin (2 * pi * Y);
%!  Y = Y + 0.08 * sin (2 * pi * X);
%!
%!  assertNoWarning (@() jacobian2D (2, X, Y, dc, nc));
%!
%!  assertWarningId (@() jacobian2D (2, X.', Y.', dc, nc), ...
%!                   "jacobian2D:leftHandedGrid");
