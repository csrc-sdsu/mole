"""
Sphinx extension to filter out license headers from MATLAB docstrings
and improve MATLAB documentation formatting.
"""
import re

def filter_matlab_docstring(app, what, name, obj, options, lines):
    """
    Process MATLAB docstrings - remove license headers and improve formatting.
    
    This function is called for each docstring during the documentation build process.
    """
    if not lines:
        return
        
    # Get configuration options
    matlab_filter_options = getattr(app.config, 'matlab_filter_options', {})
    remove_license = matlab_filter_options.get('remove_license', True)
    improve_formatting = matlab_filter_options.get('improve_formatting', True)
    fix_missing_descriptions = matlab_filter_options.get('fix_missing_descriptions', True)
    
    if remove_license:
        # Remove license headers
        license_pattern = re.compile(r'[-]{10,}|SPDX-License-Identifier:|© \d{4}-\d{4}|See LICENSE file')
        
        # Create a list of indices to remove
        indices_to_remove = []
        i = 0
        while i < len(lines):
            if license_pattern.search(lines[i]):
                # Found a license line, mark it for removal
                indices_to_remove.append(i)
                # Check if the next lines are also part of the license header
                j = i + 1
                while j < len(lines) and (j - i < 5) and (license_pattern.search(lines[j]) or lines[j].strip() == ''):
                    indices_to_remove.append(j)
                    j += 1
            i += 1
        
        # Remove the marked lines, starting from the end to avoid index shifting
        for idx in sorted(indices_to_remove, reverse=True):
            if idx < len(lines):
                del lines[idx]
    
    if improve_formatting or fix_missing_descriptions:
        # Common section patterns to recognize
        section_patterns = [
            r'Parameters\s*:', r'Returns\s*:', r'See also\s*:', 
            r'Example\s*:', r'Examples\s*:', r'Note\s*:'
        ]
        section_pattern = re.compile('|'.join(section_patterns))
        
        # Fix common formatting issues
        parameters_section = False
        
        # Add blank lines after sections if missing
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # Check for section headers
            if section_pattern.fullmatch(line):
                # Found a section header
                if line.startswith('Parameters'):
                    parameters_section = True
                
                # Make sure there's a blank line after every section header
                if improve_formatting and i + 1 < len(lines):
                    # Check if the next line is a line of dashes/tildes (section underline)
                    next_line = lines[i + 1].strip()
                    if next_line and all(c == '-' or c == '~' for c in next_line):
                        # Already has an underline, make sure there's a blank line after that
                        if i + 2 < len(lines) and lines[i + 2].strip():
                            lines.insert(i + 2, '')
                            i += 1
                    else:
                        # Add a section underline and a blank line
                        lines.insert(i + 1, '~' * len(line))
                        if i + 2 < len(lines) and lines[i + 2].strip():
                            lines.insert(i + 2, '')
                            i += 2
                        else:
                            i += 1
            
            # Handle parameters that don't have descriptions
            elif parameters_section and fix_missing_descriptions:
                param_match = re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line)
                if param_match:
                    param_name = param_match.group(1)
                    rest_of_line = line.split(':', 1)[1].strip()
                    
                    # If parameter has no description
                    if not rest_of_line:
                        # Add a placeholder description
                        lines[i] = f"{param_name} : Parameter description not provided"
                    
                    # Make sure parameter descriptions have proper spacing
                    elif improve_formatting:
                        if i + 1 < len(lines) and lines[i + 1].strip() and not lines[i + 1].strip().startswith(' '):
                            lines.insert(i + 1, '')
                            i += 1
            
            # Fix definition lists with incorrect indentation
            elif improve_formatting and i + 1 < len(lines):
                # Look for patterns like:
                # text
                # indented text (without a blank line between)
                current_line_indented = line.startswith(' ')
                next_line = lines[i + 1].strip()
                next_line_indented = lines[i + 1].startswith(' ')
                
                # If this line isn't indented but the next one is (without a blank line),
                # it's likely a definition list with incorrect formatting
                if line and next_line and not current_line_indented and next_line_indented:
                    # Insert a blank line to fix the definition list
                    lines.insert(i + 1, '')
                    i += 1
            
            i += 1

def setup(app):
    """
    Set up the extension.
    """
    # Add default configuration
    app.add_config_value('matlab_filter_options', {
        'remove_license': True,
        'improve_formatting': True,
        'fix_missing_descriptions': True,
    }, 'env')
    
    # Connect to the autodoc-process-docstring event
    app.connect('autodoc-process-docstring', filter_matlab_docstring)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 