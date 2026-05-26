from unittest.mock import MagicMock

import pytest
from scipy import sparse

from pymole.dim1d.grid import Grid1D
from pymole.dim1d.operator import MimeticOperator1D


class MockOperator(MimeticOperator1D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return accuracy_order

    def _construct_matrix(self) -> sparse.csr_matrix:
        return MagicMock(spec=sparse.csr_matrix)


class TestMimeticOperatorConstruction:
    def test_minimum_cells_requirement(self):
        grid_too_small = Grid1D(0.0, 0.3, 3)
        with pytest.raises(ValueError):
            MockOperator(grid_too_small, 4)

        grid_ok = Grid1D(0.0, 0.4, 4)
        op = MockOperator(grid_ok, 2)

        assert op.x_grid == grid_ok
        assert op.accuracy_order == 2
        assert op.minimum_cells == 2


class TestMimeticOperatorMatrix:
    def test_matrix_is_sparse_csr(self):
        grid = Grid1D(0.0, 0.4, 4)
        op = MockOperator(grid, 2)
        matrix = op.matrix

        assert isinstance(matrix, MagicMock)

    def test_matrix_cached_property(self):
        grid = Grid1D(0.0, 0.4, 4)
        op = MockOperator(grid, 2)
        matrix1 = op.matrix
        matrix2 = op.matrix

        assert matrix1 is matrix2
