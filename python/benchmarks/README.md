# MOLE Python performance benchmarks

This directory contains a reproducible benchmark for the Python mimetic
operators. It measures operator construction and sparse matrix-vector
application as the grid size increases. Dense matrix-vector application is
also measured for small grids to provide a reference point.

## Running the benchmark

From the repository root:

```bash
python -m pip install -e "./python[test]"
python python/benchmarks/benchmark_operators.py \
    --output benchmark_results.csv \
    --repeats 5
```

The default cases use 1D grid sizes 16, 32, 64, and 128, and 2D grid sizes
8, 16, 32, and 64. The 2D Curl benchmark is included automatically. Curl is
not included in the 1D cases because the current MOLE API defines Curl only
for two-dimensional grids.

For a quick test run, use smaller grids:

```bash
python python/benchmarks/benchmark_operators.py \
    --sizes-1d 16 32 \
    --sizes-2d 8 16 \
    --repeats 3 \
    --output benchmark_results.json
```

Use `--dense-limit -1` to disable the dense comparison. Dense multiplication
is intentionally restricted to small grids because dense matrices require
quadratic storage, while the MOLE operators are sparse.

## Result format

Each output row identifies the operator, dimension, grid size, matrix shape,
number of nonzero entries, measurement type, and summary statistics from the
repeated measurements. Timing values are reported in seconds. The benchmark
does not modify the operator implementations.

For meaningful comparisons, record the Python version, package versions,
operating system, processor, grid sizes, and number of repetitions. Runtime
results depend on the machine and should not be interpreted as universal
constants.
