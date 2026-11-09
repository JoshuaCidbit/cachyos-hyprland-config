# wal — Wallpaper & Color System (pywal16)

Sistema de wallpapers y temas de color unificado sobre **pywal16**.

- Selección de wallpaper vía **rofi** (picker grid con iconos).
- Toda la paleta de color sale de **pywal16** (`/usr/bin/wal`) y se propaga a
  Hyprland, kitty, btop, cava, SDDM, fastfetch, etc. (un solo tema, sin selección
  selectiva).
- **Rotación automática** de wallpapers con temporizador visible en el picker.

## Requisitos

- `pywal16` (binario: `/usr/bin/wal` — sobreescribible con `WAL_BIN`)
- `rofi` ≥ 2.0
- `awww` (daemon de wallpapers animados)
- Hyprland + `hyprctl`, `hyprctl` para recargas
- Opcionales: `mpvpaper`, `ffmpeg`, `magick`/`convert`, `notify-send`, `kitty`,
  `fastfetch`, `btop`, `cava`, `socat`, `jq` (solo si se usan esos flujos)

## Uso

### Picker de wallpaper

```bash
bin/wallpaper_picker.sh          # picker de wallpaper (grid con iconos)
~/.config/wal/bin/wallpaper_picker.sh --simple   # picker simple
```

Dentro del picker:

| Tecla | Acción |
|---|---|
| `Enter` / `MousePrimary` | Aplica el wallpaper seleccionado |
| `f` | Alterna favorito del ítem (sin aplicar) → refresca la lista |
| `t` | Abre el selector de intervalo de rotación → persiste y reabre el picker |
| `Esc` / timeout | Cierra el picker |

El prompt es limpio: `select wallpaper...`.

### Flags

| Flag | Acción |
|---|---|
| `--preview` | Abre `imv` tras aplicar (solo imágenes estáticas) |
| `--simple` | Picker de lista simple (sin iconos) |
| `--no-wal` | Omite la ejecución de pywal16 |
| `--kill` | Mata `mpvpaper` (bind de fullscreen / Win+Shift+W) |
| `--restore` | Restaura el último wallpaper animado |
| `--dry-run` | Muestra qué haría sin aplicar nada |
| `--auto` | Modo rotación automática (elige intervalo por rofi) |

### Rotación automática

- Intervalos: `No cambiar`, `30 min`, `1 hora`, `2 horas`, `24 horas`.
- Al elegir uno con `t`, se persiste en `~/.cache/wal/auto-rotate.conf`.
- El picker muestra el temporizador en la barra `-mesg` de rofi solo si la
  rotación está activa (`⏱ HH:MM` ≥ 1 h, `⏱ N min` < 1 h).
- Al arrancar el picker se recarga el intervalo persistido (fix: tras elegir
  intervalo y reabrir, el timer vuelve a mostrarse).

### Favoritos

- Archivo: `~/.cache/wal/favorites` (uno en línea por wallpaper).
- En el picker (`todos` mode): los favoritos van primero y llevan `*` prefix.
- `f` alterna favorito sin aplicar.

## Variables de entorno

| Variable | Default | Descripción |
|---|---|---|
| `WAL_BIN` | `/usr/bin/wal` | Binario de pywal16 |
| `WALL_DIR` | `~/.pictures/wallpapers/1080p` (`WALLPAPER_DIR`) | Directorio de wallpapers |
| `WALL_TRANSITION` | `wipe` | Transición: `wipe\|fade\|slide\|none` |
| `WALL_TRANSITION_DUR` | `1` | Duración de transición (s) |
| `MONITOR` | `*` | Monitor Hyprland |
| `SIMPLE_MODE` | `false` | Picker simple |
| `DO_PREVIEW` | `false` | Preview con imv |
| `SKIP_WAL` | `false` | Omitir pywal16 |
| `KILL_MODE` | `false` | Modo kill mpvpaper |
| `RESTORE_MODE` | `false` | Restaurar último animado |
| `DRY_RUN` | `false` | Modo prueba |
| `AUTO_MODE` | `false` | Rotación automática |
| `AUTO_ROTATE` | `off` | Intervalo: `off`, `30min`, `1h`, `2h`, `24h` |
| `AUTO_ROTATE_FILE` | `~/.cache/wal/auto-rotate.conf` | Archivo persistido del intervalo |
| `FAVORITES_FILE` | `~/.cache/wal/favorites` | Archivo de favoritos |
| `WAL_HISTORY` | `~/.cache/wal/wal` | Historial de pywal16 |
| `WAL_CONF` | `~/.config/wal/wal.conf` | Archivo de configuración |
| `FRAME_CACHE` | `~/.cache/wallpaper_frames` | Cache de frames |
| `AWW_BIN` | `/usr/bin/awww` | Daemon awww |
| `IMV_BIN` | `imv` | Visualizador |
| `KITTY_CONF` | `~/.cache/wal/colors-kitty.conf` | Conf kitty |

## Config file (`~/.config/wal/wal.conf`)

Formato `CLAVE=valor`. Prioridad: variables de entorno > archivo > defaults.

| Clave | Default | Descripción |
|---|---|---|
| `WALL_DIR` | … | Directorio de wallpapers |
| `WALL_TRANSITION` | `wipe` | Transición |
| `WALL_TRANSITION_DUR` | `1` | Duración (s) |
| `MONITOR` | `*` | Monitor |
| `WALL_AUTO_ROTATE` | `off` | Intervalo inicial |

## Tests

```bash
bash tests/run_tests.sh
```

- `tests/lib_test.sh` → tests unitarios de librerías.
- `tests/picker_flow_test.sh` → integración del picker con fake rofi.
- `tests/fixtures/rofi` → fake de rofi (inyecta selección vía archivo).
