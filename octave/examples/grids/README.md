# Octave grid examples

Place these files in `octave/examples/grids`. The grid functions belong in
`octave/src/grids`; `MOLE_errors.m` and its catalog belong in `octave/src/sys`.
Each example configures its paths relative to its own file.

Run an example from the repository root:

```octave
run('octave/examples/grids/grid1D_basic.m');
```

The examples are standalone scripts and clear workspace variables when started.

- `grid1D_basic.m`: validate a one-dimensional parameter struct and inspect its
  nodal and center coordinates.
- `grid2D_basic.m`: validate a two-dimensional parameter struct and inspect the
  coordinate array dimensions.
- `err_grid2D_basic.m`: catch an invalid spacing error, inspect the logger count,
  then build a corrected grid.
- `makeGrid1D_basic.m`: construct from name/value pairs and explicitly revalidate
  the returned struct.
- `makeGrid2D_basic.m`: construct a grid with periodic x boundaries and Dirichlet
  y boundaries using boundary coefficients.
- `makeGrid_arg_order.m`: construct equal grids with different pair orders.
- `makeGrid_error_handling.m`: handle incomplete pairs, conflicting dimensions,
  and invalid cell counts, then construct a valid grid with inferred dimension.
- `grid1D_periodic.m`: infer periodicity from boundary coefficients and sample a
  periodic function at the generated center coordinates.
- `grid2D_curvilinear.m`: construct a half-annulus from supplied nodes and inspect
  the derived face and center coordinates.
