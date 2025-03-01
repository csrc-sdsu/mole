# Minimal makefile for Sphinx documentation
#

# Configuration
SPHINXBUILD   ?= sphinx-build
SPHINXOPTS    ?=
SOURCEDIR     = source
BUILDDIR      = build

# Output directories
PDFDIR        = $(BUILDDIR)/pdf
DOXYDIR       = ../doxygen/cpp
DOXYXML       = $(DOXYDIR)/xml

# List of Sphinx builders
SPHINX_TARGETS := html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub latex text man changes linkcheck doctest coverage gettext

.PHONY: help clean doc-deps doc-html doc-latexpdf doc-clean doc-doxygen doc-all $(SPHINX_TARGETS)

# Default target
help:
	@echo "Documentation targets:"
	@echo "  doc-doxygen  : Generate Doxygen documentation"
	@echo "  doc-deps     : Install documentation dependencies"
	@echo "  doc-html     : Build HTML documentation"
	@echo "  doc-latexpdf : Build LaTeX documentation and generate PDF"
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

# LaTeX + PDF documentation
doc-latexpdf: doc-deps doc-doxygen
	@mkdir -p $(BUILDDIR)/latex $(PDFDIR)
	PYTHONPATH=../.. $(SPHINXBUILD) -b latex "$(SOURCEDIR)" "$(BUILDDIR)/latex"
	@make -C $(BUILDDIR)/latex
	@mv $(BUILDDIR)/latex/*.pdf $(PDFDIR)/

# Clean built documentation
doc-clean:
	@echo "Cleaning documentation build directories..."
	@rm -rf $(BUILDDIR)
	@rm -rf $(DOXYDIR)

# Generate all documentation
doc-all: doc-clean doc-doxygen doc-deps doc-html doc-latexpdf
	@echo "Documentation generated in:"
	@echo "  HTML: $(BUILDDIR)/html/"
	@echo "  PDF:  $(PDFDIR)/"
	@echo "  API:  $(DOXYDIR)/"

# Explicit Sphinx targets
$(SPHINX_TARGETS):
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)