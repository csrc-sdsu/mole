/*
 * SPDX-License-Identifier: GPL-3.0-only
 * 
 * Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * LICENSE file or on the web GNU General Public License 
 * <https:*www.gnu.org/licenses/> for more details.
 * 
 */

/* 
 * @file debug.cpp
 * @brief Debugging function, used if DEBUG_MODE is defined in build
 * @date 2025/03/15
 */
#include "debug.h"
#include <iostream>

void moleDebugLog ( const char *file, int line, const std::string &message )
{
    std::cerr << "[" << file << "]:" << line << ", " << message << endl;
}
void moleDebugLog ( const char *file, int line, const std::string &message, double value )
{
    std::cerr << "[" << file << "]:" << line << ", " << message << " is " << value << endl;
}