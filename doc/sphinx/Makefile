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

# List of Sphinx builders
SPHINX_TARGETS := html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub text man changes linkcheck doctest coverage gettext

.PHONY: help clean doc-deps doc-html doc-clean doc-doxygen doc-all $(SPHINX_TARGETS) doc-latexpdf doc-latexpdf

# Default target
help:
	@echo "Documentation targets:"
	@echo "  doc-doxygen  : Generate Doxygen documentation"
	@echo "  doc-deps     : Install documentation dependencies"
	@echo "  doc-html     : Build HTML documentation"
	@echo "  doc-latexpdf      : Build PDF documentation using XeLaTeX"
	@echo "  doc-clean    : Remove all built documentation"
	@echo "  doc-all      : Generate all documentation formats with a clean build"

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
	@pip install -r requirements.txt

# HTML documentation
doc-html: doc-deps doc-doxygen
	@echo "Generating HTML documentation..."
	@mkdir -p $(BUILDDIR)
	@if [ ! -f "$(DOXYXML)/index.xml" ]; then \
		echo "Error: Doxygen XML index file not found. Running doc-doxygen first..."; \
		$(MAKE) doc-doxygen; \
	fi
	PYTHONPATH=../.. $(SPHINXBUILD) -b html "$(SOURCEDIR)" "$(BUILDDIR)/html"

# Clean built documentation
doc-clean:
	@echo "Cleaning documentation build directories..."
	@rm -rf $(BUILDDIR)
	@rm -rf $(DOXYDIR)

# PDF documentation
doc-latexpdf: doc-deps doc-doxygen
	@echo "Generating PDF documentation..."
	@mkdir -p $(BUILDDIR)
	@if [ ! -f "$(DOXYXML)/index.xml" ]; then \
		echo "Error: Doxygen XML index file not found. Running doc-doxygen first..."; \
		$(MAKE) doc-doxygen; \
	fi
	@echo "Building PDF using Sphinx..."
	PYTHONPATH=../.. $(SPHINXBUILD) -b latex "$(SOURCEDIR)" "$(BUILDDIR)/latex"
	@echo "Running pdflatex passes (2 passes for references)..."
	@(cd $(BUILDDIR)/latex && \
		pdflatex -interaction=nonstopmode MOLE-docs.tex; \
		pdflatex -interaction=nonstopmode MOLE-docs.tex || true)
	@if [ -f "$(BUILDDIR)/latex/MOLE-docs.pdf" ]; then \
		echo "PDF documentation generated successfully at: $(BUILDDIR)/latex/MOLE-docs.pdf"; \
	else \
		echo "ERROR: PDF generation failed"; \
		exit 1; \
	fi
	@echo "Checking our debug logs..."
	@(cd $(BUILDDIR)/latex && \
		grep "DEBUG:" MOLE-docs.log || echo "No debug logs found!")

# Generate all documentation
doc-all: doc-clean doc-doxygen doc-deps doc-html doc-latexpdf
	@echo "Documentation generated in:"
	@echo "  HTML: $(BUILDDIR)/html/"
	@echo "  PDF:  $(BUILDDIR)/latex/MOLE-docs.pdf"
	@echo "  API:  $(DOXYDIR)/"

# Explicit Sphinx targets
$(SPHINX_TARGETS):
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)