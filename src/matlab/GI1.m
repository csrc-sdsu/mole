function I = GI1(M, m, n, type)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if strcmp(type, 'Gn')
        I = speye(n);
        I1 = speye(m+1, m);
        I1(end, end) = 1;
        I = kron(I, I1);
        I = [I sparse(size(I, 1), m)];
        I = I*M;
    else
        I = speye(n+1, n);
        I(end, end) = 1;
        I1 = speye(m, m+1);
        I = kron(I, I1);
        I = I*M;
    end
end