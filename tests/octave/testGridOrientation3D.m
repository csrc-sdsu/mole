function testGridOrientation3D ()
endfunction


%!function [X, Y, Z] = sineGrid3 (N, amp)
%!  [a, b, c] = meshgrid ( ...
%!      linspace (0, 1, N), ...
%!      linspace (0, 1, N), ...
%!      linspace (0, 1, N));
%!
%!  X = a + amp * sin (2 * pi * b);
%!  Y = b + amp * sin (2 * pi * a);
%!  Z = c + 0.5 * amp * sin (2 * pi * a) .* sin (2 * pi * b);
%!endfunction


%!test
%!  % A properly oriented grid should not produce a warning.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y, Z] = sineGrid3 (13, 0.08);
%!
%!  lastwarn ("");
%!  jacobian3D (2, X, Y, Z);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (isempty (warningMessage) && isempty (warningId), ...
%!          "A right-handed grid generated an unexpected warning");


%!test
%!  % Swapping two axes should produce a left-handed-grid warning.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y, Z] = sineGrid3 (13, 0.08);
%!  Xp = permute (X, [2, 1, 3]);
%!  Yp = permute (Y, [2, 1, 3]);
%!  Zp = permute (Z, [2, 1, 3]);
%!
%!  lastwarn ("");
%!  jacobian3D (2, Xp, Yp, Zp);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, "jacobian3D:leftHandedGrid"), ...
%!          sprintf ("Unexpected warning identifier: %s", warningId));


%!test
%!  % Reversing one axis should also produce a left-handed-grid warning.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y, Z] = sineGrid3 (13, 0.08);
%!
%!  Xf = X (end:-1:1, :, :);
%!  Yf = Y (end:-1:1, :, :);
%!  Zf = Z (end:-1:1, :, :);
%!
%!  lastwarn ("");
%!  jacobian3D (2, Xf, Yf, Zf);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, "jacobian3D:leftHandedGrid"), ...
%!          sprintf ("Unexpected warning identifier: %s", warningId));


%!test
%!  % The warning should propagate through grad3DCurv and div3DCurv.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  [X, Y, Z] = sineGrid3 (13, 0.08);
%!  Xp = permute (X, [2, 1, 3]);
%!  Yp = permute (Y, [2, 1, 3]);
%!  Zp = permute (Z, [2, 1, 3]);
%!
%!  lastwarn ("");
%!  grad3DCurv (2, Xp, Yp, Zp);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, "jacobian3D:leftHandedGrid"), ...
%!          sprintf ("Unexpected gradient warning identifier: %s", warningId));
%!
%!  lastwarn ("");
%!  div3DCurv (2, Xp, Yp, Zp);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, "jacobian3D:leftHandedGrid"), ...
%!          sprintf ("Unexpected divergence warning identifier: %s", warningId));


%!test
%!  % Three identical columns create vanishing Jacobians.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  N = 21;
%!  [X, Y] = meshgrid (linspace (0, 1, N), linspace (0, 1, N));
%!
%!  X = X + 0.10 * sin (2 * pi * Y);
%!  Y = Y + 0.10 * sin (2 * pi * X);
%!
%!  X (:, 9:11) = repmat (X (:, 10), 1, 3);
%!  Y (:, 9:11) = repmat (Y (:, 10), 1, 3);
%!
%!  lastwarn ("");
%!  jacobian2D (2, X, Y);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (strcmp (warningId, "jacobian2D:vanishingJacobian"), ...
%!          sprintf ("Unexpected warning identifier: %s", warningId));


%!test
%!  % A healthy grid should not produce a vanishing-Jacobian warning.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  addpath (genpath ("../../src/octave"), "-begin");
%!
%!  N = 21;
%!  [X, Y] = meshgrid (linspace (0, 1, N), linspace (0, 1, N));
%!
%!  X = X + 0.10 * sin (2 * pi * Y);
%!  Y = Y + 0.10 * sin (2 * pi * X);
%!
%!  lastwarn ("");
%!  jacobian2D (2, X, Y);
%!  [warningMessage, warningId] = lastwarn ();
%!
%!  assert (isempty (warningMessage) && isempty (warningId), ...
%!          "A healthy grid generated an unexpected warning");
