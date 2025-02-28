#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p doc/doxygen/matlab2/html

# Copy over necessary assets first
cp doc/doxygen/matlab/matlabicon.gif doc/doxygen/matlab2/html/
cp doc/doxygen/templates/custom.css doc/doxygen/matlab2/html/

# Clean up any existing files except the assets
find doc/doxygen/matlab2/html -type f ! -name 'matlabicon.gif' ! -name 'custom.css' -delete

# Run doxygen with the MATLAB configuration
doxygen doc/doxygen/Doxyfile.matlab

# Fix permissions
chmod -R 755 doc/doxygen/matlab2/html

echo "Documentation generated in doc/doxygen/matlab2/html"
echo "You can view it by opening doc/doxygen/matlab2/html/index.html in your browser" 