# Minimal makefile for Sphinx documentation
#

# Configuration
SPHINXBUILD   ?= sphinx-build
SPHINXOPTS    ?=
SOURCEDIR     = source
BUILDDIR      = build


# Output directories
PDFDIR        = $(BUILDDIR)/pdf
DOXYDIR       = $(BUILDDIR)/doxygen

.PHONY: help doc-deps doc-html doc-latexpdf doc-clean doc-doxygen doc-all

# Default target
help:
	@echo "Documentation targets:"
	@echo "  doc-deps     : Install documentation dependencies"
	@echo "  doc-html     : Build HTML documentation"
	@echo "  doc-latexpdf : Build LaTeX documentation and generate PDF"
	@echo "  doc-doxygen  : Generate Doxygen documentation"
	@echo "  doc-clean    : Remove all built documentation"
	@echo "  doc-all      : Generate all documentation formats"

# Install dependencies from requirements.txt
doc-deps:
	@pip install -r requirements.txt

# Clean built documentation
doc-clean:
	@rm -rf $(BUILDDIR)

# HTML documentation
doc-html: doc-deps
	@mkdir -p $(BUILDDIR)
	$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

# LaTeX + PDF documentation
doc-latexpdf: doc-deps
	@mkdir -p $(BUILDDIR)/latex $(PDFDIR)
	$(SPHINXBUILD) -M latex "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)
	@make -C $(BUILDDIR)/latex
	@mv $(BUILDDIR)/latex/*.pdf $(PDFDIR)/

# Doxygen documentation
doc-doxygen: doc-deps
	@mkdir -p $(DOXYDIR)
	@cd ../.. && doxygen Doxyfile

# Generate all documentation
doc-all: doc-clean doc-doxygen doc-html doc-latexpdf
	@echo "Documentation generated in:"
	@echo "  HTML: $(BUILDDIR)/html/"
	@echo "  PDF:  $(PDFDIR)/"
	@echo "  API:  $(DOXYDIR)/"

# Catch-all target: route all unknown targets to Sphinx
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)