function S = sidedNodal2D(k, m, n, dx, type)
% Returns a (m+1)(n+1) by (m+1)(n+1) matrix to perform individual (Ux or Uy) 
% sided approximations on a nodal grid of m+1 nodes by n+1 nodes. So
% in case that your staggered grid looks like the following:
%
%   *--|--*--|--*--|--*--|--*
%   |     |     |     |     |
%   -  o  -  o  -  o  -  o  -
%   |     |     |     |     |
%   *--|--*--|--*--|--*--|--*
%   |     |     |     |     |
%   -  o  -  o  -  o  -  o  -      where U is specified at (-) locations
%   |     |     |     |     |
%   *--|--*--|--*--|--*--|--*
%   |     |     |     |     |
%   -  o  -  o  -  o  -  o  -
%   |     |     |     |     |
%   *--|--*--|--*--|--*--|--*
%
% and you're interested in computing Ux then m = 4 and n = 2 (#vertical cells - 1)
%
% On the other hand, if you want to approximate Uy then m = 2 and n = 4, and
% dx should be dy (just rotate the grid 90° in your mind).
%
% Parameters:
%                k : Order of accuracy (either 1 or 2)
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%               dx : Step size along x-axis
%             type : 'backward' or 'forward'

    S = sidedNodal(k, m, dx, type);
    S = kron(speye(n+1), S);
end
