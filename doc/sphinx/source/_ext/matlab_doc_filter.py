"""
Sphinx extension to filter out license headers from MATLAB docstrings
and format them in an M2HTML-like style.
"""
import re
import os
import glob

# Cache for function descriptions
_function_descriptions = {}

# Graph of function calls (which functions call which)
_function_calls_graph = {}
# Graph of function dependencies (which functions are called by which)
_function_dependency_graph = {}
# Flag to track if we've analyzed the code
_analyzed_code = False

def analyze_matlab_code(matlab_src_dir):
    """
    Analyze MATLAB code to build a call graph.
    
    This function parses all MATLAB files in the source directory to identify
    function calls and builds call graphs for both directions (calls and called by).
    
    Args:
        matlab_src_dir: Directory containing MATLAB source files
    """
    global _function_calls_graph, _function_dependency_graph, _analyzed_code
    
    if _analyzed_code:
        return  # Only analyze once
    
    print(f"Analyzing MATLAB code in {matlab_src_dir}")
    
    # Reset graphs
    _function_calls_graph = {}
    _function_dependency_graph = {}
    
    # Get all MATLAB files
    matlab_files = glob.glob(os.path.join(matlab_src_dir, "*.m"))
    
    # Map of lowercase function names to their original case
    case_map = {}
    
    # First pass: get all function names (without extensions)
    function_names = []
    for filepath in matlab_files:
        function_name = os.path.splitext(os.path.basename(filepath))[0]
        # Store the mapping between lowercase and original case
        case_map[function_name.lower()] = function_name
        function_names.append(function_name.lower())  # Store lowercase for case-insensitive matching
        # Store keys in the graphs using original case
        _function_calls_graph[function_name] = set()
        _function_dependency_graph[function_name] = set()
    
    # Second pass: analyze function calls
    for filepath in matlab_files:
        function_name = os.path.splitext(os.path.basename(filepath))[0]
        
        try:
            with open(filepath, 'r') as f:
                content = f.read()
            
            # DEBUG: Print the file being analyzed
            print(f"Analyzing file: {os.path.basename(filepath)}")
            
            # Look for function calls
            for other_func_lower in function_names:
                # Only look for whole-word matches that are function calls
                # Using regex with word boundaries
                if other_func_lower != function_name.lower():  # Avoid self-references
                    pattern = r'\b' + re.escape(other_func_lower) + r'\s*\('
                    if re.search(pattern, content, re.IGNORECASE):
                        # Get the original case version
                        other_func = case_map[other_func_lower]
                        
                        # This function calls other_func
                        _function_calls_graph[function_name].add(other_func)
                        # Debug: Log the function call detection
                        print(f"  FOUND: {function_name} calls {other_func}")
                        
                        # other_func is called by this function
                        _function_dependency_graph[other_func].add(function_name)
                        
        except Exception as e:
            print(f"Error analyzing {filepath}: {e}")
    
    # Print some stats for debugging
    print(f"Analyzed {len(matlab_files)} MATLAB files")
    total_calls = sum(len(calls) for calls in _function_calls_graph.values())
    print(f"Found {total_calls} function calls")
    
    # DEBUG: Print both graphs for comparison
    print("\nFUNCTION CALLS GRAPH (functions that call others):")
    for func, calls in _function_calls_graph.items():
        if calls:  # Only print non-empty entries
            print(f"{func} calls: {', '.join(calls)}")
    
    print("\nFUNCTION DEPENDENCY GRAPH (functions called by others):")
    for func, called_by in _function_dependency_graph.items():
        if called_by:  # Only print non-empty entries
            print(f"{func} is called by: {', '.join(called_by)}")
    
    _analyzed_code = True

