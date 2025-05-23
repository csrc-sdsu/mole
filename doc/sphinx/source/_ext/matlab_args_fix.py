"""
Custom Sphinx extension to fix MATLAB function argument warnings.
"""

import warnings
import logging
from sphinx.util.logging import getLogger

logger = getLogger(__name__)

# Create a filter for MATLAB domain warnings
class MATLABWarningsFilter(logging.Filter):
    """Filter to suppress specific MATLAB domain warnings."""
    
    def filter(self, record):
        # Suppress warnings about formatting arguments
        if record.levelname == 'WARNING':
            if "error while formatting arguments for" in record.getMessage():
                if "'NoneType' object has no attribute 'args'" in record.getMessage():
                    return False  # Don't log this warning
        return True  # Log all other warnings

def setup(app):
    """
    Setup function for Sphinx extension.
    
    This extension adds a filter to suppress MATLAB domain warnings.
    """
    # Add the filter to the Sphinx warning logger
    warning_logger = logging.getLogger('sphinx.domains.mat')
    warning_logger.addFilter(MATLABWarningsFilter())
    
    # Also add the filter to the root logger as fallback
    root_logger = logging.getLogger('sphinx')
    root_logger.addFilter(MATLABWarningsFilter())
    
    logger.info("MATLAB argument warnings filter added")
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True
    }
