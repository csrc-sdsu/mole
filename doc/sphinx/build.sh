#!/bin/bash
set -e

echo "=== MOLE Documentation Build Script ==="

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/source"
BUILD_DIR="$SCRIPT_DIR/build"
LATEX_DIR="$BUILD_DIR/latex"
PDF_DIR="$LATEX_DIR/PDF"
SVG_DIR="$SOURCE_DIR/api/examples/md/figures"

# Clean build directory
echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Run Sphinx to generate LaTeX
echo "Running Sphinx to generate LaTeX..."
sphinx-build -b latex "$SOURCE_DIR" "$LATEX_DIR"

# Create directories for images and PDF output
mkdir -p "$LATEX_DIR/_images"
mkdir -p "$LATEX_DIR/figures"
mkdir -p "$PDF_DIR"

# Find all SVG files in the figures directory
echo "Finding SVG files..."
SVG_FILES=$(find "$SVG_DIR" -name "*.svg")

# Convert all SVGs to high-quality PDFs
echo "Converting SVGs to high-quality PDFs..."
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

# Create a fix for image includes
echo "Creating LaTeX image fix..."
cat > "$LATEX_DIR/imagequality.sty" << EOL
% High-quality PDF settings
\\pdfminorversion=7
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

# Specifically fix the broken image includes
echo "Fixing problematic image includes..."
sed -i.bak3 's/\\sphinxincludegraphics\[{[^}]*}\]{{/\\includegraphics[width=\\linewidth]{/g' MOLE-docs.tex
sed -i.bak4 's/\.svg}/.pdf}/g' MOLE-docs.tex

# Fix math environment issues if present
if grep -q "\\\\begin{split}" MOLE-docs.tex; then
    echo "Fixing math environment issues..."
    sed -i.bak5 's/\\begin{equation\*}\\begin{split}/\\begin{align}/g' MOLE-docs.tex
    sed -i.bak6 's/\\end{split}\\end{equation\*}/\\end{align}/g' MOLE-docs.tex
    sed -i.bak7 's/\\tag{[^}]*}//g' MOLE-docs.tex
fi

# Fix the \\capstart command redefinition issue
sed -i.bak8 's/\\newcommand{\\capstart}{}/\\providecommand{\\capstart}{}/g' MOLE-docs.tex

# Compile PDF
echo "Compiling LaTeX to PDF..."
pdflatex -interaction=nonstopmode MOLE-docs.tex || true
pdflatex -interaction=nonstopmode MOLE-docs.tex || true
pdflatex -interaction=nonstopmode MOLE-docs.tex || true

# Check if PDF was generated successfully
if [ -f "MOLE-docs.pdf" ]; then
  # Move PDF to the PDF directory 
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