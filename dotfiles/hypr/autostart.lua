-- Autostart — https://wiki.hypr.land/configuring/core/autostart/
-- Each command is guarded so a missing package does not break the session.

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("mako")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("sh -c 'command -v hyprpolkitagent >/dev/null && hyprpolkitagent &'")
	hl.exec_cmd("sh -c 'command -v fcitx5 >/dev/null && fcitx5 -d &'")
	hl.exec_cmd("sh -c 'command -v nm-applet >/dev/null && nm-applet &'")
	hl.exec_cmd("sh -c 'command -v blueman-applet >/dev/null && blueman-applet &'")
	hl.exec_cmd("sh -c 'command -v wl-paste >/dev/null && command -v cliphist >/dev/null && wl-paste --watch cliphist store &'")
	hl.exec_cmd("sh -c 'command -v walker >/dev/null && walker --gapplication-service &'")
	hl.exec_cmd("sh -c 'command -v gnome-keyring-daemon >/dev/null && gnome-keyring-daemon --start --components=secrets,ssh,pkcs11 &'")
end)
