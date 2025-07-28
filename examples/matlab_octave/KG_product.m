% Tests flux operator 'KG' aka tensor times the gradient
clc
close all

addpath('../../src/matlab_octave')

% Parameters
k = 2;
m = 10;
n = 7;

%K = ones(2, 2);

Kxx = rand(m*n+n, 1);
Kyy = rand(m*n+m, 1);
Kxy = rand(m*n+m, 1);
Kyx = rand(m*n+n, 1);

K = {Kxx Kyy Kxy Kyx};

G = grad2D(k, m, 1, n, 1);

KG = tensorGrad2D(K, G);
