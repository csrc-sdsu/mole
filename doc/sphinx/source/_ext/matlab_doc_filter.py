"""
Sphinx extension to filter out license headers from MATLAB docstrings
and format them in an M2HTML-like style.
"""
import re

def m2html_style_formatter(app, what, name, obj, options, lines):
    """
    Process MATLAB docstrings to create M2HTML-like output.
    
    This transforms the docstrings to have clear sections like:
    - PURPOSE
    - SYNOPSIS
    - DESCRIPTION
    - CROSS-REFERENCE INFORMATION
    """
    if not lines or len(lines) < 1:
        return
        
    # Get configuration options
    matlab_filter_options = getattr(app.config, 'matlab_filter_options', {})
    remove_license = matlab_filter_options.get('remove_license', True)
    m2html_style = matlab_filter_options.get('m2html_style', True)
    
    # Store the original first line description as the PURPOSE
    first_desc_line = ""
    for line in lines:
        if line.strip() and not re.search(r'[-]{10,}|SPDX-License-Identifier:|© \d{4}-\d{4}|See LICENSE file', line):
            first_desc_line = line.strip()
            break
    
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
    
    if m2html_style and len(lines) > 0:
        # Extract function signature if available
        signature = ""
        if what == 'function' and name:
            # Try to extract signature from the first line if it contains function definition
            if lines and re.match(r'^\s*function\s+', lines[0]):
                signature = lines[0].strip()
            else:
                # Construct a basic signature from the function name
                signature = f"function {name}"
        
        # Look for cross-reference information
        calls_functions = []
        called_by = []
        cross_ref_section = False
        cross_ref_type = None
        
        # Parse for cross-reference information
        for i, line in enumerate(lines):
            line_lower = line.lower().strip()
            if "this function calls" in line_lower:
                cross_ref_section = True
                cross_ref_type = "calls"
            elif "this function is called by" in line_lower:
                cross_ref_section = True
                cross_ref_type = "called_by"
            elif cross_ref_section and line.strip():
                if line.strip().startswith('*') or line.strip().startswith('-'):
                    func_name = line.strip()[1:].strip()
                    if cross_ref_type == "calls":
                        calls_functions.append(func_name)
                    elif cross_ref_type == "called_by":
                        called_by.append(func_name)
                elif not line.startswith(' '):
                    # New section, end cross-reference
                    cross_ref_section = False
                    cross_ref_type = None
        
        # Extract parameters section
        parameters_section = []
        in_params_section = False
        
        # Extract description section (everything between first line and parameters)
        description_section = []
        for i, line in enumerate(lines):
            if i > 0:  # Skip the first line (used as PURPOSE)
                # Check for parameter section
                if line.strip().startswith('Parameters:'):
                    in_params_section = True
                    parameters_section.append(line.strip())
                # Check for parameters in the param section
                elif in_params_section:
                    # Convert :param style to consistent MATLAB style
                    if line.strip().startswith(':param'):
                        # Convert :param x: description to x : description
                        param_match = re.match(r'^\s*:param\s+([^:]+):\s*(.*)', line)
                        if param_match:
                            param_name = param_match.group(1).strip()
                            param_desc = param_match.group(2).strip() or "Parameter description not provided"
                            # Format with the same spacing as other parameters (right-aligned param names)
                            formatted_line = f"{param_name:>16} : {param_desc}"
                            parameters_section.append(formatted_line)
                        else:
                            parameters_section.append(line)
                    elif re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line):
                        # This is a normal parameter line (already in the right format)
                        # Fix parameter formatting (ensure proper spacing)
                        param_match = re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line)
                        if param_match:
                            param_name = param_match.group(1)
                            # Check if there's no description after the colon
                            parts = line.split(':', 1)
                            if len(parts) > 1 and not parts[1].strip():
                                formatted_line = f"{param_name:>16} : Parameter description not provided"
                                parameters_section.append(formatted_line)
                            else:
                                # Keep existing formatting but ensure consistent alignment
                                # Don't change the line itself - add it as is to preserve format
                                parameters_section.append(line)
                        else:
                            parameters_section.append(line)
                    elif not line.strip():
                        # Empty line within parameters section
                        parameters_section.append(line)
                    elif line.strip() and not line.strip().startswith(' '):
                        # New section - end of parameters
                        in_params_section = False
                        # If this is not part of parameters, it might be part of description
                        if not ("this function calls" in line.lower() or "this function is called by" in line.lower()):
                            description_section.append(line)
                    else:
                        # Content that's part of the parameter section but not a parameter itself
                        parameters_section.append(line)
                elif not in_params_section and not ("this function calls" in line.lower() or "this function is called by" in line.lower()):
                    # This is part of the description
                    description_section.append(line)
        
        # Now reconstruct the docstring in M2HTML style
        new_lines = []
        
        # PURPOSE section - ensure underline matches length of the title
        purpose_title = "PURPOSE"
        new_lines.append(purpose_title)
        new_lines.append("^" * len(purpose_title))  # Underline matches title length
        new_lines.append(first_desc_line)
        new_lines.append("")
        
        # SYNOPSIS section - ensure underline matches length of the title
        synopsis_title = "SYNOPSIS"
        new_lines.append(synopsis_title)
        new_lines.append("^" * len(synopsis_title))  # Underline matches title length
        new_lines.append(".. code-block:: matlab")
        new_lines.append("")
        new_lines.append(f"    {signature}")
        new_lines.append("")
        
        # DESCRIPTION section - ensure underline matches length of the title
        description_title = "DESCRIPTION"
        new_lines.append(description_title)
        new_lines.append("^" * len(description_title))  # Underline matches title length
        
        if description_section:
            new_lines.append("")
            new_lines.append(".. code-block:: text")
            new_lines.append("")
            for d_line in description_section:
                if d_line.strip():
                    new_lines.append(f"    {d_line.strip()}")
                else:
                    new_lines.append(f"    ")
            new_lines.append("")
        
        # Add parameters section as a code block if it exists
        if parameters_section:
            new_lines.append("")
            new_lines.append(".. code-block:: text")
            new_lines.append("")
            for p_line in parameters_section:
                new_lines.append(f"    {p_line}")
            new_lines.append("")
        
        # CROSS-REFERENCE INFORMATION section - ensure underline matches length of the title
        cross_ref_title = "CROSS-REFERENCE INFORMATION"
        new_lines.append("")
        new_lines.append(cross_ref_title)
        new_lines.append("^" * len(cross_ref_title))  # Underline matches title length
        
        if calls_functions or called_by:
            if calls_functions:
                new_lines.append("This function calls:")
                for func in calls_functions:
                    new_lines.append(f"* {func}")
                new_lines.append("")
            
            if called_by:
                new_lines.append("This function is called by:")
                for func in called_by:
                    new_lines.append(f"* {func}")
        else:
            new_lines.append("This information requires code analysis which is not available at documentation time.")
        
        # Replace the original lines with the new M2HTML-style formatted lines
        lines[:] = new_lines

def setup(app):
    """
    Set up the extension.
    """
    # Add default configuration
    app.add_config_value('matlab_filter_options', {
        'remove_license': True,
        'm2html_style': True,
    }, 'env')
    
    # Connect to the autodoc-process-docstring event
    app.connect('autodoc-process-docstring', m2html_style_formatter)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 