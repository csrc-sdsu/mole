from scipy import sparse

from pymole.dim1d.gradient import Gradient1D

from .operator import MimeticOperator3D


class Gradient3D(MimeticOperator3D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return Gradient1D.minimum_cells_for_order(accuracy_order)

    def _construct_matrix(self) -> sparse.csr_matrix:
        m = self.x_grid.num_cells
        n = self.y_grid.num_cells
        o = self.z_grid.num_cells

        Gx = Gradient1D(self.x_grid, self.accuracy_order).matrix
        Gy = Gradient1D(self.y_grid, self.accuracy_order).matrix
        Gz = Gradient1D(self.z_grid, self.accuracy_order).matrix

        Im = sparse.eye(m + 2, format="csr")[1:-1, :]
        In = sparse.eye(n + 2, format="csr")[1:-1, :]
        Io = sparse.eye(o + 2, format="csr")[1:-1, :]

        Sx = sparse.kron(sparse.kron(Io, In, format="csr"), Gx, format="csr")
        Sy = sparse.kron(sparse.kron(Io, Gy, format="csr"), Im, format="csr")
        Sz = sparse.kron(sparse.kron(Gz, In, format="csr"), Im, format="csr")

        return sparse.vstack([Sx, Sy, Sz], format="csr")
