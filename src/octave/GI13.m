function I = GI13(M, m, n, o, type)
% PURPOSE
% Interpolates a logical-gradient component from the staggered face set it is
% computed on, to the face set grad3DCurv needs it on.
%
% DESCRIPTION
% grad3DCurv needs the logical eta- and zeta-derivatives evaluated at x-face
% positions, but they are computed on y- and z-faces (and likewise for the
% other components).  GI13 performs the six possible shifts between face sets.
%
% Face layouts, flattened xi-fastest then eta then zeta:
%     x-faces : (m+1) x  n    x  o     xi on nodes
%     y-faces :  m    x (n+1) x  o     eta on nodes
%     z-faces :  m    x  n    x (o+1)  zeta on nodes
%
% Every shift is a tensor product of three 1-D operators, one per axis, each
% either identity, node-to-centre, or centre-to-node:
%
%     type    source -> target      xi      eta     zeta
%     'Gn'    y-face -> x-face      c->n    n->c     I
%     'Gc'    z-face -> x-face      c->n     I      n->c
%     'Ge'    x-face -> y-face      n->c    c->n     I
%     'Gcy'   z-face -> y-face       I      c->n    n->c
%     'Gee'   x-face -> z-face      n->c     I      c->n
%     'Gnn'   y-face -> z-face       I      n->c    c->n
%
% assembled as kron(Az, kron(Ay, Ax)) to match the xi-fastest flattening.
%
% SYNTAX
% I = GI13(M, m, n, o, type)
%
% Parameters:
%          M : the operator block to be interpolated (Ge, Gn or Gc)
%    m, n, o : number of CELLS along xi, eta and zeta
%       type : which shift to perform (see table above)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    switch type
        case 'Gn'
            Ax = P(m);
            Ay = Q(n);
            Az = speye(o);
        case 'Gc'
            Ax = P(m);
            Ay = speye(n);
            Az = Q(o);
        case 'Ge'
            Ax = Q(m);
            Ay = P(n);
            Az = speye(o);
        case 'Gcy'
            Ax = speye(m);
            Ay = P(n);
            Az = Q(o);
        case 'Gee'
            Ax = Q(m);
            Ay = speye(n);
            Az = P(o);
        case 'Gnn'
            Ax = speye(m);
            Ay = Q(n);
            Az = P(o);
        otherwise
            error('GI13:BadType', 'unknown type "%s"', type);
    end

    I = kron(Az, kron(Ay, Ax)) * M;
end

function A = Q(N)
% node -> centre: N+1 values on nodes -> N values on centres, midpoint average.
    A = spdiags(0.5*ones(N, 2), [0 1], N, N+1);
end

function A = P(N)
% centre -> node: N values on centres -> N+1 values on nodes.  Midpoint average
% in the interior; at the two ends the three-point row [1, .5, -.5], which is
% the boundary row GI2 uses once Q's 0.5 weights are factored out.  Both this
% and plain linear extrapolation [1.5, -.5] are exact for linear fields and
% second order; this one keeps the 2-D and 3-D operators consistent.
    A = spdiags(0.5*ones(N+1, 2), [-1 0], N+1, N);
    A(1, 1) = 1;
    A(1, 2) = 0.5;
    A(1, 3) = -0.5;
    A(N+1, N) = 1;
    A(N+1, N-1) = 0.5;
    A(N+1, N-2) = -0.5;
end
