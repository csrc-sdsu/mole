/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file grid_builder.cpp
 *
 * @brief Parses a variable length user input containing grid 
 * attributes in a pair <attribute_name, attribute_value>, the
 * functions in this file, parses the user input and creates
 * the corresponding grid classes (actual grid validation is
 * part of the MOLE grid constructors)
 *
 * @date 2026/07/27
 *
 */
#include "grid_builder.h"

#include <cstdarg>
#include <cstring>
#include <string>
#include <variant>
#include <vector>

namespace {

const std::string kLoc = "gridBuilder";  // error-stack location tag

// parse_va_args parses an input va_args containing <key, value> pairs 
// of attributes until a nullptr sentinel is found. The key needs to
// match an MOLE grid's attribute name, else an error; 
// MAKE_GRID_UNKNOWN_ATTRIBUTE, is generated and the parsing process
// is stopped.  NOTE: The actual context of values is check in 
// validGrid()
gridRaw parse_va_args(std::stack<MOLE_Errors>& errs, 
                    const char* firstName, va_list& ap) {
    gridRaw g;
    for (const char* name = firstName; name != nullptr;
         name = va_arg(ap, const char*)) {
        if (std::strcmp(name, "m")   == 0) 
            g.m   = va_arg(ap, int);
        else if (std::strcmp(name, "n")   == 0) 
            g.n   = va_arg(ap, int);
        else if (std::strcmp(name, "o")   == 0) 
            g.o   = va_arg(ap, int);
        else if (std::strcmp(name, "dim") == 0) 
            g.dim = va_arg(ap, int);
        else if (std::strcmp(name, "dx") == 0) 
            g.dx = va_arg(ap, double);
        else if (std::strcmp(name, "dy") == 0) 
            g.dy = va_arg(ap, double);
        else if (std::strcmp(name, "dz") == 0) 
            g.dz = va_arg(ap, double);

        // The MOLE debug modes are integer macros. An unrecognized
        // value is not rejected here; applyDebugMode reports it.
        else if (std::strcmp(name, "debug") == 0)
            g.debug = va_arg(ap, int);

        // char promotes to int through varargs; read int, store char.
        else if (std::strcmp(name, "topology") == 0)
            g.topology = static_cast<char>(va_arg(ap, int));

        else if (std::strcmp(name, "nodes.X")    == 0) 
            g.nodesX    = va_arg(ap, const void*);
        else if (std::strcmp(name, "nodes.Y")    == 0) 
            g.nodesY    = va_arg(ap, const void*);
        else if (std::strcmp(name, "nodes.Z")    == 0) 
            g.nodesZ    = va_arg(ap, const void*);
        else if (std::strcmp(name, "centers.X")  == 0) 
            g.centersX  = va_arg(ap, const void*);
        else if (std::strcmp(name, "centers.Y")  == 0) 
            g.centersY  = va_arg(ap, const void*);
        else if (std::strcmp(name, "centers.Z")  == 0) 
            g.centersZ  = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.u.X")  == 0) 
            g.facesuX   = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.u.Y")  == 0) 
            g.facesuY   = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.u.Z")  == 0) 
            g.facesuZ    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.v.X")  == 0) 
            g.facesvX    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.v.Y")  == 0) 
            g.facesvY    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.v.Z")  == 0) 
            g.facesvZ    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.w.X")  == 0) 
            g.faceswX    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.w.Y")  == 0) 
            g.faceswY    = va_arg(ap, const void*);
        else if (std::strcmp(name, "faces.w.Z")  == 0) 
            g.faceswZ    = va_arg(ap, const void*);

        // isPeriodic arrives as the address of the caller's vector,
        // which carries its own size. dim may not be parsed yet
        // given the variable order of the user input pairs, so the
        // pointer is stashed and both the size check and the copy
        // happen once dim is known.
        else if (std::strcmp(name, "isPeriodic") == 0)
            g.isPeriodicSrc = va_arg(ap, const std::vector<bool>*);

        else {
            MOLEerr_log(errs, MAKE_GRID_UNKNOWN_ATTRIBUTE, kLoc, name);
            break;
        }
    }
    return g;
}

} // namespace


