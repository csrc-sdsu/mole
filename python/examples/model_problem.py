"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
"""

import numpy as np
import sys
import shutil
import matplotlib.pyplot as plt

from pymole import Grid, Gradient, Divergence, Laplacian, RobinBoundaryCondition

west = 0  # Domain's limits
east = 1

k = 6  # Operator's order of accuracy
m = 2 * k + 1  # Minimum number of cells to attain the desired accuracy
lambda_val = -1.0
alpha = -np.exp(lambda_val)
beta = (np.exp(lambda_val)-1)/lambda_val

grid = Grid.generate(west, east, shape=m + 1)
print(grid.spacing)
L = Laplacian(grid, accuracy_order=k).matrix

terminal_width, _ = shutil.get_terminal_size()
np.set_printoptions(linewidth=terminal_width, suppress=True)

B = RobinBoundaryCondition(grid, k, dirichlet_coefficient=alpha, neumann_coefficient=beta)
L_BC = L + B.matrix

print(L_BC.toarray())


x = np.r_[
    west,
    np.arange(
        west + grid.spacing / 2,
        east - grid.spacing / 2 + grid.spacing / 2,
        grid.spacing,
    ),
    east,
]


F = (-lambda_val * np.exp(lambda_val*x))/(np.exp(lambda_val)-1)
U = np.linalg.inv(L_BC.toarray()) @ -F

"""


U[0] = 0  # West BC
U[-1] = 2 * np.exp(1)  # East BC
U = np.linalg.inv(L_BC.toarray()) @ U
"""

plt.plot(x, U, "o", label="Approximated")
#plt.plot(x, np.exp(x), label="Analytical")
plt.legend(loc="upper left")
plt.title("The Model Problem")
plt.xlabel("x")
plt.ylabel("u(x)")
plt.show()
