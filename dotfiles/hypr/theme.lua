-- Theme accents: read ~/.config/theme (mocha | latte), apply border colors.
-- Re-executed on every `hyprctl reload` (theme-toggle.sh calls it).

local palettes = {
	mocha = {
		active = { "rgba(cba6f7ee)", "rgba(89b4faee)" },
		inactive = "rgba(585b70aa)",
		angle = 45,
	},
	latte = {
		active = { "rgba(1e66f5ee)", "rgba(df8e1dee)" },
		inactive = "rgba(9ca0b0aa)",
		angle = 45,
	},
}

local function read_theme()
	local conf = os.getenv("XDG_CONFIG_HOME")
	if conf == nil or conf == "" then
		conf = (os.getenv("HOME") or "") .. "/.config"
	end
	local ok, line = pcall(function()
		local f = io.open(conf .. "/theme", "r")
		if not f then
			return nil
		end
		local v = f:read("*l")
		f:close()
		return v
	end)
	if ok and line ~= nil then
		line = line:gsub("%s+", "")
		if line == "latte" or line == "mocha" then
			return line
		end
	end
	return "mocha"
end

local name = read_theme()
local p = palettes[name] or palettes.mocha

hl.config({
	general = {
		col = {
			active_border = { colors = p.active, angle = p.angle },
			inactive_border = p.inactive,
		},
	},
})

-- Qt6.5+ built-in scheme (Qt5 uses qt5ct palette instead)
if name == "latte" then
	hl.env("QT_QPA_COLOR_SCHEME", "light")
else
	hl.env("QT_QPA_COLOR_SCHEME", "dark")
end
