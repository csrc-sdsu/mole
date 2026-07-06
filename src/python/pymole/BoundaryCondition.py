from abc import ABC, abstractmethod

import numpy as np
from scipy import sparse


class BoundaryCondition(ABC):
    @abstractmethod
    def apply(self):
        """Subclasses must implement this."""
        raise NotImplementedError

    def isImplemented(self) -> bool:
        """Returns True if the boundary condition is implemented."""
        return self.apply != BoundaryCondition.apply

    @classmethod
    def hasImplemented(cls, bc) -> bool:
        """Returns True if the boundary condition is implemented."""
        return bc.apply != BoundaryCondition.apply

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim not in (1, 2, 3):
            raise ValueError(
                f"BoundaryCondition currently supports 1D, 2D, and 3D grids. "
                f"Got ndim={self.grid.ndim}"
            )

        self._configure_dimensions()
        self._matrix = None

    def _configure_dimensions(self) -> None:
        if self.grid.ndim == 1:
            self.m = self.grid.num_cells
            self.n = None
            self.o = None
        elif self.grid.ndim == 2:
            self.m, self.n = self.grid.num_cells
            self.o = None
        else:
            self.m, self.n, self.o = self.grid.num_cells

    @property
    def matrix(self):
        if self._matrix is None:
            self._matrix = self.apply()
        return self._matrix

    def _spacing_for_dimension(self, axis: int) -> float:
        spacing = self.grid.spacing
        if self.grid.ndim == 1:
            return spacing
        if self.grid.ndim == 2:
            return spacing[axis]
        return spacing[axis]

    def _build_1d_robin_matrix(self, size: int, dx: float, a: float, b: float):
        A = sparse.lil_matrix((size + 2, size + 2), dtype=float)
        A[0, 0] = a
        A[-1, -1] = a

        B = sparse.lil_matrix((size + 2, size + 1), dtype=float)
        B[0, 0] = -b
        B[-1, -1] = b

        G = self._build_1d_gradient(size, dx)
        return (A + B @ G).tocsr()

    def _build_1d_gradient(self, size: int, dx: float):
        G = sparse.lil_matrix((size + 1, size + 2), dtype=float)
        G[0, 0:3] = [-8.0 / 3.0, 3.0, -1.0 / 3.0]
        G[size, size - 1 : size + 2] = [1.0 / 3.0, -3.0, 8.0 / 3.0]

        for i in range(1, size):
            G[i, i : i + 2] = [-1.0, 1.0]

        return (G / dx).tocsr()
