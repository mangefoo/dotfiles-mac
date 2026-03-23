local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = 'nord'
config.window_decorations = "RESIZE"

config.keys = {
  { key = "d", mods = "CMD", action = act.SplitHorizontal{ domain = "CurrentPaneDomain" } },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical{ domain = "CurrentPaneDomain" } },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane{ confirm = true } },
  { key = "[", mods = "CMD", action = act.ActivatePaneDirection("Prev") },
  { key = "]", mods = "CMD", action = act.ActivatePaneDirection("Next") },
}

return config
