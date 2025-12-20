#!/usr/bin/env python3
"""
================================================================================
  NEOVIM CONFIG UNFLATTENER
================================================================================

  This script reconstructs a modular Neovim configuration from a flattened file.
  It's the companion to flatten.py.

  USAGE:
    python unflatten.py <flattened_file> [output_dir]

  EXAMPLES:
    python unflatten.py init-flat.lua              # Recreates in ./nvim-config/
    python unflatten.py init-flat.lua ~/.config/nvim-new/  # Specific output dir

  WHAT IT DOES:
  1. Reads the flattened file
  2. Parses @FILE_START and @FILE_END markers
  3. Extracts each file's content
  4. Creates the directory structure
  5. Writes each file to its original location

  MARKER FORMAT (from flatten.py):
    -- @FILE_START: lua/config/options.lua
    ... file contents ...
    -- @FILE_END: lua/config/options.lua

"""

import os
import sys
import re
from pathlib import Path
from datetime import datetime

# ============================================================================
# PARSER
# ============================================================================

def parse_flattened_file(content):
    """Parse a flattened config file and extract all embedded files.
    
    Returns a dict: { 'path/to/file.lua': 'file contents...' }
    """
    files = {}
    
    # Pattern to match file blocks
    # -- @FILE_START: path/to/file.lua
    # ... content ...
    # -- @FILE_END: path/to/file.lua
    pattern = r'-- @FILE_START: (.+?)\n(.*?)-- @FILE_END: \1'
    
    matches = re.findall(pattern, content, re.DOTALL)
    
    for filepath, file_content in matches:
        # Strip trailing newline that we added during flattening
        file_content = file_content.rstrip('\n')
        files[filepath] = file_content
    
    return files


def parse_metadata(content):
    """Extract metadata from the flattened file."""
    metadata = {}
    
    # Pattern for metadata block
    meta_pattern = r'-- @FLATTEN_METADATA_START\n(.*?)-- @FLATTEN_METADATA_END'
    match = re.search(meta_pattern, content, re.DOTALL)
    
    if match:
        meta_content = match.group(1)
        for line in meta_content.split('\n'):
            line = line.strip()
            if line.startswith('-- ') and ': ' in line:
                key, value = line[3:].split(': ', 1)
                metadata[key] = value
    
    return metadata


# ============================================================================
# MAIN RECONSTRUCTOR
# ============================================================================

def unflatten(input_file, output_dir):
    """Reconstruct the modular config from a flattened file."""
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                   NEOVIM CONFIG UNFLATTENER                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    # Read input file
    input_path = Path(input_file)
    if not input_path.exists():
        print(f"ERROR: Input file not found: {input_file}")
        sys.exit(1)
    
    print(f"Input file:  {input_path}")
    print(f"Output dir:  {output_dir}")
    print()
    
    with open(input_path, 'r') as f:
        content = f.read()
    
    # Parse metadata
    metadata = parse_metadata(content)
    if metadata:
        print("Metadata from flattened file:")
        print("-" * 50)
        for key, value in metadata.items():
            if key != 'files':  # Skip long file list
                print(f"  {key}: {value}")
        print("-" * 50)
        print()
    
    # Parse files
    print("Extracting files:")
    print("-" * 50)
    files = parse_flattened_file(content)
    
    if not files:
        print("ERROR: No files found in flattened config!")
        print("Make sure the file was created by flatten.py")
        sys.exit(1)
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Write each file
    created_files = []
    created_dirs = set()
    
    for filepath, file_content in files.items():
        full_path = output_path / filepath
        
        # Create parent directories
        parent_dir = full_path.parent
        if parent_dir not in created_dirs:
            parent_dir.mkdir(parents=True, exist_ok=True)
            created_dirs.add(parent_dir)
        
        # Write file
        with open(full_path, 'w') as f:
            f.write(file_content)
            # Ensure file ends with newline
            if not file_content.endswith('\n'):
                f.write('\n')
        
        line_count = len(file_content.splitlines())
        print(f"  [OK] {filepath} ({line_count} lines)")
        created_files.append(filepath)
    
    print("-" * 50)
    print()
    
    # Summary
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                           COMPLETE                                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    print(f"  Files created:       {len(created_files)}")
    print(f"  Directories created: {len(created_dirs)}")
    print(f"  Output location:     {output_path.resolve()}")
    print()
    
    # Show directory tree
    print("Created structure:")
    print_tree(output_path)
    print()
    
    print("To use this config:")
    print(f"  1. Backup your existing ~/.config/nvim/")
    print(f"  2. Copy contents: cp -r {output_path}/* ~/.config/nvim/")
    print(f"  3. Or symlink: ln -s {output_path.resolve()} ~/.config/nvim")
    print()
    
    return created_files


def print_tree(directory, prefix=""):
    """Print a directory tree."""
    path = Path(directory)
    entries = sorted(path.iterdir(), key=lambda x: (x.is_file(), x.name))
    
    for i, entry in enumerate(entries):
        is_last = i == len(entries) - 1
        connector = "└── " if is_last else "├── "
        
        if entry.is_dir():
            print(f"{prefix}{connector}{entry.name}/")
            extension = "    " if is_last else "│   "
            print_tree(entry, prefix + extension)
        else:
            print(f"{prefix}{connector}{entry.name}")


# ============================================================================
# CLI
# ============================================================================

def print_usage():
    """Print usage information."""
    print("Usage: python unflatten.py <flattened_file> <output_directory>")
    print()
    print("Arguments:")
    print("  flattened_file    Path to the flattened config file (from flatten.py)")
    print("  output_directory  Directory where the modular config will be created")
    print()
    print("Examples:")
    print("  python unflatten.py init-flat.lua ./nvim-config/")
    print("  python unflatten.py ~/backups/nvim-config.lua ~/.config/nvim/")
    print("  python unflatten.py /tmp/config.lua ~/my-nvim-setup/")


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print_usage()
        sys.exit(1)
    
    if sys.argv[1] in ['-h', '--help']:
        print_usage()
        sys.exit(0)
    
    input_file = Path(sys.argv[1]).expanduser().resolve()
    output_dir = Path(sys.argv[2]).expanduser().resolve()
    
    unflatten(input_file, output_dir)


if __name__ == '__main__':
    main()
