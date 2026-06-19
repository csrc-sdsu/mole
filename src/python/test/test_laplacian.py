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
from pymole import Grid, Gradient, Divergence, Laplacian

class TestLaplacian:

    def test_unsupported_dimension(self):
        grid = Grid.generate([0, 0, 0], [10, 10, 10], shape=[5, 5, 5])

        with pytest.raises(ValueError):
            Laplacian(grid)

    def test_1d_matrix_shape(self):
        grid = Grid.generate(0.0, 1.0, shape=7)

        L = Laplacian(grid).matrix

        n = len(grid.x)

        assert L.shape == (n + 1, n)

    def test_2d_matrix_shape(self):
        grid = Grid.generate([0.0, 0.0], [3.0, 2.0], shape=[7, 6])

        L = Laplacian(grid).matrix

        m, n = grid.num_cells
        expected_rows = (m + 2) * (n + 2)
        expected_cols = (m + 1) * (n + 1)

        assert L.shape == (expected_rows, expected_cols)

    def test_2d_constant_field_shape(self):
        grid = Grid.generate([0.0, 0.0], [3.0, 2.0], shape=[7, 6])

        L = Laplacian(grid).matrix

        m, n = grid.num_cells
        total_nodes = (m + 1) * (n + 1)

        assert L.shape == ((m + 2) * (n + 2), total_nodes)

    def test_1d_constant_field(self):
        grid = Grid.generate(0.0, 1.0, shape=7)

        L = Laplacian(grid).matrix

        u = np.ones(len(grid.x))
        Lu = L @ u

        assert np.allclose(Lu, 0.0, atol=1e-12)

    def test_2d_constant_field(self):
        grid = Grid.generate([0.0, 0.0], [3.0, 2.0], shape=[7, 6])

        L = Laplacian(grid).matrix

        m, n = grid.num_cells
        total_nodes = (m + 1) * (n + 1)

        u = np.ones(total_nodes)
        Lu = L @ u

        assert np.allclose(Lu, 0.0, atol=1e-12)

    def test_1d_quadratic_field(self):
        grid = Grid.generate(0.0, 1.0, shape=7)

        L = Laplacian(grid).matrix
        x = grid.x

        u = x**2
        Lu = L @ u

        # For u = x^2, d^2u/dx^2 = 2 for the interior nodes.
        # The first and last rows correspond to boundary divergence values,
        # so we verify the interior portion only.
        assert np.allclose(Lu[2:-2], 2.0, atol=1e-1)
        assert np.isfinite(Lu).all()
