% generates a comma-delimited file for weights used by MOLE libray
clc
close all

% Used to specify the number of grid points to calculate weights for
m_cnt = 25;
decimal_positions = 9;

mkdir('../dat');

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
