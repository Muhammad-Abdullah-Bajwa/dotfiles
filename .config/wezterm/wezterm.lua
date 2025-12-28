-- WezTerm Configuration
-- Mirrors Ghostty config: Modus Vivendi theme, ZedMono font

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ============================================================================
-- Theme - Modus Vivendi (WCAG AAA accessible dark theme)
-- ============================================================================
-- From https://github.com/miikanissi/modus-themes.nvim
config.colors = {
	foreground = "#ffffff",
	background = "#000000",
	cursor_fg = "#000000",
	cursor_bg = "#ffffff",
	selection_fg = "#ffffff",
	selection_bg = "#7030af",
	ansi = {
		"#000000", -- black
		"#ff5f59", -- red
		"#44bc44", -- green
		"#d0bc00", -- yellow
		"#2fafff", -- blue
		"#feacd0", -- magenta
		"#00d3d0", -- cyan
		"#ffffff", -- white
	},
	brights = {
		"#303030", -- bright black
		"#ff5f5f", -- bright red
		"#44df44", -- bright green
		"#efef00", -- bright yellow
		"#338fff", -- bright blue
		"#ff66ff", -- bright magenta
		"#00eff0", -- bright cyan
		"#989898", -- bright white
	},
	compose_cursor = "#fec43f",
	split = "#79a8ff",
	scrollbar_thumb = "#646464",
	tab_bar = {
		background = "#000000",
		active_tab = {
			bg_color = "#000000",
			fg_color = "#c6daff",
		},
		inactive_tab = {
			bg_color = "#545454",
			fg_color = "#ffffff",
		},
		inactive_tab_hover = {
			bg_color = "#545454",
			fg_color = "#c6daff",
		},
		new_tab = {
			bg_color = "#313131",
			fg_color = "#ffffff",
		},
		new_tab_hover = {
			bg_color = "#313131",
			fg_color = "#c6daff",
			intensity = "Bold",
		},
	},
}

-- ============================================================================
-- Font Settings
-- ============================================================================
config.font = wezterm.font("ZedMono Nerd Font")
config.font_size = 14.0

-- ============================================================================
-- Default Shell
-- ============================================================================
config.default_prog = { "/Users/abdullahbajwa/.nix-profile/bin/fish" }

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

-- Background opacity (0.0 = fully transparent, 1.0 = fully opaque)
config.window_background_opacity = 0.9

return config
