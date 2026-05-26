import numpy as np
import pytest

from pymole.dim1d.grid import Grid1D
from pymole.dim2d.divergence import Divergence2D


@pytest.fixture
def a_second_order_divergence():
    x_grid = Grid1D(0.0, 3.0, 6)
    y_grid = Grid1D(0.0, 2.0, 5)
    return Divergence2D(x_grid, y_grid, 2)


class TestDivergence2DConstruction:
    def test_minimum_cells_for_divergence(self):
        x_grid_too_small = Grid1D(0.0, 0.4, 4)
        y_grid_ok = Grid1D(0.0, 1.0, 5)
        with pytest.raises(ValueError):
            Divergence2D(x_grid_too_small, y_grid_ok, 2)

        x_grid_ok = Grid1D(0.0, 0.5, 5)
        y_grid_too_small = Grid1D(0.0, 0.4, 4)
        with pytest.raises(ValueError):
            Divergence2D(x_grid_ok, y_grid_too_small, 2)

        x_grid = Grid1D(0.0, 0.5, 5)
        y_grid = Grid1D(0.0, 0.5, 5)
        divergence = Divergence2D(x_grid, y_grid, 2)

        assert divergence.x_grid.num_cells == 5
        assert divergence.y_grid.num_cells == 5

    def test_unsupported_accuracy_order_raises_error(self):
        x_grid = Grid1D(0.0, 1.0, 10)
        y_grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            divergence = Divergence2D(x_grid, y_grid, 4)
            _ = divergence.matrix


class TestDivergence2DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_divergence):
        m = a_second_order_divergence.x_grid.num_cells
        n = a_second_order_divergence.y_grid.num_cells
        D = a_second_order_divergence.matrix

        assert D.shape == ((m + 2) * (n + 2), 2 * m * n + m + n)

    def test_constant_field_divergence_is_zero(self, a_second_order_divergence):
        m = a_second_order_divergence.x_grid.num_cells
        n = a_second_order_divergence.y_grid.num_cells
        v_constant = np.ones(2 * m * n + m + n)
        D = a_second_order_divergence.matrix
        div_v = D @ v_constant

        assert np.allclose(div_v, 0.0, atol=1e-12)
