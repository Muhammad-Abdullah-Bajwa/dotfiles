#!/usr/bin/env python3
"""
================================================================================
  NEOVIM CONFIG FLATTENER
================================================================================

  This script converts a modular Neovim configuration into a single init.lua file.

  USAGE:
    python flatten.py [output_file]

  EXAMPLES:
    python flatten.py                    # Creates init-flat.lua in current directory
    python flatten.py ~/init-single.lua  # Creates file at specified path

  WHAT IT DOES:
  1. Reads the modular config files from lua/config/ and lua/plugins/
  2. Adds markers for each file's start/end with full paths
  3. Outputs a single, standalone init.lua

  MARKERS FORMAT:
    -- @FILE_START: lua/config/options.lua
    ... file contents ...
    -- @FILE_END: lua/config/options.lua

  These markers allow the unflatten.py script to recreate the modular structure.

  NOTE: The flattened config is for portability/sharing.
  For daily use, keep the modular structure - it's easier to maintain!

"""

import os
import sys
from pathlib import Path
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================

# Base directory of the nvim config (where this script lives)
NVIM_CONFIG_DIR = Path(__file__).parent.resolve()

# Order matters! Files are processed in this order.
# The structure preserves the original modular organization.

# Special files (not in lua/)
SPECIAL_FILES = [
    'init.lua',
]

# Config files (core settings, no plugins)
CONFIG_FILES = [
    'lua/config/options.lua',
    'lua/config/keymaps.lua',
    'lua/config/autocmds.lua',
    'lua/config/lazy.lua',
]

# Plugin loader
PLUGIN_LOADER = [
    'lua/plugins/init.lua',
]

# Individual plugin files
PLUGIN_FILES = [
    'lua/plugins/colorscheme.lua',
    'lua/plugins/ui.lua',
    'lua/plugins/editor.lua',
    'lua/plugins/telescope.lua',
    'lua/plugins/lsp.lua',
    'lua/plugins/completion.lua',
    'lua/plugins/flash.lua',
    'lua/plugins/git.lua',
    'lua/plugins/copilot.lua',
    'lua/plugins/aerial.lua',
    'lua/plugins/diffview.lua',
    'lua/plugins/oil.lua',
    'lua/plugins/treesitter-textobjects.lua',
]

# Combine all files in processing order
ALL_FILES = SPECIAL_FILES + CONFIG_FILES + PLUGIN_LOADER + PLUGIN_FILES

# ============================================================================
# HELPERS
# ============================================================================

def read_file(filepath):
    """Read a file and return its contents."""
    full_path = NVIM_CONFIG_DIR / filepath
    if not full_path.exists():
        print(f"  [SKIP] {filepath} (not found)")
        return None
    with open(full_path, 'r') as f:
        content = f.read()
    print(f"  [OK]   {filepath} ({len(content.splitlines())} lines)")
    return content


def wrap_file_content(filepath, content):
    """Wrap file content with start/end markers for reconstruction."""
    if content is None:
        return ""
    
    marker_start = f"-- @FILE_START: {filepath}"
    marker_end = f"-- @FILE_END: {filepath}"
    
    return f"""{marker_start}
{content}
{marker_end}

"""


# ============================================================================
# MAIN GENERATOR
# ============================================================================

