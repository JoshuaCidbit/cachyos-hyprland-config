-- ============================================================
--  modules/decoration.lua
--  Rounding, opacidad, blur y sombras 
-- ============================================================

hl.config({
    decoration = {
        rounding           = 14,
        active_opacity     = 0.98,
        inactive_opacity   = 0.90,
        fullscreen_opacity = 1,

        blur = {
            enabled            = true,
            size               = 4,
            passes             = 1,
            vibrancy           = 0.1696,
            new_optimizations  = true,
            ignore_opacity     = true,
            popups_ignorealpha = 0.2,
            xray               = false,
            special            = false,
            popups             = true,
            input_methods      = false,
        },

        shadow = {
            enabled        = true,
            range          = 10,
            render_power   = 3,
            color          = "rgba(00000055)",
            color_inactive = "rgba(00000025)",
        },
    },
})
