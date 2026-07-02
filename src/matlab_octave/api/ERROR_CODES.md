# MOLE 2.0 API Error Codes

This document provides a comprehensive table of standardized error codes returned by the `makeGrid` and `validateGrid` API functions.

Instead of throwing hard MATLAB exceptions, these functions safely populate and return a standardized `grid.error` structure. The `code` field categorizes the failure, while the `id` field provides a one-to-one traceable identifier for the specific missing field or invalid state.

## Error Code Table (100 - 199)

| Code | Error Category | Description | Common Traceable IDs |
| :--- | :--- | :--- | :--- |
| **100** | **Invalid Input Structure** | The function was called with an invalid type (e.g. a number instead of a struct) or bad Name-Value pairs. | `validateGrid:InvalidInput`<br>`makeGrid:InvalidInput`<br>`makeGrid:InvalidFieldName` |
| **101** | **Missing Essential Dimensions** | The grid struct lacks necessary discretization counts (`m`, `n`, `o`) for its stated dimensionality. | `validateGrid:MissingM`<br>`validateGrid:MissingN`<br>`validateGrid:MissingO`<br>`validateGrid:MissingField1D` |
| **102** | **Invalid Grid Dimensionality** | The `dim` field is explicitly invalid (e.g., >3) or doesn't match the specific dimensionality of the operator requesting it. | `validateGrid:InvalidDim`<br>`validateGrid:InvalidDim1D`<br>`validateGrid:InvalidDim2D` |
| **103** | **Missing Uniform Spacing** | A uniform grid is missing required spacing parameters (`dx`, `dy`, `dz`). | `validateGrid:MissingDx`<br>`validateGrid:MissingDy`<br>`validateGrid:MissingDz`<br>`validateGrid:MissingUniform1D` |
| **104** | **Invalid Boundary Specifications** | The `grid.bc` structure contains incompatible configurations (e.g., `dc` provided without `nc` or vice versa). | `validateGrid:InvalidBC1D`<br>`validateGrid:InvalidBC2D`<br>`validateGrid:InvalidBC3D` |
| **105** | **Incorrect Boundary Vector Type/Size** | A boundary coefficient (`dc` or `nc`) is non-numeric, or its length does not match the expected count (2 for 1D, 4 for 2D, 6 for 3D) after scalar expansion. | `validateGrid:InvalidBC1D`<br>`validateGrid:InvalidBC2D`<br>`validateGrid:InvalidBC3D` |
| **106** | **Missing Curvilinear Coordinates** | A curvilinear grid was specified, but it lacks the required physical node coordinates (`grid.nodes.X`, `grid.nodes.Y`). | `validateGrid:CurvilinearMissingNodes` |
| **107** | **Curvilinear Size Mismatch** | The provided physical node coordinates do not match the expected `(m+1) x (n+1)` dimension requirements. | `validateGrid:SizeMismatch` |
| **108** | **Periodic Boundary Conflict** | A user marked an axis as periodic (`bc.isPeriodic = true`), but supplied non-zero Dirichlet or Neumann coefficients for it. | `validateGrid:PeriodicBCConflict` |

---

### Usage Note

When writing automated tests or catching failures in caller code, you can use the `code` to handle broad categories of errors:
```matlab
g = validateGrid(myStruct);
if g.error.hasError && g.error.code == 101
    % Handle any missing grid dimension
end
```

For strict, exact one-to-one traceability, use the string `id`:
```matlab
if g.error.hasError && strcmp(g.error.id, 'validateGrid:MissingDx')
    % Specifically handle missing dx
end
```
