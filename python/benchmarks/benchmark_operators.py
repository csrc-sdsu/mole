"""Benchmark the Python mimetic operators provided by MOLE.

The benchmark measures operator construction and sparse matrix-vector
application for increasing one- and two-dimensional grids.  Results are
written as a CSV file so that they can be inspected or plotted without any
additional dependencies.

Run from the repository root after installing the Python package::

    python python/benchmarks/benchmark_operators.py
"""

from __future__ import annotations

import argparse
import csv
import json
import platform
import sys
import time
from pathlib import Path
from statistics import mean, median, stdev
from typing import Callable

import numpy as np

from pymole import Curl, Divergence, Gradient, Grid, Laplacian


DEFAULT_1D_SIZES = (16, 32, 64, 128)
DEFAULT_2D_SIZES = (8, 16, 32, 64)
DEFAULT_REPEATS = 5


def make_grid(dimension: int, size: int) -> Grid:
    """Create a unit-domain grid with ``size`` points per dimension."""
    if dimension == 1:
        return Grid.generate(0.0, 1.0, shape=size)
    if dimension == 2:
        return Grid.generate([0.0, 0.0], [1.0, 1.0], shape=[size, size])
    raise ValueError(f"Unsupported dimension: {dimension}")


def operator_factories(dimension: int) -> dict[str, Callable[[Grid], object]]:
    """Return operators supported for a particular grid dimension."""
    operators: dict[str, Callable[[Grid], object]] = {
        "Gradient": Gradient,
        "Divergence": Divergence,
        "Laplacian": Laplacian,
    }
    if dimension == 2:
        operators["Curl"] = Curl
    return operators


def summarize(values: list[float]) -> dict[str, float]:
    """Return summary statistics in seconds for repeated measurements."""
    return {
        "mean_seconds": mean(values),
        "median_seconds": median(values),
        "minimum_seconds": min(values),
        "maximum_seconds": max(values),
        "stdev_seconds": stdev(values) if len(values) > 1 else 0.0,
    }


def measure_construction(factory: Callable[[Grid], object], grid: Grid, repeats: int) -> dict[str, float]:
    """Measure construction of an operator and its benchmark matrix."""
    samples = []
    for _ in range(repeats):
        start = time.perf_counter()
        operator = factory(grid)
        # Gradient exposes its combined matrix through a property. Access it
        # here so construction has the same meaning for every operator.
        _ = operator.matrix
        samples.append(time.perf_counter() - start)
    return summarize(samples)


def measure_sparse_application(matrix, repeats: int) -> dict[str, float]:
    """Measure sparse matrix-vector multiplication."""
    vector = np.ones(matrix.shape[1], dtype=float)
    _ = matrix @ vector  # warm-up
    samples = []
    for _ in range(repeats):
        start = time.perf_counter()
        _ = matrix @ vector
        samples.append(time.perf_counter() - start)
    return summarize(samples)


def measure_dense_application(matrix, repeats: int) -> dict[str, float]:
    """Measure dense matrix-vector multiplication for small matrices."""
    dense_matrix = matrix.toarray()
    vector = np.ones(dense_matrix.shape[1], dtype=float)
    _ = dense_matrix @ vector  # warm-up
    samples = []
    for _ in range(repeats):
        start = time.perf_counter()
        _ = dense_matrix @ vector
        samples.append(time.perf_counter() - start)
    return summarize(samples)


def benchmark(
    sizes_1d: tuple[int, ...],
    sizes_2d: tuple[int, ...],
    repeats: int,
    dense_limit: int | None,
) -> list[dict[str, object]]:
    """Run all benchmark cases and return rows suitable for CSV/JSON."""
    rows: list[dict[str, object]] = []
    for dimension, sizes in ((1, sizes_1d), (2, sizes_2d)):
        for size in sizes:
            grid = make_grid(dimension, size)
            for name, factory in operator_factories(dimension).items():
                construction = measure_construction(factory, grid, repeats)
                matrix = factory(grid).matrix
                sparse_application = measure_sparse_application(matrix, repeats)

                common = {
                    "operator": name,
                    "dimension": dimension,
                    "grid_size": size,
                    "matrix_rows": matrix.shape[0],
                    "matrix_columns": matrix.shape[1],
                    "nonzero_entries": matrix.nnz,
                    "repeats": repeats,
                }
                rows.append({**common, "measurement": "construction", **construction})
                rows.append({
                    **common,
                    "measurement": "sparse_application",
                    **sparse_application,
                })

                if dense_limit is not None and size <= dense_limit:
                    rows.append({
                        **common,
                        "measurement": "dense_application",
                        **measure_dense_application(matrix, repeats),
                    })
    return rows


def write_results(rows: list[dict[str, object]], output: Path) -> None:
    """Write benchmark rows as CSV or JSON based on the file suffix."""
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.suffix.lower() == ".json":
        output.write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
        return

    fieldnames = list(rows[0].keys())
    with output.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("benchmark_results.csv"))
    parser.add_argument("--repeats", type=int, default=DEFAULT_REPEATS)
    parser.add_argument("--sizes-1d", type=int, nargs="+", default=DEFAULT_1D_SIZES)
    parser.add_argument("--sizes-2d", type=int, nargs="+", default=DEFAULT_2D_SIZES)
    parser.add_argument(
        "--dense-limit",
        type=int,
        default=16,
        help="Also measure dense multiplication for grids up to this size; use -1 to disable.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.repeats < 1:
        raise ValueError("--repeats must be at least 1")
    dense_limit = None if args.dense_limit < 0 else args.dense_limit
    rows = benchmark(tuple(args.sizes_1d), tuple(args.sizes_2d), args.repeats, dense_limit)
    write_results(rows, args.output)
    print(f"Wrote {len(rows)} benchmark rows to {args.output}")
    print(f"Python {platform.python_version()} on {platform.platform()}")
    print(f"NumPy {np.__version__}; Python executable: {sys.executable}")


if __name__ == "__main__":
    main()
