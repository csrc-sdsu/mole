import numpy as np
import pytest

from pymole import Laplacian1D
from pymole.dim1d.divergence import Divergence1D
from pymole.dim1d.gradient import Gradient1D
from pymole.dim1d.grid import Grid1D


@pytest.fixture
def a_second_order_laplacian():
    grid = Grid1D(0.0, 1.2, 6)
    return Laplacian1D(grid, 2)


class TestLaplacian1DConstruction:
    def test_minimum_cells_for_laplacian(self):
        grid_too_small = Grid1D(0.0, 0.4, 4)
        with pytest.raises(ValueError):
            Laplacian1D(grid_too_small, 2)

        grid_ok = Grid1D(0.0, 0.5, 5)
        laplacian = Laplacian1D(grid_ok, 2)
        assert laplacian.x_grid.num_cells == 5

    def test_unsupported_accuracy_order_raises_error(self):
        grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            laplacian = Laplacian1D(grid, 4)
            _ = laplacian.matrix


class TestLaplacian1DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_laplacian):
        L = a_second_order_laplacian.matrix
        num_cells = a_second_order_laplacian.x_grid.num_cells

        assert L.shape == (num_cells + 2, num_cells + 2)

    def test_constant_field_laplacian_is_zero(self, a_second_order_laplacian):
        num_cells = a_second_order_laplacian.x_grid.num_cells
        f_constant = np.ones(num_cells + 2)
        L = a_second_order_laplacian.matrix
        lap_f = L @ f_constant

        assert np.allclose(lap_f, 0.0, atol=1e-12)

    def test_laplacian_equals_divergence_times_gradient(self, a_second_order_laplacian):
        grid = a_second_order_laplacian.x_grid
        D = Divergence1D(grid, 2).matrix
        G = Gradient1D(grid, 2).matrix
        L = a_second_order_laplacian.matrix

        assert np.allclose((L - D @ G).toarray(), 0.0, atol=1e-12)
