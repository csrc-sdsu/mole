/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/**
 * @file interpolNtoC.cpp
 * 
 * @brief Mimetic Interpolators from the Nodes to Centers
 * 
 * @date 2026/4/6
 * 
 */

#include "interpolNtoC.h"

// 1-D Constructor
InterpolNtoC::InterpolNtoC(u16 k, u32 m, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 2);
    assert(nc.n_elem == 2);

    sp_mat I;

    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        // Periodic case
        InterpolNtoC interpol(k, m, true);
        I = interpol;
    } else {
        // Nonperiodic case
        InterpolNtoC interpol(k, m);
        I = interpol;
    }

    *this = I;
}

// 2-D Constructor
InterpolNtoC::InterpolNtoC(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 4);
    assert(nc.n_elem == 4);

    sp_mat Ix, Iy;

    // left / right periodicity
    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        InterpolNtoC interpolx(k, m, true);
        Ix = interpolx;
    } else {
        InterpolNtoC interpolx(k, m);
        Ix = interpolx;
    }

    // bottom / top periodicity
    if (dc[2] == 0 && dc[3] == 0 && nc[2] == 0 && nc[3] == 0)
    {
        InterpolNtoC interpoly(k, n, true);
        Iy = interpoly;
    } else {
        InterpolNtoC interpoly(k, n);
        Iy = interpoly;
    }

    // Join
    *this = Utils::spkron(Iy, Ix);
}

// 3-D Constructor
InterpolNtoC::InterpolNtoC(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc)
{
    assert(dc.n_elem == 6);
    assert(nc.n_elem == 6);

    sp_mat Ix, Iy, Iz;

    // left / right periodicity
    if (dc[0] == 0 && dc[1] == 0 && nc[0] == 0 && nc[1] == 0)
    {
        InterpolNtoC interpolx(k, m, true);
        Ix = interpolx;
    } else {
        InterpolNtoC interpolx(k, m);
        Ix = interpolx;
    }

    // bottom / top periodicity
    if (dc[2] == 0 && dc[3] == 0 && nc[2] == 0 && nc[3] == 0)
    {
        InterpolNtoC interpoly(k, n, true);
        Iy = interpoly;
    } else {
        InterpolNtoC interpoly(k, n);
        Iy = interpoly;
    }

    // front / back periodicity
    if (dc[4] == 0 && dc[5] == 0 && nc[4] == 0 && nc[5] == 0)
    {
        InterpolNtoC interpolz(k, o, true);
        Iz = interpolz;
    } else {
        InterpolNtoC interpolz(k, o);
        Iz = interpolz;
    }

    // Join
    *this = Utils::spkron(Iz, Utils::spkron(Iy, Ix));
}

