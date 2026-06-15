-- ============================================================
--  modules/colors.lua
--  Lectura de colores desde ~/.cache/wal/colors.lua.template
-- ============================================================

local colors = dofile(os.getenv("HOME") .. "/.config/hypr/schemes/colors.lua")

hl.config({
    general = {
        col = {
            active_border = {
                colors = { 
                    "rgba(" .. (colors.primary or "bfc1ff") .. "ee)", 
                    "rgba(" .. (colors.tertiary or "f4b2e2") .. "ee)" 
                },
                angle = 45,
            },
            inactive_border = "rgba(" .. (colors.outline or "918f9a") .. "aa)",
        },
    },
    misc = {
        background_color = "rgb(" .. (colors.surfaceContainer or "1f1f23") .. ")",
    },
})

return colors
