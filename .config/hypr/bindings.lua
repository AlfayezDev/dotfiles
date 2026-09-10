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

-- NOTE: personal binds use physical keycodes (code:NN) so they fire on any
-- keyboard layout. Arabic layout emits different keysyms, so keysym binds
-- like "SUPER + Q" silently miss when Arabic is active. Codes are XKB
-- (evdev + 8): Q=24 W=25 R=27 T=28 O=32 A=38 F=41 Z=52 V=55.

-- Close window on SUPER+Q (moved from SUPER+W).
hl.unbind("SUPER + W")
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + code:24", "Close window", hl.dsp.window.close())

-- Send a shortcut to the focused surface via Hyprland itself (Omarchy's
-- clipboard.lua pattern). No wtype, no sleep: injected keys bypass the
-- physically held SUPER modifier entirely.
--
-- Layout note: send_key_state resolves keysym names against the seat
-- keyboard's ACTIVE layout group, so under the Arabic layout a latin letter
-- like "V" resolves to nothing and the whole chord silently dies. Passing
-- explicit "code:NN" bypasses resolution; the injected mods event also
-- carries group 0, so the client reads the keycode as the latin key on any
-- layout. Map: evdev + 8.
local KEY_CODES = { A = 38, C = 54, F = 41, R = 27, T = 28, V = 55, W = 25, X = 53, INSERT = 118 }

local function send_shortcut_once(mods, key)
  local code = KEY_CODES[key:upper()]
  local key_arg = code and ("code:" .. code) or key
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key_arg, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key_arg, state = "up" }))
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

-- Layout-safe universal copy/cut (Omarchy defaults pass keysym names, which
-- fail to resolve under the Arabic layout; same fix as paste above).
hl.unbind("SUPER + C")
hl.unbind("SUPER + X")
o.bind("SUPER + C", "Universal copy", function()
  if active_window_is_terminal() then
    send_shortcut_once("CTRL", "Insert")()
  else
    send_shortcut_once("CTRL", "C")()
  end
end)
o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))

-- Browser tab keys sent to the focused window.
o.bind("SUPER + code:25", "Close tab", send_shortcut_once("CTRL", "W"))
o.bind("SUPER + SHIFT + code:25", "Undo close tab", send_shortcut_once({ "CTRL", "SHIFT" }, "T"))

-- New tab on SUPER+T (moved off SUPER+W; default was float-toggle).
hl.unbind("SUPER + T")
o.bind("SUPER + code:28", "New tab", send_shortcut_once("CTRL", "T"))

-- Select all in focused window.
o.bind("SUPER + code:38", "Select all", send_shortcut_once("CTRL", "A"))

-- Search on SUPER+F; fullscreen moved to SUPER+SHIFT+F.
hl.unbind("SUPER + F")
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + code:41", "Search", send_shortcut_once("CTRL", "F"))
o.bind("SUPER + SHIFT + code:41", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Refresh: SUPER+R soft, SUPER+SHIFT+R hard (bypass cache).
o.bind("SUPER + code:27", "Refresh", send_shortcut_once("CTRL", "R"))
o.bind("SUPER + SHIFT + code:27", "Hard refresh", send_shortcut_once({ "CTRL", "SHIFT" }, "R"))

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

-- SUPER+O: omarchy default (pop window out: float & pin, via omarchy-hyprland-window-pop).
-- SUPER+SHIFT+O: pin/unpin only — toggles whether window stays on all workspaces.
-- Was: Obsidian (removed).
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + code:32", "Pin or unpin window", "hypr-window-pin-toggle")
