"""
SPDX-License-Identifier: GPL-3.0-or-later
© 2008-2024 San Diego State University Research Foundation (SDSURF).
See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.

Compute the 2D scalar curl of F = (u, v) = (-y, x) on [-10, 10]^2.
The exact curl, dv/dx - du/dy, is 2 everywhere.
"""

import matplotlib.pyplot as plt
import numpy as np

from pymole import Curl, Grid


def main():
    west, east = -10.0, 10.0
    south, north = -10.0, 10.0
    num_cells_x = num_cells_y = 20

    grid = Grid.generate(
        [west, south],
        [east, north],
        shape=[num_cells_x + 1, num_cells_y + 1],
    )

    x_faces = np.linspace(west, east, num_cells_x + 1)
    y_faces = np.linspace(south, north, num_cells_y + 1)
    x_centers = (x_faces[:-1] + x_faces[1:]) / 2.0
    y_centers = (y_faces[:-1] + y_faces[1:]) / 2.0

    # v is sampled at x-faces/y-centers; u at x-centers/y-faces.
    x_for_v, _ = np.meshgrid(x_faces, y_centers, indexing="xy")
    _, y_for_u = np.meshgrid(x_centers, y_faces, indexing="xy")
    v = x_for_v.ravel()
    u = -y_for_u.ravel()

    curl = Curl(grid).apply(u, v)
    curl = curl.reshape(num_cells_y + 2, num_cells_x + 2)
    interior_curl = curl[1:-1, 1:-1]
    max_error = np.max(np.abs(interior_curl - 2.0))
    print(f"Maximum interior curl error: {max_error:.6e}")

    x_center_grid, y_center_grid = np.meshgrid(
        x_centers, y_centers, indexing="xy"
    )
    plt.quiver(
        x_center_grid,
        y_center_grid,
        -y_center_grid,
        x_center_grid,
        interior_curl,
        cmap="viridis",
    )
    plt.colorbar(label="curl")
    plt.title(r"Curl of $\mathbf{F}=(-y,x)$")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.axis("equal")
    plt.show()


if __name__ == "__main__":
    main()
