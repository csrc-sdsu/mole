'''
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
'''
import pytest
import numpy as np
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from pymole.grid import Grid

def test_shape_grid_1d():
    # Test 1D grid generation using shape
    grid = Grid.generate(0, 10, shape=5)
    expected = np.array([0.0, 2.5, 5.0, 7.5, 10.0])
    assert np.allclose(grid, expected)
    assert grid.shape == (5,)

def test_spacing_grid_1d():
    # Test 1D grid generation using spacing
    grid = Grid.generate(0, 10, spacing=2.0)
    expected = np.array([0.0, 2.0, 4.0, 6.0, 8.0, 10.0])
    assert np.allclose(grid, expected)
    assert grid.shape == (6,)

def test_spacing_grid_1d_non_divisible():
    # Test 1D grid with non-divisible spacing (should round to nearest number of cells)
    # Length is 10, spacing is 3. 10/3 = 3.33 -> rounds to 3 cells (4 points)
    grid = Grid.generate(0, 10, spacing=3.0)
    expected = np.linspace(0, 10, 4)
    assert np.allclose(grid, expected)
    assert grid.shape == (4,)

def test_shape_grid_2d():
    # Test 2D grid generation using shape
    X, Y = Grid.generate([0, 0], [10, 20], shape=[5, 3])
    assert X.shape == (3, 5)  # for 'xy' indexing, shape of X is (Ny, Nx)
    assert Y.shape == (3, 5)
    
    # Check boundaries
    assert X[0, 0] == 0.0
    assert X[0, -1] == 10.0
    assert Y[0, 0] == 0.0
    assert Y[-1, 0] == 20.0

def test_spacing_grid_2d():
    # Test 2D grid generation using spacing
    X, Y = Grid.generate([0, 0], [10, 20], spacing=[2.5, 10.0])
    # x spacing 2.5 -> 10/2.5 = 4 cells -> 5 points
    # y spacing 10.0 -> 20/10 = 2 cells -> 3 points
    assert X.shape == (3, 5)
    assert Y.shape == (3, 5)
    
    assert np.allclose(X[0, :], [0.0, 2.5, 5.0, 7.5, 10.0])
    assert np.allclose(Y[:, 0], [0.0, 10.0, 20.0])

def test_shape_grid_3d():
    # Test 3D grid generation using shape
    X, Y, Z = Grid.generate([0, 0, 0], [10, 20, 30], shape=[5, 3, 4])
    # indexing 'xy' -> shape is (shape[1], shape[0], shape[2])
    # which is (3, 5, 4)
    assert X.shape == (3, 5, 4)
    assert Y.shape == (3, 5, 4)
    assert Z.shape == (3, 5, 4)

def test_spacing_grid_3d():
    # Test 3D grid generation using spacing
    X, Y, Z = Grid.generate([0, 0, 0], [10, 20, 30], spacing=[2.5, 10.0, 10.0])
    # x spacing 2.5 -> 4 cells -> 5 points
    # y spacing 10.0 -> 2 cells -> 3 points
    # z spacing 10.0 -> 3 cells -> 4 points
    # shape is (3, 5, 4)
    assert X.shape == (3, 5, 4)
    assert Y.shape == (3, 5, 4)
    assert Z.shape == (3, 5, 4)

def test_both_specified_raises_error():
    with pytest.raises(ValueError, match="Exactly one of 'shape' or 'spacing' must be specified"):
        Grid.generate(0, 10, shape=5, spacing=2.0)

def test_neither_specified_raises_error():
    with pytest.raises(ValueError, match="Exactly one of 'shape' or 'spacing' must be specified"):
        Grid.generate(0, 10)

def test_invalid_dimension_raises_error():
    # 4 dimensions is not supported
    with pytest.raises(ValueError, match="Grid supports 1 to 3 dimensions only"):
        Grid.generate([0, 0, 0, 0], [1, 1, 1, 1], shape=5)

def test_mismatched_p1_p2_raises_error():
    with pytest.raises(ValueError, match="p1 and p2 must have the same shape/dimension"):
        Grid.generate([0, 0], [1, 1, 1], shape=5)

def test_mismatched_shape_dimension_raises_error():
    with pytest.raises(ValueError, match="shape must be a single integer or a sequence/array of length"):
        Grid.generate([0, 0], [1, 1], shape=[5, 5, 5])

def test_mismatched_spacing_dimension_raises_error():
    with pytest.raises(ValueError, match="spacing must be a single float or a sequence/array of length"):
        Grid.generate([0, 0], [1, 1], spacing=[0.5, 0.5, 0.5])

def test_invalid_spacing_value_raises_error():
    with pytest.raises(ValueError, match="spacing values must be greater than zero"):
        Grid.generate(0, 10, spacing=0)
    
    with pytest.raises(ValueError, match="spacing values must be greater than zero"):
        Grid.generate(0, 10, spacing=-1.0)
    
    with pytest.raises(ValueError, match="spacing values must be greater than zero"):
        Grid.generate([0, 0], [10, 10], spacing=[1.0, -0.5])
