from __future__ import annotations

from typing import TYPE_CHECKING

from pymole.mimetic_operator import MimeticOperator

if TYPE_CHECKING:
    from pymole.dim1d.grid import Grid1D


class MimeticOperator3D(MimeticOperator):
    axis_names = ("x", "y", "z")

    def __init__(
        self,
        x_grid: Grid1D,
        y_grid: Grid1D,
        z_grid: Grid1D,
        accuracy_order: int = 2,
    ) -> None:
        super().__init__((x_grid, y_grid, z_grid), accuracy_order)

    @property
    def x_grid(self) -> Grid1D:
        return self.grids[0]

    @property
    def y_grid(self) -> Grid1D:
        return self.grids[1]

    @property
    def z_grid(self) -> Grid1D:
        return self.grids[2]
