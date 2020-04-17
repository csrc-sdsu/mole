function KG = tensorGrad2D(K, G)
% Returns a two-dimensional flux operator
%
% Parameters:
%                K : Tensor (e.g. diffusion tensor)
%                G : 2D mimetic gradient operator

    rowsGx = find(G(:, 2), 1)-1;
    rowsGy = size(G, 1)-rowsGx;
    
    Gx = G(1:rowsGx, :);
    Gy = G(rowsGx+1:end, :);
    
    if size(K, 1) ~= 2
        Kxx = spdiags(cell2mat(K(1)), 0, rowsGx, rowsGx);
        Kyy = spdiags(cell2mat(K(2)), 0, rowsGy, rowsGy);
        %Kxy = spdiags(cell2mat(K(3)), 0, rowsGy, rowsGy);
        %Kyx = spdiags(cell2mat(K(4)), 0, rowsGx, rowsGx);
    else
        Kxx = K(1, 1);
        Kyy = K(2, 2);
        %Kxy = K(1, 2);
        %Kyx = K(2, 1);
    end
    
    %KG = [Kxx*Gx + Kxy*Gy; Kyx*Gx + Kyy*Gy];
    KG = [Kxx*Gx; Kyy*Gy];
end