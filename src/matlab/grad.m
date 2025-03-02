% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

function G = grad(k, m, dx)
% Returns a m+1 by m+2 one-dimensional mimetic gradient operator
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size

    % Assertions:
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');
    assert(m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);

    G = sparse(m+1, m+2);

    switch k
        case 2
            A = [-8/3 3 -1/3];
            G(1, 1:3) = A; 
            G(end, end-2:end) = -fliplr(A);
            for i = 2:m
               G(i, i:i+1) = [-1 1];
            end

        case 4
            A = [-352/105  35/8  -35/24 21/40 -5/56; ...
                   16/105 -31/24  29/24 -3/40  1/168];
            G(1:2, 1:5) = A;
            G(m:m+1, m-2:end) = -rot90(A,2);
            for i = 3:m-1
               G(i, i-1:i+2) = [1/24 -9/8 9/8 -1/24];
            end

        case 6
            A = [-13016/3465  693/128  -385/128 693/320 -495/448  385/1152 -63/1408; ...
                    496/3465 -811/640   449/384 -29/960  -11/448   13/1152 -37/21120; ...
                     -8/385   179/1920 -153/128 381/320 -101/1344   1/128   -3/7040];
            G(1:3, 1:7) = A;
            G(m-1:m+1, m-4:end) = -rot90(A,2);
            for i = 4:m-2
                G(i, i-2:i+3) = [-3/640 25/384 -75/64 75/64 -25/384 3/640];
            end

        case 8
            A = [-182144/45045     6435/1024    -5005/1024  27027/5120  -32175/7168  25025/9216  -12285/11264  3465/13312   -143/5120; ...
                   86048/675675 -131093/107520  49087/46080 10973/76800  -4597/21504  4019/27648 -10331/168960 2983/199680 -2621/1612800; ...
                   -3776/225225    8707/107520 -17947/15360 29319/25600   -533/21504  -263/9216     903/56320  -283/66560    257/537600; ...
                      32/9009      -543/35840     265/3072  -1233/1024    8625/7168   -775/9216     639/56320  -15/13312       1/21504];
            G(1:4, 1:9) = A;
            G(m-2:m+1, m-6:end) = -rot90(A,2);
            for i = 5:m-3
                G(i, i-3:i+4) = [5/7168 -49/5120 245/3072 -1225/1024 1225/1024 -245/3072 49/5120 -5/7168];
            end
        otherwise 
            G=gradienthelper(k,m)
    end
    G = (1/dx).*G;
end
