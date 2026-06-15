-- ============================================================
--  modules/general.lua
-- ============================================================

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,
        gaps_workspaces  = 0,
        border_size      = 2,
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },
})
