clc;
clear;
close all;

% Run both solutions
fprintf('Running numerical solution...\n');
terzaghi1D_benchmark;   % Should output: p_all (numerical), xgrid

fprintf('Running analytical solution...\n');
terzaghi1D;  % Should output: p_all (analytical), xgrid

% Make sure xgrid is column vector
xgrid = xgrid(:);
times_hr = [1, 10, 40, 70];

% Initialize error storage
num_times = size(p_all, 2);
rel_errors = zeros(1, num_times);

% Compare and plot at each time
for i = 1:num_times
    p_num = p_all(:, i);        % From numerical
    p_ana = p_all(:, i);        % From analytical (reuses same var name)

    % Plot comparison
    figure;
    plot(xgrid, p_num / 1e6, 'b-o', 'DisplayName', 'Numerical');
    hold on;
    plot(xgrid, p_ana / 1e6, 'r--', 'LineWidth', 2, 'DisplayName', 'Analytical');
    title(['Pressure Comparison at t = ' num2str(times_hr(i)) ' hr']);
    xlabel('x (m)');
    ylabel('p(x,t) [MPa]');
    legend('Location', 'southeast');
    grid on;

    % Plot pointwise error
    figure;
    plot(xgrid, abs(p_num - p_ana), 'k-', 'LineWidth', 1.5);
    title(['Pointwise Error at t = ' num2str(times_hr(i)) ' hr']);
    xlabel('x (m)');
    ylabel('|p_{num} - p_{ana}| [Pa]');
    grid on;

    % Compute and display L2 relative error
    rel_errors(i) = norm(p_num - p_ana) / norm(p_ana);
    fprintf('\nRelative L2 error at t = %.2f hr: %.6e\n', times_hr(i), rel_errors(i));
end
