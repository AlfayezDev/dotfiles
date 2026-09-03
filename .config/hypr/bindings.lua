-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Remove bundled HEY email and calendar bindings.
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Close window on SUPER+Q (moved from SUPER+W).
hl.unbind("SUPER + W")
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Send a shortcut to the focused surface via Hyprland itself (Omarchy's
-- clipboard.lua pattern). No wtype, no sleep: injected keys bypass the
-- physically held SUPER modifier entirely.
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  if type(window.tags) == "table" then
    for _, tag in ipairs(window.tags) do
      if tag:gsub("%*$", "") == "terminal" then
        return true
      end
    end
  end

  return false
end

-- Bind paste to physical V key (XKB code 55), independent of US/Arabic layout.
hl.unbind("SUPER + V")
o.bind("SUPER + code:55", "Universal paste", function()
  if active_window_is_terminal() then
    send_shortcut_once("SHIFT", "Insert")()
  else
    send_shortcut_once("CTRL", "V")()
  end
end)

-- Browser tab keys sent to the focused window.
o.bind("SUPER + W", "Close tab", send_shortcut_once("CTRL", "W"))
o.bind("SUPER + SHIFT + W", "Undo close tab", send_shortcut_once({ "CTRL", "SHIFT" }, "T"))

-- New tab on SUPER+T (moved off SUPER+W; default was float-toggle).
hl.unbind("SUPER + T")
o.bind("SUPER + T", "New tab", send_shortcut_once("CTRL", "T"))

-- Select all in focused window.
o.bind("SUPER + A", "Select all", send_shortcut_once("CTRL", "A"))

-- Search on SUPER+F; fullscreen moved to SUPER+SHIFT+F.
hl.unbind("SUPER + F")
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + F", "Search", send_shortcut_once("CTRL", "F"))
o.bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Refresh: SUPER+R soft, SUPER+SHIFT+R hard (bypass cache).
o.bind("SUPER + R", "Refresh", send_shortcut_once("CTRL", "R"))
o.bind("SUPER + SHIFT + R", "Hard refresh", send_shortcut_once({ "CTRL", "SHIFT" }, "R"))

-- Magnifier: SUPER+SHIFT+scroll up/down zooms in/out.
hl.unbind("SUPER + CTRL + Z")
hl.unbind("SUPER + CTRL + ALT + Z")
o.bind("SUPER + SHIFT + mouse_up", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)
o.bind("SUPER + SHIFT + mouse_down", "Zoom out", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = math.max(1, zoom - 1) } })
end)
