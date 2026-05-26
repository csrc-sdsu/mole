import numpy as np
import pytest

from pymole import Gradient1D
from pymole.dim1d.grid import Grid1D


@pytest.fixture
def a_second_order_gradient():
    grid = Grid1D(0.0, 3.0, 15)
    return Gradient1D(grid, 2)


class TestGradient1DConstruction:
    def test_minimum_cells_for_gradient(self):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            Gradient1D(grid_too_small, 2)

        grid_ok = Grid1D(0.0, 0.4, 4)
        gradient = Gradient1D(grid_ok, 2)

        assert gradient.x_grid.num_cells == 4

    def test_unsupported_accuracy_order_raises_error(self):
        grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            gradient = Gradient1D(grid, 4)
            _ = gradient.matrix


class TestGradient1DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_gradient):
        G = a_second_order_gradient.matrix
        num_cells = a_second_order_gradient.x_grid.num_cells

        assert G.shape == (num_cells + 1, num_cells + 2)

    def test_constant_field_gradient_is_zero(self, a_second_order_gradient):
        num_cells = a_second_order_gradient.x_grid.num_cells
        f_constant = np.ones(num_cells + 2)
        G = a_second_order_gradient.matrix
        grad_f = G @ f_constant

        assert np.allclose(grad_f, 0.0, atol=1e-12)

    def test_row_sums_are_zero(self, a_second_order_gradient):
        G = a_second_order_gradient.matrix
        row_sums = G.sum(axis=1).A1

        assert np.allclose(row_sums, 0.0, atol=1e-12)


class TestGradient1DSecondOrder:
    def test_second_order_boundary_stencil(self):
        grid = Grid1D(0.0, 1.0, 4)
        gradient = Gradient1D(grid, 2)
        delta_x = grid.cell_size

        G = gradient.matrix.toarray()

        expected_first_row = np.array([-8.0 / 3.0, 3.0, -1.0 / 3.0, 0, 0, 0]) / delta_x
        expected_last_row = np.array([0, 0, 0, 1.0 / 3.0, -3.0, 8.0 / 3.0]) / delta_x

        assert np.allclose(G[0, :], expected_first_row, atol=1e-12)
        assert np.allclose(G[-1, :], expected_last_row, atol=1e-12)

    def test_second_order_interior_stencil(self, a_second_order_gradient):
        num_cells = a_second_order_gradient.x_grid.num_cells
        delta_x = a_second_order_gradient.x_grid.cell_size

        G = a_second_order_gradient.matrix.toarray()

        for i in range(1, num_cells):
            row = G[i, :]
            non_zero_indices = np.where(np.abs(row) > 1e-12)[0]

            assert len(non_zero_indices) == 2
            assert row[i] == pytest.approx(-1.0 / delta_x)
            assert row[i + 1] == pytest.approx(1.0 / delta_x)
