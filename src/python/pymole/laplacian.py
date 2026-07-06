'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
import numpy as np
from pymole.divergence import Divergence
from pymole.gradient import Gradient

class Laplacian:
    """
    Unified Laplacian operator for 1D and 2D Grid objects.

    The Laplacian is constructed as the matrix product of divergence and
    gradient operators.
    """

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim not in (1, 2):
            raise ValueError(
                f"Laplacian currently supports only 1D and 2D grids. "
                f"Got ndim={self.grid.ndim}"
            )

        self._matrix = self._construct_matrix()

    @property
    def matrix(self):
        return self._matrix

    def _construct_matrix(self):
        D = Divergence(self.grid, self.accuracy_order)
        G = Gradient(self.grid, self.accuracy_order)

        return D.matrix @ G.matrix
