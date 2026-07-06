'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''

from scipy import sparse

from .BoundaryCondition import BoundaryCondition


class RobinBoundaryCondition(BoundaryCondition):
    def __init__(self, grid, accuracy_order: int = 2, dirichlet_coefficient: float = 1.0, neumann_coefficient: float = 1.0):
        self.dirichlet_coefficient = dirichlet_coefficient
        self.neumann_coefficient = neumann_coefficient
        super().__init__(grid, accuracy_order)

    def apply(self):
        if self.grid.ndim == 1:
            return self._build_1d_robin_matrix(self.m, self._spacing_for_dimension(0), self.dirichlet_coefficient, self.neumann_coefficient)

        if self.grid.ndim == 2:
            Bm = self._build_1d_robin_matrix(self.m, self._spacing_for_dimension(0), self.dirichlet_coefficient, self.neumann_coefficient)
            Bn = self._build_1d_robin_matrix(self.n, self._spacing_for_dimension(1), self.dirichlet_coefficient, self.neumann_coefficient)

            Im = sparse.eye(self.m + 2, format="csr")
            In = sparse.eye(self.n + 2, format="csr")
            In = In.tolil()
            In[0, 0] = 0.0
            In[-1, -1] = 0.0
            In = In.tocsr()

            BC1 = sparse.kron(In, Bm, format="csr")
            BC2 = sparse.kron(Bn, Im, format="csr")
            return (BC1 + BC2).tocsr()

        if self.grid.ndim == 3:
            Bm = self._build_1d_robin_matrix(self.m, self._spacing_for_dimension(0), self.dirichlet_coefficient, self.neumann_coefficient)
            Bn = self._build_1d_robin_matrix(self.n, self._spacing_for_dimension(1), self.dirichlet_coefficient, self.neumann_coefficient)
            Bo = self._build_1d_robin_matrix(self.o, self._spacing_for_dimension(2), self.dirichlet_coefficient, self.neumann_coefficient)

            Im = sparse.eye(self.m + 2, format="csr")
            In = sparse.eye(self.n + 2, format="csr")
            Io = sparse.eye(self.o + 2, format="csr")
            Io = Io.tolil()
            Io[0, 0] = 0.0
            Io[-1, -1] = 0.0
            Io = Io.tocsr()

            In2 = In.tolil()
            In2[0, 0] = 0.0
            In2[-1, -1] = 0.0
            In2 = In2.tocsr()

            BC1 = sparse.kron(sparse.kron(Io, In2, format="csr"), Bm, format="csr")
            BC2 = sparse.kron(sparse.kron(Io, Bn, format="csr"), Im, format="csr")
            BC3 = sparse.kron(sparse.kron(Bo, In, format="csr"), Im, format="csr")
            return (BC1 + BC2 + BC3).tocsr()

        raise ValueError(f"Unsupported grid dimension: {self.grid.ndim}")