// 1-D Nonperiodic Constructor
InterpolNtoC::InterpolNtoC(u16 k, u32 m) : sp_mat(m + 2, m + 1)
{
    assert(!(k % 2));
    assert(k > 1 && k < 9);
    assert(m > 2 * k);

    switch (k)
    {
    case 2:
        
        at(0, 0) = 2.0;
        at(m + 1, m) = 2.0;

        for (u32 i = 1; i < m + 1; ++i)
        {
            at(i, i - 1) = 1.0;
            at(i, i) = 1.0;
        }

        *this /= 2.0;
        break;
    
    case 4:
        
        at(0, 0) = 128.0;
        at(m + 1, m) = 128.0;

        // A
        at(1, 0) = 35.0;
        at(1, 1) = 140.0;
        at(1, 2) = -70.0;
        at(1, 3) = 28.0;
        at(1, 4) = -5.0;

        // A'
        at(m, m - 4) = -5.0;
        at(m, m - 3) = 28.0;
        at(m, m - 2) = -70.0;
        at(m, m - 1) = 140.0;
        at(m, m) = 35.0;

        for (u32 i = 2; i < m; ++i)
        {
            at(i, i - 2) = -8.0;
            at(i, i - 1) = 72.0;
            at(i, i) = 72.0;
            at(i, i + 1) = -8.0;
        }

        *this /= 128.0;
        break;

    case 6:
        
        at(0, 0) = 1024.0;
        at(m + 1, m) = 1024.0;

        // A
        at(1, 0) = 231.0;
        at(1, 1) = 1386.0;
        at(1, 2) = -1155.0;
        at(1, 3) = 924.0;
        at(1, 4) = -495.0;
        at(1, 5) = 154.0;
        at(1, 6) = -21.0;

        at(2, 0) = -21.0;
        at(2, 1) = 378.0;
        at(2, 2) = 945.0;
        at(2, 3) = -420.0;
        at(2, 4) = 189.0;
        at(2, 5) = -54.0;
        at(2, 6) = 7.0;

        // A'
        at(m - 1, m - 6) = 7.0;
        at(m - 1, m - 5) = -54.0;
        at(m - 1, m - 4) = 189.0;
        at(m - 1, m - 3) = -420.0;
        at(m - 1, m - 2) = 945.0;
        at(m - 1, m - 1) = 378.0;
        at(m - 1, m) = -21.0;

        at(m, m - 6) = -21.0;
        at(m, m - 5) = 154.0;
        at(m, m - 4) = -495.0;
        at(m, m - 3) = 924.0;
        at(m, m - 2) = -1155.0;
        at(m, m - 1) = 1386.0;
        at(m, m) = 231.0;

        for (u32 i = 3; i < m - 1; ++i)
        {
            at(i, i - 3) = 12.0;
            at(i, i - 2) = -100.0;
            at(i, i - 1) = 600.0;
            at(i, i) = 600.0;
            at(i, i + 1) = -100.0;
            at(i, i + 2) = 12.0;
        }

        *this /= 1024.0;
        break;

    case 8:
        
        at(0, 0) = 1.0;
        at(m + 1, m) = 1.0;

        // A
        at(1, 0) = 6435.0 / 32768.0;
        at(1, 1) = 6435.0 / 4096.0;
        at(1, 2) = -15015.0 / 8192.0;
        at(1, 3) = 9009.0 / 4096.0;
        at(1, 4) = -32175.0 / 16384.0;
        at(1, 5) = 5005.0 / 4096.0;
        at(1, 6) = -4095.0 / 8192.0;
        at(1, 7) = 495.0 / 4096.0;
        at(1, 8) = -429.0 / 32768.0;

        at(2, 0) = -429.0 / 32768.0;
        at(2, 1) = 1287.0 / 4096.0;
        at(2, 2) = 9009.0 / 8192.0;
        at(2, 3) = -3003.0 / 4096.0;
        at(2, 4) = 9009.0 / 16384.0;
        at(2, 5) = -1287.0 / 4096.0;
        at(2, 6) = 1001.0 / 8192.0;
        at(2, 7) = -117.0 / 4096.0;
        at(2, 8) = 99.0 / 32768.0;

        at(3, 0) = 99.0 / 32768.0;
        at(3, 1) = -165.0 / 4096.0;
        at(3, 2) = 3465.0 / 8192.0;
        at(3, 3) = 3465.0 / 4096.0;
        at(3, 4) = -5775.0 / 16384.0;
        at(3, 5) = 693.0 / 4096.0;
        at(3, 6) = -495.0 / 8192.0;
        at(3, 7) = 55.0 / 4096.0;
        at(3, 8) = -45.0 / 32768.0;

        // A'
        at(m - 2, m - 8) = -45.0 / 32768.0;
        at(m - 2, m - 7) = 55.0 / 4096.0;
        at(m - 2, m - 6) = -495.0 / 8192.0;
        at(m - 2, m - 5) = 693.0 / 4096.0;
        at(m - 2, m - 4) = -5775.0 / 16384.0;
        at(m - 2, m - 3) = 3465.0 / 4096.0;
        at(m - 2, m - 2) = 3465.0 / 8192.0;
        at(m - 2, m - 1) = -165.0 / 4096.0;
        at(m - 2, m) = 99.0 / 32768.0;

        at(m - 1, m - 8) = 99.0 / 32768.0;
        at(m - 1, m - 7) = -117.0 / 4096.0;
        at(m - 1, m - 6) = 1001.0 / 8192.0;
        at(m - 1, m - 5) = -1287.0 / 4096.0;
        at(m - 1, m - 4) = 9009.0 / 16384.0;
        at(m - 1, m - 3) = -3003.0 / 4096.0;
        at(m - 1, m - 2) = 9009.0 / 8192.0;
        at(m - 1, m - 1) = 1287.0 / 4096.0;
        at(m - 1, m) = -429.0 / 32768.0;

        at(m, m - 8) = -429.0 / 32768.0;
        at(m, m - 7) = 495.0 / 4096.0;
        at(m, m - 6) = -4095.0 / 8192.0;
        at(m, m - 5) = 5005.0 / 4096.0;
        at(m, m - 4) = -32175.0 / 16384.0;
        at(m, m - 3) = 9009.0 / 4096.0;
        at(m, m - 2) = -15015.0 / 8192.0;
        at(m, m - 1) = 6435.0 / 4096.0;
        at(m, m) = 6435.0 / 32768.0;

        for (u32 i = 4; i < m - 2; ++i)
        {
            at(i, i - 4) = -5.0 / 2048.0;
            at(i, i - 3) = 49.0 / 2048.0;
            at(i, i - 2) = -245.0 / 2048.0;
            at(i, i - 1) = 1225.0 / 2048.0;
            at(i, i) = 1225.0 / 2048.0;
            at(i, i + 1) = -245.0 / 2048.0;
            at(i, i + 2) = 49.0 / 2048.0;
            at(i, i + 3) = -5.0 / 2048.0;
        }

        break;
    }
}

// 1-D Periodic Constructor
InterpolNtoC::InterpolNtoC(u16 k, u32 m, bool dummy) : sp_mat(m, m)
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
    for (int i = 0; i < (int)m; ++i)
    {
        for (int j = 0; j < (int)m; ++j)
        {
            val = V[((j - i) % (int)m + (int)m) % (int)m];
            if (val != 0.0) at(i, j) = val;
        }
    }
}