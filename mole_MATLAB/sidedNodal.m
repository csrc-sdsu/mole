function S = sidedNodal(k, m, dx, type)
% Returns a m+1 by m+1 one-dimensional sided approximation for uniformly
% spaced data points.
%
% Parameters:
%                k : Order of accuracy (only first order for now!)
%                m : Number of cells
%               dx : Step size
%             type : 'backward' or 'forward'

    if k == 1 % first-order
        if strcmp(type, 'backward')
            S = spdiags([-ones(m+1, 1) ones(m+1, 1)], [-1 0], m+1, m+1);
            S(1, end-1) = -1;
        else % forward
            % S = circshift(backward, -1) or:
            S = spdiags([-ones(m+1, 1) ones(m+1, 1)], [0 1], m+1, m+1);
            S(end, 2) = 1;
        end
        S = S/dx;
    end
end
