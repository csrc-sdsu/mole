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

# x grid
#
n = m - 2
if n <= 0:
    raise ValueError("n must be positive")

h = 1.0 / n

# Cell centers: h/2, 3h/2, ..., 1-h/2
x_internal = (np.arange(n) + 0.5) * h

# Include the two boundary points
x = np.concatenate(([0.0], x_internal, [1.0]))

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
f = (
        np.exp(lam * x) / (lam * expm1_lam)
        + C1 * x
        + C2
    )

b = np.concatenate((
    [-1.0],
    -lam * np.exp(lam * x) / np.expm1(lam),
    [0.0]
))

#F = (-lambda_val * np.exp(lambda_val*x))/(np.exp(lambda_val)-1)

print(b.shape)
#print(L_BC.toarray().shape)


grid = Grid.generate(west, east, shape=m + 1)
print(grid.spacing)
L = Laplacian(grid, accuracy_order=k).matrix

terminal_width, _ = shutil.get_terminal_size()
np.set_printoptions(linewidth=terminal_width, suppress=True)

B = RobinBoundaryCondition(grid, k, dirichlet_coefficient=alpha, neumann_coefficient=beta)
L_BC = L + B.matrix

print(L_BC.toarray())

#RHS = [-1,0]

#x = np.r_[
#    RHS[0],
#    np.arange(
#        RHS[0] + grid.spacing / 2,
#        RHS[1] + grid.spacing / 2 + grid.spacing / 2,
#        grid.spacing,
#    ),
#    RHS[1],
#]
#x_internal = (np.arange(m) + 0.5) * grid.spacing
#x = np.r_[
#    RHS[0],
#    x_internal,
#    RHS[1],
#]

#print(RHS[0] + grid.spacing / 2)
#print(RHS[1] + grid.spacing / 2 + grid.spacing / 2)
#print(grid.spacing)

#
#print(x)
#print(x.shape)



U = np.linalg.inv(L_BC.toarray()) @ -b


print(U.shape)
print(x.shape)
"""

U[0] = 0  # West BC
U[-1] = 2 * np.exp(1)  # East BC
U = np.linalg.inv(L_BC.toarray()) @ U


plt.plot(x, U, "o", label="Approximated")
#plt.plot(x, np.exp(x), label="Analytical")
plt.legend(loc="upper left")
plt.title("The Model Problem")
plt.xlabel("x")
plt.ylabel("u(x)")
plt.show()
#"""