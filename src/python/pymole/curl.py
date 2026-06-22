'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

import numpy as np

from pymole.divergence import Divergence

class Curl:
    """
    Unified 2D curl operator for a staggered vector field.

    The operator is implemented as the divergence of a staggered field
    arranged as ``[v; -u]`` so that the discrete result corresponds to
    ``dv/dx - du/dy``.
    """

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim != 2:
            raise ValueError(
                f"Curl currently supports only 2D grids. "
                f"Got ndim={self.grid.ndim}"
            )

        self._matrix = self._construct_matrix()

    @property
    def matrix(self):
        return self._matrix

    def _construct_matrix(self):
        if self.accuracy_order != 2:
            raise ValueError(
                f"Unsupported order of accuracy: {self.accuracy_order}"
            )

        return Divergence(
            self.grid,
            self.accuracy_order,
        ).matrix

    def apply(self, u, v):
        """
        Apply the discrete curl to a staggered vector field.

        Parameters
        ----------
        u, v : array-like
            The two components of the vector field, already arranged in the
            staggered layout expected by the divergence operator.
        """
        if len(u) != self._matrix.shape[1] // 2 or len(v) != self._matrix.shape[1] // 2:
            raise ValueError(
                "Expected u and v to each provide half of the staggered vector layout."
            )

        return self._matrix @ np.concatenate([v, -u])
