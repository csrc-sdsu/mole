'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
# pyrefly: ignore [missing-import]
import numpy as np
from typing import Tuple, Union, List

class Grid:
    """
    A utility class to generate 1D, 2D, or 3D grids using NumPy's meshgrid.
    """
    
    @staticmethod
    def generate(
        p1: Union[float, int, np.ndarray, List[float], Tuple[float, ...]],
        p2: Union[float, int, np.ndarray, List[float], Tuple[float, ...]],
        shape: Union[int, np.ndarray, List[int], Tuple[int, ...], None] = None,
        spacing: Union[float, np.ndarray, List[float], Tuple[float, ...], None] = None,
        indexing: str = 'xy'
    ) -> Union[np.ndarray, Tuple[np.ndarray, ...]]:
        """
        Generates a 1D, 2D, or 3D grid using shape (number of points/cells) or spacing (physical mesh size).
        
        Args:
            p1: Starting grid point (scalar or 1D array/sequence of length 1, 2, or 3).
            p2: Ending grid point (scalar or 1D array/sequence of length 1, 2, or 3).
            shape: Number of evenly spaced points (scalar integer or sequence of length 1, 2, or 3).
            spacing: Physical mesh size (scalar float/int or sequence of length 1, 2, or 3).
            indexing: 'xy' (default, MATLAB-style) or 'ij' (Matrix-style).
            
        Returns:
            A single array (for 1D) or a tuple of arrays (for 2D/3D).
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
            return coords[0]
            
        return np.meshgrid(*coords, indexing=indexing)

if __name__ == "__main__":
    # Example usage:
    # 1D: p1=0, p2=10, shape=5
    grid1d = Grid.generate(0, 10, shape=5)
    print(f"1D Grid shape: {grid1d.shape}")
    print(f"1D Grid points: {grid1d}")
    
    # 2D: p1=[0, 0], p2=[10, 20], spacing=[2.5, 10.0]
    X, Y = Grid.generate([0, 0], [10, 20], spacing=[2.5, 10.0])
    print(f"2D Grid X shape: {X.shape}, Y shape: {Y.shape}")
    print(f"2D Grid points for X:\n {X}")
    print(f"2D Grid points for Y:\n {Y}")

    # 3D: p1=[0, 0, 0], p2=[10, 20, 30], shape=[5, 3, 4]
    X, Y, Z = Grid.generate([0, 0, 0], [10, 20, 30], shape=[5, 3, 4])
    print(f"3D Grid X shape: {X.shape}, Y shape: {Y.shape}, Z shape: {Z.shape}")
    print(f"2D Grid points for X:\n {X}")
    print(f"2D Grid points for Y:\n {Y}")
    print(f"2D Grid points for Z:\n {Z}")
