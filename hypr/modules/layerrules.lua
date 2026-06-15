-- ============================================================
--  modules/layerrules.lua
-- ============================================================

-- ── Rofi ─────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.2 })

-- ── SwayNC ───────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "swaync-control-center" },   blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5 })

-- ── Hyprpicker / wlogout / slurp / wayfreeze ────────────────
hl.layer_rule({ match = { namespace = "hyprpicker" },    animation = "fade" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" },     animation = "fade" })
hl.layer_rule({ match = { namespace = "wayfreeze" },     animation = "fade" })

-- ── Fuzzel / launcher ───────────────────────────────────────
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true })

-- ── Caelestia shell ──────────────────────────────────────────
hl.layer_rule({ match = { namespace = "caelestia%-(border%-exclusion|area%-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia%-(drawers|background)" }, animation = "fade" })
