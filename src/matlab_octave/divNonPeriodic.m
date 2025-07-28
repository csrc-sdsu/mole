function D = divNonPeriodic(k, m, dx)
% Returns a m+2 by m+1 one-dimensional mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % Assertions:
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');
    assert(m >= 2*k+1, ['m >= ' num2str(2*k+1) ' for k = ' num2str(k)]);

    D = sparse(m+2, m+1);

    switch k
        case 2
            for i = 2:m+1
               D(i, i-1:i) = [-1 1];
            end

        case 4
            A = [-11/12 17/24 3/8 -5/24 1/24];
            D(2, 1:5) = A;
            D(m+1, m-3:end) = -fliplr(A);
            for i = 3:m
               D(i, i-2:i+1) = [1/24 -9/8 9/8 -1/24];
            end

        case 6
            A = [-1627/1920  211/640  59/48  -235/192 91/128 -443/1920 31/960; ...
                    31/960  -687/640 129/128   19/192 -3/32    21/640  -3/640];
            D(2:3, 1:7) = A;
            D(m:m+1, m-5:end) = -rot90(A,2);
            for i = 4:m-1
                D(i, i-3:i+2) = [-3/640 25/384 -75/64 75/64 -25/384 3/640];
            end

        case 8
            A = [-1423/1792     -491/7168   7753/3072 -18509/5120  3535/1024 -2279/1024  953/1024 -1637/7168  2689/107520; ...
                  2689/107520 -36527/35840  4259/5120   6497/15360 -475/1024  1541/5120 -639/5120  1087/35840  -59/17920; ...
                   -59/17920    1175/21504 -1165/1024   1135/1024    25/3072  -251/5120   25/1024   -45/7168     5/7168];
            D(2:4, 1:9) = A;
            D(m-1:m+1, m-7:end) = -rot90(A,2);
            for i = 5:m-2
                D(i, i-4:i+3) = [5/7168 -49/5120 245/3072 -1225/1024 1225/1024 -245/3072 49/5120 -5/7168];
            end
    end
    D = (1/dx).*D;
end
