import numpy as np
import pytest

from pymole.dim1d.grid import Grid1D
from pymole.dim2d.gradient import Gradient2D


@pytest.fixture
def a_second_order_gradient():
    x_grid = Grid1D(0.0, 3.0, 6)
    y_grid = Grid1D(0.0, 2.0, 5)
    return Gradient2D(x_grid, y_grid, 2)


class TestGradient2DConstruction:
    def test_minimum_cells_for_gradient(self):
        x_grid_too_small = Grid1D(0.0, 0.3, 3)
        y_grid_ok = Grid1D(0.0, 1.0, 4)
        with pytest.raises(ValueError):
            Gradient2D(x_grid_too_small, y_grid_ok, 2)

        x_grid_ok = Grid1D(0.0, 0.4, 4)
        y_grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            Gradient2D(x_grid_ok, y_grid_too_small, 2)

        x_grid = Grid1D(0.0, 0.4, 4)
        y_grid = Grid1D(0.0, 0.4, 4)
        gradient = Gradient2D(x_grid, y_grid, 2)

        assert gradient.x_grid.num_cells == 4
        assert gradient.y_grid.num_cells == 4

    def test_unsupported_accuracy_order_raises_error(self):
        x_grid = Grid1D(0.0, 1.0, 10)
        y_grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            gradient = Gradient2D(x_grid, y_grid, 4)
            _ = gradient.matrix


class TestGradient2DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_gradient):
        m = a_second_order_gradient.x_grid.num_cells
        n = a_second_order_gradient.y_grid.num_cells
        G = a_second_order_gradient.matrix

        assert G.shape == (2 * m * n + m + n, (m + 2) * (n + 2))

    def test_constant_field_gradient_is_zero(self, a_second_order_gradient):
        m = a_second_order_gradient.x_grid.num_cells
        n = a_second_order_gradient.y_grid.num_cells
        f_constant = np.ones((m + 2) * (n + 2))
        G = a_second_order_gradient.matrix
        grad_f = G @ f_constant

        assert np.allclose(grad_f, 0.0, atol=1e-12)

    def test_row_sums_are_zero(self, a_second_order_gradient):
        G = a_second_order_gradient.matrix
        row_sums = G.sum(axis=1).A1

        assert np.allclose(row_sums, 0.0, atol=1e-12)
