function I = GI2(M, m, n, type)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if strcmp(type, 'Gn')
        I = zeros(4*n*(m-1)+12*n, 1);
        J = I;
        V = J;
        k = 1;
        kt = 4*(m-1)-1;
        
        for idx = 0 : n-1
            i = idx*(m+1);
            j = idx*m;
            
            I(k:k+kt, 1) = [i+2:i+m   i+2:i+m i+2:i+m i+2:i+m];
            J(k:k+kt, 1) = [j+1:j+m-1 j+2:j+m j+m+1:j+2*m-1 j+m+2:j+2*m];
            V(k:k+kt, 1) = .25;
            
            k = k+kt+1;
        end
        
        for idx = 0 : n-1
            i = idx*(m+1);
            j = idx*m;
            
            I(k:k+5, 1) = [i+1 i+1 i+1 i+1 i+1 i+1];
            J(k:k+5, 1) = [j+1 j+2 j+3 j+m+1 j+m+2 j+m+3];
            V(k:k+5, 1) = [.5 .25 -.25 .5 .25 -.25];
            k = k+6;
            
            I(k:k+5, 1) = [i+m+1 i+m+1 i+m+1 i+m+1 i+m+1 i+m+1];
            J(k:k+5, 1) = [j+m-2 j+m-1 j+m j+2*m-2 j+2*m-1 j+2*m];
            V(k:k+5, 1) = [-.25 .25 .5 -.25 .25 .5];
            k = k+6;
        end
        
        I = sparse(I, J, V)*M;
    else
        I = zeros(4*m*(n-1)+12*m, 1);
        J = I;
        V = J;
        k = 1;
        kt = 4*m;
        
        jt = 1;
        it = m;
        
        for idx = 0 : n-2
            ib = it+1;
            it = ib+m-1;
            jb = jt;
            jt = jb+m+1;
            
            I(k:kt) = [ib:it ib:it ib:it ib:it];
            J(k:kt) = [jb:jt-2 jb+1:jt-1 jt:jt+m-1 jt+1:jt+m];
            V(k:kt) = .25;
            
            k = kt+1;
            kt = kt+4*m;
        end
        
        ib = 1;
        it = m;
        kt = k+6*m-1;
        jb = 1;
        jm = m+2;
        jt = 2*m+3;
        
        E = ones(m, 1);
        
        I(k:kt) = [ib:it ib:it ib:it ib:it ib:it ib:it];
        J(k:kt) = [jb:jm-2 jb+1:jm-1 jm:jt-2 jm+1:jt-1 jt:jt+m-1 jt+1:jt+m];
        V(k:kt) = [.5*E .5*E .25*E .25*E -.25*E -.25*E];
        
        ib = n*m+1;
        it = ib+m-1;
        jb = (n-3) * (m+1)+1;
        jm = jb+m+1;
        jt = jm+m+1;
        k = kt+1;
        kt = k+6*m-1;
        
        I(k:kt) = [ib:it ib:it ib:it ib:it ib:it ib:it];
        J(k:kt) = [jb:jm-2 jb+1:jm-1 jm:jt-2 jm+1:jt-1 jt:jt+m-1 jt+1:jt+m];
        V(k:kt) = [-.25*E -.25*E .25*E .25*E .5*E .5*E];
        
        I = sparse(I, J, V)*M;
    end
end