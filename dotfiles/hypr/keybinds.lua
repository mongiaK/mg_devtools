-- Keybinds
-- https://wiki.hypr.land/configuring/core/binds/

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "thunar"
local launcher = "wofi --show drun"
local spotlight = "walker"
local themeToggle = "~/.config/scripts/theme-toggle.sh"

-- Apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(launcher))

-- Global search (macOS Spotlight-style)
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(spotlight))

-- Theme: mocha <-> latte (same entry as waybar sun/moon)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(themeToggle))

-- Window management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- Move window
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))

-- Workspaces 1-5
for i = 1, 5 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Session
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- Media / brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Screenshots (grim + slurp + wl-copy, save to ~/Pictures)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(
	"sh -c 'grim -g \"$(slurp)\" - | wl-copy && grim ~/Pictures/$(date +%Y%m%d-%H%M%S).png'"
))

-- Region screenshot → annotate with satty
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(
	"sh -c 'grim -g \"$(slurp)\" - | satty --filename - --output-filename ~/Pictures/satty-$(date +%Y%m%d-%H%M%S).png --early-exit'"
))

-- Screen record toggle (wf-recorder)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(
	"sh -c 'if pidof wf-recorder >/dev/null; then pkill -INT wf-recorder; else mkdir -p ~/Videos; wf-recorder -f ~/Videos/rec-$(date +%Y%m%d-%H%M%S).mp4; fi'"
))

-- Lock screen (Super+L is focus-right here → use Ctrl+L)
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Color picker
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("hyprpicker -a"))
