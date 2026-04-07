/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/**
 * @file interpolCtoN.cpp
 * 
 * @brief Mimetic Interpolators from the Centers to Nodes
 * 
 * @date 2026/4/6
 * 
 */

#include "interpolCtoN.h"

// 1-D Constructor
InterpolCtoN::InterpolCtoN(u16 k, u32 m, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 2);
    assert(nc.n_elem == 2);

    sp_mat I;
    
    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        // Periodic case
        InterpolCtoN interpol(k, m, true);
        I = interpol;
    } else {
        // Nonperiodic case
        InterpolCtoN interpol(k, m);
        I = interpol;
    }

    *this = I;
}

// 2-D Constructor
InterpolCtoN::InterpolCtoN(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 4);
    assert(nc.n_elem == 4);

    sp_mat Ix, Iy;

    // left / right periodicity
    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        InterpolCtoN interpolx(k, m, true);
        Ix = interpolx;
    } else {
        InterpolCtoN interpolx(k, m);
        Ix = interpolx;
    }
    

    // bottom / top periodicity
    if (dc[2] == 0 && dc[3] == 0 && nc[2] == 0 && nc[3] == 0)
    {
        InterpolCtoN interpoly(k, n, true);
        Iy = interpoly;
    } else {
        InterpolCtoN interpoly(k, n);
        Iy = interpoly;
    }

    // Join
    *this = Utils::spkron(Iy, Ix);
}

// 3-D Constructor
InterpolCtoN::InterpolCtoN(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 6);
    assert(nc.n_elem == 6);

    sp_mat Ix, Iy, Iz;

    // left / right periodicity
    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        InterpolCtoN interpolx(k, m, true);
        Ix = interpolx;
    } else {
        InterpolCtoN interpolx(k, m);
        Ix = interpolx;
    }

    // bottom / top periodicity
    if (dc[2] == 0 && dc[3] == 0 && nc[2] == 0 && nc[3] == 0)
    {
        InterpolCtoN interpoly(k, n, true);
        Iy = interpoly;
    } else {
        InterpolCtoN interpoly(k, n);
        Iy = interpoly;
    }

    // front / back periodicity
    if (dc[4] == 0 && dc[5] == 0 && nc[4] == 0 && nc[5] == 0)
    {
        InterpolCtoN interpolz(k, o, true);
        Iz = interpolz;
    } else {
        InterpolCtoN interpolz(k, o);
        Iz = interpolz;
    }

    // Join
    *this = Utils::spkron(Iz, Utils::spkron(Iy, Ix));
}

