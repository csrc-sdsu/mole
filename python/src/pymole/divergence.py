'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

import numpy as np
from scipy import sparse


class Divergence:
    """
    Unified divergence operator supporting 1D and 2D Grid objects.
    """

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim not in (1, 2):
            raise ValueError(
                f"Divergence currently supports only 1D and 2D grids. "
                f"Got ndim={self.grid.ndim}"
            )

        self._matrix = self._construct_matrix()

    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return 2 * accuracy_order + 1

    @property
    def matrix(self):
        return self._matrix

    def _construct_matrix(self):
        if self.accuracy_order not in (2, 4, 6):
            raise ValueError(
                f"Unsupported order of accuracy: {self.accuracy_order}"
            )

        match self.grid.ndim:

            case 1:
                return self._construct_1d()

            case 2:
                if self.accuracy_order != 2:
                    raise ValueError(
                        f"Unsupported order of accuracy for 2D Divergence: {self.accuracy_order}"
                    )
                return self._construct_2d()

            case _:
                raise ValueError(
                    f"Unsupported grid dimension: {self.grid.ndim}"
                )

    def _construct_1d(self):

        m = self.grid.num_cells

        # In this Grid API, users often specify the number of points via shape.
        # Validate against points so k=2,4,6 examples match MATLAB-style usage.
        num_points = len(self.grid.x)

        if num_points < self.minimum_cells_for_order(self.accuracy_order):
            raise ValueError(
                f"Grid requires at least "
                f"{self.minimum_cells_for_order(self.accuracy_order)} "
                f"points for order {self.accuracy_order}"
            )

        dx = self.grid.spacing

        return self._build_1d_divergence(m, dx)

    def _construct_2d(self):

        m, n = self.grid.num_cells
        dx, dy = self.grid.spacing

        minimum_cells = self.minimum_cells_for_order(
            self.accuracy_order
        )

        if m < minimum_cells or n < minimum_cells:
            raise ValueError(
                f"Both dimensions require at least "
                f"{minimum_cells} cells."
            )

        return self._build_2d_divergence(
            m,
            n,
            dx,
            dy,
        )

    def _build_1d_divergence(
        self,
        m: int,
        dx: float,
    ):

        D = sparse.lil_matrix((m + 2, m + 1), dtype=float)

        match self.accuracy_order:
            case 2:
                for i in range(1, m + 1):
                    D[i, i - 1 : i + 1] = [-1.0, 1.0]

            case 4:
                A = np.array([-11.0 / 12.0, 17.0 / 24.0, 3.0 / 8.0, -5.0 / 24.0, 1.0 / 24.0])
                D[1, 0:5] = A
                D[m, m - 4 : m + 1] = -A[::-1]

                for i in range(2, m):
                    D[i, i - 2 : i + 2] = [1.0 / 24.0, -9.0 / 8.0, 9.0 / 8.0, -1.0 / 24.0]

            case 6:
                A = np.array(
                    [
                        [
                            -1627.0 / 1920.0,
                            211.0 / 640.0,
                            59.0 / 48.0,
                            -235.0 / 192.0,
                            91.0 / 128.0,
                            -443.0 / 1920.0,
                            31.0 / 960.0,
                        ],
                        [
                            31.0 / 960.0,
                            -687.0 / 640.0,
                            129.0 / 128.0,
                            19.0 / 192.0,
                            -3.0 / 32.0,
                            21.0 / 640.0,
                            -3.0 / 640.0,
                        ],
                    ]
                )
                D[1:3, 0:7] = A
                D[m - 1 : m + 1, m - 6 : m + 1] = -np.rot90(A, 2)

                for i in range(3, m - 1):
                    D[i, i - 3 : i + 3] = [-3.0 / 640.0, 25.0 / 384.0, -75.0 / 64.0, 75.0 / 64.0, -25.0 / 384.0, 3.0 / 640.0]

            case _:
                raise ValueError(
                    f"Unsupported order of accuracy: {self.accuracy_order}"
                )

        return (D / dx).tocsr()

    def _build_2d_divergence(
        self,
        m: int,
        n: int,
        dx: float,
        dy: float,
    ):

        Dx = self._build_1d_divergence(
            m,
            dx,
        )

        Dy = self._build_1d_divergence(
            n,
            dy,
        )

        Im = sparse.eye(
            m + 2,
            format="csr",
        )[:, 1:-1]

        In = sparse.eye(
            n + 2,
            format="csr",
        )[:, 1:-1]

        Sx = sparse.kron(
            In,
            Dx,
            format="csr",
        )

        Sy = sparse.kron(
            Dy,
            Im,
            format="csr",
        )

        return sparse.hstack(
            [Sx, Sy],
            format="csr",
        )
