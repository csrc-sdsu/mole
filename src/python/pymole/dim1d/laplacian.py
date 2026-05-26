from scipy import sparse

from .divergence import Divergence1D
from .gradient import Gradient1D
from .operator import MimeticOperator1D


class Laplacian1D(MimeticOperator1D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return max(
            Divergence1D.minimum_cells_for_order(accuracy_order),
            Gradient1D.minimum_cells_for_order(accuracy_order),
        )

    def _construct_matrix(self) -> sparse.csr_matrix:
        D = Divergence1D(self.x_grid, self.accuracy_order)
        G = Gradient1D(self.x_grid, self.accuracy_order)

        return D.matrix @ G.matrix
