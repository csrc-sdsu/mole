import os
import shutil
from pathlib import Path
from sphinx.util import logging

logger = logging.getLogger(__name__)

def copy_assets(app, exception):
    """Copy assets directory to the build directory after the build is complete."""
    if exception is None:  # Only execute if the build succeeded
        # Get the root directory
        root_dir = Path(app.srcdir).resolve().parents[3]
        
        # Copy assets directory
        src_dir = root_dir / 'doc' / 'assets'
        dst_dir = Path(app.outdir) / '_static' / 'img'
        
        if src_dir.exists():
            # Create destination directory if it doesn't exist
            dst_dir.mkdir(parents=True, exist_ok=True)
            
            # Copy image files
            img_src_dir = src_dir / 'img'
            if img_src_dir.exists():
                for img_file in img_src_dir.glob('*.png'):
                    shutil.copy2(img_file, dst_dir)
                logger.info(f'Copied images from {img_src_dir} to {dst_dir}')
            else:
                logger.warning(f'Images directory not found at {img_src_dir}')
        else:
            logger.warning(f'Assets directory not found at {src_dir}')

def setup(app):
    """Set up the extension."""
    # Connect to the build-finished event
    app.connect('build-finished', copy_assets)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