def get_function_description(func_name, matlab_src_dir):
    """
    Get the first line description of a MATLAB function.
    
    Args:
        func_name: The name of the function
        matlab_src_dir: The directory containing MATLAB source files
        
    Returns:
        The first line description if found, empty string otherwise
    """
    if func_name in _function_descriptions:
        return _function_descriptions[func_name]
    
    # Add .m extension if not present
    if not func_name.endswith('.m'):
        func_file = f"{func_name}.m"
    else:
        func_file = func_name
        func_name = func_name[:-2]  # Remove .m

    # Look for the file in the MATLAB source directory
    filepath = os.path.join(matlab_src_dir, func_file)
    if not os.path.exists(filepath):
        # Try finding it with case-insensitive search
        all_files = glob.glob(os.path.join(matlab_src_dir, "*.m"))
        for file in all_files:
            if os.path.basename(file).lower() == func_file.lower():
                filepath = file
                break
        else:
            _function_descriptions[func_name] = ""
            return ""

    # Read the file and extract the first comment line as the description
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            
        # Skip the function declaration line
        for i, line in enumerate(lines):
            if line.strip().startswith('%'):
                # Found the first comment line
                description = line.strip()[1:].strip()
                # Clean up the description by removing dash sequences
                description = re.sub(r'-{5,}', '', description).strip()
                _function_descriptions[func_name] = description
                return description
    except Exception as e:
        print(f"Error reading function description for {func_name}: {e}")
    
    _function_descriptions[func_name] = ""
    return ""

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
    
    # Get MATLAB source directory from configuration
    matlab_src_dir = getattr(app.config, 'matlab_src_dir', '')
    
    # Analyze the MATLAB code to build call graphs
    if matlab_src_dir and not _analyzed_code:
        analyze_matlab_code(matlab_src_dir)
    
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
        # Process parameter descriptions - convert :param k: to k:
        for i, line in enumerate(lines):
            # Match :param name: description pattern
            param_match = re.match(r'\s*:param\s+(\w+):\s*(.*)', line)
            if param_match:
                param_name = param_match.group(1)
                param_desc = param_match.group(2)
                lines[i] = f"{param_name} : {param_desc}"
        
        # Extract function signature if available
        signature = ""
        if what == 'function' and name:
            # Try to extract signature from the first line if it contains function definition
            if lines and re.match(r'^\s*function\s+', lines[0]):
                signature = lines[0].strip()
            else:
                # Construct a basic signature from the function name
                signature = f"function {name}"
        
        # Get cross-reference information from our code analysis
        # Get the call information for this function
        function_base_name = name.split('.')[-1] if '.' in name else name
        
        # For case-insensitivity, try to find a matching function name irrespective of case
        calls_functions = []
        found_in_calls_graph = False
        for func_name in _function_calls_graph:
            if func_name.lower() == function_base_name.lower():
                calls_functions = list(_function_calls_graph[func_name])
                found_in_calls_graph = True
                break
        
        called_by = []
        found_in_dependency_graph = False
        for func_name in _function_dependency_graph:
            if func_name.lower() == function_base_name.lower():
                called_by = list(_function_dependency_graph[func_name])
                found_in_dependency_graph = True
                break
        
        # Extract all content from lines (excluding purpose line, cross-reference info)
        description_content = []
        parameters = []
        in_params_section = False
        
        # First pass: collect all lines that are not part of the cross-reference section
        cross_ref_keywords = ['this function calls', 'this function is called by']
        
        for i, line in enumerate(lines):
            # Skip first line (used as PURPOSE) and cross-reference info
            if i > 0 and not any(keyword in line.lower() for keyword in cross_ref_keywords):
                if line.strip().startswith('Parameters:'):
                    in_params_section = True
                    continue
                
                # Check if line looks like a parameter
                param_match = re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line) or re.match(r'^\s*:param\s+([^:]+):', line)
                
                if param_match:
                    param_name = param_match.group(1).strip()
                    if ':' in line:
                        parts = line.split(':', 1)
                        desc = parts[1].strip() if len(parts) > 1 and parts[1].strip() else "Parameter description not provided"
                    else:
                        desc = "Parameter description not provided"
                    parameters.append((param_name, desc))
                    in_params_section = True
                elif not in_params_section:
                    # If not in parameters section, treat as description
                    if line.strip() and not line.strip().startswith(':'):
                        description_content.append(line.strip())
                elif in_params_section and line.strip() and not re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line) and not line.strip().startswith(':param'):
                    # End of parameters section
                    if not any(keyword in line.lower() for keyword in cross_ref_keywords):
                        description_content.append(line.strip())
                    in_params_section = False
        
        # Now reconstruct the docstring in M2HTML style
        new_lines = []
        
        # PURPOSE section
        purpose_title = "PURPOSE"
        new_lines.append(purpose_title)
        new_lines.append("^" * len(purpose_title))
        new_lines.append(first_desc_line)
        new_lines.append("")
        
        # SYNOPSIS section
        synopsis_title = "SYNOPSIS"
        new_lines.append(synopsis_title)
        new_lines.append("^" * len(synopsis_title))
        new_lines.append(".. code-block:: matlab")
        new_lines.append("")
        new_lines.append(f"    {signature}")
        new_lines.append("")
        
        # DESCRIPTION section
        description_title = "DESCRIPTION"
        new_lines.append(description_title)
        new_lines.append("^" * len(description_title))
        
        # Only add a code block if we have content to show
        if description_content or parameters:
            new_lines.append("")
            new_lines.append(".. code-block:: text")
            new_lines.append("")
            
            # Add description content
            if description_content:
                for line in description_content:
                    new_lines.append(f"    {line}")
                
                # Add a blank line between description and parameters if both exist
                if parameters:
                    new_lines.append(f"    ")
            
            # Add parameters with proper formatting
            for param_name, param_desc in parameters:
                new_lines.append(f"    {param_name:>16} : {param_desc}")
        
        # CROSS-REFERENCE INFORMATION section
        cross_ref_title = "CROSS-REFERENCE INFORMATION"
        new_lines.append("")
        new_lines.append(cross_ref_title)
        new_lines.append("^" * len(cross_ref_title))
        
        if calls_functions or called_by:
            if calls_functions:
                new_lines.append("This function calls:")
                new_lines.append("")  # Add empty line after section title
                for i, func in enumerate(calls_functions):
                    # Get description for the function
                    func_name = func.strip().split()[0] if func.strip() else func
                    desc = get_function_description(func_name, matlab_src_dir)
                    
                    # Clean up the description to remove dash sequences
                    if desc:
                        desc = re.sub(r'-{5,}', '', desc).strip()
                    
                    # Create a link using Sphinx cross-reference
                    link = f":mat:func:`{func_name}`"
                    if desc:
                        new_line = f"{link} {desc}"
                    else:
                        new_line = f"{link}"
                    # Add each function with explicit paragraph marking
                    new_lines.append(new_line)
                    # Add a paragraph break between entries
                    if i < len(calls_functions) - 1:
                        new_lines.append("")
                new_lines.append("")
            
            if called_by:
                new_lines.append("This function is called by:")
                new_lines.append("")  # Add empty line after section title
                for i, func in enumerate(called_by):
                    # Get description for the function
                    func_name = func.strip().split()[0] if func.strip() else func
                    desc = get_function_description(func_name, matlab_src_dir)
                    
                    # Clean up the description to remove dash sequences
                    if desc:
                        desc = re.sub(r'-{5,}', '', desc).strip()
                    
                    # Create a link using Sphinx cross-reference
                    link = f":mat:func:`{func_name}`"
                    if desc:
                        new_line = f"{link} {desc}"
                    else:
                        new_line = f"{link}"
                    # Add each function with explicit paragraph marking
                    new_lines.append(new_line)
                    # Add a paragraph break between entries
                    if i < len(called_by) - 1:
                        new_lines.append("")
        else:
            new_lines.append("No cross-reference information found. This typically means this function neither calls nor is called by other functions in the codebase.")
        
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
    
    # Note: matlab_src_dir is already defined in conf.py
    # Do not add it again to avoid the "Config value already present" error
    
    # Connect to the autodoc-process-docstring event
    app.connect('autodoc-process-docstring', m2html_style_formatter)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    } 