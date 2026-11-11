function testTTMGrids ()
endfunction


%!function [npos, nneg] = jacobianSigns (X, Y)
%!  state1 = warning ("off", "jacobian2D:leftHandedGrid");
%!  restore1 = onCleanup (@() warning (state1));
%!
%!  state2 = warning ("off", "jacobian2D:tangledGrid");
%!  restore2 = onCleanup (@() warning (state2));
%!
%!  d = nonzeros (jacobian2D (2, X.', Y.'));
%!  npos = sum (d > 0);
%!  nneg = sum (d < 0);
%!endfunction


%!test
%!  % Chevron and horseshoe should not be folded by TTM.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  origDir = pwd ();
%!  cleanupDir = onCleanup (@() cd (origDir));
%!
%!  srcDir = fullfile (pwd (), "..", "..", "src", "octave");
%!  addpath (srcDir, "-begin");
%!  cd (srcDir);
%!
%!  grids = {"chevron", "horseshoe"};
%!
%!  for i = 1:numel (grids)
%!    [X, Y] = ttm (grids{i}, 39, 99, 500, false);
%!    [~, nneg] = jacobianSigns (X, Y);
%!
%!    assert (nneg == 0, ...
%!            sprintf ( ...
%!                "ttm folded the %s grid: %d negative Jacobian entries", ...
%!                grids{i}, nneg));
%!  endfor


%!test
%!  % Elliptic smoothing should repair the folded swan TFI grid.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  origDir = pwd ();
%!  cleanupDir = onCleanup (@() cd (origDir));
%!
%!  srcDir = fullfile (pwd (), "..", "..", "src", "octave");
%!  addpath (srcDir, "-begin");
%!  cd (srcDir);
%!
%!  [Xt, Yt] = tfi ("swan", 39, 99, false);
%!  [~, nnegTFI] = jacobianSigns (Xt, Yt);
%!
%!  assert (nnegTFI > 0, ...
%!          "swan is expected to be folded under TFI; test premise changed");
%!
%!  [X, Y] = ttm ("swan", 39, 99, 500, false);
%!  [~, nneg] = jacobianSigns (X, Y);
%!
%!  assert (nneg == 0, ...
%!          sprintf ("ttm left swan folded: %d negative entries", nneg));


%!test
%!  % The grid should remain unfolded after only a few iterations.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  origDir = pwd ();
%!  cleanupDir = onCleanup (@() cd (origDir));
%!
%!  srcDir = fullfile (pwd (), "..", "..", "src", "octave");
%!  addpath (srcDir, "-begin");
%!  cd (srcDir);
%!
%!  iterations = [5, 25, 100];
%!
%!  for i = 1:numel (iterations)
%!    it = iterations (i);
%!    [X, Y] = ttm ("chevron", 39, 99, it, false);
%!    [~, nneg] = jacobianSigns (X, Y);
%!
%!    assert (nneg == 0, ...
%!            sprintf ( ...
%!                "ttm folded chevron after %d iterations (%d negative)", ...
%!                it, nneg));
%!  endfor


%!test
%!  % TTM should not modify boundary nodes.
%!  origPath = path ();
%!  cleanupObj = onCleanup (@() path (origPath));
%!  origDir = pwd ();
%!  cleanupDir = onCleanup (@() cd (origDir));
%!
%!  srcDir = fullfile (pwd (), "..", "..", "src", "octave");
%!  addpath (srcDir, "-begin");
%!  cd (srcDir);
%!
%!  m = 39;
%!  n = 99;
%!
%!  [X, Y] = ttm ("chevron", m, n, 50, false);
%!  [Xt, Yt] = tfi ("chevron", m, n, false);
%!
%!  assert (all (abs (X (1, :) - Xt (1, :)) <= 1e-12), ...
%!          "Lower X boundary changed");
%!  assert (all (abs (X (end, :) - Xt (end, :)) <= 1e-12), ...
%!          "Upper X boundary changed");
%!  assert (all (abs (Y (:, 1) - Yt (:, 1)) <= 1e-12), ...
%!          "Left Y boundary changed");
%!  assert (all (abs (Y (:, end) - Yt (:, end)) <= 1e-12), ...
%!          "Right Y boundary changed");
