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
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
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