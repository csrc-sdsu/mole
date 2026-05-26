from scipy import sparse

from pymole.dim1d.divergence import Divergence1D

from .operator import MimeticOperator2D


class Divergence2D(MimeticOperator2D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return Divergence1D.minimum_cells_for_order(accuracy_order)

    def _construct_matrix(self) -> sparse.csr_matrix:
        m = self.x_grid.num_cells
        n = self.y_grid.num_cells

        Dx = Divergence1D(self.x_grid, self.accuracy_order).matrix
        Dy = Divergence1D(self.y_grid, self.accuracy_order).matrix

        Im = sparse.eye(m + 2, format="csr")[:, 1:-1]
        In = sparse.eye(n + 2, format="csr")[:, 1:-1]

        Sx = sparse.kron(In, Dx, format="csr")
        Sy = sparse.kron(Dy, Im, format="csr")

        return sparse.hstack([Sx, Sy], format="csr")
