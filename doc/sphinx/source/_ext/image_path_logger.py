"""
Sphinx extension to log image path resolution for debugging image inclusion issues.

This extension hooks into Sphinx's document reading and image processing to log:
1. When documents with includes are processed
2. Image references found in markdown files
3. Path resolution attempts
4. Final image paths used by Sphinx
"""
import os
import logging
from pathlib import Path
from docutils import nodes
from sphinx.util import logging as sphinx_logging

logger = sphinx_logging.getLogger(__name__)

def log_document_read(app, doctree):
    """Log when a document is read and what images it contains."""
    docname = app.env.docname
    
    # Get the source file path
    source_file = app.env.doc2path(docname, base=None)
    
    # Check if this is an OSE organization wrapper document
    if 'ose_organization' in docname:
        logger.info("=" * 80)
        logger.info(f"[IMAGE_DEBUG] Processing document: {docname}")
        logger.info(f"[IMAGE_DEBUG] Source file: {source_file}")
        logger.info(f"[IMAGE_DEBUG] Source directory: {os.path.dirname(source_file)}")
        
        # Check for image nodes
        for node in doctree.traverse(nodes.image):
            uri = node.get('uri', 'NO_URI')
            logger.info(f"[IMAGE_DEBUG] Found image node with URI: {uri}")
            
            # Try to resolve the full path
            if hasattr(app.env, 'relfn2path'):
                try:
                    rel_fn, abs_fn = app.env.relfn2path(uri, docname)
                    logger.info(f"[IMAGE_DEBUG]   Resolved relative path: {rel_fn}")
                    logger.info(f"[IMAGE_DEBUG]   Resolved absolute path: {abs_fn}")
                    logger.info(f"[IMAGE_DEBUG]   File exists: {os.path.exists(abs_fn)}")
                except Exception as e:
                    logger.warning(f"[IMAGE_DEBUG]   Failed to resolve path: {e}")
        
        logger.info("=" * 80)


def log_missing_reference(app, env, node, contnode):
    """Log missing reference attempts (including images)."""
    if isinstance(node, nodes.image):
        uri = node.get('uri', 'UNKNOWN')
        logger.warning(f"[IMAGE_DEBUG] Missing image reference: {uri}")
        logger.warning(f"[IMAGE_DEBUG] Current docname: {env.docname}")
        logger.warning(f"[IMAGE_DEBUG] Current doc path: {env.doc2path(env.docname)}")
    return None


def log_image_copying(app, exception):
    """Log image copying at the end of the build."""
    if exception is not None:
        return
    
    logger.info("=" * 80)
    logger.info("[IMAGE_DEBUG] Build finished - checking copied images")
    
    # Check what images ended up in _images
    build_images_dir = Path(app.outdir) / "_images"
    if build_images_dir.exists():
        logger.info(f"[IMAGE_DEBUG] Images directory: {build_images_dir}")
        logger.info(f"[IMAGE_DEBUG] Images in _images directory:")
        for img in sorted(build_images_dir.glob("*.png")):
            logger.info(f"[IMAGE_DEBUG]   - {img.name} ({img.stat().st_size} bytes)")
    else:
        logger.warning(f"[IMAGE_DEBUG] Images directory does not exist: {build_images_dir}")
    
    logger.info("=" * 80)


def trace_myst_include_processing(app, docname, source):
    """
    Hook into source-read event to log MyST include processing.
    This runs BEFORE MyST parses the document.
    """
    if 'ose_organization' in docname:
        logger.info("=" * 80)
        logger.info(f"[IMAGE_DEBUG] Source-read event for: {docname}")
        
        # Check if this file has an include directive
        if '{include}' in source[0]:
            logger.info(f"[IMAGE_DEBUG] Document contains include directive")
            
            # Extract the included file path
            import re
            include_match = re.search(r'\{include\}\s+([^\s\n]+)', source[0])
            if include_match:
                included_path = include_match.group(1)
                logger.info(f"[IMAGE_DEBUG] Including file: {included_path}")
                
                # Resolve the full path
                source_dir = Path(app.env.doc2path(docname, base=None)).parent
                full_included_path = (source_dir / included_path).resolve()
                logger.info(f"[IMAGE_DEBUG] Source document dir: {source_dir}")
                logger.info(f"[IMAGE_DEBUG] Resolved include path: {full_included_path}")
                logger.info(f"[IMAGE_DEBUG] Include file exists: {full_included_path.exists()}")
                
                if full_included_path.exists():
                    # Read the included file and look for image references
                    with open(full_included_path, 'r') as f:
                        included_content = f.read()
                    
                    # Find markdown image references
                    image_matches = re.findall(r'!\[([^\]]*)\]\(([^)]+)\)', included_content)
                    if image_matches:
                        logger.info(f"[IMAGE_DEBUG] Found {len(image_matches)} image(s) in included file:")
                        for alt_text, img_path in image_matches:
                            logger.info(f"[IMAGE_DEBUG]   - Alt: '{alt_text}', Path: '{img_path}'")
                            
                            # Check if image path is relative to included file or source file
                            # Path relative to included file's location
                            rel_to_included = (full_included_path.parent / img_path).resolve()
                            logger.info(f"[IMAGE_DEBUG]     Relative to included file: {rel_to_included}")
                            logger.info(f"[IMAGE_DEBUG]     Exists (rel to included): {rel_to_included.exists()}")
                            
                            # Path relative to source document
                            rel_to_source = (source_dir / img_path).resolve()
                            logger.info(f"[IMAGE_DEBUG]     Relative to source doc: {rel_to_source}")
                            logger.info(f"[IMAGE_DEBUG]     Exists (rel to source): {rel_to_source.exists()}")
        
        logger.info("=" * 80)


def setup(app):
    """Register the extension."""
    # Connect to various events
    app.connect('doctree-read', log_document_read)
    app.connect('missing-reference', log_missing_reference)
    app.connect('build-finished', log_image_copying)
    app.connect('source-read', trace_myst_include_processing)
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }

