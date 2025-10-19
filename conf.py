# ReadTheDocs configuration wrapper
# This file imports the actual configuration from doc/sphinx/source/conf.py

import sys
import os
from pathlib import Path

# Change to the correct directory for relative paths
original_cwd = os.getcwd()
conf_dir = Path(__file__).parent / 'doc' / 'sphinx' / 'source'
os.chdir(conf_dir)

# Add the actual conf.py directory to the path
sys.path.insert(0, str(conf_dir))

# Import all configurations from the actual conf.py
from conf import *

# Restore original working directory
os.chdir(original_cwd)
