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

        if self.accuracy_order != 2:
            raise ValueError(
                f"Unsupported order of accuracy: {self.accuracy_order}"
            )

        match self.grid.ndim:

            case 1:
                return self._construct_1d()

            case 2:
                return self._construct_2d()

            case _:
                raise ValueError(
                    f"Unsupported grid dimension: {self.grid.ndim}"
                )

    def _construct_1d(self):

        m = self.grid.num_cells

        if m < self.minimum_cells_for_order(self.accuracy_order):
            raise ValueError(
                f"Grid requires at least "
                f"{self.minimum_cells_for_order(self.accuracy_order)} "
                f"cells for order {self.accuracy_order}"
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

        main_diag = np.ones(m + 1)

        sub_diag = np.full(
            m + 1,
            -1.0,
        )

        main_diag[0] = 0.0
        sub_diag[-1] = 0.0

        D = sparse.diags(
            [sub_diag, main_diag],
            offsets=[-1, 0],
            shape=(m + 2, m + 1),
        ).tocsr()

        return D / dx

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
