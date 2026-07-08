'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
import numpy as np
import sys
import shutil
import matplotlib.pyplot as plt

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

BC = RobinBoundaryCondition(grid, k, dirichlet_coefficient=1.0, neumann_coefficient=1.0)
L_BC = L + BC.matrix

x = np.r_[west, np.arange(west + grid.spacing/2, east - grid.spacing/2 + grid.spacing/2, grid.spacing), east]
U = np.exp(x)[:, None]
U[0] = 0          # West BC
U[-1] = 2*np.exp(1)  # East BC
U = np.linalg.inv(L_BC.toarray()) @ U

plt.plot(x, U, 'o', label='Approximated')
plt.plot(x, np.exp(x), label='Analytical')
plt.legend(loc='upper left')
plt.title("Poisson's equation with Robin BC")
plt.xlabel('x')
plt.ylabel('u(x)')
plt.show()