function I = interpolCentersToFacesD1D(k, m)
% 1D interpolation from centers to faces.
% logical centers are [1 1.5 2.5 ... m-1.5 m-0.5 m]
% m is the number of cells in the logic x-axis
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    I = sparse(m+1, m+2);

    switch k
        case 2
            I(1, 1) = 2; I(end, end) = 2;
            for i = 2:m
               I(i, i:i+1) = [1 1];
            end
            denom = 2;

        case 4
            I(1, 1) = 112; I(end, end) = 112;
            A = [-16 70 70 -14 2];
            I(2, 1:5) = A;
            I(m, m-2:end) = fliplr(A);
            for i = 3:m-1
               I(i, i-1:i+2) = [-7 63 63 -7];
            end
            denom = 112;

        case 6
            I(1, 1) = 8448; I(end, end) = 8448;
            A = [-768 4158 6930 -2772  1188 -330  42; ...
                  256 -924 4620  5544 -1320  308 -36];
            I(2:3, 1:7) = A;
            I(m-1:m, m-4:end) = flipud(fliplr(A));%#ok
            for i = 4:m-2
                I(i, i-2:i+3) = [99 -825 4950 4950 -825 99];
            end
            denom = 8448;

        case 8
            I(1, 1) = 1; I(end, end) = 1;
            A = [-1/15  429/1024 1001/1024 -3003/5120  429/1024 -715/3072  91/1024   -21/1024  11/5120; ...
                  1/65  -33/512   231/512   2079/2560 -165/512    77/512  -27/512     77/6656  -3/2560; ...
                 -1/143  27/1024 -105/1024   567/1024  675/1024 -175/1024 567/11264 -135/13312  1/1024];
            I(2:4, 1:9) = A;
            I(m-2:m, m-6:end) = flipud(fliplr(A));%#ok
            for i = 5:m-3
                I(i, i-3:i+4) = (1/2048).*[-5 49 -245 1225 1225 -245 49 -5];
            end
            denom = 1;   

    end
    I = (1/denom).*I;
end