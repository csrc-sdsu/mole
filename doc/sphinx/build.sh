#!/bin/bash
set -e

echo "=== MOLE Documentation Build Script ==="

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source"
BUILD_DIR="$SCRIPT_DIR/build"
LATEX_DIR="$BUILD_DIR/latex"
PDF_DIR="$LATEX_DIR/PDF"

# Multiple SVG directories to check
SVG_DIRS=(
  "$SOURCE_DIR/api/examples/md/figures"
  "$SOURCE_DIR/api/examples-m/md/figures"
  "$SOURCE_DIR/math_functions/figures"
)

# Clean latex directory but preserve html
echo "Cleaning LaTeX build directory but preserving HTML..."
if [ -d "$LATEX_DIR" ]; then
  rm -rf "$LATEX_DIR"
fi
mkdir -p "$LATEX_DIR"

# Run Sphinx to generate LaTeX
echo "Running Sphinx to generate LaTeX..."
sphinx-build -b latex "$SOURCE_DIR" "$LATEX_DIR"

# Universal image asset copying - copy all images from various sources
echo "Copying all image assets to LaTeX build directory..."
mkdir -p "$LATEX_DIR/_images"

# Copy governance images
cp -f "$SCRIPT_DIR/../assets/img/"*.png "$LATEX_DIR/_images/" 2>/dev/null || true
cp -f "$SCRIPT_DIR/../assets/img/"*.jpg "$LATEX_DIR/_images/" 2>/dev/null || true
cp -f "$SCRIPT_DIR/../assets/img/"*.jpeg "$LATEX_DIR/_images/" 2>/dev/null || true

# Copy images from source directories (figures, etc.)
find "$SOURCE_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read img; do
  cp -f "$img" "$LATEX_DIR/_images/" 2>/dev/null || true
done

# Create directories for images and PDF output
mkdir -p "$LATEX_DIR/_images"
mkdir -p "$LATEX_DIR/figures"
mkdir -p "$PDF_DIR"

# Process all SVG directories
echo "Finding and processing SVG files..."
for SVG_DIR in "${SVG_DIRS[@]}"; do
  if [ -d "$SVG_DIR" ]; then
    echo "Checking directory: $SVG_DIR"
    SVG_FILES=$(find "$SVG_DIR" -name "*.svg" 2>/dev/null || echo "")
    
    # Convert all SVGs to high-quality PDFs
    if [ -n "$SVG_FILES" ]; then
      echo "Converting SVGs from $SVG_DIR to high-quality PDFs..."
      for svg in $SVG_FILES; do
        base_name=$(basename "$svg" .svg)
        echo "  Converting: $base_name.svg"
        
        # Using Inkscape with very high DPI
        inkscape "$svg" \
          --export-filename="$LATEX_DIR/_images/$base_name.pdf" \
          --export-area-drawing \
          --export-dpi=2400
          
        # Copy to figures directory
        cp "$LATEX_DIR/_images/$base_name.pdf" "$LATEX_DIR/figures/"
      done
    else
      echo "No SVG files found in $SVG_DIR"
    fi
  else
    echo "Directory does not exist, skipping: $SVG_DIR"
  fi
done

# Create a fix for image includes
echo "Creating LaTeX image fix..."
cat > "$LATEX_DIR/imagequality.sty" << EOL
% High-quality PDF settings
% PDF versioning is now handled by hyperref
\\pdfcompresslevel=0
\\pdfobjcompresslevel=0
\\pdfimageresolution=2400

% Graphics paths
\\graphicspath{
  {_images/}
  {figures/}
  {./}
}

