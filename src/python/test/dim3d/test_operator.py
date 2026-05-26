from unittest.mock import MagicMock

import pytest
from scipy import sparse

from pymole.dim1d.grid import Grid1D
from pymole.dim3d.operator import MimeticOperator3D


class MockOperator3D(MimeticOperator3D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return accuracy_order

    def _construct_matrix(self) -> sparse.csr_matrix:
        return MagicMock(spec=sparse.csr_matrix)


@pytest.fixture
def x_grid():
    return Grid1D(-9.4, 2.6, 12)


@pytest.fixture
def y_grid():
    return Grid1D(0.0, 1.0, 7)


@pytest.fixture
def z_grid():
    return Grid1D(0.0, 1.0, 11)


class TestMimeticOperator3DConstruction:
    def test_x_grid_too_small_raises_error(self, y_grid, z_grid):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator3D(grid_too_small, y_grid, z_grid, 4)

    def test_y_grid_too_small_raises_error(self, x_grid, z_grid):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator3D(x_grid, grid_too_small, z_grid, 4)

    def test_z_grid_too_small_raises_error(self, x_grid, y_grid):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator3D(x_grid, y_grid, grid_too_small, 4)

    def test_stores_grids_and_accuracy_order(self, x_grid, y_grid, z_grid):
        op = MockOperator3D(x_grid, y_grid, z_grid, 2)

        assert op.x_grid == x_grid
        assert op.y_grid == y_grid
        assert op.z_grid == z_grid
        assert op.accuracy_order == 2

    def test_minimum_cells_property(self, x_grid, y_grid, z_grid):
        op = MockOperator3D(x_grid, y_grid, z_grid, 2)

        assert op.minimum_cells == 2


class TestMimeticOperator3DMatrix:
    def test_matrix_cached_property(self, x_grid, y_grid, z_grid):
        op = MockOperator3D(x_grid, y_grid, z_grid, 2)
        matrix1 = op.matrix
        matrix2 = op.matrix

        assert matrix1 is matrix2
