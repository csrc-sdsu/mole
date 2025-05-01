# Minimal makefile for Sphinx documentation
#

# Configuration
SPHINXBUILD   ?= sphinx-build
SPHINXOPTS    ?=
SOURCEDIR     = source
BUILDDIR      = build

# Output directories
DOXYDIR       = ../doxygen/cpp
DOXYXML       = $(DOXYDIR)/xml
PDFDIR        = $(BUILDDIR)/latex/PDF
HTMLDIR       = $(BUILDDIR)/html

# List of Sphinx builders
SPHINX_TARGETS := html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub text man changes linkcheck doctest coverage gettext

# Detect operating system for open command
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  # macOS
  OPEN_CMD := open
else ifeq ($(UNAME), Linux)
  # Linux (using xdg-open)
  OPEN_CMD := xdg-open
else
  # Windows or others (with limited functionality)
  OPEN_CMD := start
endif

.PHONY: help clean doc-deps doc-html doc-clean doc-doxygen doc-all $(SPHINX_TARGETS) doc-latexpdf doc-latexpdf

# Default target
help:
	@echo "Documentation targets:"
	@echo "  doc-doxygen  : Generate Doxygen documentation"
	@echo "  doc-deps     : Install documentation dependencies"
	@echo "  doc-html     : Build HTML documentation and open in browser"
	@echo "  doc-latexpdf : Build PDF documentation and open in viewer"
	@echo "  doc-clean    : Remove all built documentation"
	@echo "  doc-all      : Generate all HTML+PDF formats with a clean build"

# Doxygen documentation
doc-doxygen:
	@echo "Generating Doxygen documentation..."
	@cd ../.. && doxygen Doxyfile
	@if [ ! -d "$(DOXYXML)" ]; then \
		echo "Error: Doxygen XML output directory not found at $(DOXYXML)"; \
		echo "Please check your Doxyfile configuration"; \
		exit 1; \
	fi

# Install dependencies from requirements.txt
doc-deps:
	@python3 -m pip install -r requirements.txt

# HTML documentation
doc-html: 
	@echo "Generating HTML documentation..."
	@mkdir -p $(BUILDDIR)
	@if [ ! -f "$(DOXYXML)/index.xml" ]; then \
		echo "Error: Doxygen XML index file not found. Running doc-doxygen first..."; \
		$(MAKE) doc-doxygen; \
	fi
	PYTHONPATH=../.. $(SPHINXBUILD) -b html "$(SOURCEDIR)" "$(BUILDDIR)/html"
	@if [ -f "$(HTMLDIR)/index.html" ]; then \
		echo "=== HTML documentation generated successfully ==="; \
		echo "   View documentation at: $(HTMLDIR)/index.html"; \
		echo "   Open with a browser:  file://$(CURDIR)/$(HTMLDIR)/index.html"; \
		$(OPEN_CMD) "$(HTMLDIR)/index.html" || echo "Could not automatically open documentation"; \
	else \
		echo "=== Error: HTML generation failed ==="; \
		exit 1; \
	fi

# Clean built documentation
doc-clean:
	@echo "Cleaning documentation build directories..."
	@rm -rf $(BUILDDIR)
	@rm -rf $(DOXYDIR)

# high-quality PDF docs with optimized figures
doc-latexpdf: MAKEFLAGS += -f $(lastword $(MAKEFILE_LIST))
doc-latexpdf: depcheck-pdflatex depcheck-inkscape
	@echo "=== Generating high-quality PDF documentation with optimized figures ==="
	@chmod +x $(CURDIR)/build.sh
	@$(CURDIR)/build.sh
	@if [ $$? -eq 0 ] && [ -f "$(PDFDIR)/MOLE-docs.pdf" ]; then \
		echo "=== PDF generated successfully at $(PDFDIR)/MOLE-docs.pdf ==="; \
		$(OPEN_CMD) "$(PDFDIR)/MOLE-docs.pdf" || echo "Could not automatically open PDF documentation"; \
	else \
		echo "=== Error: PDF generation failed ==="; \
		exit 1; \
	fi

# Check for required tools
depcheck-pdflatex:
	@command -v pdflatex >/dev/null 2>&1 || { \
		echo >&2 "pdflatex is required for PDF generation."; \
		echo >&2 "  - macOS: brew install --cask mactex"; \
		echo >&2 "  - Ubuntu/Debian: apt-get install texlive-latex-base texlive-fonts-recommended texlive-latex-extra"; \
		echo >&2 "  - RHEL/Fedora: dnf install texlive-scheme-medium"; \
		exit 1; \
	}

depcheck-inkscape:
	@command -v inkscape >/dev/null 2>&1 || { \
		echo >&2 "Inkscape is required for high-quality SVG to PDF conversion."; \
		echo >&2 "  - macOS: brew install inkscape"; \
		echo >&2 "  - Ubuntu/Debian: apt-get install inkscape"; \
		echo >&2 "  - Windows: download from https://inkscape.org/"; \
		exit 1; \
	}

# Generate all documentation
doc-all: doc-clean doc-doxygen doc-deps doc-html doc-latexpdf
	@echo "================================================================"
	@echo "Documentation generated and opened:"
	@echo "  HTML: $(HTMLDIR)/index.html"
	@echo "  PDF:  $(PDFDIR)/MOLE-docs.pdf"
	@echo "  API:  ../doxygen/cpp/"
	@echo "================================================================"
# Explicit Sphinx targets
$(SPHINX_TARGETS):
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)
	
.PHONY: copy-images
copy-images:
	mkdir -p source/_images
	cp -r ../assets/img/* source/_images/ || true
	# Copy README images to the _images directory for proper reference
	mkdir -p source/intros/doc/assets/img
	cp -r ../assets/img/* source/intros/doc/assets/img/ || true
	# Create figure directories for SVG files
	mkdir -p source/api/examples/md/figures
	mkdir -p source/api/examples-m/md/figures
	mkdir -p source/math_functions/figures

.PHONY: clean
clean:
	rm -rf $(BUILDDIR)/*

.PHONY: doc-clean
doc-clean: clean
	rm -rf source/examples
	rm -rf source/_images
	rm -rf source/intros/doc
	rm -f source/README.md

html: copy-images
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)