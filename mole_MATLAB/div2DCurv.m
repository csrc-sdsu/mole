function D = div2DCurv(k, X, Y)
% Returns a two-dimensional curvilinear mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates of meshgrid
%                Y : y-coordinates of meshgrid

    [n, m] = size(X);
    n = n-1;
    m = m-1;
    
    Ux = (X(1:end-1, :) + X(2:end, :))/2;
    Vy = (Y(:, 1:end-1) + Y(:, 2:end))/2;
    
    Ux_ = reshape(Ux.', [], 1);
    Vy_ = reshape(Vy.', [], 1);
    
    D_ = div2D(k, m, 1, n, 1);
    De = D_(:, 1:n*(m+1));
    Dn = D_(:, n*(m+1)+1:end);
    
    Dex = spdiags((De*Ux_).^-1, 0, (m+2)*(n+2),...
                                   (m+2)*(n+2));
    Sx = Dex*De;
    
    Dny = spdiags((Dn*Vy_).^-1, 0, (m+2)*(n+2),...
                                   (m+2)*(n+2));
    Sy = Dny*Dn;
    
    D = [Sx Sy];
end