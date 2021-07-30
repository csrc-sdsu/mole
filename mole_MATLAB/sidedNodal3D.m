function S = sidedNodal3D(k, m, n, o, dx, type)
% Returns a (m+1)(n+1)(o+1) by (m+1)(n+1)(o+1) matrix to perform individual (Ux, Uy
% or Uz) sided approximations on a nodal grid of m+1 by n+1 by o+1 nodes. So
% in case that your staggered grid looks like the following:
%
%       /-----/-----/-----/-----/
%      /  |  /  |  /  |  /  |  /|
%     /-----/-----/-----/-----/ |
%    /  |  /  |  /  |  /  |  /|_|
%   |-----|-----|-----|-----| | /
%   |     |     |     |     |_|/|
%  -|  /  |  /  |  /  |  /  | / |
%   |     |     |     |     |/|_|
%   |-----|-----|-----|-----| | /
%   |     |     |     |     |_|/|
%  -|  /  |  /  |  /  |  /  | / |     where U is specified at (-) locations
%   |     |     |     |     |/|_|
%   |-----|-----|-----|-----| | /
%   |     |     |     |     |_|/
%  -|  /  |  /  |  /  |  /  | /
%   |     |     |     |     |/
%   '-----'-----'-----'-----'
%
% and you're interested in computing Ux then m = 4, n = 2 (#vertical cells - 1) and 
% o = 1 (#pages - 1)
%
% On the other hand, if you want to approximate Uy then m = 2, n = 4, and
% o = 1, and dx should be dy (just rotate the grid 90° in your mind).
%
% Parameters:
%                k : Order of accuracy (either 1 or 2)
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%                o : Number of cells along z-axis
%               dx : Step size along x-axis
%             type : 'backward' or 'forward'

    S = sidedNodal(k, m, dx, type);
    S = kron(speye(o+1), kron(speye(n+1), S));
end
