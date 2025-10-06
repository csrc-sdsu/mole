% Generates a comma-delimited file for weights used by MOLE libray
% Note: These weights are generated assuming dx = 1.0.  To use them they
% should be multiplied by dx for the problem being computed.
%
% Parameters:
%   None
%
% Returns:
%   None
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
clc
close all

% Used to specify the number of grid points to calculate weights for
m_cnt = 25;
decimal_positions = 9;
dx = 1.0;

% Make a folder for data files under the src root
warning("off","all");
mkdir('../dat');
warning("on","all");

% Generate P weights
fid = fopen('../dat/pweights.csv','wt');
for i = 1:3
    k = 2*i;
    j = 2*k+1;
    m_max = j + m_cnt;
    for m = j:m_max 
        P = weightsP(k, m, dx);
        out = string(k) + ',' + string(m) + ',' + strjoin(compose("%."+string(decimal_positions)+"f",P),",") + '\n';
        fprintf(fid, out);
    end;
end;
fclose(fid);

% Generate Q weights
fid = fopen('../dat/qweights.csv','wt');
for i = 1:3
    k = 2*i;
    j = 2*k+1;
    m_max = j + m_cnt;
    for m = j:m_max 
        Q = weightsQ(k, m, dx);
        out = string(k) + ',' + string(m) + ',' + strjoin(compose("%."+string(decimal_positions)+"f",Q),",") + '\n';
        fprintf(fid, out);
    end;
end;
fclose(fid);
