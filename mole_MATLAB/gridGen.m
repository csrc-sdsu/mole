function [X, Y] = gridGen(method, grid_name, m, n, plot_grid, varargin)
% Returns X and Y which are both m by n matrices that contains the physical
% coordinates
%
% Parameters:
%        grid_name : String with the name of the grid folder
%                m : Number of nodes along the horizontal axis
%                n : Number of nodes along the vertical axis
%        plot_grid : If true -> plot the grid
%         varargin : Maximum number of iterations (Required for TTM)
    
    if strcmp(method, 'TFI')
        [X, Y] = tfi(grid_name, m, n, plot_grid);
    elseif strcmp(method, 'TTM')
        if ~isempty(varargin)
            [X, Y] = ttm(grid_name, m, n, varargin{1}, plot_grid);
        else
            disp('Must specify maximum number of iterations for SOR algorithm.')
        end
    else
        disp('Method must be TFI or TTM.')
    end
end