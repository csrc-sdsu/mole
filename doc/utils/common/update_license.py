#!/usr/bin/env python3

from pathlib import Path
import re
import sys


def normalize_line(line: str) -> str:
    """
    Normalize a line for comparison:
    - strip newline
    - remove leading MATLAB comment marker %
    - trim whitespace
    """
    line = line.rstrip("\n").strip()
    if line.startswith("%"):
        line = line[1:].strip()
    return line


def read_license_lines(input_file: Path):
    with input_file.open("r", encoding="utf-8") as f:
        raw_lines = f.readlines()
    return [line.rstrip("\n") for line in raw_lines]


def make_license_block(license_lines):
    """
    Build the LICENSE section to insert/update.
    Format:
    % LICENSE:
    % line 1
    % line 2
    """
    block = ["% LICENSE:"]
    for line in license_lines:
        if line.strip() == "":
            block.append("%")
        else:
            block.append(f"% {line}")
    return "\n".join(block) + "\n\n"


def find_purpose_or_description(lines):
    """
    Find first PURPOSE or DESCRIPTION tag line.
    Returns index or None.
    """
    pattern = re.compile(r'^\s*%\s*(PURPOSE|DESCRIPTION)\s*:', re.IGNORECASE)
    for i, line in enumerate(lines):
        if pattern.match(line):
            return i
    return None


def extract_existing_license_block(lines, stop_idx):
    """
    Extract LICENSE block if present before stop_idx.
    If PURPOSE/DESCRIPTION is not present, stop_idx should be len(lines),
    so the whole file is scanned and a top-of-file LICENSE block can still be found.

    Returns:
        (start_idx, end_idx, normalized_content_lines)
    where end_idx is exclusive.

    The LICENSE block starts at a line matching:
        % LICENSE:

    and continues through consecutive comment lines / blank lines until:
    - PURPOSE:/DESCRIPTION: is reached, or
    - a non-comment, non-blank line is reached.
    """
    license_tag_pattern = re.compile(r'^\s*%\s*LICENSE\s*:\s*$', re.IGNORECASE)
    purpose_desc_pattern = re.compile(r'^\s*%\s*(PURPOSE|DESCRIPTION)\s*:', re.IGNORECASE)

    for i in range(stop_idx):
        if license_tag_pattern.match(lines[i]):
            start = i
            end = i + 1

            while end < stop_idx:
                line = lines[end]
                stripped = line.strip()

                if purpose_desc_pattern.match(line):
                    break

                if stripped == "" or stripped.startswith("%"):
                    end += 1
                else:
                    break

            existing_lines = lines[start:end]

            # Remove trailing blank spacer lines from comparison
            while existing_lines and normalize_line(existing_lines[-1]) == "":
                existing_lines.pop()
                end -= 1

            normalized = [normalize_line(x) for x in existing_lines]
            return start, end, normalized

    return None, None, None


def process_file(m_file: Path, desired_license_lines):
    with m_file.open("r", encoding="utf-8") as f:
        original_lines = f.readlines()

    purpose_idx = find_purpose_or_description(original_lines)

    # If PURPOSE/DESCRIPTION is missing, scan whole file for an existing LICENSE block
    scan_limit = purpose_idx if purpose_idx is not None else len(original_lines)

    desired_normalized = ["LICENSE:"] + [line.strip() for line in desired_license_lines]
    desired_block = make_license_block(desired_license_lines)

    start, end, existing_normalized = extract_existing_license_block(original_lines, scan_limit)

    # Same LICENSE block already present
    if existing_normalized is not None and existing_normalized == desired_normalized:
        print(f"Skipped (same LICENSE header): {m_file}")
        return "skipped_same"

    # Different LICENSE block exists -> replace it
    if existing_normalized is not None:
        new_lines = original_lines[:start] + [desired_block] + original_lines[end:]
        with m_file.open("w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print(f"Updated LICENSE header: {m_file}")
        return "updated"

    # No LICENSE block found -> insert before PURPOSE/DESCRIPTION if present, else at top
    insert_idx = purpose_idx if purpose_idx is not None else 0
    new_lines = original_lines[:insert_idx] + [desired_block] + original_lines[insert_idx:]

    with m_file.open("w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"Inserted LICENSE header: {m_file}")
    return "inserted"


def update_matlab_license_headers(input_file, target_folder):
    input_path = Path(input_file)
    folder_path = Path(target_folder)

    if not input_path.is_file():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    if not folder_path.is_dir():
        raise NotADirectoryError(f"Target folder not found: {folder_path}")

    desired_license_lines = read_license_lines(input_path)
    m_files = list(folder_path.rglob("*.m"))

    if not m_files:
        print("No .m files found.")
        return

    summary = {
        "inserted": 0,
        "updated": 0,
        "skipped_same": 0,
    }

    for m_file in m_files:
        result = process_file(m_file, desired_license_lines)
        summary[result] += 1

    print("\nDone.")
    print(f"Inserted: {summary['inserted']}")
    print(f"Updated : {summary['updated']}")
    print(f"Skipped (same header): {summary['skipped_same']}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_matlab_license.py <input_file> <target_folder>")
        sys.exit(1)

    input_file = sys.argv[1]      # Input #1
    target_folder = sys.argv[2]   # Input #2

    update_matlab_license_headers(input_file, target_folder)