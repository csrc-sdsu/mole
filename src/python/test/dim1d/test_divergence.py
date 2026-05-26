import numpy as np
import pytest

from pymole import Divergence1D
from pymole.dim1d.grid import Grid1D


@pytest.fixture
def a_second_order_divergence():
    grid = Grid1D(0.0, 1.2, 6)
    return Divergence1D(grid, 2)


class TestDivergence1DConstruction:
    def test_minimum_cells_for_divergence(self):
        grid_too_small = Grid1D(0.0, 0.4, 4)
        with pytest.raises(ValueError):
            Divergence1D(grid_too_small, 2)

        grid_ok = Grid1D(0.0, 0.5, 5)
        divergence = Divergence1D(grid_ok, 2)
        assert divergence.x_grid.num_cells == 5

    def test_unsupported_accuracy_order_raises_error(self):
        grid = Grid1D(0.0, 1.0, 10)
        with pytest.raises(ValueError):
            divergence = Divergence1D(grid, 4)
            _ = divergence.matrix


class TestDivergence1DMatrix:
    def test_matrix_has_correct_shape(self, a_second_order_divergence):
        D = a_second_order_divergence.matrix
        num_cells = a_second_order_divergence.x_grid.num_cells

        assert D.shape == (num_cells + 2, num_cells + 1)

    def test_constant_field_divergence_is_zero(self, a_second_order_divergence):
        num_cells = a_second_order_divergence.x_grid.num_cells
        v_constant = np.ones(num_cells + 1)
        D = a_second_order_divergence.matrix
        div_v = D @ v_constant

        assert np.allclose(div_v, 0.0, atol=1e-12)


class TestDivergence1DSecondOrder:
    def test_second_order_boundary_cells(self):
        grid = Grid1D(0.0, 1.25, 5)
        divergence = Divergence1D(grid, 2)
        num_cells = grid.num_cells

        D = divergence.matrix.toarray()

        expected_first_row = np.zeros(num_cells + 1)
        expected_last_row = np.zeros(num_cells + 1)

        assert np.allclose(D[0, :], expected_first_row, atol=1e-12)
        assert np.allclose(D[-1, :], expected_last_row, atol=1e-12)

    def test_second_order_interior_stencil(self, a_second_order_divergence):
        num_cells = a_second_order_divergence.x_grid.num_cells
        delta_x = a_second_order_divergence.x_grid.cell_size

        D = a_second_order_divergence.matrix.toarray()

        for i in range(1, num_cells + 1):
            row = D[i, :]
            non_zero_indices = np.where(np.abs(row) > 1e-12)[0]

            assert len(non_zero_indices) == 2
            assert row[i - 1] == pytest.approx(-1.0 / delta_x)
            assert row[i] == pytest.approx(1.0 / delta_x)