// runChecks: checks require grid attributes and their consistency
// for MOLE grid specifications. In case of issues with the grid
// specifications, it records all possible errors with the grid 
// attributes before returning. 
int runChecks(std::stack<MOLE_Errors>& errs, const gridRaw& g) {
    // The grid dimensionality is a required parameter and is not
    // derived from m, n, o. Without it the remaining checks have 
    // nothing to compare against, so return early.
    if (g.dim == -1) {
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, kLoc);
        return 0;
    }
    if (g.dim < 1 || g.dim > 3) {
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, kLoc, 
                    std::to_string(g.dim));
        return 0;
    }

    // The cell counts supplied must agree with the dimensionality, 
    // in both directions: a count the dimension needs but did not 
    // get, and a count the dimension has no use for.
    if (g.dim >= 1 && g.m <  0) {
        std::string errparam = "m = " + std::to_string(g.m);
        MOLEerr_log(errs, MOLE_ERR_INVALID_CELL_COUNT, kLoc, 
                    errparam);
    }
    if (g.dim >= 2 && g.n < 0) {
        std::string errparam = "n = " + std::to_string(g.n);
        MOLEerr_log(errs, MOLE_ERR_INVALID_CELL_COUNT, kLoc, 
                    errparam);  
    }
    if (g.dim >= 3 && g.o <  0) {
        std::string errparam = "o = " + std::to_string(g.o);
        MOLEerr_log(errs, MOLE_ERR_INVALID_CELL_COUNT, kLoc, 
                    errparam);
    }
    if (g.dim ==  1 && g.n > 0) {
        std::string errparam =
            "1D grid with n = " + std::to_string(g.n);
        MOLEerr_log(errs, MOLE_ERR_INVALID_CELL_COUNT, kLoc, 
                    errparam);
    }
    if (g.dim <  3 && g.o > 0) { 
        std::string errparam =
            "Not a 3D grid but o = " + std::to_string(g.o);
        MOLEerr_log(errs, MOLE_ERR_INVALID_CELL_COUNT, kLoc,
                    errparam);
    }

    // isPeriodic holds one flag per dimension. The vector reports
    // its own size, so the count is checked here rather than
    // trusted at the point the flags are read.
    if (g.isPeriodicSrc &&
        g.isPeriodicSrc->size() != static_cast<size_t>(g.dim)) {
        std::string errparam =
            "isPeriodic size = " +
            std::to_string(g.isPeriodicSrc->size()) +
            ", dim = " + std::to_string(g.dim);
        MOLEerr_log(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM, kLoc,
                    errparam);
    }

    // Topology is compulsory and has no default value.
    if (g.topology == '\0')
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY, kLoc);
    else if (g.topology != 'u' && g.topology != 'c' && 
             g.topology != 'n')
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY, kLoc, 
        std::string(1, g.topology));

    return g.dim;
}

// --- instantiating MOLE grid structures ----------------------------
//
// Builds the dimension-specific struct from an parsed gridRaw,
// copying across only the fields that dimension has. Anything a user
// did not supply keeps the struct's own default, so the MOLE library
// sees it as unset during validation
//

