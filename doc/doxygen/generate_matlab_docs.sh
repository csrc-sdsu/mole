#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p doc/doxygen/matlab2/html

# Copy over necessary assets first
# Navigation and UI images
cp doc/doxygen/matlab/{up,down,left,right}.png doc/doxygen/matlab2/html/
# Icons
cp doc/doxygen/matlab/{matlabicon,simulinkicon,demoicon}.gif doc/doxygen/matlab2/html/
cp doc/doxygen/matlab/{c,c++,fortran,mex,pcode}.png doc/doxygen/matlab2/html/
# Platform icons
cp doc/doxygen/matlab/{alpha,hp,linux,solaris,sgi,windows}.png doc/doxygen/matlab2/html/
# Template files
cp doc/doxygen/templates/custom.css doc/doxygen/matlab2/html/
cp doc/doxygen/templates/header.html doc/doxygen/matlab2/html/
cp doc/doxygen/templates/footer.html doc/doxygen/matlab2/html/
cp doc/doxygen/templates/menu.html doc/doxygen/matlab2/html/
# Search functionality
cp doc/doxygen/matlab/doxysearch.php doc/doxygen/matlab2/html/

# Clean up any existing files except the assets
find doc/doxygen/matlab2/html -type f ! -name '*.png' ! -name '*.gif' ! -name '*.css' ! -name '*.html' ! -name '*.php' -delete

# Run doxygen with the MATLAB configuration
doxygen doc/doxygen/Doxyfile.matlab

# Fix permissions
chmod -R 755 doc/doxygen/matlab2/html

echo "Documentation generated in doc/doxygen/matlab2/html"
echo "You can view it by opening doc/doxygen/matlab2/html/index.html in your browser" 