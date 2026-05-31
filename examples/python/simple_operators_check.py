from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "src" / "python"))

import numpy as np
from numpy.typing import NDArray
from scipy import sparse

from pymole import (
    Divergence1D,
    Divergence2D,
    Gradient1D,
    Gradient2D,
    Grid1D,
    Laplacian1D,
    Laplacian2D,
)


def report_grid(name: str, grid: Grid1D) -> None:
    print(f"{name}: {grid}; cell size (resolution): {grid.cell_size:.4f}")


def report_nullity_check(
    name: str,
    op: sparse.csr_matrix,
    expected_shape: tuple[int, int],
    constant_field: NDArray[np.float64],
) -> None:
    print(f"{name} shape: {op.shape}; expected {expected_shape}")
    print(
        f"||{name} @ constant||_inf = {np.linalg.norm(op @ constant_field, ord=np.inf)}"
    )


def check_1d_operators(accuracy_order: int = 2) -> None:
    num_cells = 2 * accuracy_order + 1

    grid = Grid1D(0.0, 1.0, num_cells)

    G = Gradient1D(grid, accuracy_order).matrix
    D = Divergence1D(grid, accuracy_order).matrix
    L = Laplacian1D(grid, accuracy_order).matrix

    f_constant = np.ones(num_cells + 2)
    v_constant = np.ones(num_cells + 1)

    print("=== 1D operators ===")
    report_grid("x grid", grid)
    report_nullity_check("G", G, (num_cells + 1, num_cells + 2), f_constant)
    report_nullity_check("D", D, (num_cells + 2, num_cells + 1), v_constant)
    report_nullity_check("L", L, (num_cells + 2, num_cells + 2), f_constant)
    print(f"D @ G == L? -> {abs(D @ G - L).max() < 1e-12}")
    print()


def check_2d_operators(accuracy_order: int = 2) -> None:
    x_grid = Grid1D(-1.0, 1.0, 2 * accuracy_order + 1)
    y_grid = Grid1D(-0.5, 2.0, 2 * accuracy_order + 2)

    m = x_grid.num_cells
    n = y_grid.num_cells

    G = Gradient2D(x_grid, y_grid, accuracy_order).matrix
    D = Divergence2D(x_grid, y_grid, accuracy_order).matrix
    L = Laplacian2D(x_grid, y_grid, accuracy_order).matrix

    f_constant = np.ones((m + 2) * (n + 2))
    v_constant = np.ones(2 * m * n + m + n)

    print("=== 2D operators ===")
    report_grid("x grid", x_grid)
    report_grid("y grid", y_grid)
    report_nullity_check("G", G, (2 * m * n + m + n, (m + 2) * (n + 2)), f_constant)
    report_nullity_check("D", D, ((m + 2) * (n + 2), 2 * m * n + m + n), v_constant)
    report_nullity_check("L", L, ((m + 2) * (n + 2), (m + 2) * (n + 2)), f_constant)
    print(f"D @ G == L? -> {abs(D @ G - L).max() < 1e-12}")
    print()


def main() -> None:
    check_1d_operators()
    check_2d_operators()


if __name__ == "__main__":
    main()
