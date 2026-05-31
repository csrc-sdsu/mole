from __future__ import annotations

from typing import TYPE_CHECKING

from pymole.mimetic_operator import MimeticOperator

if TYPE_CHECKING:
    from .grid import Grid1D


class MimeticOperator1D(MimeticOperator):
    axis_names = ("x",)

    def __init__(self, x_grid: Grid1D, accuracy_order: int = 2) -> None:
        super().__init__((x_grid,), accuracy_order)

    @property
    def x_grid(self) -> Grid1D:
        return self.grids[0]
