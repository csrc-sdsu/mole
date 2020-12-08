function D = div3DCurv_(k, X, Y, Z)
% Returns a three-dimensional curvilinear mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates of meshgrid
%                Y : y-coordinates of meshgrid
%                Z : z-coordinates of meshgrid

    [n, m, o] = size(X);
    n = n-1;
    m = m-1;
    o = o-1;
    
    Ux = (X(1:end-1, :, :) + X(2:end, :, :))/2;
    Ux = (Ux(:, :, 1:end-1) + Ux(:, :, 2:end))/2;
    Vy = (Y(:, 1:end-1, :) + Y(:, 2:end, :))/2;
    Vy = (Vy(:, :, 1:end-1) + Vy(:, :, 2:end))/2;
    Wz = (Z(1:end-1, :, :) + Z(2:end, :, :))/2;
    Wz = (Wz(:, 1:end-1, :) + Wz(:, 2:end, :))/2;
    
    Ux_ = reshape(permute(Ux, [2, 1, 3]), [], 1, 1);
    Vy_ = reshape(permute(Vy, [2, 1, 3]), [], 1, 1);
    Wz_ = reshape(permute(Wz, [2, 1, 3]), [], 1, 1);
    
    D_ = div3D(k, m, 1, n, 1, o, 1);
    off1 = (m+1)*n*o;
    off2 = m*(n+1)*o;
    De = D_(:, 1:off1);
    D_ = D_(:, off1+1:end);
    Dn = D_(:, 1:off2);
    Dc = D_(:, off2+1:end);
    
    Dex = spdiags((De*Ux_).^-1, 0, size(De, 1), size(De, 1));
    Sx = Dex*De;
    
    Dny = spdiags((Dn*Vy_).^-1, 0, size(Dn, 1), size(Dn, 1));
    Sy = Dny*Dn;
    
    Dcz = spdiags((Dc*Wz_).^-1, 0, size(Dc, 1), size(Dc, 1));
    Sz = Dcz*Dc;
    
    D = [Sx Sy Sz];
end
