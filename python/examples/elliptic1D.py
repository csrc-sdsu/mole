"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

One-dimensional elliptic problem with Robin boundary conditions.

Problem:
    u''(x) = exp(x), 0 < x < 1

Boundary conditions:
    u(0) - u'(0) = 0
    u(1) + u'(1) = 2e

Exact solution:
    u(x) = exp(x)
"""

import numpy as np
import matplotlib.pyplot as plt

from pymole import Grid, Laplacian, RobinBoundaryCondition


WEST = 0.0
EAST = 1.0
ACCURACY_ORDER = 6
NUM_CELLS = 13
DIRICHLET_COEFFICIENT = 1.0
NEUMANN_COEFFICIENT = 1.0


def exact_solution(x):
    """return the analytical solution u(x) = exp(x)."""
    #comparison of the numerical solution with the exact one
    return np.exp(x)


def solve_problem(
    num_cells=NUM_CELLS,
    accuracy_order=ACCURACY_ORDER,
):
    """solve the one-dimensional elliptic problem."""
    #the grid needs at least 2k+1 cells for the selected accuracy order
    minimum_cells = 2 * accuracy_order + 1

    if num_cells < minimum_cells:
        raise ValueError(
            f"At least {minimum_cells} cells are required "
            f"for accuracy order {accuracy_order}."
        )

    #creation ofthe computational grid between west and east
    grid = Grid.generate(
        WEST,
        EAST,
        shape=num_cells + 1,
    )

    #creation of the discrete Laplacian operator
    laplacian = Laplacian(
        grid,
        accuracy_order=accuracy_order,
    ).matrix

    #Application of Robin boundary conditions at both ends of the domain
    boundary_condition = RobinBoundaryCondition(
        grid,
        accuracy_order=accuracy_order,
        dirichlet_coefficient=DIRICHLET_COEFFICIENT,
        neumann_coefficient=NEUMANN_COEFFICIENT,
    )

    #this is the matrix of the linear system that will be solved
    system_matrix = (
        laplacian + boundary_condition.matrix
    ).toarray()

    #calculations of the locations of the cell centers
    cell_centers = WEST + (
        np.arange(num_cells) + 0.5
    ) * grid.spacing

    #the full coordinate vector includes the two boundary points
    x = np.concatenate(
        ([WEST], cell_centers, [EAST])
    )

    #the exact solution is also used to build the right-hand side
    analytical_solution = exact_solution(x)
    right_hand_side = np.copy(analytical_solution)

    # Robin boundary conditions:
    # u(0) - u'(0) = 0
    # u(1) + u'(1) = 2e
    right_hand_side[0] = 0.0
    right_hand_side[-1] = 2.0 * np.exp(1.0)

    #solve the system without explicitly calculating the inverse matrix
    numerical_solution = np.linalg.solve(
        system_matrix,
        right_hand_side,
    )

    return x, numerical_solution, analytical_solution


def plot_solution(
    x,
    numerical_solution,
    analytical_solution,
):
    """plot the numerical and analytical solutions."""
    #the markers show the values calculated by MOLE
    plt.plot(
        x,
        numerical_solution,
        "o",
        label="Numerical",
    )

    #preparing the exact analytical solution
    x_plot = np.linspace(WEST, EAST, 200)

    plt.plot(
        x_plot,
        exact_solution(x_plot),
        label="Analytical",
    )

    plt.legend()
    plt.title("Poisson's equation with Robin boundary conditions")
    plt.xlabel("x")
    plt.ylabel("u(x)")
    plt.grid(True)
    plt.show()


def main():
    """solve the problem and display the results."""
    #equation solution
    x, numerical_solution, analytical_solution = solve_problem()

    #plot both solutions for comparison
    plot_solution(
        x,
        numerical_solution,
        analytical_solution,
    )


if __name__ == "__main__":
    main()