% Use PDF figures instead of SVG
\\let\\oldsphinxincludegraphics\\sphinxincludegraphics
\\renewcommand{\\sphinxincludegraphics}[2][]{%
  \\includegraphics[#1]{#2}%
}

% Fix for Unicode characters
\\DeclareUnicodeCharacter{FE0F}{}
EOL

# Fix the LaTeX file
echo "Updating LaTeX file..."
cd "$LATEX_DIR"

# Replace SVG with PDF in image references
sed -i.bak 's/\.svg}/.pdf}/g' MOLE-docs.tex

# Add our fix package after sphinx package
sed -i.bak2 's/\\usepackage{sphinx}/\\usepackage{sphinx}\\usepackage{imagequality}/' MOLE-docs.tex

# Universal image processing - handle all images consistently
echo "Processing all image includes with universal sizing..."

# Step 0: Convert sphinxincludegraphics to includegraphics
sed -i.bak3 's/\\sphinxincludegraphics/\\includegraphics/g' MOLE-docs.tex

# Step 1: Convert MyST width tokens to proper LaTeX format
# Pattern: \includegraphics{{filename}.ext}\{width=NN%\}
sed -E -i.bak4 's#\\includegraphics\{\{([^}]+)\}\.([a-zA-Z]+)\}\\\{width=([0-9]{1,3})\\\%\\\}#\\includegraphics[width=0.\3\\linewidth]{\1.\2}#g' MOLE-docs.tex

# Step 2: Normalize image paths - remove complex path structures and use simple filenames
# Pattern: \includegraphics[width=...]{path/to/filename.ext} -> \includegraphics[width=...]{filename.ext}
sed -E -i.bak5 's#\\includegraphics\[([^]]+)\]\{[^}]*/([^/}]+\.(png|jpg|jpeg|pdf))\}#\\includegraphics[\1]{\2}#g' MOLE-docs.tex
# Pattern: \includegraphics{{path/to/filename}.ext} -> \includegraphics{filename.ext}
sed -E -i.bak5a 's#\\includegraphics\{\{[^}]*/([^/}]+)\}\.([a-zA-Z]+)\}#\\includegraphics{\1.\2}#g' MOLE-docs.tex
# Also handle paths without double braces: \includegraphics{path/to/filename.ext} -> \includegraphics{filename.ext}
sed -E -i.bak5b 's#\\includegraphics\{[^}]*/([^/}]+\.(png|jpg|jpeg|pdf))\}#\\includegraphics{\1}#g' MOLE-docs.tex

# Step 3: Apply default sizing to images without explicit width
# Pattern: \includegraphics{filename.ext} -> \includegraphics[width=0.85\linewidth]{filename.ext}
sed -E -i.bak6 's#\\includegraphics\{([^}]+\.(png|jpg|jpeg|pdf))\}#\\includegraphics[width=0.85\\linewidth]{\1}#g' MOLE-docs.tex
# Also handle images with double braces: \includegraphics{{filename}.ext} -> \includegraphics[width=0.85\linewidth]{filename.ext}
sed -E -i.bak6a 's#\\includegraphics\{\{([^}]+)\}\.((png|jpg|jpeg|pdf))\}#\\includegraphics[width=0.85\\linewidth]{\1.\2}#g' MOLE-docs.tex

# Step 4: Handle special cases for specific image types
# Large diagrams/charts: use full width
sed -E -i.bak7 's#\\includegraphics\[width=0\.85\\linewidth\]\{(MOLE_pillars|MOLE_OSE_circles|governance|organization|chart|diagram)[^}]*\}#\\includegraphics[width=\\linewidth]{\1}#g' MOLE-docs.tex

# Small technical figures: use smaller width
sed -E -i.bak8 's#\\includegraphics\[width=0\.85\\linewidth\]\{(.*figure.*|.*plot.*|.*graph.*)\}#\\includegraphics[width=0.70\\linewidth]{\1}#g' MOLE-docs.tex

# Fix math environment issues if present
if grep -q "\\\\begin{split}" MOLE-docs.tex; then
    echo "Fixing math environment issues..."
    sed -i.bak9 's/\\begin{equation\*}\\begin{split}/\\begin{align}/g' MOLE-docs.tex
    sed -i.bak10 's/\\end{split}\\end{equation\*}/\\end{align}/g' MOLE-docs.tex
    sed -i.bak11 's/\\tag{[^}]*}//g' MOLE-docs.tex
fi

# Fix the \\capstart command redefinition issue
sed -i.bak12 's/\\newcommand{\\capstart}{}/\\providecommand{\\capstart}{}/g' MOLE-docs.tex

# Compile PDF
echo "Compiling LaTeX to PDF..."
pdflatex -interaction=nonstopmode MOLE-docs.tex || true
pdflatex -interaction=nonstopmode MOLE-docs.tex || true
pdflatex -interaction=nonstopmode MOLE-docs.tex || true

# Check if PDF was generated successfully
if [ -f "MOLE-docs.pdf" ]; then
  # Move PDF to the PDF directory 
  mkdir -p "$PDF_DIR"
  mv "MOLE-docs.pdf" "$PDF_DIR/MOLE-docs.pdf"
  echo "Success! PDF generated at: $PDF_DIR/MOLE-docs.pdf"
  ls -lh "$PDF_DIR/MOLE-docs.pdf"
  
  # No copies or symlinks to other locations, only one original at PDF_DIR
  exit 0
else
  echo "Failed to generate PDF."
  echo "=== DEBUG: Examining LaTeX log for errors ==="
  grep -A 5 "Error:" MOLE-docs.log || echo "No specific error messages found"
  grep -A 5 "! LaTeX Error:" MOLE-docs.log || echo "No LaTeX errors found"
  grep -A 5 "! Package amsmath Error:" MOLE-docs.log || echo "No amsmath errors found"
  exit 1
fi 