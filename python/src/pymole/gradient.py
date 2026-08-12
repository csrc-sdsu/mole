'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

import numpy as np
from scipy import sparse


class Gradient:
    """
    Unified gradient operator supporting 1D, 2D, and 3D Grid objects.
    """

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim not in (1, 2, 3):
            raise ValueError(
                f"Gradient currently supports 1D, 2D, and 3D grids. "
                f"Got ndim={self.grid.ndim}"
            )

        self._matrices = self._construct_matrices()

    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return 2 * accuracy_order + 1

    @property
    def matrices(self):
        """Returns tuple of gradient matrices (Gx,) for 1D, (Gx, Gy) for 2D, or (Gx, Gy, Gz) for 3D."""
        return self._matrices

    @property
    def matrix(self):
        """Returns the combined gradient matrix for divergence-based Laplacian."""
        match self.grid.ndim:
            case 1:
                return self._construct_1d()
            case 2:
                return self._construct_2d_matrix()
            case 3:
                raise NotImplementedError(
                    "Gradient.matrix is only available for 1D and 2D grids."
                )
            case _:
                raise ValueError(
                    f"Unsupported grid dimension: {self.grid.ndim}"
                )

    def _construct_matrices(self):
        if self.accuracy_order not in (2, 4, 6):
            raise ValueError(
                f"Unsupported order of accuracy: {self.accuracy_order}"
            )

        match self.grid.ndim:

            case 1:
                return (self._construct_1d(),)

            case 2:
                if self.accuracy_order != 2:
                    raise ValueError(
                        f"Unsupported order of accuracy for 2D Gradient: {self.accuracy_order}"
                    )
                Gx, Gy = self._construct_2d()
                return (Gx, Gy)

            case 3:
                if self.accuracy_order != 2:
                    raise ValueError(
                        f"Unsupported order of accuracy for 3D Gradient: {self.accuracy_order}"
                    )
                Gx, Gy, Gz = self._construct_3d()
                return (Gx, Gy, Gz)

            case _:
                raise ValueError(
                    f"Unsupported grid dimension: {self.grid.ndim}"
                )

    def _construct_1d(self):
        """Constructs 1D gradient operator from nodal scalar values."""

        n = len(self.grid.x)
        dx = self.grid.spacing

        if n < self.minimum_cells_for_order(self.accuracy_order):
            raise ValueError(
                f"Grid requires at least "
                f"{self.minimum_cells_for_order(self.accuracy_order)} "
                f"points for order {self.accuracy_order}"
            )

        m = self.grid.num_cells
        return self._build_1d_gradient_mimetic(m, dx)

    def _build_1d_gradient_mimetic(self, m: int, dx: float):
        """Builds 1D non-periodic mimetic gradient (MATLAB gradNonPeriodic)."""

        G = sparse.lil_matrix((m + 1, m + 2), dtype=float)

        match self.accuracy_order:
            case 2:
                A = np.array([-8.0 / 3.0, 3.0, -1.0 / 3.0])
                G[0, 0:3] = A
                G[m, m - 1 : m + 2] = -A[::-1]

                for i in range(1, m):
                    G[i, i : i + 2] = [-1.0, 1.0]

            case 4:
                A = np.array(
                    [
                        [-352.0 / 105.0, 35.0 / 8.0, -35.0 / 24.0, 21.0 / 40.0, -5.0 / 56.0],
                        [16.0 / 105.0, -31.0 / 24.0, 29.0 / 24.0, -3.0 / 40.0, 1.0 / 168.0],
                    ]
                )
                G[0:2, 0:5] = A
                G[m - 1 : m + 1, m - 3 : m + 2] = -np.rot90(A, 2)

                for i in range(2, m - 1):
                    G[i, i - 1 : i + 3] = [1.0 / 24.0, -9.0 / 8.0, 9.0 / 8.0, -1.0 / 24.0]

            case 6:
                A = np.array(
                    [
                        [
                            -13016.0 / 3465.0,
                            693.0 / 128.0,
                            -385.0 / 128.0,
                            693.0 / 320.0,
                            -495.0 / 448.0,
                            385.0 / 1152.0,
                            -63.0 / 1408.0,
                        ],
                        [
                            496.0 / 3465.0,
                            -811.0 / 640.0,
                            449.0 / 384.0,
                            -29.0 / 960.0,
                            -11.0 / 448.0,
                            13.0 / 1152.0,
                            -37.0 / 21120.0,
                        ],
                        [
                            -8.0 / 385.0,
                            179.0 / 1920.0,
                            -153.0 / 128.0,
                            381.0 / 320.0,
                            -101.0 / 1344.0,
                            1.0 / 128.0,
                            -3.0 / 7040.0,
                        ],
                    ]
                )
                G[0:3, 0:7] = A
                G[m - 2 : m + 1, m - 5 : m + 2] = -np.rot90(A, 2)

                for i in range(3, m - 2):
                    G[i, i - 2 : i + 4] = [-3.0 / 640.0, 25.0 / 384.0, -75.0 / 64.0, 75.0 / 64.0, -25.0 / 384.0, 3.0 / 640.0]

            case _:
                raise ValueError(
                    f"Unsupported order of accuracy: {self.accuracy_order}"
                )

        return (G / dx).tocsr()

    def _construct_2d(self):
        """Constructs 2D gradient operators from nodal scalar values."""

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

        Gx = self._build_2d_gradient_x(m, n, dx)
        Gy = self._build_2d_gradient_y(m, n, dy)

        return Gx, Gy

    def _construct_2d_matrix(self):
        """Constructs the combined 2D gradient matrix [Gx; Gy]."""

        Gx, Gy = self._construct_2d()
        return sparse.vstack([Gx, Gy], format="csr")

    def _construct_3d(self):
        """Constructs 3D gradient operators (du/dx, du/dy, du/dz)."""

        m, n, p = self.grid.X.shape
        dx, dy, dz = self.grid.spacing

        minimum_points = self.minimum_cells_for_order(
            self.accuracy_order
        )

        if m < minimum_points or n < minimum_points or p < minimum_points:
            raise ValueError(
                f"All dimensions require at least "
                f"{minimum_points} points."
            )

        Gx = self._build_3d_gradient_x(m, n, p, dx)
        Gy = self._build_3d_gradient_y(m, n, p, dy)
        Gz = self._build_3d_gradient_z(m, n, p, dz)

        return Gx, Gy, Gz

    def _build_1d_gradient(self, n: int, dx: float):
        """Builds square 1D central-difference gradient used by 3D helpers."""

        G = sparse.lil_matrix((n, n), dtype=float)
        
        # Central differences for interior points: du/dx ≈ (u[i+1] - u[i-1]) / (2*dx)
        for i in range(1, n - 1):
            G[i, i - 1] = -1.0 / (2.0 * dx)
            G[i, i + 1] = 1.0 / (2.0 * dx)
        
        # Forward difference at left boundary: du/dx ≈ (u[1] - u[0]) / dx
        G[0, 0] = -1.0 / dx
        G[0, 1] = 1.0 / dx
        
        # Backward difference at right boundary: du/dx ≈ (u[n-1] - u[n-2]) / dx
        G[n - 1, n - 2] = -1.0 / dx
        G[n - 1, n - 1] = 1.0 / dx

        return G.tocsr()

    def _build_2d_gradient_x(self, m: int, n: int, dx: float):
        """Builds 2D gradient operator in x-direction."""

        rows = n * (m + 1)
        cols = (m + 1) * (n + 1)
        G = sparse.lil_matrix((rows, cols), dtype=float)

        for yi in range(n):
            for xj in range(m + 1):
                row = yi * (m + 1) + xj
                base = yi * (m + 1)
                if xj == 0:
                    G[row, base + xj] = -1.0 / dx
                    G[row, base + xj + 1] = 1.0 / dx
                elif xj == m:
                    G[row, base + xj - 1] = -1.0 / dx
                    G[row, base + xj] = 1.0 / dx
                else:
                    G[row, base + xj - 1] = -1.0 / (2.0 * dx)
                    G[row, base + xj + 1] = 1.0 / (2.0 * dx)

        return G.tocsr()

    def _build_2d_gradient_y(self, m: int, n: int, dy: float):
        """Builds 2D gradient operator in y-direction."""

        rows = m * (n + 1)
        cols = (m + 1) * (n + 1)
        G = sparse.lil_matrix((rows, cols), dtype=float)

        for xj in range(m):
            for yi in range(n + 1):
                row = xj * (n + 1) + yi
                col_bottom = yi * (m + 1) + xj
                col_top = (yi + 1) * (m + 1) + xj
                if yi == 0:
                    G[row, col_bottom] = -1.0 / dy
                    G[row, col_top] = 1.0 / dy
                elif yi == n:
                    G[row, col_bottom - (m + 1)] = -1.0 / dy
                    G[row, col_bottom] = 1.0 / dy
                else:
                    G[row, col_bottom - (m + 1)] = -1.0 / (2.0 * dy)
                    G[row, col_top] = 1.0 / (2.0 * dy)

        return G.tocsr()

    def _build_3d_gradient_x(self, m: int, n: int, p: int, dx: float):
        """Builds 3D gradient operator in x-direction."""

        Gx_1d = self._build_1d_gradient(n, dx)
        Im = sparse.eye(m, format="csr")
        Ip = sparse.eye(p, format="csr")

        return sparse.kron(sparse.kron(Im, Gx_1d, format="csr"), Ip, format="csr")

    def _build_3d_gradient_y(self, m: int, n: int, p: int, dy: float):
        """Builds 3D gradient operator in y-direction."""

        Gy_1d = self._build_1d_gradient(m, dy)
        In = sparse.eye(n, format="csr")
        Ip = sparse.eye(p, format="csr")

        return sparse.kron(sparse.kron(Gy_1d, In, format="csr"), Ip, format="csr")

    def _build_3d_gradient_z(self, m: int, n: int, p: int, dz: float):
        """Builds 3D gradient operator in z-direction."""

        Gz_1d = self._build_1d_gradient(p, dz)
        Im = sparse.eye(m, format="csr")
        In = sparse.eye(n, format="csr")

        return sparse.kron(sparse.kron(Im, In, format="csr"), Gz_1d, format="csr")