namespace {

// Casts a type-erased coordinate pointer to the concrete array
// class for this dimension and copies the whole object, which
// carries the array's own error stack along with its data. A null
// pointer means the attribute was not supplied, so dst keeps its
// default and MOLE reads it as unset.
template <typename T>
void copyArrayAs(const void* src, T& dst) {
    if (src) dst = *static_cast<const T*>(src);
}

// isPeriodicSrc points at a caller-owned vector. It is null when
// the attribute was omitted, so it is checked before any element
// is read. runChecks has already confirmed the size matches dim.
gridParams1D narrow1D(const gridRaw& g) {
    gridParams1D p;
    p.topology  = g.topology;
    p.m         = static_cast<size_t>(g.m);
    p.dx        = g.dx;
    copyArrayAs<array1D>(g.nodesX,   p.nodes_X);
    copyArrayAs<array1D>(g.centersX, p.centers_X);
    if (g.isPeriodicSrc)
        p.bc_isPeriodic = (*g.isPeriodicSrc)[0];
    return p;
}

gridParams2D narrow2D(const gridRaw& g) {
    gridParams2D p;
    p.topology  = g.topology;
    p.m         = static_cast<size_t>(g.m);
    p.n         = static_cast<size_t>(g.n);
    p.dx        = g.dx;
    p.dy        = g.dy;
    copyArrayAs<array2D>(g.nodesX,   p.nodes_X);
    copyArrayAs<array2D>(g.nodesY,   p.nodes_Y);
    copyArrayAs<array2D>(g.centersX, p.centers_X);
    copyArrayAs<array2D>(g.centersY, p.centers_Y);
    copyArrayAs<array2D>(g.facesuX,  p.faces_u_X);
    copyArrayAs<array2D>(g.facesuY,  p.faces_u_Y);
    copyArrayAs<array2D>(g.facesvX,  p.faces_v_X);
    copyArrayAs<array2D>(g.facesvY,  p.faces_v_Y);
    if (g.isPeriodicSrc) {
        p.bc_isPeriodic[0] = (*g.isPeriodicSrc)[0];
        p.bc_isPeriodic[1] = (*g.isPeriodicSrc)[1];
    }
    return p;
}

gridParams3D narrow3D(const gridRaw& g) {
    gridParams3D p;
    p.topology  = g.topology;
    p.m         = static_cast<size_t>(g.m);
    p.n         = static_cast<size_t>(g.n);
    p.o         = static_cast<size_t>(g.o);
    p.dx        = g.dx;
    p.dy        = g.dy;
    p.dz        = g.dz;
    copyArrayAs<array3D>(g.nodesX,   p.nodes_X);
    copyArrayAs<array3D>(g.nodesY,   p.nodes_Y);
    copyArrayAs<array3D>(g.nodesZ,   p.nodes_Z);
    copyArrayAs<array3D>(g.centersX, p.centers_X);
    copyArrayAs<array3D>(g.centersY, p.centers_Y);
    copyArrayAs<array3D>(g.centersZ, p.centers_Z);
    copyArrayAs<array3D>(g.facesuX,  p.faces_u_X);
    copyArrayAs<array3D>(g.facesuY,  p.faces_u_Y);
    copyArrayAs<array3D>(g.facesuZ,  p.faces_u_Z);
    copyArrayAs<array3D>(g.facesvX,  p.faces_v_X);
    copyArrayAs<array3D>(g.facesvY,  p.faces_v_Y);
    copyArrayAs<array3D>(g.facesvZ,  p.faces_v_Z);
    copyArrayAs<array3D>(g.faceswX,  p.faces_w_X);
    copyArrayAs<array3D>(g.faceswY,  p.faces_w_Y);
    copyArrayAs<array3D>(g.faceswZ,  p.faces_w_Z);
    if (g.isPeriodicSrc) {
        p.bc_isPeriodic[0] = (*g.isPeriodicSrc)[0];
        p.bc_isPeriodic[1] = (*g.isPeriodicSrc)[1];
        p.bc_isPeriodic[2] = (*g.isPeriodicSrc)[2];
    }
    return p;
}

// buildGrid runs the dispatch that turns a parsed gridRaw into a
// gridVar. It is split out of gridBuilder_impl so that every path,
// including the failure paths, funnels through a single point where
// the debug mode is applied.
gridVar buildGrid(std::stack<MOLE_Errors>& errs, const gridRaw& g,
                    int dim) {
    // A parse-time failure means the grid cannot be built. the error
    // MOLE_ERR_INVALID_GRID_ARGS sits on top of the error log; the
    // errors beneath it will provide the details. A paramsNull routes
    // makeGrid to gridNull, carrying the whole error stack with it.
    if (MOLEerr_haserrors(errs)) {
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_ARGS, kLoc, "");
        return makeGrid(paramsNull{}, errs);
    }

    // makeGrid takes the params variant and the error stack (by const
    // reference) and runs the grid1D/2D/3D constructor internally, so
    // nothing is heap-allocated here.
    switch (dim) {
        case 1:
            return makeGrid(narrow1D(g), errs);
        case 2:
            return makeGrid(narrow2D(g), errs);
        case 3:
            return makeGrid(narrow3D(g), errs);
        default:
            // invalid grid dimension found
            MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, kLoc,
                        std::to_string(dim));
            return makeGrid(paramsNull{}, errs);
    }
}

} // namespace

// gridBuilder_impl is called through the gridBuilder macro, which 
// appends the nullptr sentinel. The MOLE error structure is created
// and initialized here for the duration of the build. The narrowed
// this function returns a MOLE grid to the user of type gridVar
// which is a C++ variant for Grid1D, Grid2D or Grid3D
gridVar gridBuilder_impl(const char* firstName, ...) {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);

    va_list ap;
    va_start(ap, firstName);
    gridRaw g = parse_va_args(errs, firstName, ap);
    va_end(ap);

    const int dim = runChecks(errs, g);

    gridVar out = buildGrid(errs, g, dim);

    // The debug mode governs what gridBuilder reports, not what the
    // grid holds: the error log is left intact in every mode, so a
    // caller can still print it or write it to a file afterwards.
    // A grid that validated ignores the mode.
    const size_t dbg = static_cast<size_t>(g.debug);
    std::visit([dbg](auto&& grid) { grid.applyDebugMode(dbg); }, out);

    return out;
}
