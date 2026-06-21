-- ============================================================
--  modules/environment-variables.lua
-- ============================================================

-- ── Detección de GPU ───────────────────────────────────────────
local function kernel_module_loaded(name)
    local f = io.open("/sys/module/" .. name .. "/version", "r")
    if f then
        f:close()
        return true
    end
    local d = io.open("/sys/module/" .. name .. "/", "r")
    if d then
        d:close()
        return true
    end
    return false
end
 
local has_nvidia = kernel_module_loaded("nvidia")
local has_amd    = kernel_module_loaded("amdgpu")
 
if has_nvidia then
    hl.env("LIBVA_DRIVER_NAME",         "nvidia")
    hl.env("GBM_BACKEND",               "nvidia-drm")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("__GL_GSYNC_ALLOWED", "1")
    hl.env("__GL_VRR_ALLOWED",   "1")
    hl.env("AQ_FORCE_LINEAR_BLIT", "0")
end
 
if has_amd then
    hl.env("LIBVA_DRIVER_NAME", "radeonsi")
    hl.env("VDPAU_DRIVER",      "radeonsi")
end

-- ── XDG ──────────────────────────────────────────────────────
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_DATA_DIRS", "/var/lib/flatpak/exports/share:/home/joshua/.local/share/flatpak/exports/share:/usr/local/share:/usr/share")

-- ── Toolkit backends ─────────────────────────────────────────
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND",     "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ── Qt ───────────────────────────────────────────────────────
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",         "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME",                "qt6ct")

-- ── Forzar el uso de PipeWire para captura de pantalla ───────
hl.env("QT_WAYLAND_FORCE_DPI", "physical")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("NVD_BACKEND", "direct")
hl.env("NVD_BACKEND", "direct")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- ── Otros ────────────────────────────────────────────────────
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
