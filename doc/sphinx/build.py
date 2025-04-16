#!/usr/bin/env python3
"""
Build script for MOLE Documentation
----------------------------------
This script handles SVG to PDF conversion and builds the LaTeX PDF documentation.
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def run_cmd(cmd, cwd=None):
    """Run a command and print its output in real-time."""
    print(f"\n=== Running: {cmd} ===")
    try:
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            cwd=cwd
        )
        
        # Print output in real-time
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.rstrip())
                
        return_code = process.poll()
        if return_code != 0:
            print(f"Command failed with return code {return_code}")
            return False
        return True
    except Exception as e:
        print(f"Error executing command: {e}")
        return False

def convert_svg_files():
    """Convert SVG files to PDFs using rsvg-convert."""
    if not shutil.which('rsvg-convert'):
        print("Error: rsvg-convert not found. Please install librsvg.")
        return False
    
    # Create output directory
    os.makedirs('build/latex/_images', exist_ok=True)
    
    # Find all SVG files
    svg_files = list(Path('source').rglob('*.svg'))
    print(f"\nFound {len(svg_files)} SVG files to convert")
    
    for svg_file in svg_files:
        output_pdf = Path('build/latex/_images') / f"{svg_file.stem}.pdf"
        print(f"\nConverting {svg_file} to {output_pdf}")
        
        try:
            # Use rsvg-convert for high-quality conversion
            subprocess.run([
                'rsvg-convert',
                '-f', 'pdf',
                '-o', str(output_pdf),
                '--dpi-x', '600',
                '--dpi-y', '600',
                '--page-width', '2500',
                '--page-height', '2000',
                '--keep-aspect-ratio',
                str(svg_file)
            ], check=True, capture_output=True, text=True)
            
            if output_pdf.exists() and output_pdf.stat().st_size > 1000:
                print(f"✅ Success: Created PDF ({output_pdf.stat().st_size:,} bytes)")
            else:
                print(f"⚠️  Warning: PDF seems too small ({output_pdf.stat().st_size} bytes)")
        except subprocess.CalledProcessError as e:
            print(f"❌ Error: {e}")
            return False
    
    return True

def compile_latex():
    """Compile LaTeX to PDF using pdflatex directly."""
    os.chdir('build/latex')
    
    # Run pdflatex multiple times to resolve references
    for i in range(3):
        print(f"\n=== LaTeX Pass {i+1}/3 ===")
        if not run_cmd('pdflatex -interaction=nonstopmode MOLE-docs.tex', cwd='.'):
            print("LaTeX compilation failed")
            return False
    
    # Check if PDF was generated
    if os.path.exists('MOLE-docs.pdf'):
        pdf_size = os.path.getsize('MOLE-docs.pdf')
        print(f"\n✅ PDF generated successfully ({pdf_size:,} bytes)")
        print(f"Location: {os.path.abspath('MOLE-docs.pdf')}")
        return True
    else:
        print("\n❌ PDF generation failed")
        return False

def build_pdf():
    """Build the PDF documentation."""
    print("\n=== Building PDF documentation ===")
    
    # Clean build directory
    if os.path.exists('build'):
        print("Cleaning build directory...")
        shutil.rmtree('build')
    
    # Convert SVG files first
    if not convert_svg_files():
        print("\n❌ SVG conversion failed")
        return False
    
    # Build LaTeX
    print("\n=== Generating LaTeX files ===")
    if not run_cmd('sphinx-build -b latex source build/latex'):
        print("\n❌ LaTeX generation failed")
        return False
    
    # Compile LaTeX to PDF
    print("\n=== Compiling LaTeX to PDF ===")
    if not compile_latex():
        return False
    
    print("\n✅ Build completed successfully!")
    return True

if __name__ == '__main__':
    if not build_pdf():
        sys.exit(1) 