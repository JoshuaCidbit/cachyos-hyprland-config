-- ============================================================
--  modules/groups.lua
--  Requiere modules.colors cargado antes (usa tabla c)
-- ============================================================

local c = require("modules.colors")

hl.config({
    group = {
        -- Nota: Los colores de borde no llevan sub-tabla 'col'
	{["col.border_active"]         = {"rgba(" .. (c.primary or "bfc1ff") .. "ee)", "rgba(" .. (c.tertiary or "f4b2e2") .. "ee)"}, angle = 45},
        ["col.border_inactive"]       = "rgba(" .. (c.outline or "918f9a") .. "aa)",
	{["col.border_locked_active"]  = {"rgba(" .. (c.primary or "bfc1ff") .. "ee)", "rgba(" .. (c.tertiary or "f4b2e2") .. "ee)}"}, angle = 45},
        ["col.border_locked_inactive"] = "rgba(" .. (c.secondary or "c5c4e0") .. "aa)",

        groupbar = {
            font_family             = "JetBrains Mono NF",
            font_size               = 15,
            gradients               = true,
            gradient_round_only_edges = false,
            gradient_rounding       = 5,
            height                  = 25,
            indicator_height        = 0,
            gaps_in                 = 3,
            gaps_out                = 3,

            text_color              = "rgb(" .. (c.onPrimary or "282b60") .. ")",
            ["col.active"]          = "rgba(" .. (c.primaryContainer or "6f72ac") .. "dd)",
            ["col.inactive"]        = "rgba(" .. (c.outline or "918f9a") .. "dd)",
            ["col.locked_active"]   = "rgba(" .. (c.primaryContainer or "6f72ac") .. "dd)",
            ["col.locked_inactive"] = "rgba(" .. (c.secondaryContainer or "44455c") .. "dd)",
        },
    },
})
