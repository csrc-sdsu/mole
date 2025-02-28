# Doxyfile for MATLAB API Documentation

# Project settings
PROJECT_NAME           = "MOLE MATLAB API"
PROJECT_BRIEF         = "MATLAB API Documentation"
OUTPUT_DIRECTORY      = doc/doxygen/matlab2

# Input settings
INPUT                 = src/matlab
FILE_PATTERNS         = *.m
RECURSIVE             = YES
EXTRACT_ALL          = YES
EXTRACT_PRIVATE      = YES
EXTRACT_STATIC       = YES

# Output settings
GENERATE_HTML         = YES
GENERATE_LATEX        = NO
HTML_OUTPUT          = html
HTML_FILE_EXTENSION  = .html

# HTML styling
HTML_EXTRA_STYLESHEET = custom.css
HTML_EXTRA_FILES     = doc/doxygen/matlab/matlabicon.gif doc/doxygen/templates/header.html doc/doxygen/templates/footer.html doc/doxygen/templates/menu.html

# Source browsing
SOURCE_BROWSER       = YES
INLINE_SOURCES      = YES
STRIP_CODE_COMMENTS = NO

# MATLAB specific settings
EXTENSION_MAPPING    = m=C++
CASE_SENSE_NAMES    = NO

# Documentation extraction
HIDE_UNDOC_MEMBERS  = NO
HIDE_UNDOC_CLASSES  = NO
BRIEF_MEMBER_DESC   = YES
REPEAT_BRIEF        = YES
SHOW_INCLUDE_FILES  = YES
SORT_MEMBER_DOCS    = YES

# Navigation
GENERATE_TREEVIEW    = YES
DISABLE_INDEX        = NO
HTML_DYNAMIC_SECTIONS = NO

# Input parsing
INPUT_ENCODING      = UTF-8
EXTRACT_PRIVATE     = YES
EXTRACT_STATIC      = YES
EXTRACT_LOCAL_CLASSES = YES
EXTRACT_LOCAL_METHODS = YES
EXTRACT_ANON_NSPACES = YES

# Comment parsing
TCL_SUBST           = NO
MULTILINE_CPP_IS_BRIEF = NO
INHERIT_DOCS        = YES
SEPARATE_MEMBER_PAGES = NO
TAB_SIZE            = 4
ALIASES            += "matlab=\par MATLAB Example:\n"

# Disable unnecessary features
GENERATE_TODOLIST   = NO
GENERATE_TESTLIST   = NO
GENERATE_BUGLIST    = NO
GENERATE_DEPRECATEDLIST = NO
SHOW_USED_FILES     = NO
SHOW_FILES          = YES
SHOW_NAMESPACES     = NO

# Other settings
QUIET               = NO
WARNINGS            = YES
WARN_IF_UNDOCUMENTED = YES
WARN_IF_DOC_ERROR   = YES
WARN_NO_PARAMDOC    = YES

# Search engine
SEARCHENGINE        = NO
SERVER_BASED_SEARCH = NO

# MATLAB specific settings
OPTIMIZE_OUTPUT_FOR_MATLAB = YES
FILE_NAMING         = NO_LONG_NAMES

# MATLAB specific settings
EXTRACT_LOCAL_CLASSES = YES
EXTRACT_LOCAL_METHODS = YES
EXTRACT_ANON_NSPACES = YES

# Comment parsing
TCL_SUBST           = NO
MULTILINE_CPP_IS_BRIEF = NO
INHERIT_DOCS        = YES
SEPARATE_MEMBER_PAGES = NO
TAB_SIZE            = 4
ALIASES            += "matlab=\par MATLAB Example:\n"

# Documentation extraction
HIDE_UNDOC_MEMBERS  = NO
HIDE_UNDOC_CLASSES  = NO
BRIEF_MEMBER_DESC   = YES
REPEAT_BRIEF        = YES
ALWAYS_DETAILED_SEC = NO
INLINE_INHERITED_MEMB = NO
SHOW_INCLUDE_FILES  = YES
SORT_MEMBER_DOCS    = YES
SORT_BRIEF_DOCS     = NO
SORT_GROUP_NAMES    = NO
SORT_BY_SCOPE_NAME  = NO

# Disable unnecessary features
GENERATE_TODOLIST   = NO
GENERATE_TESTLIST   = NO
GENERATE_BUGLIST    = NO
GENERATE_DEPRECATEDLIST = NO
SHOW_USED_FILES     = NO
SHOW_FILES          = YES
SHOW_NAMESPACES     = NO

# Other settings
QUIET               = NO
WARNINGS            = YES
WARN_IF_UNDOCUMENTED = YES
WARN_IF_DOC_ERROR   = YES
WARN_NO_PARAMDOC    = YES

# Search engine
SEARCHENGINE        = NO
SERVER_BASED_SEARCH = NO

# Navigation
GENERATE_TREEVIEW    = YES
DISABLE_INDEX        = NO 