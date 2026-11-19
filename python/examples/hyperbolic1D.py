"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

Solve u_t + a*u_x = 0 on [0, 1] with periodic boundary conditions.
The initial condition is sin(2*pi*x), so the exact solution is
sin(2*pi*(x-a*t)).
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy import sparse

from pymole import Divergence, Grid
from pymole.mimetic_operator import MimeticOperator


class Interpol(MimeticOperator):
    """Second-order interpolation from staggered values to cell faces."""

    axis_names = ("x",)

    def __init__(self, grids, accuracy_order=2, c=0.5):
        if accuracy_order != 2:
            raise ValueError("Interpol supports only second-order accuracy.")
        if not 0.0 <= c <= 1.0:
            raise ValueError("Interpolation coefficient c must be in [0, 1].")
        self.c = c
        super().__init__(grids, accuracy_order)

    @classmethod
    def minimum_cells_for_order(cls, accuracy_order):
        if accuracy_order != 2:
            raise ValueError("Interpol supports only second-order accuracy.")
        return 4

    def _construct_matrix(self):
        num_cells = self.grids[0].num_cells
        matrix = sparse.lil_matrix((num_cells + 1, num_cells + 2))
        matrix[0, 0] = 1.0
        matrix[-1, -1] = 1.0

        for row in range(1, num_cells):
            matrix[row, row : row + 2] = [self.c, 1.0 - self.c]

        return matrix.tocsr()


def main():
    advection_speed = 1.0
    west, east = 0.0, 1.0
    accuracy_order = 2
    num_cells = 50
    final_time = 1.0

    grid = Grid.generate(west, east, shape=num_cells + 1)
    dx = grid.spacing
    dt = dx / abs(advection_speed)
    steps = round(final_time / dt)

    x = np.concatenate(
        ([west], grid.x[:-1] + dx / 2.0, [east])
    )
    initial = np.sin(2.0 * np.pi * x)

    divergence = Divergence(grid, accuracy_order).matrix.tolil()
    divergence[0, 1] = divergence[-1, 1] = 1.0 / (2.0 * dx)
    divergence[0, -2] = divergence[-1, -2] = -1.0 / (2.0 * dx)
    divergence = divergence.tocsr()

    interpolation = Interpol(
        (grid,), accuracy_order, c=0.5
    ).matrix
    update = (
        -advection_speed
        * dt
        * 2.0
        * divergence
        @ interpolation
    )

    previous = initial
    current = previous + 0.5 * (update @ previous)

    plt.ion()
    figure, axis = plt.subplots()
    numerical_line, = axis.plot(x, current, "o-", label="PyMole")
    exact_line, = axis.plot(x, initial, "-", label="Exact")
    axis.set(xlabel="x", ylabel="u(x,t)", ylim=(-1.5, 1.5))
    axis.legend()

    for step in range(1, steps):
        next_solution = previous + update @ current
        previous, current = current, next_solution

        time = (step + 1) * dt
        exact = np.sin(2.0 * np.pi * (x - advection_speed * time))
        numerical_line.set_ydata(current)
        exact_line.set_ydata(exact)
        axis.set_title(f"Periodic advection, t = {time:.2f}")
        figure.canvas.draw_idle()
        plt.pause(0.01)

    exact = np.sin(2.0 * np.pi * (x - advection_speed * final_time))
    max_error = np.max(np.abs(current - exact))
    print(f"Maximum error at t={final_time:g}: {max_error:.6e}")

    plt.ioff()
    plt.show()


if __name__ == "__main__":
    main()
