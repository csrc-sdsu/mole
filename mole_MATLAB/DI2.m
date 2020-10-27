function I = DI2(m, n, type)
    if strcmp(type, 'Dn')
        padm3 = spalloc(m+3, (m+1)*n, 0);
        pad1 = spalloc(1, (m+1)*n, 0);
        e = ones(m, 1);
        
        bdry = spdiags([-0.5*e -0.5*e 0.5*e 0.5*e], [0 1 m+1 m+2], m, (m+1)*n);
        
        I = [padm3; bdry; pad1];
        
        middle = spdiags([-0.25*e -0.25*e 0.25*e 0.25*e], [0 1 2*m+2 2*m+3], m, (m+1)*n);
        middle = kron(ones(n-2, 1), [pad1; middle; pad1]);
        
        j = m+4;
        for i = 1 : n-3
            % This line is too slow
            middle(j:j+m-1, :) = circshift(middle(j:j+m-1, :), i*(m+1), 2);
            j = j+m+2;
        end
        
        I = [I; middle; pad1; circshift(bdry, (m+1)*(n-2), 2); padm3];
    else
        padm2 = spalloc(m+2, (n+1)*m, 0);
        pad1 = spalloc(1, (n+1)*m, 0);
        bdry = spdiags([-0.5 0.5 -0.5 0.5], [0 1 m m+1], 1, (n+1)*m);
        
        e = ones(m-2, 1);
        middle = spdiags([-0.25*e 0.25*e -0.25*e 0.25*e], [0 2 m m+2], m-2, (n+1)*m);
        middle = kron(ones(n, 1), [pad1; bdry; middle; circshift(bdry, m-2, 2); pad1]);
        
        j = m+4;
        for i = 1 : n-1
            % This line is too slow
            middle(j:j+m-1, :) = circshift(middle(j:j+m-1, :), i*m, 2);
            j = j+m+2;
        end
        
        I = [padm2; middle; padm2];
    end
end