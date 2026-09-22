-- Environment variables (Wayland-first)
-- https://wiki.hypr.land/configuring/core/environment-variables/

-- Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "hyprland")

-- Qt5 / Qt6
-- QT_QPA_PLATFORMTHEME is one value for both toolkits:
--   qt5ct → Qt5 apps get full palette from qt5ct.conf (theme-toggle keeps it in sync)
--   Qt6 apps fall back to QT_QPA_COLOR_SCHEME (set in theme.lua)
--   To prefer Qt6 apps instead: switch to "qt6ct" (configs live in ~/.config/qt6ct/)
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GTK / GDK / general toolkits (no GTK_THEME — let color-scheme drive light/dark)
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Input method (Fcitx5)
-- Values must be "fcitx" (not "fcitx5") for GTK/Qt IM modules.
-- XMODIFIERS covers XWayland / X11 clients.
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")

-- Cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_THEME", "Adwaita")
