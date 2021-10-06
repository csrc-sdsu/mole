function I = interpDMat(k, m)
% Interpolation function for DIV.
% Interpolates from cell centers to a staggered grid.

    x = [-fliplr(1/2:1:k/2), 1/2:1:k/2];
    C = vanderCoef(x);

    I = zeros(m+1, m+2);
    I(1, 1) = 1; I(end, end) = 1;

    switch k
        case 2
            for i = 2:m
               I(i, i:i+1) = C;
            end
            
        case 4
            for i = 3:m-1
               I(i, i-1:i+2) = C;
            end
            
            C1 = vanderCoef(0.5*[-2, -1, 1, 3, 5]);
            I(2, 1:5) = C1;
            I(end-1, end-4:end) = fliplr(C1);
            
        case 6
            for i = 4:m-2
                I(i, i-2:i+3) = C;
            end
            
            C1 = vanderCoef(0.5*[-2, -1, 1, 3, 5, 7, 9]);
            I(2, 1:7) = C1;
            I(end-1, end-6:end) = fliplr(C1);
            
            C2 = vanderCoef(0.5*[-2, -1, 1, 3, 5, 7, 9]-1);
            I(3, 1:7) = C2;
            I(end-2, end-6:end) = fliplr(C2);
    end
    I = sparse(I);
end