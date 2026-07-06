'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
import numpy as np
import sys
import shutil

from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent)+'/src/python')
from pymole import Grid, Gradient, Divergence, Laplacian, RobinBoundaryCondition

west = 0   # Domain's limits
east = 1

k = 6      # Operator's order of accuracy
m = 2*k+1  # Minimum number of cells to attain the desired accuracy

grid = Grid.generate(west, east, shape=m+1)

L = Laplacian(grid, accuracy_order=k).matrix

terminal_width, _ = shutil.get_terminal_size()
np.set_printoptions(linewidth=terminal_width, suppress=True)
print(L.toarray())

BC = RobinBoundaryCondition(grid, k, dirichlet_coefficient=1.0, neumann_coefficient=1.0)
print(BC.matrix.toarray())

L_BC = L + BC.matrix
print(L_BC.toarray())