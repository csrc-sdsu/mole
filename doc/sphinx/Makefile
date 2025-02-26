# Minimal makefile for Sphinx documentation

# Variables
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
PDFDIR        = $(BUILDDIR)/pdf
DOXYDIR       = $(BUILDDIR)/doxygen
REQUIREMENTS  = requirements.txt

# Colors for status messages
GREEN  := $(shell tput -Txterm setaf 2)
RED    := $(shell tput -Txterm setaf 1)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help doc-html doc-latexpdf doc-clean doc-deps doc-doxygen doc-all

# Default target
help:
	@echo "$(GREEN)Available documentation targets:$(RESET)"
	@echo "  $(YELLOW)doc-deps$(RESET)     - Install documentation dependencies"
	@echo "  $(YELLOW)doc-html$(RESET)     - Build HTML documentation"
	@echo "  $(YELLOW)doc-latexpdf$(RESET) - Build LaTeX documentation and generate PDF"
	@echo "  $(YELLOW)doc-doxygen$(RESET)  - Generate Doxygen documentation"
	@echo "  $(YELLOW)doc-clean$(RESET)    - Remove all built documentation"
	@echo "  $(YELLOW)doc-all$(RESET)      - Generate all documentation formats"

# Install dependencies
doc-deps:
	@echo "$(YELLOW)Installing documentation dependencies...$(RESET)"
	@if [ -f "$(REQUIREMENTS)" ]; then \
		pip install -r $(REQUIREMENTS) || \
		{ echo "$(RED)Error: Failed to install requirements from $(REQUIREMENTS)$(RESET)"; exit 1; }; \
	else \
		pip install sphinx sphinx-rtd-theme sphinx-autodoc-typehints doxygen-sphinx-inventory || \
		{ echo "$(RED)Error: Failed to install default dependencies$(RESET)"; exit 1; }; \
	fi
	@echo "$(GREEN)Dependencies installed successfully.$(RESET)"

# Clean built documentation
doc-clean:
	@echo "$(YELLOW)Cleaning documentation build directory...$(RESET)"
	@rm -rf $(BUILDDIR)
	@echo "$(GREEN)Clean completed.$(RESET)"

# HTML documentation
doc-html: doc-deps
	@echo "$(YELLOW)Building HTML documentation...$(RESET)"
	@if ! command -v $(SPHINXBUILD) >/dev/null 2>&1; then \
		echo "$(RED)Error: sphinx-build is not installed. Run 'pip install sphinx'$(RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(BUILDDIR)
	@$(SPHINXBUILD) -b html $(SOURCEDIR) $(BUILDDIR)/html || \
		{ echo "$(RED)Error: HTML build failed. Check the error messages above.$(RESET)"; exit 1; }
	@echo "$(GREEN)HTML documentation built successfully in $(BUILDDIR)/html/$(RESET)"

# LaTeX + PDF documentation
doc-latexpdf: doc-deps
	@echo "$(YELLOW)Building LaTeX documentation and generating PDF...$(RESET)"
	@if ! command -v $(SPHINXBUILD) >/dev/null 2>&1; then \
		echo "$(RED)Error: sphinx-build is not installed. Run 'pip install sphinx'$(RESET)"; \
		exit 1; \
	fi
	@if ! command -v pdflatex >/dev/null 2>&1; then \
		echo "$(RED)Error: pdflatex is not installed. Install TeX Live or similar LaTeX distribution.$(RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(BUILDDIR)/latex
	@$(SPHINXBUILD) -b latex $(SOURCEDIR) $(BUILDDIR)/latex || \
		{ echo "$(RED)Error: LaTeX build failed. Check the error messages above.$(RESET)"; exit 1; }
	@echo "$(YELLOW)Running LaTeX to generate PDF...$(RESET)"
	@(cd $(BUILDDIR)/latex && make) || \
		{ echo "$(RED)Error: PDF generation failed. Check the LaTeX error messages above.$(RESET)"; exit 1; }
	@mkdir -p $(PDFDIR)
	@mv $(BUILDDIR)/latex/*.pdf $(PDFDIR)/ || \
		{ echo "$(RED)Error: Could not move PDF files to output directory.$(RESET)"; exit 1; }
	@echo "$(GREEN)PDF documentation built successfully in $(PDFDIR)/$(RESET)"

# Doxygen documentation
doc-doxygen: doc-deps
	@echo "$(YELLOW)Generating Doxygen documentation...$(RESET)"
	@if ! command -v doxygen >/dev/null 2>&1; then \
		echo "$(RED)Error: doxygen is not installed. Please install doxygen first.$(RESET)"; \
		exit 1; \
	fi
	@mkdir -p $(DOXYDIR)
	@if [ -f Doxyfile ]; then \
		doxygen Doxyfile || \
		{ echo "$(RED)Error: Doxygen generation failed. Check the error messages above.$(RESET)"; exit 1; }; \
	else \
		echo "$(RED)Error: Doxyfile not found. Please create a Doxyfile first.$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Doxygen documentation built successfully in $(DOXYDIR)/$(RESET)"

# Generate all documentation
doc-all: doc-clean doc-deps doc-doxygen doc-html doc-latexpdf
	@echo "$(GREEN)All documentation generated successfully!$(RESET)"
	@echo "$(YELLOW)Documentation locations:$(RESET)"
	@echo "  HTML: $(BUILDDIR)/html/"
	@echo "  PDF:  $(PDFDIR)/"
	@echo "  API:  $(DOXYDIR)/"
