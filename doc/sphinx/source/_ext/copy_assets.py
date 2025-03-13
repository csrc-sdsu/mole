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
    
    # Add CSS to fix image paths in the README
    app.add_css_file('css/custom.css')
    
    # Create the CSS directory and file if they don't exist
    css_dir = Path(app.srcdir) / '_static' / 'css'
    css_dir.mkdir(parents=True, exist_ok=True)
    
    css_file = css_dir / 'custom.css'
    with open(css_file, 'w') as f:
        f.write("""
/* Fix image paths in the included README.md */
img[src^="doc/assets/img/"] {
    display: none;
}
img[src="doc/assets/img/4thOrder.png"] {
    content: url("/_static/img/4thOrder.png");
    display: inline;
}
img[src="doc/assets/img/4thOrder2.png"] {
    content: url("/_static/img/4thOrder2.png");
    display: inline;
}
img[src="doc/assets/img/4thOrder3.png"] {
    content: url("/_static/img/4thOrder3.png");
    display: inline;
}
img[src="doc/assets/img/grid2.png"] {
    content: url("/_static/img/grid2.png");
    display: inline;
}
img[src="doc/assets/img/grid.png"] {
    content: url("/_static/img/grid.png");
    display: inline;
}
img[src="doc/assets/img/WavyGrid.png"] {
    content: url("/_static/img/WavyGrid.png");
    display: inline;
}
img[src="doc/assets/img/wave2D.png"] {
    content: url("/_static/img/wave2D.png");
    display: inline;
}
img[src="doc/assets/img/burgers.png"] {
    content: url("/_static/img/burgers.png");
    display: inline;
}
""")
    logger.info(f'Created custom CSS file at {css_file}')
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