// 1-D Nonperiodic Constructor
InterpolCtoN::InterpolCtoN(u16 k, u32 m) : sp_mat(m + 1, m + 2)
{
    assert(!(k % 2));
    assert(k > 1 && k < 9);
    assert(m > 2 * k);

    switch (k)
    {
    case 2:
        at(0, 0) = 2.0;
        at(m, m + 1) = 2.0;

        for (u32 i = 1; i < m; ++i)
        {
            at(i, i) = 1.0;
            at(i, i + 1) = 1.0;
        }

        *this /= 2.0;
        break;

    case 4:
        at(0, 0) = 112.0;
        at(m, m + 1) = 112.0;

        // A
        at(1, 0) = -16.0;
        at(1, 1) = 70.0;
        at(1, 2) = 70.0;
        at(1, 3) = -14.0;
        at(1, 4) = 2.0;

        // A'
        at(m - 1, m - 3) = 2.0;
        at(m - 1, m - 2) = -14.0;
        at(m - 1, m - 1) = 70.0;
        at(m - 1, m) = 70.0;
        at(m - 1, m + 1) = -16.0;

        for (u32 i = 2; i < m - 1; ++i)
        {
            at(i, i - 1) = -7.0;
            at(i, i) = 63.0;
            at(i, i + 1) = 63.0;
            at(i, i + 2) = -7.0;
        }

        *this /= 112.0;
        break;

    case 6:
        at(0, 0) = 8448.0;
        at(m, m + 1) = 8448.0;

        // A
        at(1, 0) = -768.0;
        at(1, 1) = 4158.0;
        at(1, 2) = 6930.0;
        at(1, 3) = -2772.0;
        at(1, 4) = 1188.0;
        at(1, 5) = -330.0;
        at(1, 6) = 42.0;

        at(2, 0) = 256.0;
        at(2, 1) = -924.0;
        at(2, 2) = 4620.0;
        at(2, 3) = 5544.0;
        at(2, 4) = -1320.0;
        at(2, 5) = 308.0;
        at(2, 6) = -36.0;

        // A'
        at(m - 2, m - 5) = -36.0;
        at(m - 2, m - 4) = 308.0;
        at(m - 2, m - 3) = -1320.0;
        at(m - 2, m - 2) = 5544.0;
        at(m - 2, m - 1) = 4620.0;
        at(m - 2, m) = -924.0;
        at(m - 2, m + 1) = 256.0;

        at(m - 1, m - 5) = 42.0;
        at(m - 1, m - 4) = -330.0;
        at(m - 1, m - 3) = 1188.0;
        at(m - 1, m - 2) = -2772.0;
        at(m - 1, m - 1) = 6930.0;
        at(m - 1, m) = 4158.0;
        at(m - 1, m + 1) = -768.0;

        for (u32 i = 3; i < m - 2; ++i)
        {
            at(i, i - 2) = 99.0;
            at(i, i - 1) = -825.0;
            at(i, i) = 4950.0;
            at(i, i + 1) = 4950.0;
            at(i, i + 2) = -825.0;
            at(i, i + 3) = 99.0;
        }

        *this /= 8448.0;
        break;

    case 8:
        at(0, 0) = 1.0;
        at(m, m + 1) = 1.0;

        // A
        at(1, 0) = -1.0 / 15.0;
        at(1, 1) = 429.0 / 1024.0;
        at(1, 2) = 1001.0 / 1024.0;
        at(1, 3) = -3003.0 / 5120.0;
        at(1, 4) = 429.0 / 1024.0;
        at(1, 5) = -715.0 / 3072.0;
        at(1, 6) = 91.0 / 1024.0;
        at(1, 7) = -21.0 / 1024.0;
        at(1, 8) = 11.0 / 5120.0;

        at(2, 0) = 1.0 / 65.0;
        at(2, 1) = -33.0 / 512.0;
        at(2, 2) = 231.0 / 512.0;
        at(2, 3) = 2079.0 / 2560.0;
        at(2, 4) = -165.0 / 512.0;
        at(2, 5) = 77.0 / 512.0;
        at(2, 6) = -27.0 / 512.0;
        at(2, 7) = 77.0 / 6656.0;
        at(2, 8) = -3.0 / 2560.0;

        at(3, 0) = -1.0 / 143.0;
        at(3, 1) = 27.0 / 1024.0;
        at(3, 2) = -105.0 / 1024.0;
        at(3, 3) = 567.0 / 1024.0;
        at(3, 4) = 675.0 / 1024.0;
        at(3, 5) = -175.0 / 1024.0;
        at(3, 6) = 567.0 / 11264.0;
        at(3, 7) = -135.0 / 13312.0;
        at(3, 8) = 1.0 / 1024.0;

        // A'
        at(m - 3, m - 7) = 1.0 / 1024.0;
        at(m - 3, m - 6) = -135.0 / 13312.0;
        at(m - 3, m - 5) = 567.0 / 11264.0;
        at(m - 3, m - 4) = -175.0 / 1024.0;
        at(m - 3, m - 3) = 675.0 / 1024.0;
        at(m - 3, m - 2) = 567.0 / 1024.0;
        at(m - 3, m - 1) = -105.0 / 1024.0;
        at(m - 3, m) = 27.0 / 1024.0;
        at(m - 3, m + 1) = -1.0 / 143.0;

        at(m - 2, m - 7) = -3.0 / 2560.0;
        at(m - 2, m - 6) = 77.0 / 6656.0;
        at(m - 2, m - 5) = -27.0 / 512.0;
        at(m - 2, m - 4) = 77.0 / 512.0;
        at(m - 2, m - 3) = -165.0 / 512.0;
        at(m - 2, m - 2) = 2079.0 / 2560.0;
        at(m - 2, m - 1) = 231.0 / 512.0;
        at(m - 2, m) = -33.0 / 512.0;
        at(m - 2, m + 1) = 1.0 / 65.0;

        at(m - 1, m - 7) = 11.0 / 5120.0;
        at(m - 1, m - 6) = -21.0 / 1024.0;
        at(m - 1, m - 5) = 91.0 / 1024.0;
        at(m - 1, m - 4) = -715.0 / 3072.0;
        at(m - 1, m - 3) = 429.0 / 1024.0;
        at(m - 1, m - 2) = -3003.0 / 5120.0;
        at(m - 1, m - 1) = 1001.0 / 1024.0;
        at(m - 1, m) = 429.0 / 1024.0;
        at(m - 1, m + 1) = -1.0 / 15.0;

        for (u32 i = 4; i < m - 3; ++i)
        {
            at(i, i - 3) = -5.0 / 2048.0;
            at(i, i - 2) = 49.0 / 2048.0;
            at(i, i - 1) = -245.0 / 2048.0;
            at(i, i) = 1225.0 / 2048.0;
            at(i, i + 1) = 1225.0 / 2048.0;
            at(i, i + 2) = -245.0 / 2048.0;
            at(i, i + 3) = 49.0 / 2048.0;
            at(i, i + 4) = -5.0 / 2048.0;
        }

        break;
    }
}

// 1-D Periodic Constructor
InterpolCtoN::InterpolCtoN(u16 k, u32 m, bool dummy) : sp_mat(m, m)
{
    assert(!(k % 2));
    assert(k > 1 && k < 9);
    assert(m > 2 * k);

    vec V(m, fill::zeros);

    switch (k)
    {
    case 2:
    
        V[0] = 1.0 / 2.0;
        V[1] = 1.0 / 2.0;
        
        break;
    
    case 4:

        V[0] = 72.0 / 128.0;
        V[1] = 72.0 / 128.0;
        V[2] = -8.0 / 128.0;
        V[m - 1] = -8.0 / 128.0;

        break;

    case 6:
        
        V[0] = 600.0 / 1024.0;
        V[1] = 600.0 / 1024.0;
        V[2] = -100.0 / 1024.0;
        V[3] = 12.0 / 1024.0;
        V[m - 2] = 12.0 / 1024.0;
        V[m - 1] = -100.0 / 1024.0;

        break;

    case 8:
        
        V[0] = 1225.0 / 2048.0;
        V[1] = 1225.0 / 2048.0;
        V[2] = -245.0 / 2048.0;
        V[3] = 49.0 / 2048.0;
        V[4] = -5.0 / 2048.0;
        V[m - 3] = -5.0 / 2048.0;
        V[m - 2] = 49.0 / 2048.0;
        V[m - 1] = -245.0 / 2048.0;

        break;
    }

    Real val;
    sp_mat I(m, m);
    for (int i = 0; i < (int)m; ++i)
    {
        for (int j = 0; j < (int)m; ++j)
        {
            val = V[((j - i) % (int)m + (int)m) % (int)m];
            if (val != 0.0) I(i, j) = val;
        }
    }

    // Compiler does not like *this = *this.t()
    *this = I.t();
}