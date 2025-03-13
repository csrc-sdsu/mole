#!/usr/bin/env python3
import os
import re
from pathlib import Path

# Define paths
html_file = Path("build/html/api/readme_wrapper.html")
static_img_dir = Path("build/html/_static/img")

# Ensure the _static/img directory exists
static_img_dir.mkdir(parents=True, exist_ok=True)

# Function to fix image paths in HTML
def fix_image_paths():
    if not html_file.exists():
        print(f"Error: {html_file} does not exist!")
        return

    # Read the HTML file
    with open(html_file, "r", encoding="utf-8") as f:
        html_content = f.read()

    # Find all image tags with src="api/doc/assets/img/*.png"
    img_pattern = re.compile(r'<img alt="[^"]*" src="(?:api/)?doc/assets/img/([^"]+)"')
    
    # Replace the image paths
    fixed_content = img_pattern.sub(r'<img alt="Obtained with curvilinear operators" src="../_static/img/\1"', html_content)
    
    # Write the fixed content back to the file
    with open(html_file, "w", encoding="utf-8") as f:
        f.write(fixed_content)
    
    print(f"Image paths fixed in {html_file}")

if __name__ == "__main__":
    fix_image_paths() 