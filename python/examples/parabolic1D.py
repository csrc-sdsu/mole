"""Solve the one-dimensional heat equation with MOLE mimetic operators.

This is a Python implementation of
``examples/octave/parabolic1D.m``.

The problem is

    u_t = alpha * u_xx,       0 <= x <= 1,

with initial condition ``u(x, 0) = 0`` at the interior locations and fixed
Dirichlet boundary values ``u(0, t) = u(1, t) = 100``.  The spatial second
derivative is supplied by :class:`pymole.Laplacian`.

SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
"""

from __future__ import annotations

import argparse
from time import perf_counter

import numpy as np
from numpy.typing import NDArray
from scipy import sparse
from scipy.sparse.linalg import factorized

from pymole import Grid, Laplacian


FloatArray = NDArray[np.float64]


def parabolic1d(
    alpha: float = 1.0,
    west: float = 0.0,
    east: float = 1.0,
    accuracy_order: int = 2,
    final_time: float = 1.0,
    scheme: str = "explicit",
    time_step: float | None = None,
    animate: bool = False,
    animation_pause: float = 0.01,
) -> tuple[FloatArray, FloatArray, float, float, int]:
    """Solve the 1D heat equation.

    Parameters
    ----------
    alpha:
        Thermal diffusivity.
    west, east:
        Domain limits, with ``west < east``.
    accuracy_order:
        Mimetic operator order.  The current Python implementation supports
        orders 2, 4, and 6.
    final_time:
        Requested simulation time.
    scheme:
        Either ``"explicit"`` for forward Euler or ``"implicit"`` for
        backward Euler.
    time_step:
        Time step.  If omitted, use the stability-oriented value from the
        Octave example: ``dx**2/(3*alpha)`` for order 2 and
        ``dx**2/(4*alpha)`` for higher orders.
    animate:
        If ``True``, display the temperature profile during every time-step
        iteration, matching the Octave example's animation loop.
    animation_pause:
        Delay in seconds between animation frames.

    Returns
    -------
    x, temperature, elapsed_time, actual_time, steps:
        The staggered coordinates, final temperature, measured solve time,
        simulated time, and number of time steps.
    """

    if alpha <= 0.0:
        raise ValueError("alpha must be positive")
    if east <= west:
        raise ValueError("east must be greater than west")
    if final_time < 0.0:
        raise ValueError("final_time must be nonnegative")
    if scheme not in {"explicit", "implicit"}:
        raise ValueError("scheme must be 'explicit' or 'implicit'")

    minimum_cells = 2 * accuracy_order + 1
    cells = minimum_cells
    dx = (east - west) / cells
    if time_step is None:
        denominator = 3.0 if accuracy_order <= 2 else 4.0
        time_step = dx**2 / (denominator * alpha)
    if time_step <= 0.0:
        raise ValueError("time_step must be positive")
    if animation_pause < 0.0:
        raise ValueError("animation_pause must be nonnegative")

    # Grid.x has m+1 points for the m cells used to construct the operators.
    # The scalar solution has m+2 entries: two boundaries and m staggered
    # cell-center values, matching the MATLAB/Octave implementation.
    grid = Grid.generate(west, east, shape=cells + 1)
    x = np.concatenate(
        (
            [west],
            west + dx / 2.0 + dx * np.arange(cells),
            [east],
        )
    )

    laplacian = Laplacian(grid, accuracy_order=accuracy_order).matrix
    # The boundary rows of the mimetic Laplacian are zero.  Adding the
    # identity matrix therefore keeps the prescribed boundary values fixed.
    identity = sparse.eye(laplacian.shape[0], format="csr")
    if scheme == "explicit":
        update_matrix = identity + alpha * time_step * laplacian
        solve_step = lambda value: update_matrix @ value
    else:
        system_matrix = identity - alpha * time_step * laplacian
        solve = factorized(system_matrix.tocsc())
        solve_step = solve

    temperature = np.zeros(x.size, dtype=float)
    temperature[[0, -1]] = 100.0

    if animate:
        import matplotlib.pyplot as plt

        plt.ion()
        figure, axes = plt.subplots()
        (temperature_line,) = axes.plot(x, temperature, "o-")
        axes.set_xlim(west, east)
        axes.set_ylim(0.0, 105.0)
        axes.set_xlabel("x")
        axes.set_ylabel("T")
        axes.grid(True)

    # The original example advances through t/dt+1 iterations.  Using ceil
    # gives an integer number of steps while preserving that extra update.
    steps = int(np.ceil(final_time / time_step)) + 1

    start = perf_counter()
    for iteration in range(steps):
        if animate:
            # This is the Python equivalent of the Octave loop's plot call:
            # plot(grid, U, 'o-') at i = 0 : t/dt+1.
            temperature_line.set_ydata(temperature)
            axes.set_title(
                f"{scheme.capitalize()} heat equation, "
                f"t = {iteration * time_step:.2f}"
            )
            figure.canvas.draw_idle()
            figure.canvas.flush_events()
            if animation_pause > 0.0:
                plt.pause(animation_pause)

        temperature = np.asarray(solve_step(temperature), dtype=float).reshape(-1)
        # Keep the prescribed boundary values explicit, which also makes the
        # boundary behavior clear for the explicit update.
        temperature[[0, -1]] = 100.0
    elapsed_time = perf_counter() - start

    if animate:
        plt.ioff()
        plt.show()

    return x, temperature, elapsed_time, steps * time_step, steps


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--scheme",
        choices=("explicit", "implicit"),
        default="explicit",
        help="time integration scheme (default: explicit)",
    )
    parser.add_argument(
        "--order",
        type=int,
        default=2,
        choices=(2, 4, 6),
        help="mimetic spatial order (default: 2)",
    )
    parser.add_argument("--alpha", type=float, default=1.0)
    parser.add_argument("--final-time", type=float, default=1.0)
    parser.add_argument(
        "--dt",
        type=float,
        default=None,
        help="time step; otherwise use the example's default",
    )
    parser.add_argument(
        "--no-plot",
        action="store_true",
        help="run without opening an animated Matplotlib window",
    )
    parser.add_argument(
        "--pause",
        type=float,
        default=0.01,
        help="pause between animation frames in seconds (default: 0.01)",
    )
    args = parser.parse_args()

    x, temperature, elapsed, actual_time, steps = parabolic1d(
        alpha=args.alpha,
        accuracy_order=args.order,
        final_time=args.final_time,
        scheme=args.scheme,
        time_step=args.dt,
        animate=not args.no_plot,
        animation_pause=args.pause,
    )

    print(f"scheme:       {args.scheme}")
    print(f"order:        {args.order}")
    print(f"grid points:  {x.size}")
    print(f"time steps:   {steps}")
    print(f"actual time:  {actual_time:.6f}")
    print(f"elapsed time: {elapsed:.6f} s")
    print(f"temperature:  [{temperature.min():.6f}, {temperature.max():.6f}]")

if __name__ == "__main__":
    main()
