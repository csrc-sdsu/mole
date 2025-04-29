function B = invvander(v, m)
%INVVANDER inverse or pseudoinverse of transpose of vandermode matrix 


assert(isrow(v), 'v must be a row vector.')
assert(numel(v) == numel(unique(v)), 'all elements in the v must be distinct.')
n = numel(v);
if nargin == 1
    m = n;
else
    assert(isscalar(m), 'm must be a scalar.')
    assert(m > 0 && mod(m, 1) == 0, 'm must be a poistive integer.')
end

if m == n
    % 1-by-1 matrix
    if n == 1
        B = 1 / v;
        return;
    end
    
    p = [-v(1) 1];
    C(1) = 1;
    for i = 2:n
        p = [0, p] + [-v(i) * p, 0];
        
        Cp = C;
        C = zeros(1, i);
        for j = 1:i - 1
            C(j) = Cp(j) / (v(j) - v(i));       
        end
        C(i) = - sum(C);
    end
    
    B = zeros(n);
    c = zeros(1, n);
    
    for i = 1:n
        c(n) = 1;
        for j = n-1:-1:1
            c(j) = p(j + 1) + v(i) * c(j + 1);
        end
        B(i, :) = c * C(i);
    end
    
else
    V = (v.' .^ (0:(m - 1)));
    if m > n % over-determined
        V = V.';
    end
    [~, R] = qr(V);
    B = mldivide(R, mldivide(R', V'));
    if m < n % under-determined
        B = B.';
    end
end