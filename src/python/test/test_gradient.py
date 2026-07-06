'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

import numpy as np
import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from pymole import Grid, Gradient

class TestGradient:

    def test_unsupported_accuracy_order(self):

        grid = Grid.generate(
            0,
            10,
            shape=10,
        )

        with pytest.raises(ValueError):
            Gradient(
                grid,
                accuracy_order=4,
            )

    def test_grid_too_small_1d(self):

        grid = Grid.generate(
            0,
            10,
            shape=4,
        )

        with pytest.raises(ValueError):
            Gradient(
                grid,
                2,
            )

    def test_grid_too_small_2d(self):

        grid = Grid.generate(
            [0, 0],
            [10, 10],
            shape=[4, 4],
        )

        with pytest.raises(ValueError):
            Gradient(
                grid,
                2,
            )

    def test_grid_too_small_3d(self):

        grid = Grid.generate(
            [0, 0, 0],
            [10, 10, 10],
            shape=[3, 5, 6],
        )

        with pytest.raises(ValueError):
            Gradient(
                grid,
                2,
            )

    def test_1d_matrix_shape(self):

        grid = Grid.generate(
            0,
            1.2,
            shape=7,
        )

        Gx = Gradient(
            grid,
            2,
        ).matrices[0]

        n = len(grid.x)

        assert Gx.shape == (
            n,
            n,
        )

    def test_2d_matrix_shape(self):

        grid = Grid.generate(
            [0, 0],
            [3, 2],
            shape=[7, 6],
        )

        Gx, Gy = Gradient(
            grid,
            2,
        ).matrices

        m, n = grid.num_cells
        total_nodes = (m + 1) * (n + 1)

        assert Gx.shape == (n * (m + 1), total_nodes)
        assert Gy.shape == (m * (n + 1), total_nodes)

    def test_3d_matrix_shape(self):

        grid = Grid.generate(
            [0, 0, 0],
            [3, 2, 4],
            shape=[5, 6, 7],
        )

        Gx, Gy, Gz = Gradient(
            grid,
            2,
        ).matrices

        m, n, p = grid.X.shape

        total_nodes = m * n * p

        assert Gx.shape == (total_nodes, total_nodes)
        assert Gy.shape == (total_nodes, total_nodes)
        assert Gz.shape == (total_nodes, total_nodes)

    def test_1d_constant_field(self):

        grid = Grid.generate(
            0.0,
            1.2,
            shape=7,
        )

        Gx = Gradient(
            grid,
            2,
        ).matrices[0]

        n = len(grid.x)

        u = np.ones(n)

        grad_u = Gx @ u

        assert np.allclose(
            grad_u,
            0.0,
            atol=1e-12,
        )

    def test_2d_constant_field(self):

        grid = Grid.generate(
            [0.0, 0.0],
            [3.0, 2.0],
            shape=[7, 6],
        )

        Gx, Gy = Gradient(
            grid,
            2,
        ).matrices

        m, n = grid.X.shape

        total_nodes = m * n

        u = np.ones(total_nodes)

        grad_u_x = Gx @ u
        grad_u_y = Gy @ u

        assert np.allclose(grad_u_x, 0.0, atol=1e-12)
        assert np.allclose(grad_u_y, 0.0, atol=1e-12)

    def test_3d_constant_field(self):

        grid = Grid.generate(
            [0.0, 0.0, 0.0],
            [3.0, 2.0, 4.0],
            shape=[5, 6, 7],
        )

        Gx, Gy, Gz = Gradient(
            grid,
            2,
        ).matrices

        m, n, p = grid.X.shape

        total_nodes = m * n * p

        u = np.ones(total_nodes)

        grad_u_x = Gx @ u
        grad_u_y = Gy @ u
        grad_u_z = Gz @ u

        assert np.allclose(grad_u_x, 0.0, atol=1e-12)
        assert np.allclose(grad_u_y, 0.0, atol=1e-12)
        assert np.allclose(grad_u_z, 0.0, atol=1e-12)

    def test_1d_linear_field(self):

        grid = Grid.generate(
            0.0,
            10.0,
            shape=11,
        )

        Gx = Gradient(
            grid,
            2,
        ).matrices[0]

        # u = 2*x, so du/dx = 2
        u = 2 * grid.x

        grad_u = Gx @ u

        # Should be approximately 2 everywhere
        assert np.allclose(
            grad_u,
            2.0,
            atol=1e-10,
        )

    def test_2d_linear_field_x(self):

        grid = Grid.generate(
            [0.0, 0.0],
            [10.0, 10.0],
            shape=[11, 11],
        )

        Gx, Gy = Gradient(
            grid,
            2,
        ).matrices

        # u = 2*x, so du/dx = 2, du/dy = 0
        u = 2 * grid.X.flatten()

        grad_u_x = Gx @ u
        grad_u_y = Gy @ u

        assert np.allclose(grad_u_x, 2.0, atol=1e-10)
        assert np.allclose(grad_u_y, 0.0, atol=1e-12)

    def test_2d_linear_field_y(self):

        grid = Grid.generate(
            [0.0, 0.0],
            [10.0, 10.0],
            shape=[11, 11],
        )

        Gx, Gy = Gradient(
            grid,
            2,
        ).matrices

        # u = 3*y, so du/dx = 0, du/dy = 3
        u = 3 * grid.Y.flatten()

        grad_u_x = Gx @ u
        grad_u_y = Gy @ u

        assert np.allclose(grad_u_x, 0.0, atol=1e-12)
        assert np.allclose(grad_u_y, 3.0, atol=1e-10)
