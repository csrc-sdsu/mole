from abc import ABC, abstractmethod

class BoundaryCondition(ABC):
    @abstractmethod
    def apply(self) -> None:
        """Subclasses must implement this."""
        pass
    
    def isImplemented(self) -> bool:
        """Returns True if the boundary condition is implemented."""
        return self.apply != BoundaryCondition.apply
    
    def hasImplemented(cls, bc) -> bool:
        """Returns True if the boundary condition is implemented."""
        return bc.apply != BoundaryCondition.apply

    def __init__(self, grid, accuracy_order: int = 2):
        self.grid = grid
        self.accuracy_order = accuracy_order

        if self.grid.ndim not in (1, 2, 3):
            raise ValueError(
                f"BoundaryCondition currently supports 1D, 2D, and 3D grids. "
                f"Got ndim={self.grid.ndim}"
            )