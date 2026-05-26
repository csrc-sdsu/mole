from math import isclose


class Grid1D:
    def __init__(self, lower_bound: float, upper_bound: float, num_cells: int):
        if lower_bound >= upper_bound:
            raise ValueError(
                f"Lower bound ({lower_bound}) value must be less than "
                f"the upper bound ({upper_bound})",
            )
        if num_cells < 1:
            raise ValueError(f"Number of cells ({num_cells}) must be at least 1")

        self._lower_bound = lower_bound
        self._upper_bound = upper_bound
        self._num_cells = num_cells

    @classmethod
    def from_number_of_cells(cls, num_cells: int):
        if num_cells < 1:
            raise ValueError(f"Number of cells ({num_cells}) must be at least 1")

        lower_bound = 0.0
        upper_bound = 1.0

        return cls(lower_bound, upper_bound, num_cells)

    @property
    def lower_bound(self) -> float:
        return self._lower_bound

    @property
    def upper_bound(self) -> float:
        return self._upper_bound

    @property
    def num_cells(self) -> int:
        return self._num_cells

    @property
    def cell_size(self) -> float:
        return (self.upper_bound - self.lower_bound) / self.num_cells

    def __repr__(self) -> str:
        return (
            f"Grid1D(lower_bound={self.lower_bound}, "
            f"upper_bound={self.upper_bound}, "
            f"num_cells={self.num_cells})"
        )

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Grid1D):
            return False
        return (
            isclose(self.lower_bound, other.lower_bound)
            and isclose(self.upper_bound, other.upper_bound)
            and self.num_cells == other.num_cells
        )
