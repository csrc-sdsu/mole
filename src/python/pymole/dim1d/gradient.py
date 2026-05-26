import numpy as np
from scipy import sparse

from .operator import MimeticOperator1D


class Gradient1D(MimeticOperator1D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return 2 * accuracy_order

    def _construct_matrix(self) -> sparse.csr_matrix:
        match self.accuracy_order:
            case 2:
                return self._gradient_2nd_order()
            case _:
                raise ValueError(
                    f"Unsupported {self.__class__.__name__} "
                    f"order of accuracy: {self.accuracy_order}."
                )

    def _gradient_2nd_order(self) -> sparse.csr_matrix:
        m = self.x_grid.num_cells
        delta_x = self.x_grid.cell_size

        main_diag = np.full(m + 1, -1.0)
        super_diag = np.ones(m + 1)

        main_diag[-1] = 0.0

        G = sparse.diags(
            [main_diag, super_diag], offsets=[0, 1], shape=(m + 1, m + 2)
        ).tolil()

        G[0, 0:3] = [-8.0 / 3.0, 3.0, -1.0 / 3.0]
        G[m, m - 1 : m + 2] = [1.0 / 3.0, -3.0, 8.0 / 3.0]

        return G.tocsr() / delta_x
