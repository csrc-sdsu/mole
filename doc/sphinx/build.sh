#!/bin/bash
set -e

echo "=== Cleaning build directory ==="
rm -rf build/
mkdir -p build/latex/_images

echo "=== Converting SVG files ==="
find source -name "*.svg" -print0 | while IFS= read -r -d '' f; do
    echo "Converting $f..."
    basename_no_ext=$(basename "${f%.svg}")
    output_pdf="build/latex/_images/${basename_no_ext}.pdf"
    rsvg-convert -f pdf -o "$output_pdf" \
        --dpi-x 600 --dpi-y 600 --page-width 2500 --page-height 2000 \
        --keep-aspect-ratio "$f"
    
    echo "  Created: $output_pdf ($(du -h "$output_pdf" | cut -f1))"
done

echo "=== Creating mathconf.js for math fixes ==="
mkdir -p source/_static
cat > source/_static/mathconf.js << 'EOL'
// Fix math rendering issues
window.MathJax = {
  tex: {
    inlineMath: [['\\(', '\\)']],
    displayMath: [['\\[', '\\]'], ['$$', '$$']],
    processEscapes: true,
    processEnvironments: true,
    packages: ['base', 'ams', 'noerrors', 'noundefined']
  },
  options: {
    ignoreHtmlClass: 'tex2jax_ignore',
    processHtmlClass: 'tex2jax_process'
  }
};
EOL

echo "=== Building LaTeX files ==="
sphinx-build -b latex source build/latex

echo "=== Fixing LaTeX file issues ==="
# Fix extensions in includegraphics commands
sed -i.bak 's/includegraphics{{/includegraphics[width=\\linewidth]{{/g' build/latex/MOLE-docs.tex
sed -i.bak 's/}.svg}/}.pdf}/g' build/latex/MOLE-docs.tex
sed -i.bak 's/}.png}/}.pdf}/g' build/latex/MOLE-docs.tex

# Check for math environment issues in the LaTeX file
if grep -q "\\\\begin{split}" build/latex/MOLE-docs.tex; then
    echo "=== WARNING: Found split environments in the LaTeX file ==="
    
    # Fix problematic split environments
    sed -i.bak 's/\\begin{equation\*}\\begin{split}/\\begin{align}/g' build/latex/MOLE-docs.tex
    sed -i.bak 's/\\end{split}\\end{equation\*}/\\end{align}/g' build/latex/MOLE-docs.tex
    
    # Remove any \tag commands inside split environments
    sed -i.bak 's/\\tag{[^}]*}//g' build/latex/MOLE-docs.tex
fi

# Fix the \\capstart command redefinition issue
sed -i.bak 's/\\newcommand{\\capstart}{}/\\providecommand{\\capstart}{}/g' build/latex/MOLE-docs.tex

echo "=== Compiling PDF ==="
cd build/latex
pdflatex -interaction=nonstopmode MOLE-docs.tex
pdflatex -interaction=nonstopmode MOLE-docs.tex
pdflatex -interaction=nonstopmode MOLE-docs.tex

if [ -f MOLE-docs.pdf ]; then
    echo "=== Success! ==="
    echo "PDF generated at: $(pwd)/MOLE-docs.pdf"
    ls -lh MOLE-docs.pdf
    
    # Copy PDF to a more accessible location
    cp MOLE-docs.pdf ../../MOLE-docs.pdf
    echo "PDF also copied to: $(cd ../.. && pwd)/MOLE-docs.pdf"
else
    echo "=== Error: PDF generation failed ==="
    echo "=== DEBUG: Examining LaTeX log for errors ==="
    grep -A 5 "Error:" MOLE-docs.log || echo "No specific error messages found"
    grep -A 5 "! LaTeX Error:" MOLE-docs.log || echo "No LaTeX errors found"
    grep -A 5 "! Package amsmath Error:" MOLE-docs.log || echo "No amsmath errors found"
    exit 1
fi 