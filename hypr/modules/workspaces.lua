-- ============================================================
--  modules/workspaces.lua
-- ============================================================

for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = "HDMI-A-1",
        default   = (i == 1),
    })
end

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = 0, gaps_in = 0 })
