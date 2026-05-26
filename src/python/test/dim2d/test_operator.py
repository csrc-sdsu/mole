from unittest.mock import MagicMock

import pytest
from scipy import sparse

from pymole.dim1d.grid import Grid1D
from pymole.dim2d.operator import MimeticOperator2D


class MockOperator2D(MimeticOperator2D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return accuracy_order

    def _construct_matrix(self) -> sparse.csr_matrix:
        return MagicMock(spec=sparse.csr_matrix)


@pytest.fixture
def x_grid():
    return Grid1D(0.0, 1.0, 4)


@pytest.fixture
def y_grid():
    return Grid1D(0.0, 1.0, 4)


class TestMimeticOperator2DConstruction:
    def test_x_grid_too_small_raises_error(self, y_grid):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator2D(grid_too_small, y_grid, 4)

    def test_y_grid_too_small_raises_error(self, x_grid):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator2D(x_grid, grid_too_small, 4)

    def test_stores_grids_and_accuracy_order(self, x_grid, y_grid):
        op = MockOperator2D(x_grid, y_grid, 2)

        assert op.x_grid == x_grid
        assert op.y_grid == y_grid
        assert op.accuracy_order == 2

    def test_minimum_cells_property(self, x_grid, y_grid):
        op = MockOperator2D(x_grid, y_grid, 2)

        assert op.minimum_cells == 2


class TestMimeticOperator2DMatrix:
    def test_matrix_cached_property(self, x_grid, y_grid):
        op = MockOperator2D(x_grid, y_grid, 2)
        matrix1 = op.matrix
        matrix2 = op.matrix

        assert matrix1 is matrix2
