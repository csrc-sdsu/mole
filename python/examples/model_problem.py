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
lam = -1.0
alpha = -np.exp(lam)
beta = (np.exp(lam)-1)/lam

# Generate the discrete operator first
grid = Grid.generate(west, east, shape=m + 1)
#print(grid.spacing)
L = Laplacian(grid, accuracy_order=k).matrix

B = RobinBoundaryCondition(grid, k, dirichlet_coefficient=alpha, neumann_coefficient=beta)
L_BC = -L + B.matrix
A = L_BC.toarray()

# Number of interior cell centers required by the matrix
n = A.shape[0] - 2
h = (east - west) / n

# Staggered grid
#
# Cell centers: h/2, 3h/2, ..., 1-h/2
x_internal = west + (np.arange(n) + 0.5) * h

# Include the two boundary points
x = np.concatenate(([west], x_internal, [east]))

# Exact solution
#
exp_lam = np.exp(lam)
expm1_lam = np.expm1(lam)  # exp(lam) - 1
C1 = (lam - 1.0) / (2.0 * expm1_lam - lam * exp_lam)
C2 = (
        lam
        - 1.0
        - exp_lam / expm1_lam
        - expm1_lam * C1
    ) / (lam * exp_lam)
f_exact = (
        np.exp(lam * x) / (lam * expm1_lam)
        + C1 * x
        + C2
    )

F_internal = (
    -lam
    * np.exp(lam * x_internal)
    / np.expm1(lam)
)

b = np.concatenate((
    [-1.0],
    F_internal,
    [0.0]
))

# Solve without explicitly forming the matrix inverse
f_approx = np.linalg.solve(A, b)

terminal_width, _ = shutil.get_terminal_size()
np.set_printoptions(linewidth=terminal_width, suppress=True)

plt.plot(x, f_approx, "o", label="Approximated")
plt.plot(x, f_exact, label="Analytical")
plt.legend(loc="upper left")
plt.title(fr"The Model Problem ($\lambda$ = {lam})")
plt.xlabel("x")
plt.ylabel("f(x)")
plt.show()
