"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

Solve -u'' = 1 on [0, 1] with u'(0) = 0 and u(1) = 0.
The exact solution is u(x) = (1-x^2)/2.
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy import sparse
from scipy.sparse.linalg import spsolve

from pymole import (
    BoundaryCondition,
    Grid,
    Laplacian,
    RobinBoundaryCondition,
)


class LeftRightBoundaryCondition(BoundaryCondition):
    """Use different Robin coefficients at the two ends of a 1D domain."""

    def __init__(
        self,
        grid,
        accuracy_order,
        left_coefficients,
        right_coefficients,
    ):
        self.left_coefficients = left_coefficients
        self.right_coefficients = right_coefficients
        super().__init__(grid, accuracy_order)

    def apply(self):
        if self.grid.ndim != 1:
            raise ValueError("LeftRightBoundaryCondition supports only 1D grids.")

        left = RobinBoundaryCondition(
            self.grid,
            self.accuracy_order,
            dirichlet_coefficient=self.left_coefficients[0],
            neumann_coefficient=self.left_coefficients[1],
        ).matrix
        right = RobinBoundaryCondition(
            self.grid,
            self.accuracy_order,
            dirichlet_coefficient=self.right_coefficients[0],
            neumann_coefficient=self.right_coefficients[1],
        ).matrix

        empty_interior = sparse.csr_matrix((self.m, self.m + 2))
        return sparse.vstack(
            [left.getrow(0), empty_interior, right.getrow(self.m + 1)],
            format="csr",
        )


def main():
    west, east = 0.0, 1.0
    accuracy_order = 2
    num_cells = 2 * accuracy_order + 1

    grid = Grid.generate(west, east, shape=num_cells + 1)
    laplacian = Laplacian(grid, accuracy_order).matrix
    boundary = LeftRightBoundaryCondition(
        grid,
        accuracy_order,
        left_coefficients=(0.0, 1.0),
        right_coefficients=(1.0, 0.0),
    ).matrix

    system = -laplacian + boundary
    rhs = np.ones(num_cells + 2)
    rhs[[0, -1]] = 0.0
    numerical = spsolve(system, rhs)

    x = np.concatenate(
        ([west], grid.x[:-1] + grid.spacing / 2.0, [east])
    )
    exact = (1.0 - x**2) / 2.0
    max_error = np.max(np.abs(numerical - exact))
    print(f"Maximum error: {max_error:.6e}")

    plt.plot(x, numerical, "o", label="PyMole")
    plt.plot(x, exact, "-", label="Exact")
    plt.title("1D Poisson equation: left Neumann, right Dirichlet")
    plt.xlabel("x")
    plt.ylabel("u(x)")
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
