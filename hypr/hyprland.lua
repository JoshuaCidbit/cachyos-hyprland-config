-- ============================================================
--  hyprland.lua — Punto de entrada principal
--  ~/.config/hypr/hyprland.lua
--
--  modules/
--  ├── environment-variables.lua
--  ├── monitors.lua
--  ├── general.lua
--  ├── input.lua
--  ├── misc.lua
--  ├── decoration.lua
--  ├── animations.lua
--  ├── colors.lua          ← scheme/colors.conf → bordes/grupos
--  ├── groups.lua
--  ├── scrolling.lua
--  ├── workspaces.lua
--  ├── layerrules.lua
--  ├── windowrules.lua
--  └── auto-start.lua
-- ============================================================

require("modules.environment-variables")
require("modules.monitors")
require("modules.general")
require("modules.input")
require("modules.misc")
require("modules.decoration")
require("modules.animations")
require("modules.colors")
require("modules.groups")
require("modules.scrolling")
require("modules.workspaces")
require("modules.layerrules")
require("modules.windowrules")
require("modules.auto-start")

-- ── Keybindings ──────────────────────────────────────────────
local mod = "SUPER"

-- ── caelestia launcher ───────────────────────────────────────
hl.bind(mod .. " + Super_L",hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))

-- ─── Apps ────────────────────────────────────────────────────
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + D",      hl.dsp.exec_cmd("rofi -show drun"))

-- ─── Wallpaper ───────────────────────────────────────────────
hl.bind(mod .. " + W",         hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/wal/bin/wallpaper_picker.sh"))
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/wal/bin/toggle_mpvpaper.sh"))

-- ─── Ventanas ────────────────────────────────────────────────
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow -j | jq '.pid' | xargs kill -9"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Backslash", hl.dsp.window.center({ respect = true }), { mods = "CTRL" })

-- ─── Foco ────────────────────────────────────────────────────
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- ─── Mover ventanas (teclado) ────────────────────────────────
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))

-- ─── Mouse: mover y redimensionar ventanas ───────────────────
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─── Tab entre workspaces ────────────────────────────────────
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + TAB",   hl.dsp.focus({ workspace = "e-1" }))

-- ─── Scroll entre workspaces ─────────────────────────────────
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ─── Workspaces ──────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10  -- 10 → tecla 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ─── Toggle special workspaces (Caelestia) ───────────────────
hl.bind(mod .. " + M",         hl.dsp.exec_cmd("caelestia toggle music"))
hl.bind(mod .. " + C",         hl.dsp.exec_cmd("caelestia toggle communication"))
hl.bind(mod .. " + T",         hl.dsp.exec_cmd("caelestia toggle todo"))
hl.bind(mod .. " + S",         hl.dsp.exec_cmd("caelestia toggle sysmon"))

-- ─── Sistema ─────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"))

-- ─── Screenshot / color picker ───────────────────────────────
hl.bind("Print",               hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- ─── Clipboard ───────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), { mods = "ALT" })

-- ─── Gamemode ────────────────────────────────────────────────
hl.bind("SUPER + G", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/gamemode.sh"))

-- ─── Firefox ─────────────────────────────────────────────────
hl.bind(mod .. " + Y",      hl.dsp.exec_cmd("firefox https://www.youtube.com/"))
hl.bind(mod .. " + N",      hl.dsp.exec_cmd("firefox https://app.notion.com/"))
