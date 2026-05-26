import pytest

from pymole.dim1d.grid import Grid1D


@pytest.fixture
def basic_grid():
    return Grid1D(0.0, 1.0, 10)


class TestGrid1DConstruction:
    def test_valid_grid_creation(self, basic_grid):
        assert basic_grid.lower_bound == pytest.approx(0.0)
        assert basic_grid.upper_bound == pytest.approx(1.0)
        assert basic_grid.num_cells == 10
        assert basic_grid.cell_size == pytest.approx(0.1)

    def test_lower_bound_greater_than_upper_bound_raises_error(self):
        with pytest.raises(ValueError):
            Grid1D(1.0, 0.0, 10)

    def test_num_cells_less_than_one_raises_error(self):
        with pytest.raises(ValueError):
            Grid1D(0.0, 1.0, 0)


class TestGrid1DFromNumberOfCells:
    def test_from_number_of_cells_basic(self):
        expected_num_cells = 13
        grid = Grid1D.from_number_of_cells(expected_num_cells)

        assert grid.lower_bound == pytest.approx(0.0)
        assert grid.upper_bound == pytest.approx(1.0)
        assert grid.num_cells == expected_num_cells
        assert grid.cell_size == pytest.approx(1.0 / expected_num_cells)

    def test_zero_number_of_cells_raises_error(self):
        with pytest.raises(ValueError):
            Grid1D.from_number_of_cells(0)

    def test_negative_number_of_cells_raises_error(self):
        with pytest.raises(ValueError):
            Grid1D.from_number_of_cells(-5)


class TestGrid1DProperties:
    def test_cell_size_computed(self):
        grid = Grid1D(0.0, 2.0, 4)

        assert grid.cell_size == pytest.approx(0.5)


class TestGrid1DEquality:
    def test_equal_grids(self, basic_grid):
        grid2 = Grid1D(0.0, 1.0, 10)

        assert basic_grid == grid2

    def test_unequal_grids_different_lower_bound(self, basic_grid):
        grid2 = Grid1D(0.5, 1.0, 10)

        assert basic_grid != grid2

    def test_unequal_grids_different_upper_bound(self, basic_grid):
        grid2 = Grid1D(0.0, 2.0, 10)

        assert basic_grid != grid2

    def test_unequal_grids_different_num_cells(self, basic_grid):
        grid2 = Grid1D(0.0, 1.0, 20)

        assert basic_grid != grid2

    def test_grid_not_equal_to_non_grid(self, basic_grid):
        assert basic_grid != "not a grid"


class TestGrid1DRepr:
    def test_repr_strings(self, basic_grid):
        repr_str = repr(basic_grid)

        assert "Grid1D" in repr_str
        assert "lower_bound=0.0" in repr_str
        assert "upper_bound=1.0" in repr_str
        assert "num_cells=10" in repr_str
