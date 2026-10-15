#!/usr/bin/env python3
"""
Filter a list of candidate C/C++ source files down to only those that
actually appear in compile_commands.json (i.e. files CMake really
compiles). This automatically excludes old_version/ and any other
directory not wired into the CMake build, with no hardcoded paths.

Usage:
    python3 filter_compiled_sources.py <compile_commands.json> <raw_files.txt> <filtered_files.txt>
"""
import json
import os
import sys


def main():
    if len(sys.argv) != 4:
        print("Usage: filter_compiled_sources.py <compile_commands.json> <raw_files.txt> <filtered_files.txt>")
        sys.exit(2)

    compile_commands_path, raw_files_path, filtered_files_path = sys.argv[1:4]

    with open(compile_commands_path) as f:
        compiled = {os.path.realpath(entry["file"]) for entry in json.load(f)}

    with open(raw_files_path) as f:
        candidates = [line.strip() for line in f if line.strip()]

    kept = [c for c in candidates if os.path.realpath(c) in compiled]
    skipped = [c for c in candidates if os.path.realpath(c) not in compiled]

    if skipped:
        print(f"Skipping {len(skipped)} file(s) not in compile_commands.json:")
        for s in skipped:
            print(f"  - {s}")

    with open(filtered_files_path, "w") as f:
        f.write("\n".join(kept))


if __name__ == "__main__":
    main()