def generate_flat_config():
    """Generate the complete flattened configuration with file markers."""
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Header with metadata
    output = f'''--[[
================================================================================
  FLATTENED NEOVIM CONFIGURATION
================================================================================

  This is an auto-generated single-file version of a modular Neovim config.
  
  Generated: {timestamp}
  Source:    {NVIM_CONFIG_DIR}

  FILE MARKERS:
    Each original file is wrapped with markers:
      -- @FILE_START: path/to/file.lua
      ... original file contents ...
      -- @FILE_END: path/to/file.lua

  TO RECONSTRUCT THE MODULAR CONFIG:
    Run: python unflatten.py init-flat.lua [output_dir]

  WARNING: 
    This flattened file will NOT work as a direct init.lua replacement!
    It's meant for sharing/backup. The file markers break the Lua syntax.
    Use unflatten.py to restore the modular structure before using.

  ORIGINAL DIRECTORY STRUCTURE:
    ~/.config/nvim/
    ├── init.lua                 # Entry point
    └── lua/
        ├── config/              # Core settings
        │   ├── options.lua      # Editor options
        │   ├── keymaps.lua      # Keyboard shortcuts
        │   ├── autocmds.lua     # Auto commands
        │   └── lazy.lua         # Plugin manager bootstrap
        └── plugins/             # Plugin configurations
            ├── init.lua         # Plugin loader
            ├── colorscheme.lua  # Theme
            ├── ui.lua           # UI enhancements
            ├── editor.lua       # Editor plugins
            ├── telescope.lua    # Fuzzy finder
            ├── lsp.lua          # Language servers
            ├── completion.lua   # Autocompletion
            ├── flash.lua        # Navigation
            ├── git.lua          # Git integration
            ├── copilot.lua      # AI assistant
            ├── aerial.lua       # Code outline
            ├── diffview.lua     # Diff viewer
            ├── oil.lua          # File explorer
            └── treesitter-textobjects.lua

================================================================================
--]]

-- @FLATTEN_METADATA_START
-- generator: flatten.py
-- timestamp: {timestamp}
-- source_dir: {NVIM_CONFIG_DIR}
-- file_count: {len(ALL_FILES)}
-- files: {', '.join(ALL_FILES)}
-- @FLATTEN_METADATA_END

'''
    
    # Process each file category
    categories = [
        ("ENTRY POINT", SPECIAL_FILES),
        ("CORE CONFIGURATION", CONFIG_FILES),
        ("PLUGIN LOADER", PLUGIN_LOADER),
        ("PLUGIN SPECIFICATIONS", PLUGIN_FILES),
    ]
    
    for category_name, files in categories:
        output += f'''
-- ############################################################################
-- #  {category_name:^72}  #
-- ############################################################################

'''
        for filepath in files:
            content = read_file(filepath)
            if content:
                output += wrap_file_content(filepath, content)
    
    # Footer
    output += '''
--[[
================================================================================
  END OF FLATTENED CONFIGURATION
  
  To reconstruct: python unflatten.py init-flat.lua [output_dir]
================================================================================
--]]
'''
    
    return output


def print_usage():
    """Print usage information."""
    print("Usage: python flatten.py <output_file>")
    print()
    print("Arguments:")
    print("  output_file    Path where the flattened config will be written")
    print()
    print("Examples:")
    print("  python flatten.py init-flat.lua")
    print("  python flatten.py ~/backups/nvim-config.lua")
    print("  python flatten.py /tmp/my-nvim-config.lua")


def main():
    """Main entry point."""
    # Require output file argument
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)
    
    if sys.argv[1] in ['-h', '--help']:
        print_usage()
        sys.exit(0)
    
    output_file = Path(sys.argv[1]).expanduser().resolve()
    
    # Create parent directory if needed
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                    NEOVIM CONFIG FLATTENER                           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    print(f"Source directory: {NVIM_CONFIG_DIR}")
    print(f"Output file:      {output_file}")
    print()
    
    # Check that we're in the right directory
    if not (NVIM_CONFIG_DIR / 'init.lua').exists():
        print("ERROR: init.lua not found in config directory!")
        print("Make sure this script is in your ~/.config/nvim/ directory.")
        sys.exit(1)
    
    # Generate the flat config
    print("Processing files:")
    print("-" * 50)
    flat_config = generate_flat_config()
    print("-" * 50)
    
    # Write output
    print()
    print(f"Writing to {output_file}...")
    with open(output_file, 'w') as f:
        f.write(flat_config)
    
    # Stats
    line_count = flat_config.count('\n')
    file_size = len(flat_config.encode('utf-8'))
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                           COMPLETE                                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    print(f"  Lines:    {line_count:,}")
    print(f"  Size:     {file_size:,} bytes ({file_size/1024:.1f} KB)")
    print(f"  Files:    {len(ALL_FILES)} embedded")
    print()
    print("To reconstruct the modular config:")
    print(f"  python unflatten.py {output_file} <output_directory>")
    print()


if __name__ == '__main__':
    main()
