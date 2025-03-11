#!/bin/bash

# Get the current directory (should be the project root)
CURRENT_DIR=$(pwd)

# Create the assets directory if it doesn't exist
mkdir -p "${CURRENT_DIR}/doc/assets/img"

# Create placeholder images if they don't exist
if [ ! -f "${CURRENT_DIR}/doc/assets/img/4thOrder.png" ]; then
    echo "Creating placeholder images..."
    # Create a simple 1x1 pixel PNG for each required image
    convert -size 100x100 xc:blue "${CURRENT_DIR}/doc/assets/img/4thOrder.png"
    convert -size 100x100 xc:green "${CURRENT_DIR}/doc/assets/img/4thOrder2.png"
    convert -size 100x100 xc:red "${CURRENT_DIR}/doc/assets/img/4thOrder3.png"
    convert -size 100x100 xc:yellow "${CURRENT_DIR}/doc/assets/img/grid.png"
    convert -size 100x100 xc:orange "${CURRENT_DIR}/doc/assets/img/grid2.png"
    convert -size 100x100 xc:purple "${CURRENT_DIR}/doc/assets/img/WavyGrid.png"
    convert -size 100x100 xc:cyan "${CURRENT_DIR}/doc/assets/img/wave2D.png"
    convert -size 100x100 xc:magenta "${CURRENT_DIR}/doc/assets/img/burgers.png"
    
    # If ImageMagick is not available, create empty files
    if [ $? -ne 0 ]; then
        echo "ImageMagick not found, creating empty files..."
        touch "${CURRENT_DIR}/doc/assets/img/4thOrder.png"
        touch "${CURRENT_DIR}/doc/assets/img/4thOrder2.png"
        touch "${CURRENT_DIR}/doc/assets/img/4thOrder3.png"
        touch "${CURRENT_DIR}/doc/assets/img/grid.png"
        touch "${CURRENT_DIR}/doc/assets/img/grid2.png"
        touch "${CURRENT_DIR}/doc/assets/img/WavyGrid.png"
        touch "${CURRENT_DIR}/doc/assets/img/wave2D.png"
        touch "${CURRENT_DIR}/doc/assets/img/burgers.png"
    fi
fi

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