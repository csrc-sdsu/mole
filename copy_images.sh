#!/bin/bash

# Get the current directory (should be the project root)
CURRENT_DIR=$(pwd)

# Create the destination directory if it doesn't exist
mkdir -p "${CURRENT_DIR}/doc/sphinx/build/html/_static/img"

# Copy all images from the assets directory to the _static/img directory
cp -f "${CURRENT_DIR}/doc/assets/img/"*.png "${CURRENT_DIR}/doc/sphinx/build/html/_static/img/"

# Fix image paths in the HTML file
HTML_FILE="${CURRENT_DIR}/doc/sphinx/build/html/api/readme_wrapper.html"
if [ -f "$HTML_FILE" ]; then
    # Use sed to replace the image paths
    sed -i '' 's|src="api/doc/assets/img/\([^"]*\)"|src="../_static/img/\1"|g' "$HTML_FILE"
    sed -i '' 's|src="doc/assets/img/\([^"]*\)"|src="../_static/img/\1"|g' "$HTML_FILE"
    echo "Image paths fixed in $HTML_FILE"
else
    echo "HTML file not found: $HTML_FILE"
fi

echo "Images copied and paths fixed successfully!" 