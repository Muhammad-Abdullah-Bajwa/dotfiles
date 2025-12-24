-- WezTerm Configuration
-- Mirrors Ghostty config: Dracula theme, ZedMono font, zellij auto-attach

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ============================================================================
-- Theme - Dracula (high contrast purple/pink)
-- ============================================================================
config.color_scheme = "Dracula"

-- ============================================================================
-- Font Settings
-- ============================================================================
config.font = wezterm.font("ZedMono Nerd Font")
config.font_size = 14.0

-- ============================================================================
-- Default Command - auto-attach to zellij session
-- ============================================================================
config.default_prog = {
	"/Users/abdullahbajwa/.nix-profile/bin/fish",
	"-c",
	"zellij attach --create",
}

-- ============================================================================
-- Keybindings
-- ============================================================================
config.keys = {
	-- Shift+Enter sends literal newline (matches Ghostty behavior)
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

-- ============================================================================
-- Window Appearance (sensible defaults)
-- ============================================================================
-- Hide the tab bar when only one tab exists (cleaner look with zellij)
config.hide_tab_bar_if_only_one_tab = true

-- Native macOS window decorations
config.window_decorations = "RESIZE"

-- Slight padding for aesthetics
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

return config
