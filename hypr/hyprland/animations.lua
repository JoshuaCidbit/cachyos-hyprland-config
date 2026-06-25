hl.config({
    animations = {
        enabled = true,

        bezier = {
            { name = "smooth",           x1 = 0.05, y1 = 0.9,  x2 = 0.1,  y2 = 1.05 },
            { name = "overshot",         x1 = 0.13, y1 = 0.99, x2 = 0.29, y2 = 1.10 },
            { name = "linear",           x1 = 0,    y1 = 0,    x2 = 1,    y2 = 1    },
            { name = "workAnim",         x1 = 0.5,  y1 = 0,    x2 = 0.2,  y2 = 1    },
            { name = "popIn",            x1 = 0.1,  y1 = 1,    x2 = 0.1,  y2 = 1.05 },
            { name = "easeOut",          x1 = 0,    y1 = 1,    x2 = 0,    y2 = 1    },
            { name = "specialWorkSwitch",x1 = 0.05, y1 = 0.7,  x2 = 0.1,  y2 = 1    },
            { name = "emphasizedAccel",  x1 = 0.3,  y1 = 0,    x2 = 0.8,  y2 = 0.15 },
            { name = "emphasizedDecel",  x1 = 0.05, y1 = 0.7,  x2 = 0.1,  y2 = 1    },
            { name = "standard",         x1 = 0.2,  y1 = 0,    x2 = 0,    y2 = 1    },
        },

        animation = {
            { event = "windows",          enable = true, speed = 5,  curve = "smooth",   style = "slide"     },
            { event = "windowsIn",         enable = true, speed = 5,  curve = "smooth",   style = "slide"     },
            { event = "windowsOut",        enable = true, speed = 3,  curve = "emphasizedAccel" },
            { event = "windowsMove",       enable = true, speed = 4,  curve = "smooth"                        },
            { event = "border",            enable = true, speed = 12, curve = "linear"                        },
            { event = "borderangle",       enable = true, speed = 60, curve = "linear",   style = "loop"      },
            { event = "fade",              enable = true, speed = 5,  curve = "smooth"                        },
            { event = "fadeIn",            enable = true, speed = 5,  curve = "smooth"                        },
            { event = "fadeDim",           enable = true, speed = 6,  curve = "standard"                      },
            { event = "fadeLayers",        enable = true, speed = 5,  curve = "standard"                      },
            { event = "layersIn",          enable = true, speed = 5,  curve = "emphasizedDecel", style = "slide" },
            { event = "layersOut",         enable = true, speed = 4,  curve = "emphasizedAccel", style = "slide" },
            { event = "workspaces",        enable = true, speed = 6,  curve = "workAnim", style = "slide"     },
            { event = "specialWorkspace",  enable = true, speed = 6,  curve = "smooth",   style = "slidevert" },
        },
    },
})