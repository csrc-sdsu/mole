#!/usr/bin/env python3

from pathlib import Path
import re
import sys


SUPPORTED_EXTENSIONS = {".m", ".cpp", ".hpp", ".h"}


def get_comment_prefix(file_path: Path) -> str:
    ext = file_path.suffix.lower()
    if ext == ".m":
        return "%"
    if ext in {".cpp", ".hpp", ".h"}:
        return "//"
    raise ValueError(f"Unsupported file type: {file_path}")


def normalize_line(line: str, comment_prefix: str) -> str:
    """
    Normalize a line for comparison:
    - strip newline
    - remove leading comment marker
    - trim whitespace
    """
    line = line.rstrip("\n").strip()
    if line.startswith(comment_prefix):
        line = line[len(comment_prefix):].strip()
    return line


def read_license_lines(input_file: Path):
    with input_file.open("r", encoding="utf-8") as f:
        raw_lines = f.readlines()
    return [line.rstrip("\n") for line in raw_lines]


def make_license_block(license_lines, comment_prefix: str, add_trailing_blank_line: bool = True):
    """
    Build the LICENSE section.

    add_trailing_blank_line=True  -> use when inserting at top
    add_trailing_blank_line=False -> use when replacing existing block
    """
    block = [f"{comment_prefix} LICENSE:"]
    for line in license_lines:
        if line.strip() == "":
            block.append(comment_prefix)
        else:
            block.append(f"{comment_prefix} {line}")

    text = "\n".join(block) + "\n"
    if add_trailing_blank_line:
        text += "\n"
    return text


def find_top_license_block(lines, comment_prefix: str):
    """
    Find a LICENSE block only at the top of the file.

    Allowed before LICENSE:
    - blank lines

    The LICENSE block starts at:
        <comment_prefix> LICENSE:

    and continues through consecutive comment lines / blank lines until:
    - a non-comment, non-blank line is reached.

    Returns:
        (start_idx, end_idx, normalized_lines)
    where end_idx is exclusive.
    """
    license_tag_pattern = re.compile(
        rf'^\s*{re.escape(comment_prefix)}\s*LICENSE\s*:\s*$',
        re.IGNORECASE
    )

    i = 0

    # Skip leading blank lines only
    while i < len(lines) and lines[i].strip() == "":
        i += 1

    # If first meaningful line is not LICENSE, treat as no top license block
    if i >= len(lines) or not license_tag_pattern.match(lines[i]):
        return None, None, None

    start = i
    end = i + 1

    while end < len(lines):
        stripped = lines[end].strip()
        if stripped == "" or stripped.startswith(comment_prefix):
            end += 1
        else:
            break

    existing_lines = lines[start:end]

    # Remove trailing blank spacer lines from comparison
    while existing_lines and normalize_line(existing_lines[-1], comment_prefix) == "":
        existing_lines.pop()
        end -= 1

    normalized = [normalize_line(x, comment_prefix) for x in existing_lines]
    return start, end, normalized


def process_file(file_path: Path, desired_license_lines):
    comment_prefix = get_comment_prefix(file_path)

    with file_path.open("r", encoding="utf-8") as f:
        original_lines = f.readlines()

    desired_normalized = ["LICENSE:"] + [line.strip() for line in desired_license_lines]

    desired_block_for_insert = make_license_block(
        desired_license_lines, comment_prefix, add_trailing_blank_line=True
    )
    desired_block_for_update = make_license_block(
        desired_license_lines, comment_prefix, add_trailing_blank_line=False
    )

    start, end, existing_normalized = find_top_license_block(original_lines, comment_prefix)

    # Same LICENSE block already present at top
    if existing_normalized is not None and existing_normalized == desired_normalized:
        print(f"Skipped (same LICENSE header): {file_path}")
        return "skipped_same"

    # Different LICENSE block exists at top -> replace it
    if existing_normalized is not None:
        new_lines = original_lines[:start] + [desired_block_for_update] + original_lines[end:]
        with file_path.open("w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print(f"Updated LICENSE header: {file_path}")
        return "updated"

# No top LICENSE block found -> insert at top
    new_lines = [desired_block_for_insert] + original_lines
    with file_path.open("w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"Inserted LICENSE header: {file_path}")
    return "inserted"


def update_license_headers(license_header_file, target_folder):
    license_header_path = Path(license_header_file)
    folder_path = Path(target_folder)

    if not license_header_path.is_file():
        raise FileNotFoundError(f"License header file not found: {license_header_path}")

    if not folder_path.is_dir():
        raise NotADirectoryError(f"Target folder not found: {folder_path}")

    desired_license_lines = read_license_lines(license_header_path)

    files_to_process = []
    for ext in SUPPORTED_EXTENSIONS:
        files_to_process.extend(folder_path.rglob(f"*{ext}"))

    files_to_process = sorted(files_to_process)

    if not files_to_process:
        print("No supported source files found.")
        return

    summary = {
        "inserted": 0,
        "updated": 0,
        "skipped_same": 0,
    }

    for file_path in files_to_process:
        result = process_file(file_path, desired_license_lines)
        summary[result] += 1

    print("\nDone.")
    print(f"Inserted: {summary['inserted']}")
    print(f"Updated : {summary['updated']}")
    print(f"Skipped (same header): {summary['skipped_same']}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_license.py <license_header_file> <target_folder>")
        sys.exit(1)

    license_header_file = sys.argv[1]
    target_folder = sys.argv[2]

    update_license_headers(license_header_file, target_folder)