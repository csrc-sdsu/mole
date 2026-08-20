#ifndef MOLE_GRID_BUILDER_H
#define MOLE_GRID_BUILDER_H

// grid_builder.h
//
// MOLE Grid Utility: parses a user's <key, value> input into 
// an internal gridRaw, then narrows gridRaw into a dimensionality
// specific gridParams[1D][2D][3D] used inside MOLE 2.0 to construct
// grids. Grid builder will instantiate a temporaty gridRaw structure
// which will be used in the construction of a Grid1D, Grid2D or 
// Grid3D object. MOLE grid objects are created and validated during
// construction.
// The wrapper performs only these parse-time checks:
//   1. invalid key            -> MAKE_GRID_UNKNOWN_ATTRIBUTE   
//   2. dimension consistency  -> MOLE_ERR_INVALID_CELL_COUNT   
//   3. invalid dimensionality -> MOLE_ERR_INVALID_GRID_DIM     
//   4. invalid topology       -> MOLE_ERR_INVALID_GRID_TOPOLOGY
//   5. isPeriodic size        -> MOLE_ERR_INVALID_ISPERIODIC_DIM
//
// Users need to input the grid's dimensionaly and topology. Thus, 
// these are not inferred nor defaulted. This utility uses MOLE's 
// error reporting and tracking mechanism.
//
// SYNTAX:
// ------------------------------------------------------------------
// gridVar g = gridBuilder(va_arg);
// where va_arg is a list of pairs of the form: 
//              <grid-attribute, grid-attribute-value>
// Example:
// gridVar g=gridBuilder("dim",1, "m",20, "dx",0.2, "topology",'u');
//
// isPeriodic takes the address of a vector<bool> holding one flag
// per dimension. The vector must outlive the gridBuilder call:
//   std::vector<bool> per = {true, false};
//   gridVar g = gridBuilder("dim", 2, ..., "isPeriodic", &per);
// ------------------------------------------------------------------
// Note I: callers who know the dimension at compile time can call 
// the MOLE grid constructors directly by using the corresponding 
// gridParams1D/2D/3D directly, and invoking the corresponding grid 
// constructor, Grid1D/2D/3D, respectively.
//
// Note II: there are not type-checking for va_arg at compile time,
// users need to be aware of the correct data types:
//                          ATTRIBUTE                              //
//   TYPE:                  Name:             Valid C++ Input Type //
// -----------------------:------------------:---------------------//
//   counters               m, n, o, dim      const int ()
//   cell spacing           dx, dy, dz        const double      
//   grid topology          topology          const char 
//   grid coordinates       Nodal, Centers,   const vector (doubles)
//                          Normal faces      const &flatNDArray
//   grid periodicity       isPeriodic        const vector<bool>*
//                                            (size must equal dim)
//   debugging mode         debug             const int
//                                            (MOLE debug mode)
//
// Note III: the debug attribute takes one of the MOLE debug modes
// declared in MOLE_errors.h (DEBUG_DEFAULT_MD,
// DEBUG_REPORTS_STDOUT_MD, DEBUG_AND_ABORT_MD) and governs what
// gridBuilder does with a grid that fails to build. Parsing stops
// at an unrecognized attribute name, because the type of the value
// after an unknown name is unknown too. A debug pair placed after
// one is therefore never read, on exactly the calls that need it.
// Pass debug as the first pair:
//   gridVar g = gridBuilder("debug", DEBUG_REPORTS_STDOUT_MD,
//                           "dim", 1, "m", 20, "dx", 0.2,
//                           "topology", 'u');
// 
// -------------------------------------------------------------------------

#include <stack>
#include <vector>
#include "MOLE_grids.h"

// The variadic list, va_arg, needs to end with a nullptr. A va_arg
// without an nullptr at end fails. Therefore, gridBuilder is 
// designed as a macro that always appends a nullpointer sentinel,
#define gridBuilder(...) \
    ::gridBuilder_impl(__VA_ARGS__, static_cast<const char*>(nullptr))

// gridRaw is the gridBuilder's generic structure. 
struct gridRaw {
    int  dim      = -1;      // required; -1 means the user omitted it
    char topology = '\0';    // 'u'|'c'|'n'; required, no default

    int m = -1;
    int n = -1;
    int o = -1;

    Real dx = 0.0;
    Real dy = 0.0;
    Real dz = 0.0;

    // MOLE debug mode applied to a grid that fails to build. See
    // Note III above for why the debug pair has to come first.
    int debug = DEBUG_DEFAULT_MD;

    // points at the caller's vector; null when not supplied. The
    // vector carries its own size, which runChecks compares with
    // dim regardless of the order the attributes arrived in.
    const std::vector<bool>* isPeriodicSrc = nullptr;

    const void* nodesX   = nullptr;
    const void* nodesY   = nullptr;
    const void* nodesZ   = nullptr;
    const void* centersX = nullptr;
    const void* centersY = nullptr;
    const void* centersZ = nullptr;
    const void* facesuX  = nullptr;
    const void* facesuY  = nullptr;
    const void* facesuZ  = nullptr;
    const void* facesvX  = nullptr;
    const void* facesvY  = nullptr;
    const void* facesvZ  = nullptr;
    const void* faceswX  = nullptr;
    const void* faceswY  = nullptr;
    const void* faceswZ  = nullptr;
};

// runChecks runs the five parse-time validations, and logs failures
// to errs. It also returns the grid dimensionality, or a 0 whenever
// the dim attribute is missing or <= 0 or > 3.
int runChecks(std::stack<MOLE_Errors>& errs, const gridRaw& g);

// gridBuilder_impl is the entry point behind the gridBuilder macro: 
// it parses, checks for errors, and instantiates the gridParams. It
// calls MOLE's makeGrid and returns an instant of a MOLE gridVar a
// c++ variant for the MOLE classes Grid[1D][2D][3D]. When a grid
// cannot be constructed it returns a gridNull, built via
// makeGrid(paramsNull, errs) (user checks errors). In MOLE_grids.h:
// using gridVar = std::variant<grid1D, grid2D, grid3D, gridNull>;
// Before returning, the debug mode is applied to the resulting
// grid. The mode governs only what gridBuilder reports; the grid
// keeps its full error log in every mode.
gridVar gridBuilder_impl(const char* firstName, ...);

// makeGrid (the factory that turns a paramVars into a gridVar) is
// declared in MOLE_grids.h; gridBuilder_impl calls it for both the
// success path (gridParams1D/2D/3D) and the failure path
// (paramsNull -> gridNull).

#endif // MOLE_GRID_BUILDER_H
