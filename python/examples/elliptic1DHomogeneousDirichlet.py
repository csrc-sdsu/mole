"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

Solve -u'' = 1 on [0, 1] with u(0) = u(1) = 0.
The exact solution is u(x) = x(1-x)/2.
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy.sparse.linalg import spsolve

from pymole import Grid, Laplacian, RobinBoundaryCondition


def main():
    west, east = 0.0, 1.0
    accuracy_order = 2
    num_cells = 2 * accuracy_order + 1

    grid = Grid.generate(west, east, shape=num_cells + 1)
    laplacian = Laplacian(grid, accuracy_order).matrix
    boundary = RobinBoundaryCondition(
        grid,
        accuracy_order,
        dirichlet_coefficient=1.0,
        neumann_coefficient=0.0,
    ).matrix

    system = laplacian + boundary
    rhs = -np.ones(num_cells + 2)
    rhs[[0, -1]] = 0.0
    numerical = spsolve(system, rhs)

    x = np.concatenate(
        ([west], grid.x[:-1] + grid.spacing / 2.0, [east])
    )
    exact = x * (1.0 - x) / 2.0
    max_error = np.max(np.abs(numerical - exact))
    print(f"Maximum error: {max_error:.6e}")

    plt.plot(x, numerical, "o", label="PyMole")
    plt.plot(x, exact, "-", label="Exact")
    plt.title("1D Poisson equation: homogeneous Dirichlet conditions")
    plt.xlabel("x")
    plt.ylabel("u(x)")
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
