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
from pymole import Grid, Divergence

class TestDivergence:

    def test_unsupported_accuracy_order(self):

        grid = Grid.generate(
            0,
            10,
            shape=10,
        )

        with pytest.raises(ValueError):
            Divergence(
                grid,
                accuracy_order=4,
            )

    def test_grid_too_small_1d(self):

        grid = Grid.generate(
            0,
            10,
            shape=5,
        )

        with pytest.raises(ValueError):
            Divergence(
                grid,
                2,
            )

    def test_grid_too_small_2d(self):

        grid = Grid.generate(
            [0, 0],
            [10, 10],
            shape=[5, 10],
        )

        with pytest.raises(ValueError):
            Divergence(
                grid,
                2,
            )

    def test_1d_matrix_shape(self):

        grid = Grid.generate(
            0,
            1.2,
            shape=7,
        )

        D = Divergence(
            grid,
            2,
        ).matrix

        m = grid.num_cells

        assert D.shape == (
            m + 2,
            m + 1,
        )

    def test_2d_matrix_shape(self):

        grid = Grid.generate(
            [0, 0],
            [3, 2],
            shape=[7, 6],
        )

        D = Divergence(
            grid,
            2,
        ).matrix

        m, n = grid.num_cells

        expected_columns = (
            2 * m * n
            + m
            + n
        )

        expected_rows = (
            (m + 2)
            * (n + 2)
        )

        assert D.shape == (
            expected_rows,
            expected_columns,
        )

    def test_1d_constant_field(self):

        grid = Grid.generate(
            0.0,
            1.2,
            shape=7,
        )

        D = Divergence(
            grid,
            2,
        ).matrix

        m = grid.num_cells

        v = np.ones(
            m + 1
        )

        div_v = D @ v

        assert np.allclose(
            div_v,
            0.0,
            atol=1e-12,
        )

    def test_2d_constant_field(self):

        grid = Grid.generate(
            [0.0, 0.0],
            [3.0, 2.0],
            shape=[7, 6],
        )

        D = Divergence(
            grid,
            2,
        ).matrix

        m, n = grid.num_cells

        vector_size = (
            2 * m * n
            + m
            + n
        )

        v = np.ones(
            vector_size
        )

        div_v = D @ v

        assert np.allclose(
            div_v,
            0.0,
            atol=1e-12,
        )
