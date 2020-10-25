function G = grad(k, m, dx, varargin)
% Returns a m+1 by m+2 one-dimensional mimetic gradient operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
    
    % Assertions:
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');
    assert(m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
    assert(nargin < 5, 'Too many input arguments.')
    
    % Dimensions of G:
    if nargin < 4
        nodal = false;
        n_rows = m+1;
        n_cols = m+2;
    else
        nodal = true;
        n_rows = m+1;
        n_cols = n_rows;
    end
    
    G = sparse(n_rows, n_cols);
    
    % Fill the middle of G -----------------------------------------------------
    if  ~nodal
        neighbors = zeros(1, k); % Bandwidth = k
        neighbors(1) = 1/2-k/2;
        len = k;
        j = 2;
    else
        neighbors = zeros(1, k+1); % Bandwidth = k+1
        neighbors(1) = -k/2;
        len = k+1;
        j = 1;
    end
    
    for i = 2 : len
        neighbors(i) = neighbors(i-1)+1;
    end
    
    % Create a k by k Vandermonde matrix based on the neighbors:
    A = vander(neighbors)';
    
    % First-order derivative
    b = zeros(len, 1);
    b(len-1) = 1;
    
    % Solve the linear system to get the coefficients
    coeffs = A\b;
    
    for i = k/2+1 : n_rows-k/2
        G(i, j:j+len-1) = coeffs;
        j = j+1;
    end
    % --------------------------------------------------------------------------
    
    % Create A -----------------------------------------------------------------
    p = k/2;
    q = k+1;
    A = sparse(p, q);
    for i = 1 : p % For each row of A
        neighbors = zeros(1, q); % k+1 points are used for the boundaries
        neighbors(1) = 1-i; % Shifting the stencil to the right
        if ~nodal
            neighbors(2) = neighbors(1)+1/2;
        else
            neighbors(2) = neighbors(1)+1;
        end
        for j = 3 : q
            neighbors(j) = neighbors(j-1)+1;
        end
        
        V = vander(neighbors)';
        b = zeros(q, 1);
        b(q-1) = 1;
        coeffs = V\b;
        A(i, 1:q) = coeffs;
    end
    % --------------------------------------------------------------------------
    
    % Insert A into G (upper-left corner of G)
    G(1:p, 1:q) = A;
    
    % Permutation matrices
    Pp = fliplr(speye(p));
    Pq = fliplr(speye(q));
    % Construct A' (lower-right corner of G)
    A = -Pp*A*Pq;
    
    % Insert A' into G
    G(n_rows-p+1:n_rows, n_cols-q+1:n_cols) = A;
    
    % Scale G
    G = 1/dx*G;
end