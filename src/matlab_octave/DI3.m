function I = DI3(m, n, o, type)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if strcmp(type, 'Dn')
        e = ones(m, 1);
        bdry = spdiags([-0.5*e -0.5*e 0.5*e 0.5*e], [0 1 m+1 m+2], m, (m+1)*n);
        block = spdiags([[0.25*e; 0; 0] [0.25*e; 0.25; 0]], [0 1], m+2, m+1);
        pattern = spdiags([-ones(n-2, 1) ones(n-2, 1)], [0 2], n-2, n);
        middle = kron(pattern, block);
        I = [spalloc(m+3, (m+1)*n, 0); bdry; spalloc(2, (m+1)*n, 0); middle; circshift(bdry, (m+1)*(n-2), 2); spalloc(m+3, (m+1)*n, 0)];
        I = kron(speye(o), I);
        I = [spalloc((m+2)*(n+2), size(I, 2), 0); I; spalloc((m+2)*(n+2), size(I, 2), 0)];
    elseif strcmp(type, 'De')
        e = ones(m-2, 1);
        block = spdiags([[-0.25*e; -0.25; 0] [0; 0.25*e; 0.25]], [-1 1], m+2, m);
        block(1, 1) = -0.5;
        block(1, 2) = 0.5;
        block(m, m-1) = -0.5;
        block(m, m) = 0.5;
        pattern = spdiags([ones(n, 1) ones(n, 1)], [0 1], n, n+1);
        middle = kron(pattern, block);
        I = [spalloc(m+3, (n+1)*m, 0); middle; spalloc(m+1, (n+1)*m, 0)];
        I = kron(speye(o), I);
        I = [spalloc((m+2)*(n+2), size(I, 2), 0); I; spalloc((m+2)*(n+2), size(I, 2), 0)];
    elseif strcmp(type, 'Dc')
        e = ones(m, 1);
        bdry = spdiags([0.5*e 0.5*e], [0 1], m, m+1);
        bdry = [bdry; spalloc(2, m+1, 0)];
        bdry = kron(speye(n), bdry);
        middle = kron(0.25*speye(o-2), [bdry; spalloc(2*(m+2), size(bdry, 2), 0)]);
        middle = [spalloc(2*(m+2), size(middle, 2), 0); middle];
        middle = [middle spalloc(size(middle, 1), (m+1)*n*o-size(middle, 2), 0)];
        middle = -middle + circshift(middle, 2*(m+1)*n, 2);
        bdry = [-bdry bdry spalloc(size(bdry, 1), (m+1)*n*o-2*size(bdry, 2), 0)];
        I = [spalloc((m+2)*(n+2)+m+3, size(bdry, 2), 0); bdry];
        I = [I; middle; circshift(bdry, (m+1)*n*(o-2), 2); spalloc((m+2)*(n+2)+m+1, size(bdry, 2), 0)];
    elseif strcmp(type, 'Dcc')
        e = ones(m, 1);
        bdry = spdiags(0.5*e, 0, m, m);
        bdry = [bdry; spalloc(2, m, 0)];
        I = spdiags([ones(n, 1) ones(n, 1)], [0 1], n, n+1);
        middle = kron(0.25*I, bdry);
        middle = [middle; spalloc(2*(m+2), size(middle, 2), 0)];
        middle = kron(spdiags([-ones(o-2, 1) ones(o-2, 1)], [0 2], o-2, o), middle);
        bdry = kron(I, bdry);
        bdry = [-bdry bdry spalloc(size(bdry, 1), m*(n+1)*o-2*size(bdry, 2), 0)];
        I = [spalloc((m+2)*(n+2)+m+3, size(bdry, 2), 0); bdry; spalloc(2*(m+2), size(bdry, 2), 0); middle; circshift(bdry, m*(n+1)*(o-2), 2); spalloc((m+2)*(n+2)+m+1, size(bdry, 2), 0)];
    elseif strcmp(type, 'Dee')
        e = ones(m-2, 1);
        block = spdiags([[-0.25*e; -0.25; 0] [0; 0.25*e; 0.25]], [-1 1], m+2, m);
        block(1, 1) = -0.5;
        block(1, 2) = 0.5;
        block(m, m-1) = -0.5;
        block(m, m) = 0.5;
        middle = kron(speye(n), block);
        middle = [middle; spalloc(2*(m+2), size(middle, 2), 0)];
        I = kron(spdiags([ones(o, 1) ones(o, 1)], [0 1], o, o+1), middle);
        I = [spalloc((m+2)*(n+2)+m+3, size(I, 2), 0); I; spalloc((m+2)*n+m+1, size(I, 2), 0)];
    elseif strcmp(type, 'Dnn')
        e = ones(m, 1);
        bdry = spdiags([-0.5*e 0.5*e -0.5*e 0.5*e], [0 m m*n m*n+m], m, 2*m*n);
        middle = 0.25*speye(m);
        middle = [middle; spalloc(2, m, 0)];
        middle = kron(spdiags([-ones(n-2, 1) ones(n-2, 1)], [0 2], n-2, n), middle);
        middle = [middle middle];
        I = [bdry; spalloc(2, size(bdry, 2), 0); middle; circshift(bdry, m*(n-2), 2)];
        I = I(:, 1:m*n);
        I = [I; spalloc(2*(m+2)+2, size(I, 2), 0)];
        I = kron(spdiags([ones(o, 1) ones(o, 1)], [0 1], o, o+1), I);
        I = [spalloc((m+2)*(n+2)+m+3, size(I, 2), 0); I; spalloc((m+2)*n+m+1, size(I, 2), 0)];
    end
end