% MOLE error codes supported by the Octave interface.
% Values are indexed by the symbolic error name in keys.


% Codes 011-099: input user parameter errors.
keys = {
    "MOLE_ERR_GRID_UNCHECKED",
    "MOLE_ERR_GRID_FLAGGED_W_ERRS",
    "MOLE_ERR_INVALID_GRID_ARGS",
    "MOLE_ERR_GRID_CONSTRUCTION_FAILED",
    "MAKE_GRID_INVALID_INPUT_ARGS",
    "MAKE_GRID_MISSING_ARGS",
    "MAKE_GRID_UNKNOWN_ATTRIBUTE",
    "MAKE_GRID_DUPLICATE_ATTRIBUTES",

    % Codes 100-199: grid and vector errors.
    "MOLE_ERR_INVALID_GRID_DIM",
    "MOLE_ERR_INVALID_GRID_TOPOLOGY",
    "MOLE_ERR_INVALID_GRID_SPACING",
    "MOLE_ERR_INVALID_GRID_SIZE",
    "MOLE_ERR_GRID_NODAL_SZ_MISMATCH",
    "MOLE_ERR_GRID_CENTERS_SZ_MISMATCH",
    "MOLE_ERR_GRID_FACES_SZ_MISMATCH",
    "MOLE_ERR_INVALID_INPUT_TYPE",
    "MOLE_ERR_ARRAY_HAS_NULL_POINTER",
    "MOLE_ERR_INVALID_CELL_COUNT",
    "MOLE_ERR_INVALID_ISPERIODIC_DIM",
    "MOLE_ERR_ISPERIODIC_TYPE",
    "MOLE_ERR_INVALID_CURVILINEAR_GRID",
    "MOLE_ERR_INVALID_1D_CURVILINEAR",
    "MOLE_ERR_INVALID_NONUNIFORM_GRID",
    "MOLE_ERR_INVALID_ARRAY_INDEX",
    "MOLE_ERR_INVALID_NODAL_COORDINATES",
    "MOLE_ERR_INVALID_CENTER_COORDINATES",
    "MOLE_ERR_INVALID_NORMAL_FACE_COORDS",

    % Codes 200-299: MOLE array errors.
    "MOLE_ERR_INVALID_ARRAY_SIZE",
    "MOLE_ERR_ARRAY_SIZE_OVERFLOW",
    "MOLE_ERR_ARRAY_INDEX_OUTBOUNDS",
    "MOLE_ERR_FAILED_ARRAY_ALLOC",
    "MOLE_ERR_FAILED_ARRAY_RESIZE",

    % Codes 300-600: MOLE operator errors.
    "MOLE_ERR_DIVISION_BY_ZERO",
    "MOLE_ERR_INF_VALUE",
    "MOLE_ERR_NAN_VALUE"
};

values = [
    % Codes 011-099.
    struct("Code", 11, "Message", "Grid has not been validated or checked for operations. All grids are initialized with this error until they are validated."),
    struct("Code", 12, "Message", "Grid failed to be validated and it has been flagged with ERRORS"),
    struct("Code", 13, "Message", "Error(s) in input parameters, resulting grid is invalid."),
    struct("Code", 14, "Message", "Grid construction failed, see full list of errors"),
    struct("Code", 15, "Message", "Invalid number of arguments passed during grid creation, valid inputs are pairs of the form <grid_attribute, value>"),
    struct("Code", 16, "Message", "The number of arguments doesn't match the args actually passed."),
    struct("Code", 17, "Message", "Unknown grid structure attribute name."),
    struct("Code", 18, "Message", "Duplicate grid attribute passed"),

    % Codes 100-199.
    struct("Code", 100, "Message", "Invalid grid dimension"),
    struct("Code", 101, "Message", "Invalid grid topology"),
    struct("Code", 102, "Message", "Invalid grid spacing"),
    struct("Code", 103, "Message", "Invalid grid size"),
    struct("Code", 104, "Message", "Mismatch in the size of the nodal grid array(s)"),
    struct("Code", 105, "Message", "Mismatch in the size of the grid centers array(s)"),
    struct("Code", 106, "Message", "Mismatch in the size of the grid faces array(s)"),
    struct("Code", 107, "Message", "Invalid input type for input name"),
    struct("Code", 108, "Message", "Array has a null pointer either allocation failed or user passed a null pointer"),
    struct("Code", 109, "Message", "Non-positive cell count (m/n/o <= 0)"),
    struct("Code", 110, "Message", "Invalid dimension for the isPeriodic member"),
    struct("Code", 111, "Message", "isPeriodic is not boolean"),
    struct("Code", 112, "Message", "Curvilinear grids need user-provided nodal grid coordinates"),
    struct("Code", 113, "Message", "Curvilinear grids cannot be one dimensional"),
    struct("Code", 114, "Message", "Nonuniform grids need user-provided nodal grid coordinates"),
    struct("Code", 115, "Message", "One or more indices to the array are not valid, check arrays sizes"),
    struct("Code", 116, "Message", "User-provided nodal coordinates do not agree with other uniform grid parameters"),
    struct("Code", 117, "Message", "User-provided cell center coordinates do not agree with other uniform grid parameters"),
    struct("Code", 118, "Message", "User-provided normal face coordinates do not agree with other uniform grid parameters"),

    % Codes 200-299.
    struct("Code", 200, "Message", "Array dimensions need to be natural numbers >= 1"),
    struct("Code", 201, "Message", "Array allocation overflow"),
    struct("Code", 202, "Message", "The array index is out of bound."),
    struct("Code", 203, "Message", "Fail to allocate array <array name>"),
    struct("Code", 204, "Message", "Fail to resize array <array name>"),

    % Codes 300-600.
    struct("Code", 300, "Message", "Division by zero"),
    struct("Code", 301, "Message", "Infinite value detected"),
    struct("Code", 302, "Message", "NaN value detected")
];

% Codes 119, 303, and 304 are not included because the source table does
% not provide complete code-symbol/message entries for those rows.
MOLE_errors = containers.Map(keys, values);
