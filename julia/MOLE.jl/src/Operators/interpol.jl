using SparseArrays
#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#


"""
    interpol(m, c)

Returns a (m+1)×(m+2) one-dimensional interpolator of 2nd-order

# Arguments
- `m::Int`  : number of cells
- `c::Float`: left interpolation coefficient
"""
function interpol(m::Int, c::Float64)

    #Assertions:
    @assert m>=4 ["m >= 4"];
    @assert c >= 0 && c <= 1 ["0 <= c <= 1"];

    #Dimensions of I:
    n_rows = m+1;
    n_cols = m+2;

    I = zeros(n_rows, n_cols);

    I[1, 1] = 1;
    I[end, end]=1;

    #Average between two continuous cells
    avg = [c 1-c];

    j = 2;
    for i in 2:(n_rows - 1)
        I[i, j:(j + 2 - 1)] = avg;
        j = j + 1;
    end
    return I
end
