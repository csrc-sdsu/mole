"""
Solve the one-dimensional two-way wave equation with mimetic differences.

This example is the Python counterpart of
``examples/matlab_octave/tutorials/two_way_wave_equation/
mimetic_diff_two_way_wave_eq_neumann.m``.

The equation is

    u_tt = c**2 u_xx,   -2 <= x <= 2,

with homogeneous Neumann boundary conditions, ``u_x(-2,t) =
u_x(2,t) = 0``.  The time integration is the centered-in-time,
centered-in-space (CTCS) scheme.  The spatial second derivative is
provided by :class:`pymole.Laplacian`.

The initial displacement is a Gaussian pulse.  Its reflected traveling-wave
extension gives an exact solution on the finite interval with Neumann
boundaries, which is used to calculate the relative error at the final time.

SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
"""

from __future__ import annotations

from time import perf_counter
from typing import Iterable

import numpy as np
from numpy.typing import ArrayLike, NDArray

from pymole import Grid, Laplacian, RobinBoundaryCondition


FloatArray = NDArray[np.float64]


def reflected_coordinate(x: ArrayLike, west: float, east: float) -> FloatArray:
    """Reflect coordinates into ``[west, east]`` for Neumann boundaries."""

    x_array = np.asarray(x, dtype=float)
    interval = east - west
    return west + interval - np.abs(
        np.mod(x_array - west, 2.0 * interval) - interval
    )


def exact_solution(
    x: ArrayLike, time: float, wave_speed: float, west: float = -2.0, east: float = 2.0
) -> FloatArray:
    """Return the reflected Gaussian-pulse solution ``u(x, time)``."""

    reflected = lambda coordinate: np.exp(
        -reflected_coordinate(coordinate, west, east) ** 2 / 0.1
    )
    x_array = np.asarray(x, dtype=float)
    return 0.5 * (
        reflected(x_array - wave_speed * time)
        + reflected(x_array + wave_speed * time)
    )


def _apply_neumann_boundary(value: FloatArray, boundary_matrix) -> None:
    """Solve the two boundary equations for the boundary entries in place."""

    left = boundary_matrix.getrow(0)
    value[0] = 0.0
    value[0] = -(left @ value)[0] / left[0, 0]

    right = boundary_matrix.getrow(boundary_matrix.shape[0] - 1)
    value[-1] = 0.0
    value[-1] = -(right @ value)[0] / right[0, -1]


def mimetic_diff_two_way_wave_eq_neumann(
    accuracy_order: int,
    wave_speed: float,
    time_step: float,
    num_cells: Iterable[int] | int,
) -> tuple[FloatArray, FloatArray, FloatArray, FloatArray]:
    """Solve the wave equation for one or more mesh sizes.

    Parameters
    ----------
    accuracy_order:
        Spatial mimetic order.  The current Python operators support 2, 4,
        and 6.
    wave_speed:
        Constant wave speed ``c``.
    time_step:
        Time step ``dt``.  It should satisfy the stability restriction for the
        selected spatial operator.
    num_cells:
        Number of cells, or an iterable of cell counts to test.

    Returns
    -------
    final_solution, relative_error, wall_time, flop_count:
        Arrays with one entry per requested mesh size.  ``final_solution`` is
        the solution from the last mesh size; its length is ``m + 2`` for the
        last ``m`` in ``num_cells``.  The other arrays contain one value per
        mesh size.
    """

    if wave_speed <= 0.0:
        raise ValueError("wave_speed must be positive")
    if time_step <= 0.0:
        raise ValueError("time_step must be positive")

    cells = np.atleast_1d(np.asarray(num_cells, dtype=int))
    if cells.size == 0 or np.any(cells < 2 * accuracy_order + 1):
        raise ValueError(
            "Each mesh must have at least 2 * accuracy_order + 1 cells"
        )

    west, east = -2.0, 2.0
    final_solution = np.empty(0, dtype=float)
    relative_errors = np.empty(cells.size, dtype=float)
    wall_times = np.empty(cells.size, dtype=float)
    flop_counts = np.empty(cells.size, dtype=float)

    for mesh_index, cell_count in enumerate(cells):
        cell_count = int(cell_count)
        dx = (east - west) / cell_count
        time_levels = int(np.ceil((4.0 / wave_speed) / time_step))

        # Grid.x contains the m+1 locations needed by pymole's staggered
        # operators.  The solution itself is stored at the m+2 mimetic
        # locations: boundary, m cell centers, boundary.
        grid = Grid.generate(west, east, shape=cell_count + 1)
        solution_coordinates = np.concatenate(
            (
                [west],
                west + dx / 2.0 + dx * np.arange(cell_count),
                [east],
            )
        )

        laplacian = Laplacian(grid, accuracy_order=accuracy_order).matrix
        boundary = RobinBoundaryCondition(
            grid,
            accuracy_order=accuracy_order,
            dirichlet_coefficient=0.0,
            neumann_coefficient=1.0,
        ).matrix

        initial = exact_solution(solution_coordinates, 0.0, wave_speed, west, east)
        analytic = exact_solution(
            solution_coordinates,
            (time_levels + 1) * time_step,
            wave_speed,
            west,
            east,
        )

        # The first CTCS level is obtained with the half-step Taylor update.
        scaled_laplacian = (wave_speed * time_step) ** 2 * laplacian
        previous = initial
        current = previous + 0.5 * (scaled_laplacian @ previous)
        _apply_neumann_boundary(current, boundary)

        start = perf_counter()
        for _ in range(time_levels):
            next_value = 2.0 * current + scaled_laplacian @ current - previous
            _apply_neumann_boundary(next_value, boundary)
            previous, current = current, next_value
        wall_times[mesh_index] = perf_counter() - start

        final_solution = current
        relative_errors[mesh_index] = np.linalg.norm(
            current - analytic
        ) / np.linalg.norm(analytic)
        flop_counts[mesh_index] = (
            2.0 * laplacian.nnz + 3.0 * len(previous)
        ) * time_levels

    return final_solution, relative_errors, wall_times, flop_counts


if __name__ == "__main__":
    import matplotlib.pyplot as plt

    order = 4
    wave_speed = 1.0
    time_step = 0.002
    meshes = [40, 80, 160]

    solution, errors, wall_times, flop_counts = (
        mimetic_diff_two_way_wave_eq_neumann(
            order, wave_speed, time_step, meshes
        )
    )

    print("mesh cells       relative error       wall time (s)       estimated flops")
    for mesh, error, wall_time, flops in zip(
        meshes, errors, wall_times, flop_counts
    ):
        print(f"{mesh:10d}       {error:14.6e}       {wall_time:13.6f}       {flops:15.6e}")

    grid = Grid.generate(-2.0, 2.0, shape=meshes[-1] + 1)
    dx = grid.spacing
    x = np.concatenate(([-2.0], -2.0 + dx / 2.0 + dx * np.arange(meshes[-1]), [2.0]))
    final_time = (int(np.ceil(4.0 / time_step)) + 1) * time_step
    analytical = exact_solution(x, final_time, wave_speed)

    plt.plot(x, solution, label="Mimetic difference")
    plt.plot(x, analytical, "--", label="Analytical solution")
    plt.xlabel("x")
    plt.ylabel("u(x, t)")
    plt.title(f"Two-way wave equation, mimetic order {order}")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()
