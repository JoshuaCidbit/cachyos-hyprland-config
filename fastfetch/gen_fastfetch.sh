#!/bin/bash
# Rutas
PYWAL_JSON="$HOME/.cache/wal/colors.json"
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"
idx_to_ansi() {
printf "\\\\u001b[38;5;%dm" "$1"
}
C1=$(idx_to_ansi 4)    # color4
C2=$(idx_to_ansi 2)    # color2
C3=$(idx_to_ansi 3)    # color3
C4=$(idx_to_ansi 6)    # color6
RESET="\\u001b[0m"

LC1D=$(idx_to_ansi 4)    # teal oscuro/sombra (color4)
LC1L=$(idx_to_ansi 12)   # teal claro/vivo   (color12, bright de color4)
LC2D=$(idx_to_ansi 6)    # cian oscuro/sombra (color6)
LC2L=$(idx_to_ansi 14)   # cian claro/vivo    (color14, bright de color6)
 
LOGO_SRC="          ${LC1L}++++++++++++${LC2L}=            \n"
LOGO_SRC+="         ${LC2L}=${LC1L}+++++++++${LC1D}*${LC1L}++    ${LC1L}++       \n"
LOGO_SRC+="        ${LC2L}==${LC1L}++${LC2L}===${LC1L}++++++              \n"
LOGO_SRC+="       ${LC2L}===${LC1L}+++                      \n"
LOGO_SRC+="     ${LC2L}===${LC1L}++++           ${LC2L}====        \n"
LOGO_SRC+="    ${LC1L}+++++++             ${LC2D}--         \n"
LOGO_SRC+="     ${LC2L}===${LC1L}+++                ${LC1L}+++     \n"
LOGO_SRC+="      ${LC1D}**${LC1L}++++               ${LC2L}====    \n"
LOGO_SRC+="       ${LC1L}++++${LC2L}=${LC1L}+${LC1D}*${LC2L}============         \n"
LOGO_SRC+="        ${LC1L}+++${LC2L}=${LC1L}++++++${LC2L}=======          \n"
LOGO_SRC+="         ${LC1L}++++++++++++${LC2L}===           ${RESET}"

# Generar el archivo
cat <<EOF > "$CONFIG_FILE"
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "data-raw",
        "source": "$LOGO_SRC"
    },
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