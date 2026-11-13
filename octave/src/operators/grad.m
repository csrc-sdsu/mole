function [G, errorFlag] = grad(k, grid, errorObj = MOLE_errors())
% PURPOSE
% This gradient operator computes the vector of partial derivatives,
% indicating the direction of maximum rate of increase and the steepest
% slope of a scalar field.
%
% DESCRIPTION
% Returns a one-dimensional mimetic gradient operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                grid : Grid object with m cells, dx step size, 
%                       dc, and nc attributes
%
% SYNTAX
% G = grad(k, grid)
% G = grad(k, grid, errorObj)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%
    %Need to ask about error naming and error not being in mole errors file!!!
    if nargin ~= 2 && nargin ~= 3
        params = sprintf('grad:InvalidNumArgs grad expects 2 or 3 arguments', mat2str(k));
        errorObj.log_error('MOLE_ERR_INVALID_ARGS', 'grad', true, params);
    end
    
    % for legacy code
    %if nargin == 3
        %G = gradNonPeriodic(k, grid.m, grid.dx);
        %return;
    %end
    % NEED TO ASK ABOUT THE ERROR USED THE MESSAGE IS NOT EXPLICIT ABOUT ALL INVALID ARGS THEY ARE FOR GRID CREATION !!
    if k < 2 || mod(k, 2) != 0 || k > 8
        params = sprintf('Order of accuracy k must be greater than 2 and even but k: %s was  given.', mat2str(k));
        errorObj.log_error('MOLE_ERR_INVALID_ARGS', 'grad', true, params);

    end
    if grid.m < 2*k
        params = sprintf('grid.m and k must meet m >= %s for k = %s',num2str(2*k), mat2str(k));
        errorObj.log_error('MOLE_ERR_INVALID_ARGS', 'grad', true, params);
    end
    %NEED TO ASK ABOUT THE NEW IMPLEMENTATION OF DC AND NC
    % periodic boundary condition case
    dc = grid.bc.dc;
    nc = grid.bc.nc;
    q = find(dc.*dc + nc.*nc,1);

    if isempty(q)
        G = gradPeriodic(k, grid, errorObj);
        errorFlag = grid.valid
    else
        G = gradNonPeriodic(k, grid, errorObj);
        errorFlag = grid.valid
    end
end
