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
 * @file debug.h
 * @brief Preprocessor directives for debugging
 * @date 2025/03/15
 */
#ifndef DEBUG_H
#define DEBUG_H

#include <stdio.h>
#include <string>

using namespace std;

/* Compile with flag -DDEBUG_MODE to activate debuggin statements */

#ifdef DEBUG_MODE
#define DBGMSG( msg )         logDebugMessage( __FILE__, __LINE__, msg );              // regular debug
#define DBGVMSG( msg, value ) logDebugMessageWithValue( __FILE__, __LINE__,  msg, value );      // regular debug with value
#else
#define DBGMSG( msg )
#define DBGVMSG( msg, value )
#endif

/* Error message function for #define DEBUG */
// DEBUG debugging message
void logDebugMessage ( const char *file, int line, const std::string &message );
void logDebugMessageWithValue ( const char *file, int line, const std::string &message, double value );

#endif