from __future__ import annotations

from abc import ABC, abstractmethod
from functools import cached_property
from typing import TYPE_CHECKING, ClassVar

from scipy import sparse

if TYPE_CHECKING:
    from pymole.dim1d.grid import Grid1D


class MimeticOperator(ABC):
    axis_names: ClassVar[tuple[str, ...]]

    def __init__(self, grids: tuple[Grid1D, ...], accuracy_order: int = 2) -> None:
        if len(grids) != len(self.axis_names):
            raise TypeError(
                f"{type(self).__name__} expects {len(self.axis_names)} "
                f"grid(s) (one per axis in {self.axis_names}), got {len(grids)}."
            )

        self.grids = grids
        self.accuracy_order = accuracy_order

        min_cells = self.minimum_cells_for_order(accuracy_order)
        undersized = [
            f"{name}: {g.num_cells}"
            for name, g in zip(self.axis_names, grids)
            if g.num_cells < min_cells
        ]
        if undersized:
            raise ValueError(
                f"Grid too small for requested accuracy: "
                f"Number of cells in {', '.join(undersized)} "
                f"must be at least {min_cells} for a "
                f"{accuracy_order}-order accurate {len(grids)}D "
                f"{type(self).__name__}.",
            )

    @property
    def minimum_cells(self) -> int:
        return self.minimum_cells_for_order(self.accuracy_order)

    @classmethod
    @abstractmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        pass

    @cached_property
    def matrix(self) -> sparse.csr_matrix:
        return self._construct_matrix()

    @abstractmethod
    def _construct_matrix(self) -> sparse.csr_matrix:
        pass
