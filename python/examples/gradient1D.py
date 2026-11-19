"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

Demonstrate the 1D mimetic gradient and its convergence on [0, 1].
For u(x) = exp(x), the exact derivative is also exp(x).
"""

import matplotlib.pyplot as plt
import numpy as np

from pymole import Gradient, Grid


def gradient_error(accuracy_order, num_cells):
    grid = Grid.generate(0.0, 1.0, shape=num_cells + 1)
    staggered_x = np.concatenate(
        ([0.0], grid.x[:-1] + grid.spacing / 2.0, [1.0])
    )

    numerical = Gradient(grid, accuracy_order).matrix @ np.exp(staggered_x)
    exact = np.exp(grid.x)
    pointwise_error = np.abs(numerical - exact)
    return grid.x, pointwise_error


def main():
    accuracy_orders = (2, 4, 6)
    grid_sizes = (20, 40, 80)

    print("  k     m       max error     observed order")
    print("----  ----  --------------  --------------")

    finest_errors = {}
    for accuracy_order in accuracy_orders:
        previous_error = None
        for num_cells in grid_sizes:
            x, pointwise_error = gradient_error(
                accuracy_order, num_cells
            )
            max_error = np.max(pointwise_error)
            observed_order = (
                np.log2(previous_error / max_error)
                if previous_error is not None
                else np.nan
            )
            order_text = (
                f"{observed_order:14.6f}"
                if np.isfinite(observed_order)
                else "             -"
            )
            print(
                f"{accuracy_order:4d}  {num_cells:4d}  "
                f"{max_error:14.6e}  {order_text}"
            )
            previous_error = max_error

        finest_errors[accuracy_order] = (x, pointwise_error)

    for accuracy_order, (x, pointwise_error) in finest_errors.items():
        plt.semilogy(
            x,
            pointwise_error,
            label=f"k = {accuracy_order}",
        )

    plt.title("Pointwise error of the 1D mimetic gradient (m = 80)")
    plt.xlabel("x")
    plt.ylabel("absolute error")
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
