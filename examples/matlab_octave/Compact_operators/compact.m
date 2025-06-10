% Compact mimetic operators
% Factorizes higher order mimetic divergence or gradient operators
% STAR (D2*STAR*G2) operator has dimensions: m+1 by m+1
% Where STAR = RKD*LKG
% The logic is the same for operators in any dimension. Take into 
% account that D has null rows which results in rank deficiency, 
% ergo, all null rows must me removed to make its deficiency == 0.

close all
format rat

addpath('../../src/matlab_octave')

k = 4;
m = 2*k+1;
dx = 1;

% Factorize Divergence ----------------------------------------------------
D2 = div(2, m, dx);

DK = div(k, m, dx);

RKD = full(D2(2:end-1, :)\DK(2:end-1, :));

LKD = full(DK(2:end-1, :)/D2(2:end-1, :));

LKD(abs(LKD) < 1e-8) = 0;

spy(LKD), title(['L_' num2str(k) 'for D_2']), figure

% Factorize Gradient ------------------------------------------------------
G2 = grad(2, m, dx);

GK = grad(k, m, dx);

RKG = full(G2\GK);

LKG = full(GK/G2);

LKG(abs(LKG) < 1e-8) = 0;

spy(LKG), title(['L_' num2str(k) 'for G_2']);

STAR = RKD*LKG;
