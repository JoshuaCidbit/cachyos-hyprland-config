#!/bin/bash

# Ruta a tus archivos
PYWAL_JSON="$HOME/.cache/wal/colors.json"
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

# Función para convertir HEX a ANSI TrueColor con doble escape para JSON
hex_to_ansi() {
    local hex=${1#\#}
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    # El doble \\ asegura que el JSON sea válido y Fastfetch reciba el \ original
    printf "\\\\u001b[38;2;%d;%d;%dm" "$r" "$g" "$b"
}

# Extraer colores
C1=$(hex_to_ansi $(jq -r '.colors.color1' "$PYWAL_JSON"))
C2=$(hex_to_ansi $(jq -r '.colors.color2' "$PYWAL_JSON"))
C3=$(hex_to_ansi $(jq -r '.colors.color3' "$PYWAL_JSON"))
C4=$(hex_to_ansi $(jq -r '.colors.color4' "$PYWAL_JSON"))

# Generar el archivo
cat <<EOF > "$CONFIG_FILE"
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": null,
    "display": {
        "separator": "  ",
        "color": "white",
        "constants": ["\\u001b[37m", "$C1", "$C2", "$C3", "$C4"]
    },
    "modules": [
        "break",
        { "type": "custom", "key": "╭───────────────────────────────────╮" },
        { "type": "kernel", "key": "│ {\$2}{\$1}  kernel", "format": "{\$2}{release>22}{\$1} │" },
        { "type": "command", "key": "│   uptime", "text": "uptime -p | cut -d ' ' -f 2-", "format": "{>22} │" },
        { "type": "shell", "key": "│ {\$2}{\$1}  shell ", "format": "{\$2}{pretty-name>22}{\$1} │" },
        { "type": "command", "key": "│ {\$3}{\$1}  mem   ", "text": "free -m | awk 'NR==2{printf \"%.2f GiB / %.2f GiB\",\$3/1024,\$2/1024}'", "format": "{\$3}{>22}{\$1} │" },
        { "type": "packages", "key": "│   pkgs  ", "format": "{all>22} │" },
        { "type": "command", "key": "│ {\$2}{\$1}  user  ", "text": "echo \$USER", "format": "{\$2}{>22}{\$1} │" },
        { "type": "command", "key": "│   hname ", "text": "hostnamectl hostname", "format": "{>22} │" },
        { "type": "os", "key": "│ {\$4}󰻀{\$1}  distro", "format": "{\$4}{pretty-name>22}{\$1} │" },
        { "type": "custom", "key": "╰───────────────────────────────────╯" },
        "break"
    ]
}
EOF
