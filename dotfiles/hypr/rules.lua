-- Window / layer / workspace rules
-- Layer blur is what powers the 70% frosted-glass waybar & wofi.

-- Waybar: blur behind 70% module backgrounds
hl.layer_rule({
	match = { namespace = "waybar" },
	blur = true,
	ignore_alpha = 0.7,
})

-- Wofi launcher
hl.layer_rule({
	match = { namespace = "wofi" },
	blur = true,
	ignore_alpha = 0.7,
})

-- Walker (Spotlight-style global search)
hl.layer_rule({
	match = { namespace = "walker" },
	blur = true,
	ignore_alpha = 0.7,
})

-- Common floating utility windows
hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "^Pavucontrol$" },
	float = true,
})

hl.window_rule({
	name = "float-nm-connection-editor",
	match = { class = "^nm-connection-editor$" },
	float = true,
})

hl.window_rule({
	name = "float-blueman-manager",
	match = { class = "^Blueman-manager$" },
	float = true,
})

hl.window_rule({
	name = "float-wlogout",
	match = { class = "^wlogout$" },
	fullscreen = true,
})
