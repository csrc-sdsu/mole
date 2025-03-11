#!/bin/bash

# Create the destination directory if it doesn't exist
mkdir -p doc/sphinx/build/html/_static/img

# Copy all images from the assets directory to the _static/img directory
cp -f doc/assets/img/*.png doc/sphinx/build/html/_static/img/

echo "Images copied successfully!"
