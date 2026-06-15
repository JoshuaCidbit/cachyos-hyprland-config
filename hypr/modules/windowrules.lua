-- ============================================================
--  modules/windowrules.lua
--  Reglas personales + reglas necesarias de Caelestia
-- ============================================================

-- ── Global: suprimir maximize ────────────────────────────────
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- ── Dashboard: suprimir activatefocus ────────────────────────
hl.window_rule({ match = { class = "^(dashboard)$" }, suppress_event = "activatefocus" })

-- ── btop popup ───────────────────────────────────────────────
hl.window_rule({
    match     = { class = "^(btop-popup)$" },
    float     = true, size = { 960, 580 }, center = true,
    animation = "popin 80%", opacity = "0.92 override", rounding = 16,
})

-- ── fastfetch popup ──────────────────────────────────────────
hl.window_rule({
    match     = { class = "^(fastfetch-popup)$" },
    float     = true, size = { 850, 500 }, center = true,
    animation = "popin 80%", opacity = "0.90 override", rounding = 16,
})

-- ── firefox ──────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(firefox)$" }, opacity = "0.97 override" })
hl.window_rule({ match = { class = "^(firefox)$", fullscreen = true }, opacity = "1.0 override" })

-- ── Spotify ──────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(Spotify)$" }, opacity = "0.95 override", rounding = 14, animation = "fade" })

-- ── Apps que ya manejan transparencia / quieren opacas ───────
hl.window_rule({ match = { class = "foot|equibop|org%.quickshell|imv|swappy" }, opaque = true })

-- ── Centrar floats (no xwayland) ──────────────────────────────
hl.window_rule({ match = { float = true, xwayland = false }, center = true })

-- ── Floats varios ─────────────────────────────────────────────
for _, cls in ipairs({
    "guifetch", "yad", "zenity", "wev",
    "org%.gnome%.FileRoller", "file-roller",
    "blueman-manager", "com%.github%.GradienceTeam%.Gradience",
    "feh", "imv", "system-config-printer", "org%.quickshell",
}) do
    hl.window_rule({ match = { class = cls }, float = true })
end

-- ── nmtui ──────────────────────────────────────────────────────
hl.window_rule({ match = { class = "foot", title = "nmtui" }, float = true, size = { "60%", "70%" }, center = true })

-- ── GNOME Settings ───────────────────────────────────────────
hl.window_rule({ match = { class = "org%.gnome%.Settings" }, float = true, size = { "70%", "80%" }, center = true })

-- ── Pavucontrol / yad icon browser ────────────────────────────
hl.window_rule({ match = { class = "org%.pulseaudio%.pavucontrol|yad-icon-browser" }, float = true, size = { "60%", "70%" }, center = true })

-- ── nwg-look ────────────────────────────────────────────────────
hl.window_rule({ match = { class = "nwg-look" }, float = true, size = { "50%", "60%" }, center = true })

-- ── Workspaces especiales (Caelestia) ────────────────────────
hl.window_rule({ match = { class = "btop" }, workspace = "special:sysmon" })
hl.window_rule({ match = { class = "feishin|Spotify|Supersonic|Cider|com%.github%.th_ch%.youtube_music|Plexamp|com%-maxrave%-simpmusic%-MainKt" }, workspace = "special:music" })
hl.window_rule({ match = { initial_title = "Spotify( Free)?" }, workspace = "special:music" })
hl.window_rule({ match = { class = "discord|equibop|vesktop|whatsapp" }, workspace = "special:communication" })
hl.window_rule({ match = { class = "Todoist" }, workspace = "special:todo" })

-- ── Diálogos ────────────────────────────────────────────────────
hl.window_rule({ match = { title = "(Select|Open)( a)? (File|Folder)(s)?" }, float = true })
hl.window_rule({ match = { title = "File (Operation|Upload)( Progress)?" }, float = true })
hl.window_rule({ match = { title = ".* Properties" }, float = true })
hl.window_rule({ match = { title = "Export Image as PNG" }, float = true })
hl.window_rule({ match = { title = "GIMP Crash Debug" }, float = true })
hl.window_rule({ match = { title = "Save As" }, float = true })
hl.window_rule({ match = { title = "Library" }, float = true })

-- ── Picture-in-Picture ───────────────────────────────────────
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, move = { "100%-w-2%", "100%-w-3%" } })
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, keep_aspect_ratio = true })
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, float = true })
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, pin = true })

-- ── Software creativo ────────────────────────────────────────
hl.window_rule({ match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, opaque = true })

-- ── Ueberzugpp ────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, float = true })
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, no_initial_focus = true })

-- ── Steam ─────────────────────────────────────────────────────
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({ match = { title = "Friends List", class = "steam" }, float = true })

-- ── Juegos ────────────────────────────────────────────────────
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, opaque = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, immediate = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, idle_inhibit = "always" })

-- ── Minecraft launchers ───────────────────────────────────────
hl.window_rule({ match = { class = "com%-atlauncher%-App", title = "ATLauncher Console" }, float = true })
hl.window_rule({ match = { class = "PandoraLauncher", title = "Minecraft Game Output" }, float = true })

-- ── Fusion 360 ────────────────────────────────────────────────
hl.window_rule({ match = { title = "Fusion360|(Marking Menu)", class = "fusion360%.exe" }, no_blur = true })

-- ── Xwayland popups ──────────────────────────────────────────
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_dim = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_shadow = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, rounding = 10 })
