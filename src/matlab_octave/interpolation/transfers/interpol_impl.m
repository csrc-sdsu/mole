function I = interpol_impl(grid, direction)
% PURPOSE
% Canonical direction-dispatching implementation for unified interpol.
%
% DESCRIPTION
% Routes to the appropriate dimension- and direction-specific transfer
% operator based on grid.dim and the direction string. All underlying
% implementations use order k=2.
%
% Parameters:
%   I         : Sparse matrix — interpolation operator
%   grid      : Validated grid struct with grid.dim, grid.m (and .n, .o)
%   direction : One of 'CentersToFaces', 'FacesToCenters',
%               'NodesToCenters', 'CentersToNodes'
%
% SYNTAX
% I = interpol_impl(grid, direction)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    k = 2;

    switch lower(direction)

    case 'centerstofaces'
        switch grid.dim
        case 1
            I = interpolCentersToFacesD1D_impl(k, grid.m);
        case 2
            I = interpolCentersToFacesD2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolCentersToFacesD3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'facestocenters'
        switch grid.dim
        case 1
            I = interpolFacesToCentersG1D_impl(k, grid.m);
        case 2
            I = interpolFacesToCentersG2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolFacesToCentersG3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'nodestocenters'
        switch grid.dim
        case 1
            I = interpolFacesToCentersG1D_impl(k, grid.m);
        case 2
            I = interpolFacesToCentersG2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolFacesToCentersG3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    case 'centerstonodes'
        switch grid.dim
        case 1
            I = interpolCentersToFacesD1D_impl(k, grid.m);
        case 2
            I = interpolCentersToFacesD2D_impl(k, grid.m, grid.n);
        case 3
            I = interpolCentersToFacesD3D_impl(k, grid.m, grid.n, grid.o);
        otherwise
            error('interpol:InvalidDim', 'grid.dim must be 1, 2, or 3');
        end

    otherwise
        error('interpol:UnknownDirection', ...
              'direction must be CentersToFaces, FacesToCenters, NodesToCenters, or CentersToNodes');
    end
end
