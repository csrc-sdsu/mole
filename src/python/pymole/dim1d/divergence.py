import numpy as np
from scipy import sparse

from .operator import MimeticOperator1D


class Divergence1D(MimeticOperator1D):
    @classmethod
    def minimum_cells_for_order(cls, accuracy_order: int) -> int:
        return 2 * accuracy_order + 1

    def _construct_matrix(self) -> sparse.csr_matrix:
        match self.accuracy_order:
            case 2:
                return self._divergence_2nd_order()
            case _:
                raise ValueError(
                    f"Unsupported {self.__class__.__name__} "
                    f"order of accuracy: {self.accuracy_order}."
                )

    def _divergence_2nd_order(self) -> sparse.csr_matrix:
        m = self.x_grid.num_cells
        delta_x = self.x_grid.cell_size

        main_diag = np.ones(m + 1)
        sub_diag = np.full(m + 1, -1.0)

        main_diag[0] = 0.0
        sub_diag[-1] = 0.0

        D = sparse.diags(
            [sub_diag, main_diag], offsets=[-1, 0], shape=(m + 2, m + 1)
        ).tocsr()

        return D / delta_x
