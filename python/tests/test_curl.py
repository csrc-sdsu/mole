import numpy as np
import pytest
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from pymole import Curl, Divergence, Grid

class TestCurl:

    def test_unsupported_dimension(self):
        grid = Grid.generate(0.0, 1.0, shape=7)

        with pytest.raises(ValueError):
            Curl(grid)

    def test_2d_matrix_shape(self):
        grid = Grid.generate([0.0, 0.0], [3.0, 2.0], shape=[7, 6])

        C = Curl(grid).matrix
        D = Divergence(grid).matrix

        assert C.shape == D.shape

    def test_2d_constant_vector_field(self):
        grid = Grid.generate([0.0, 0.0], [3.0, 2.0], shape=[7, 6])

        C = Curl(grid).matrix
        w = np.ones(C.shape[1])

        assert np.allclose(C @ w, 0.0, atol=1e-12)
