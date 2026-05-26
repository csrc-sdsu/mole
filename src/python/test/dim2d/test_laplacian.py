import numpy as np
import pytest

from pymole.dim1d.grid import Grid1D
from pymole.dim2d.divergence import Divergence2D
from pymole.dim2d.gradient import Gradient2D
from pymole.dim2d.laplacian import Laplacian2D


@pytest.fixture
def a_second_order_laplacian():
    x_grid = Grid1D(0.0, 3.0, 6)
    y_grid = Grid1D(0.0, 2.0, 5)
    return Laplacian2D(x_grid, y_grid, 2)


class TestLaplacian2DConstruction:
    def test_minimum_cells_for_laplacian(self):
        x_grid_too_small = Grid1D(0.0, 0.4, 4)
        y_grid_ok = Grid1D(0.0, 1.0, 5)
        with pytest.raises(ValueError):
            Laplacian2D(x_grid_too_small, y_grid_ok, 2)

        x_grid_ok = Grid1D(0.0, 0.5, 5)
        y_grid_too_small = Grid1D(0.0, 0.4, 4)
        with pytest.raises(ValueError):
            Laplacian2D(x_grid_ok, y_grid_too_small, 2)

        x_grid = Grid1D(0.0, 0.5, 5)
        y_grid = Grid1D(0.0, 0.5, 5)
        laplacian = Laplacian2D(x_grid, y_grid, 2)

        assert laplacian.x_grid.num_cells == 5
        assert laplacian.y_grid.num_cells == 5

    def test_unsupported_accuracy_order_raises_error(self):
        x_grid = Grid1D(0.0, 1.0, 10)
        y_grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            laplacian = Laplacian2D(x_grid, y_grid, 4)
            _ = laplacian.matrix


class TestLaplacian2DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_laplacian):
        m = a_second_order_laplacian.x_grid.num_cells
        n = a_second_order_laplacian.y_grid.num_cells
        L = a_second_order_laplacian.matrix

        assert L.shape == ((m + 2) * (n + 2), (m + 2) * (n + 2))

    def test_constant_field_laplacian_is_zero(self, a_second_order_laplacian):
        m = a_second_order_laplacian.x_grid.num_cells
        n = a_second_order_laplacian.y_grid.num_cells
        f_constant = np.ones((m + 2) * (n + 2))
        L = a_second_order_laplacian.matrix
        lap_f = L @ f_constant

        assert np.allclose(lap_f, 0.0, atol=1e-12)

    def test_laplacian_equals_divergence_times_gradient(self, a_second_order_laplacian):
        x_grid = a_second_order_laplacian.x_grid
        y_grid = a_second_order_laplacian.y_grid
        D = Divergence2D(x_grid, y_grid, 2).matrix
        G = Gradient2D(x_grid, y_grid, 2).matrix
        L = a_second_order_laplacian.matrix

        assert np.allclose((L - D @ G).toarray(), 0.0, atol=1e-12)
