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