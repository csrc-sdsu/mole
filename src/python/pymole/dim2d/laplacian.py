from scipy import sparse

from .divergence import Divergence2D
from .gradient import Gradient2D
from .operator import MimeticOperator2D


class Laplacian2D(MimeticOperator2D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return max(
            Divergence2D.minimum_cells_for_order(accuracy_order),
            Gradient2D.minimum_cells_for_order(accuracy_order),
        )

    def _construct_matrix(self) -> sparse.csr_matrix:
        D = Divergence2D(self.x_grid, self.y_grid, self.accuracy_order)
        G = Gradient2D(self.x_grid, self.y_grid, self.accuracy_order)

        return D.matrix @ G.matrix
