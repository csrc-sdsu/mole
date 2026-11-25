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
GRID_SIZES = [13, 26, 52] #grid sizes with constants for convergence study

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

def calculate_errors(
    numerical_solution,
    analytical_solution,
    spacing,
):
    #difference between the numerical and analytical solutions
    error = numerical_solution - analytical_solution

    #maximum absolute error
    maximum_error = np.max(np.abs(error))

    #discrete L2 error
    l2_error = np.sqrt(spacing * np.sum(error**2))

    return error, maximum_error, l2_error

#convergence study for different grid sizes
def run_convergence_study(
    grid_sizes=GRID_SIZES,
    accuracy_order=ACCURACY_ORDER,
):
    results = []

    for num_cells in grid_sizes:
        #solve the problem using the current grid size
        x, numerical_solution, analytical_solution = solve_problem(
            num_cells=num_cells,
            accuracy_order=accuracy_order,
        )

        #calculate the grid spacing
        spacing = (EAST - WEST) / num_cells

        #calculate the errors for this grid
        error, maximum_error, l2_error = calculate_errors(
            numerical_solution,
            analytical_solution,
            spacing,
        )

        results.append(
            {
                "num_cells": num_cells,
                "spacing": spacing,
                "x": x,
                "numerical_solution": numerical_solution,
                "analytical_solution": analytical_solution,
                "error": error,
                "maximum_error": maximum_error,
                "l2_error": l2_error,
            }
        )

    return results

#calculate the observed convergence rates for the errors
def calculate_convergence_rates(results):
    #the first grid does not have a previous grid for comparison
    results[0]["maximum_rate"] = None
    results[0]["l2_rate"] = None

    for previous, current in zip(results[:-1], results[1:]):
        #calculate the rate for the maximum error
        previous["maximum_rate"] = np.log(
            previous["maximum_error"] / current["maximum_error"]
        ) / np.log(
            previous["spacing"] / current["spacing"]
        )

        #calculate the rate for the discrete L2 error
        previous["l2_rate"] = np.log(
            previous["l2_error"] / current["l2_error"]
        ) / np.log(
            previous["spacing"] / current["spacing"]
        )

    #the finest grid does not have a following grid for comparison
    results[-1]["maximum_rate"] = None
    results[-1]["l2_rate"] = None

    return results

#print the errors and convergence rates in a formatted table
def print_convergence_table(results):
    print("\nGrid-refinement convergence study")
    print("-" * 78)
    print(
        f"{'Cells':>8}"
        f"{'Spacing':>14}"
        f"{'Max error':>18}"
        f"{'Max rate':>14}"
        f"{'L2 error':>18}"
        f"{'L2 rate':>14}"
    )
    print("-" * 78)

    for result in results:
        maximum_rate = (
            "-"
            if result["maximum_rate"] is None
            else f"{result['maximum_rate']:.4f}"
        )

        l2_rate = (
            "-"
            if result["l2_rate"] is None
            else f"{result['l2_rate']:.4f}"
        )

        print(
            f"{result['num_cells']:>8}"
            f"{result['spacing']:>14.6e}"
            f"{result['maximum_error']:>18.6e}"
            f"{maximum_rate:>14}"
            f"{result['l2_error']:>18.6e}"
            f"{l2_rate:>14}"
        )

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

#plot the error and grid-convergence results
def plot_validation_results(results):
    #the finest grid gives the most detailed error distribution
    finest_result = results[-1]

    figure, axes = plt.subplots(1, 2, figsize=(14, 5))

    #plot the absolute error across the finest grid
    axes[0].plot(
        finest_result["x"],
        np.abs(finest_result["error"]),
        "o-",
        label="Absolute error",
    )
    axes[0].set_yscale("log")
    axes[0].set_title("Absolute error on the finest grid")
    axes[0].set_xlabel("x")
    axes[0].set_ylabel("Absolute error")
    axes[0].grid(True)
    axes[0].legend()

    #collect the errors and grid spacings from all grids
    spacings = [
        result["spacing"]
        for result in results
    ]

    maximum_errors = [
        result["maximum_error"]
        for result in results
    ]

    l2_errors = [
        result["l2_error"]
        for result in results
    ]

    #plot the error as the grid becomes finer
    axes[1].loglog(
        spacings,
        maximum_errors,
        "o-",
        label="Maximum error",
    )

    axes[1].loglog(
        spacings,
        l2_errors,
        "s-",
        label="Discrete L2 error",
    )

    axes[1].set_title("Grid-convergence study")
    axes[1].set_xlabel("Grid spacing")
    axes[1].set_ylabel("Error")
    axes[1].invert_xaxis()
    axes[1].grid(True)
    axes[1].legend()

    figure.tight_layout()
    plt.show()

def main():
    #solve the problem using several grid sizes
    results = run_convergence_study()

    #calculate the convergence rates
    results = calculate_convergence_rates(results)

    #print the errors and convergence rates
    print_convergence_table(results)

    #plot the solution from the finest grid
    finest_result = results[-1]

    plot_solution(
        finest_result["x"],
        finest_result["numerical_solution"],
        finest_result["analytical_solution"],
    )

    #plot the error and convergence results
    plot_validation_results(results)


if __name__ == "__main__":
    main()