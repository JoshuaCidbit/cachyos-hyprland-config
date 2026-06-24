#!/usr/bin/env python3
import json
import sys
from pathlib import Path

# pywal genera esto fresco con cada wallpaper
WAL_COLORS = Path("~/.cache/wal/colors.json").expanduser()
OUT = Path("~/.local/state/caelestia/scheme.json").expanduser()

def main():
    if not WAL_COLORS.exists():
        print(f"Error: no encontré {WAL_COLORS}", file=sys.stderr)
        sys.exit(1)

    wal = json.loads(WAL_COLORS.read_text())
    colors = wal["colors"]   # color0..color15
    special = wal["special"] # background, foreground, cursor

    bg = special["background"].lstrip("#")
    r, g, b = int(bg[0:2], 16), int(bg[2:4], 16), int(bg[4:6], 16)
    mode = "light" if (0.299*r + 0.587*g + 0.114*b) > 128 else "dark"

    # Mapear color0..color15 a term0..term15
    term = {f"term{i}": colors[f"color{i}"].lstrip("#") for i in range(16)}

    # Construir paleta M3 mapeando colores de pywal
    bg_hex   = special["background"].lstrip("#")
    fg_hex   = special["foreground"].lstrip("#")
    c1       = colors["color1"].lstrip("#")
    c2       = colors["color2"].lstrip("#")
    c3       = colors["color3"].lstrip("#")
    c4       = colors["color4"].lstrip("#")
    c5       = colors["color5"].lstrip("#")
    c6       = colors["color6"].lstrip("#")
    c9       = colors["color9"].lstrip("#")
    c10      = colors["color10"].lstrip("#")
    c13      = colors["color13"].lstrip("#")

    colours = {
        # Primarios (color dominante del wallpaper)
        "primary":                      c1,
        "onPrimary":                    bg_hex,
        "primaryContainer":             c5,
        "onPrimaryContainer":           fg_hex,
        "inversePrimary":               c9,
        "primary_paletteKeyColor":      c1,

        # Secundarios
        "secondary":                    c2,
        "onSecondary":                  bg_hex,
        "secondaryContainer":           c6,
        "onSecondaryContainer":         fg_hex,
        "secondary_paletteKeyColor":    c2,

        # Terciarios
        "tertiary":                     c3,
        "onTertiary":                   bg_hex,
        "tertiaryContainer":            c4,
        "onTertiaryContainer":          bg_hex,
        "tertiary_paletteKeyColor":     c3,

        # Fondos y superficies
        "background":                   bg_hex,
        "onBackground":                 fg_hex,
        "surface":                      bg_hex,
        "surfaceDim":                   bg_hex,
        "surfaceBright":                c10,
        "surfaceContainerLowest":       bg_hex,
        "surfaceContainerLow":          bg_hex,
        "surfaceContainer":             c5,
        "surfaceContainerHigh":         c6,
        "surfaceContainerHighest":      c10,
        "onSurface":                    fg_hex,
        "surfaceVariant":               c6,
        "onSurfaceVariant":             fg_hex,
        "inverseSurface":               fg_hex,
        "inverseOnSurface":             bg_hex,
        "surfaceTint":                  c1,

        # Outlines
        "outline":                      c13,
        "outlineVariant":               c5,
        "shadow":                       "000000",
        "scrim":                        "000000",

        # Error / Success
        "error":                        colors["color1"].lstrip("#"),
        "onError":                      bg_hex,
        "errorContainer":               colors["color9"].lstrip("#"),
        "onErrorContainer":             fg_hex,
        "success":                      colors["color2"].lstrip("#"),
        "onSuccess":                    bg_hex,
        "successContainer":             colors["color10"].lstrip("#"),
        "onSuccessContainer":           fg_hex,

        # Neutrales
        "neutral_paletteKeyColor":      c6,
        "neutral_variant_paletteKeyColor": c5,

        # Fixed (mismos valores que primary/secondary/tertiary)
        "primaryFixed":                 c1,
        "primaryFixedDim":              c9,
        "onPrimaryFixed":               bg_hex,
        "onPrimaryFixedVariant":        c5,
        "secondaryFixed":               c2,
        "secondaryFixedDim":            c10,
        "onSecondaryFixed":             bg_hex,
        "onSecondaryFixedVariant":      c6,
        "tertiaryFixed":                c3,
        "tertiaryFixedDim":             c13,
        "onTertiaryFixed":              bg_hex,
        "onTertiaryFixedVariant":       c4,

        **term,
    }

    scheme = {
        "name": "Pywal",
        "variant": "dynamic",
        "mode": mode,
        "colours": colours,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(scheme, indent=2))
    print(f"✓ Caelestia: {len(colours)} colores desde {WAL_COLORS.name} (modo: {mode})")

if __name__ == "__main__":
    main()
