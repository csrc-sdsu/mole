"""
Sphinx extension to generate a sitemap.xml for the HTML website.
"""

import os
from datetime import datetime
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def generate_sitemap(app, exception):
    """
    Generate sitemap.xml in the HTML build directory.
    """
    if exception is not None or app.builder.name != "html":
        return

    try:
        # Get configuration variables
        sitemap_url_base = app.config.html_baseurl or "https://mole-pdes.readthedocs.io"
        if not sitemap_url_base.endswith("/"):
            sitemap_url_base += "/"

        # Get template directory and set up jinja2 environment
        template_dir = os.path.join(app.srcdir, "_templates")
        env = Environment(loader=FileSystemLoader(template_dir))
        template = env.get_template("sitemap.xml")

        # Build a list of all HTML files in the build directory
        html_dir = app.outdir
        build_path = Path(html_dir)
        
        # Create a list of pages for the sitemap
        pages = []
        
        for path in build_path.rglob("*.html"):
            # Get the relative path from the build directory
            rel_path = path.relative_to(build_path)
            url = sitemap_url_base + str(rel_path).replace(os.sep, "/")
            
            # Get the last modification time of the file
            last_mod = datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d")
            
            # Skip some files that shouldn't be in the sitemap
            if any(part.startswith("_") for part in rel_path.parts):
                continue
                
            # Add the page to the list
            pages.append({
                "loc": url,
                "lastmod": last_mod
            })
            
        # Render the sitemap
        sitemap_content = template.render(pages=pages)
        
        # Write the sitemap to the build directory
        sitemap_path = os.path.join(html_dir, "sitemap.xml")
        with open(sitemap_path, "w") as f:
            f.write(sitemap_content)
            
        print(f"Generated sitemap.xml with {len(pages)} pages")
        
    except Exception as e:
        print(f"Error generating sitemap.xml: {e}")

def setup(app):
    """
    Set up the Sphinx extension.
    """
    # Run after the HTML build is finished
    app.connect("build-finished", generate_sitemap)
    
    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    } 