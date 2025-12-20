{
  # ==============================================================================
  # DOTFILES FLAKE
  # ==============================================================================
  #
  # This flake provides reproducible package management for the dotfiles.
  #
  # USAGE:
  #   nix flake check          # Verify flake is valid
  #   nix flake update         # Update all inputs (nixpkgs)
  #   nix profile install .#   # Install all packages
  #   nix develop              # Enter dev shell with all packages
  #
  # WHY FLAKES?
  #   1. Reproducibility: flake.lock pins exact versions
  #   2. Speed: Faster evaluation than channels
  #   3. Composability: Easy to add more inputs (overlays, etc.)
  #   4. Modern: Standard in the Nix ecosystem
  #
  # BINARY CACHES:
  #   This flake works with the caches configured in .config/nix/nix.conf
  #   Most packages will be fetched pre-built, not compiled locally.
  #
  # ==============================================================================

  description = "Abdullah's dotfiles - Development environment packages";

  # ==============================================================================
  # INPUTS
  # ==============================================================================
  # External dependencies for this flake
  #
  # nixpkgs-unstable: Latest packages, good binary cache coverage
  # You could pin to a specific commit for even more reproducibility:
  #   nixpkgs.url = "github:nixos/nixpkgs/abc123...";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  # ==============================================================================
  # OUTPUTS
  # ==============================================================================
  # What this flake provides to the world

  outputs = { self, nixpkgs }:
    let
      # Supported systems - add more as needed
      supportedSystems = [
        "x86_64-darwin"   # Intel Mac
        "aarch64-darwin"  # Apple Silicon Mac
        "x86_64-linux"    # Intel/AMD Linux
        "aarch64-linux"   # ARM Linux (Raspberry Pi, etc.)
      ];

      # Helper function to generate outputs for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Get nixpkgs for a specific system
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      # ========================================================================
      # PACKAGE LIST
      # ========================================================================
      # This should match packages.txt for consistency
      # Comment out any packages that don't exist in nixpkgs
      #
      # To find package names: nix search nixpkgs <name>
      # To check if a package exists: nix eval nixpkgs#<name>.name

      packageList = pkgs: with pkgs; [
        # ---------- Shell & Terminal ----------
        zsh                       # Primary shell
        zsh-autosuggestions       # Fish-like autosuggestions for zsh
        zsh-completions           # Additional zsh completions
        zsh-syntax-highlighting   # Syntax highlighting for zsh
        fish                      # Alternative shell
        nushell                   # Data-focused shell
        bash-completion           # Bash completion scripts

        # ---------- Editors ----------
        neovim                    # Primary editor (modular Lua config)
        helix                     # Secondary editor (modal, Kakoune-inspired)

        # ---------- Modern CLI Replacements ----------
        eza                       # Modern ls (formerly exa)
        bat                       # Modern cat with syntax highlighting
        fd                        # Modern find
        ripgrep                   # Modern grep (rg)
        procs                     # Modern ps
        delta                     # Git diff pager (was git-delta in some repos)
        zoxide                    # Smart cd (z command)

        # ---------- Fuzzy Finding & Navigation ----------
        fzf                       # Fuzzy finder
        carapace                  # Multi-shell completion bridge

        # ---------- Shell Enhancements ----------
        atuin                     # Shell history manager (replaces Ctrl+R)
        starship                  # Cross-shell prompt

        # ---------- Terminal Multiplexer ----------
        zellij                    # Terminal multiplexer (modern tmux alternative)

        # ---------- Git & GitHub ----------
        gh                        # GitHub CLI
        # Note: git is typically provided by the system

        # ---------- Development Tools ----------
        jq                        # JSON processor
        tree-sitter               # Parser generator (for syntax highlighting)
        zig                       # Zig programming language
        nodejs                    # Node.js (required for Copilot, some LSPs)

        # ---------- Utilities ----------
        curl                      # HTTP client
        bc                        # Calculator
        wrk                       # HTTP benchmarking tool

        # ---------- NOT IN NIXPKGS (install separately) ----------
        # claude-code             # Install via: npm install -g @anthropic-ai/claude-code
        # opencode                # Not in nixpkgs - check alternative sources
      ];

    in
    {
      # ========================================================================
      # PACKAGES OUTPUT
      # ========================================================================
      # nix profile install .#   (installs the default package)
      # nix build .#default      (builds without installing)

      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          # Default package: a bundle of all tools
          default = pkgs.buildEnv {
            name = "dotfiles-packages";
            paths = packageList pkgs;

            # Handle conflicts (e.g., multiple packages providing same binary)
            # pathsToLink = [ "/bin" "/share" ];
            # ignoreCollisions = true;
          };

          # Individual packages can be exposed here if needed
          # neovim = pkgs.neovim;
        }
      );

      # ========================================================================
      # DEV SHELLS OUTPUT
      # ========================================================================
      # nix develop   (enters a shell with all packages available)
      #
      # Useful for testing packages without installing to profile

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            name = "dotfiles-shell";
            buildInputs = packageList pkgs;

            shellHook = ''
              echo "Dotfiles development shell"
              echo "All packages from flake.nix are available"
              echo ""
              echo "Installed packages:"
              echo "  Shells: zsh, fish, nushell"
              echo "  Editors: neovim, helix"
              echo "  CLI tools: eza, bat, fd, ripgrep, fzf, etc."
              echo ""
            '';
          };
        }
      );

      # ========================================================================
      # OVERLAYS (optional, for customization)
      # ========================================================================
      # Overlays let you modify packages or add new ones
      # Uncomment and customize as needed

      # overlays.default = final: prev: {
      #   # Example: Use neovim-nightly from nix-community
      #   # neovim = inputs.neovim-nightly.packages.${final.system}.default;
      # };
    };
}
