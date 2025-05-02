"""
Custom Sphinx extension to fix MATLAB function argument warnings.
"""

import sys
import os
import logging
import warnings
from functools import wraps

def setup(app):
    """
    Setup function for Sphinx extension.
    
    This extension modifies how MATLAB functions with missing args are handled.
    """
    try:
        # Now try to import
        from sphinxcontrib.matlab import domain
        
        # Monkey patch the format_args method
        old_format_args = domain.MatlabObject.format_args
        
        def new_format_args(self):
            try:
                return old_format_args(self)
            except AttributeError:
                return '(...)'
            except Exception:
                return '(...)'
        
        domain.MatlabObject.format_args = new_format_args
        
        app.info("MATLAB argument formatting patched successfully")
    except ImportError as e:
        warnings.warn(f"Could not patch MATLAB domain: {e}")
    except Exception as e:
        warnings.warn(f"Failed to patch MATLAB domain: {e}")
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True
    }
