function I = interpolFacesToCentersG1D(k, m)
% 1D interpolation from faces to centers
% centers logical coordinates [1,1.5:m-0.5,m]
% m is the number of cells in the logical x-axis
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    I = sparse(m+2, m+1);

    switch k
        case 2
            I(1, 1) = 2; I(end, end) = 2;
            for i = 2:m+1
               I(i, i-1:i) = [1 1];
            end
            denom = 2;

        case 4
            I(1, 1) = 128; I(end, end) = 128;
            A = [35 140 -70 28 -5];
            I(2, 1:5) = A;
            I(m+1, m-3:end) = fliplr(A);
            for i = 3:m
               I(i, i-2:i+1) = [-8 72 72 -8];
            end
            denom = 128;

        case 6
            I(1, 1) = 1024; I(end, end) = 1024;
            A = [231 1386 -1155  924 -495 154 -21; ... % (2,2) 1278
                 -21  378   945 -420  189 -54   7];
            I(2:3, 1:7) = A;
            I(m:m+1, m-5:end) = flipud(fliplr(A));%#ok
            for i = 4:m-1
                I(i, i-3:i+2) = [12 -100 600 600 -100 12];
            end
            denom = 1024;

        case 8
            I(1, 1) = 1; I(end, end) = 1;
            A = [6435/32768 6435/4096 -15015/8192  9009/4096 -32175/16384  5005/4096 -4095/8192  495/4096 -429/32768; ...
                 -429/32768 1287/4096   9009/8192 -3003/4096   9009/16384 -1287/4096  1001/8192 -117/4096   99/32768; ...
                   99/32768 -165/4096   3465/8192  3465/4096  -5775/16384   693/4096  -495/8192   55/4096  -45/32768];
            I(2:4, 1:9) = A;
            I(m-1:m+1, m-7:end) = flipud(fliplr(A));%#ok
            for i = 5:m-2
                I(i, i-4:i+3) = (1/2048).*[-5 49 -245 1225 1225 -245 49 -5];
            end
            denom = 1;   

    end
    I = (1/denom).*I;
end