function I = DI2(m, n, type)
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
    else
        e = ones(m-2, 1);
        block = spdiags([[-0.25*e; -0.25; 0] [0; 0.25*e; 0.25]], [-1 1], m+2, m);
        block(1, 1) = -0.5;
        block(1, 2) = 0.5;
        block(m, m-1) = -0.5;
        block(m, m) = 0.5;
        pattern = spdiags([ones(n, 1) ones(n, 1)], [0 1], n, n+1);
        middle = kron(pattern, block);
        I = [spalloc(m+3, (n+1)*m, 0); middle; spalloc(m+1, (n+1)*m, 0)];
    end
end
