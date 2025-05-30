clc;
clear;
close all;

% Run both scripts (make sure they don't "clear" variables internally)
fprintf('Running numerical solution...\n');
terzaghi1D;   % Ensure this does not call "clear" or overwrite shared variables

fprintf('Running analytical solution...\n');
terzaghi1D_benchmark;  % Same here

% Ensure xgrid shapes match
xgrid = xgrid(:);         % Make sure xgrid is a column vector
p_numerical = p(:);       % From numerical script
p_analytical = p(:);      % From analytical script (last computed 'p')

% Plot Comparison
figure;
plot(xgrid, p_numerical, 'b-o', 'DisplayName', 'Numerical');
hold on;
plot(xgrid, p_analytical, 'r--', 'LineWidth', 2, 'DisplayName', 'Analytical');
xlabel('x');
ylabel('p(x, t)');
title('Terzaghi 1D: Numerical vs Analytical');
legend('Location', 'best');
grid on;

% Compute L2 Error
rel_error = norm(p_numerical - p_analytical) / norm(p_analytical);
fprintf('\nRelative L2 error: %.6f\n', rel_error);

% Plot Pointwise Error
figure;
plot(xgrid, abs(p_numerical - p_analytical), 'k', 'LineWidth', 1.5);
xlabel('x');
ylabel('|p_{numerical} - p_{analytical}|');
title('Pointwise Absolute Error');
grid on;
