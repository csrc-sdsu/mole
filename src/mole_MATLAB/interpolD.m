function I = interpolD(m, c)
% Returns a m+2 by m+1 one-dimensional interpolator of 2nd-order
%
% Parameters:
%               m : Number of cells
%               c : Left interpolation coeff.

    % Assertions:
    assert(m >= 4, 'm >= 4');
    assert(c >= 0 && c <= 1, '0 <= c <= 1');

    % Dimensions of I:
    n_rows = m+2;
    n_cols = m+1;
    
    I = sparse(n_rows, n_cols);
    
    I(1, 1) = 1;
    I(end, end) = 1;
    
    % Average between two continuous cells
    avg = [c 1-c];
    
    j = 1;
    for i = 2 : n_cols
        I(i, j:j+2-1) = avg;
        j = j + 1;
    end
end
