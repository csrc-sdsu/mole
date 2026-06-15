'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
# pyrefly: ignore [missing-import]
import numpy as np
from typing import Tuple, Union, List, Optional

class Grid:
    """
    A class that encapsulates 1D, 2D, or 3D grids generated using NumPy's meshgrid,
    providing access to individual dimension arrays and unpacking support.
    """
    
    def __init__(
        self,
        x: np.ndarray,
        y: Optional[np.ndarray] = None,
        z: Optional[np.ndarray] = None
    ):
        self._x = x
        self._y = y
        self._z = z

    @property
    def x(self) -> np.ndarray:
        return self._x

    @property
    def y(self) -> Optional[np.ndarray]:
        return self._y

    @property
    def z(self) -> Optional[np.ndarray]:
        return self._z

    @property
    def X(self) -> np.ndarray:
        return self._x

    @property
    def Y(self) -> Optional[np.ndarray]:
        return self._y

    @property
    def Z(self) -> Optional[np.ndarray]:
        return self._z

    @property
    def ndim(self) -> int:
        if self._z is not None:
            return 3
        if self._y is not None:
            return 2
        return 1
    @property
    def num_cells(self):
        if self.ndim == 1:
            return len(self.x) - 1

        return tuple(s - 1 for s in self.x.shape)

    @property
    def spacing(self):
        if self.ndim == 1:
            return self.x[1] - self.x[0]

        if self.ndim == 2:
            dx = self.x[0, 1] - self.x[0, 0]
            dy = self.y[1, 0] - self.y[0, 0]
            return dx, dy
       
        dx = self.x[0, 1, 0] - self.x[0, 0, 0]
        dy = self.y[1, 0, 0] - self.y[0, 0, 0]
        dz = self.z[0, 0, 1] - self.z[0, 0, 0]
        return dx, dy, dz

    def __iter__(self):
        """Allows unpacking the grid object, e.g., X, Y = Grid.generate(...)"""
        if self.ndim == 1:
            yield self.x
        elif self.ndim == 2:
            yield self.x
            yield self.y
        else:
            yield self.x
            yield self.y
            yield self.z

    def __repr__(self) -> str:
        if self.ndim == 1:
            return f"Grid(ndim=1, x={self.x.shape})"
        elif self.ndim == 2:
            return f"Grid(ndim=2, x={self.x.shape}, y={self.y.shape})"
        else:
            return f"Grid(ndim=3, x={self.x.shape}, y={self.y.shape}, z={self.z.shape})"

    @staticmethod
    def generate(
        p1: Union[float, int, np.ndarray, List[float], Tuple[float, ...]],
        p2: Union[float, int, np.ndarray, List[float], Tuple[float, ...]],
        shape: Union[int, np.ndarray, List[int], Tuple[int, ...], None] = None,
        spacing: Union[float, np.ndarray, List[float], Tuple[float, ...], None] = None,
        indexing: str = 'xy'
    ) -> 'Grid':
        """
        Generates a 1D, 2D, or 3D grid using shape (number of points/cells) or spacing (physical mesh size).
        
        Args:
            p1: Starting grid point (scalar or 1D array/sequence of length 1, 2, or 3).
            p2: Ending grid point (scalar or 1D array/sequence of length 1, 2, or 3).
            shape: Number of evenly spaced points (scalar integer or sequence of length 1, 2, or 3).
            spacing: Physical mesh size (scalar float/int or sequence of length 1, 2, or 3).
            indexing: 'xy' (default, MATLAB-style) or 'ij' (Matrix-style).
            
        Returns:
            A Grid object encapsulating the coordinate arrays.
        """
        if (shape is None) == (spacing is None):
            raise ValueError("Exactly one of 'shape' or 'spacing' must be specified.")

        p1_arr = np.atleast_1d(p1)
        p2_arr = np.atleast_1d(p2)
        
        if p1_arr.ndim > 1 or p2_arr.ndim > 1:
            raise ValueError("Starting and ending grid points must be scalars or 1D sequences.")
        if p1_arr.shape != p2_arr.shape:
            raise ValueError("p1 and p2 must have the same shape/dimension.")
            
        dims = len(p1_arr)
        if not (1 <= dims <= 3):
            raise ValueError("Grid supports 1 to 3 dimensions only.")
            
        if shape is not None:
            if isinstance(shape, (int, np.integer)):
                shape_arr = np.full(dims, shape, dtype=int)
            else:
                shape_arr = np.atleast_1d(shape).astype(int)
                if shape_arr.ndim > 1 or len(shape_arr) != dims:
                    raise ValueError(
                        f"shape must be a single integer or a sequence/array of length {dims}."
                    )
            n_arr = shape_arr
        else:
            if isinstance(spacing, (int, float, np.number)):
                spacing_arr = np.full(dims, spacing, dtype=float)
            else:
                spacing_arr = np.atleast_1d(spacing).astype(float)
                if spacing_arr.ndim > 1 or len(spacing_arr) != dims:
                    raise ValueError(
                        f"spacing must be a single float or a sequence/array of length {dims}."
                    )
            
            if np.any(spacing_arr <= 0):
                raise ValueError("spacing values must be greater than zero.")
                
            n_arr = np.empty(dims, dtype=int)
            for i in range(dims):
                length = abs(p2_arr[i] - p1_arr[i])
                num_cells = int(round(length / spacing_arr[i]))
                if num_cells < 1:
                    num_cells = 1
                n_arr[i] = num_cells + 1
                
        coords = [np.linspace(p1_arr[i], p2_arr[i], n_arr[i]) for i in range(dims)]
        
        if dims == 1:
            return Grid(coords[0])
            
        mesh = np.meshgrid(*coords, indexing=indexing)
        return Grid(*mesh)

if __name__ == "__main__":
    # Example usage:
    # 1D: p1=0, p2=10, shape=5
    grid1d = Grid.generate(0, 10, shape=5)
    print(f"1D Grid object: {grid1d}")
    print(f"1D Grid x shape: {grid1d.x.shape}")
    print(f"1D Grid points: {grid1d.x}")
    
    # 2D: p1=[0, 0], p2=[10, 20], spacing=[2.5, 10.0]
    grid2d = Grid.generate([0, 0], [10, 20], spacing=[2.5, 10.0])
    print(f"2D Grid object: {grid2d}")
    print(f"2D Grid X shape: {grid2d.X.shape}, Y shape: {grid2d.Y.shape}")
    print(f"2D Grid points for X:\n {grid2d.X}")
    print(f"2D Grid points for Y:\n {grid2d.Y}")

    # 3D: p1=[0, 0, 0], p2=[10, 20, 30], shape=[5, 3, 4] (using unpacking)
    grid3d = Grid.generate([0, 0, 0], [10, 20, 30], shape=[5, 3, 4])
    print(f"3D Grid object: {grid3d}")
    X, Y, Z = grid3d
    print(f"Unpacked 3D Grid X shape: {X.shape}, Y shape: {Y.shape}, Z shape: {Z.shape}")
