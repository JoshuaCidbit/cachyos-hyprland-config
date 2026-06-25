#!/usr/bin/env bash
# lib/theme.sh — Tema de rofi generado dinámicamente con colores de pywal
# ────────────────────────────────────────────────────────────────────────
#
# Requiere que load_wal_colors (lib/colors.sh) haya sido llamado antes,
# ya que usa las variables color0..color7.
#
# Uso:
#   source lib/theme.sh
#   build_grid_theme    # imprime el tema a stdout (listo para -theme-str)

build_grid_theme() {
    cat <<EOF
* {
    font: "JetBrainsMono Nerd Font 11";
}
window {
    width: 820px;
    height: 700px;
    anchor: center;
    location: center;
    border: 2px;
    border-radius: 22px;
    border-color: ${color1};
    background-color: ${color0}cc;
    padding: 18px;
}
mainbox {
    background-color: transparent;
    spacing: 14px;
    children: [ inputbar, listview ];
}
inputbar {
    padding: 12px 16px;
    border-radius: 16px;
    background-color: ${color0}55;
    children: [ prompt, entry ];
}
prompt {
    enabled: true;
    text-color: ${color1};
    background-color: transparent;
    margin: 0px 8px 0px 0px;
}
entry {
    placeholder: "Search wallpaper...";
    placeholder-color: ${color7}66;
    text-color: ${color7};
    background-color: transparent;
}
listview {
    columns: 3;
    lines: 2;
    flow: horizontal;
    fixed-height: true;
    fixed-columns: true;
    cycle: false;
    scrollbar: false;
    spacing: 16px;
    background-color: transparent;
}
element {
    orientation: vertical;
    padding: 10px;
    spacing: 10px;
    border-radius: 18px;
    background-color: ${color0}88;
    border: 2px;
    border-color: ${color2}22;
}
element normal.normal,
element normal.active,
element normal.urgent,
element alternate.normal,
element alternate.active,
element alternate.urgent {
    background-color: ${color0}88;
    border: 2px;
    border-color: ${color2}22;
}
element selected.normal,
element selected.active,
element selected.urgent {
    background-color: ${color3}44;
    border: 2px;
    border-color: ${color3};
}
element-icon {
    size: 210px;
    horizontal-align: 0.5;
    vertical-align: 0.5;
    border-radius: 14px;
    background-color: transparent;
}
element-text {
    horizontal-align: 0.5;
    text-color: ${color7};
    background-color: transparent;
}
EOF
}

