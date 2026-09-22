#!/usr/bin/env bash
# theme-toggle.sh — flip mocha <-> latte globally
# Writes: ~/.config/theme, colors/current.css symlink, gtk-3.0/4.0 settings,
#         foot/foot.ini [colors]; reloads hyprland + waybar.
# Every side effect degrades silently if the target is missing.

set -u

CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

LOCK="$CONF/.theme-toggle.lock"
exec 9>"$LOCK" 2>/dev/null || true
if command -v flock >/dev/null 2>&1; then
	flock 9 || true
fi

current=$(cat "$CONF/theme" 2>/dev/null || echo mocha)
current=$(printf '%s' "$current" | tr -d '[:space:]')
case "$current" in
latte) next=mocha ;;
*) next=latte ;;
esac

# --- 1. state file (atomic) ---
tmp_state=$(mktemp "$CONF/.theme.XXXXXX" 2>/dev/null || echo "$CONF/.theme.tmp.$$")
printf '%s\n' "$next" >"$tmp_state" && mv -f "$tmp_state" "$CONF/theme"

# --- 2. palette symlink ---
if [ -d "$CONF/colors" ] && [ -f "$CONF/colors/$next.css" ]; then
	ln -sfn "$next.css" "$CONF/colors/current.css" 2>/dev/null || true
fi

# --- 3. GTK settings.ini (gtk-3.0 / gtk-4.0) ---
if [ "$next" = latte ]; then
	dark=0
	color_scheme=prefer-light
else
	dark=1
	color_scheme=prefer-dark
fi

for d in gtk-3.0 gtk-4.0; do
	f="$CONF/$d/settings.ini"
	[ -f "$f" ] || continue
	if grep -q '^gtk-application-prefer-dark-theme=' "$f" 2>/dev/null; then
		sed -i.bak -E "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$dark/" "$f" 2>/dev/null \
			&& rm -f "$f.bak"
	else
		printf 'gtk-application-prefer-dark-theme=%s\n' "$dark" >>"$f"
	fi
done

# --- 4. gsettings color-scheme (optional, needs DBUS session) ---
if command -v gsettings >/dev/null 2>&1; then
	gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" 2>/dev/null || true
fi

# --- 5. foot [colors] section rebuilt from colors/$next.css ---
foot_file="$CONF/foot/foot.ini"
palette="$CONF/colors/$next.css"
if [ -f "$foot_file" ] && [ -f "$palette" ]; then
	get() {
		awk -v n="$1" '
			$1 == "@define-color" && $2 == n {
				v = $3; gsub(/;/, "", v); sub(/^#/, "", v); print v; exit
			}
		' "$palette"
	}
	bg=$(get base)
	fg=$(get text)
	r0=$(get surface1)
	r1=$(get red)
	r2=$(get green)
	r3=$(get yellow)
	r4=$(get blue)
	r5=$(get pink)
	r6=$(get teal)
	r7=$(get subtext1)
	b0=$(get surface2)
	b7=$(get subtext0)

	if [ -n "$bg" ] && [ -n "$fg" ]; then
		line_no=$(grep -n '^\[colors\]' "$foot_file" 2>/dev/null | head -1 | cut -d: -f1)
		if [ -n "$line_no" ]; then
			foot_tmp=$(mktemp "$CONF/foot/.foot.XXXXXX" 2>/dev/null || echo "$foot_file.tmp.$$")
			if head -n "$((line_no - 1))" "$foot_file" >"$foot_tmp" 2>/dev/null; then
				{
					echo "[colors]"
					echo "background=$bg"
					echo "foreground=$fg"
					echo "regular0=$r0"
					echo "regular1=$r1"
					echo "regular2=$r2"
					echo "regular3=$r3"
					echo "regular4=$r4"
					echo "regular5=$r5"
					echo "regular6=$r6"
					echo "regular7=$r7"
					echo "bright0=$b0"
					echo "bright1=$r1"
					echo "bright2=$r2"
					echo "bright3=$r3"
					echo "bright4=$r4"
					echo "bright5=$r5"
					echo "bright6=$r6"
					echo "bright7=$b7"
				} >>"$foot_tmp" && mv -f "$foot_tmp" "$foot_file"
			else
				rm -f "$foot_tmp" 2>/dev/null || true
			fi
		fi
	fi
fi

# --- 6. qt5ct / qt6ct palette path ---
for qt in qt5ct qt6ct; do
	qt_conf="$CONF/$qt/$qt.conf"
	[ -f "$qt_conf" ] || continue
	scheme="\$HOME/.config/$qt/colors/$next.conf"
	if grep -q '^color_scheme_path=' "$qt_conf" 2>/dev/null; then
		sed -i.bak -E "s|^color_scheme_path=.*|color_scheme_path=$scheme|" "$qt_conf" 2>/dev/null \
			&& rm -f "$qt_conf.bak"
	else
		printf 'color_scheme_path=%s\n' "$scheme" >>"$qt_conf"
	fi
	if grep -q '^custom_palette=' "$qt_conf" 2>/dev/null; then
		sed -i.bak -E 's/^custom_palette=.*/custom_palette=true/' "$qt_conf" 2>/dev/null \
			&& rm -f "$qt_conf.bak"
	else
		printf 'custom_palette=true\n' >>"$qt_conf"
	fi
done

# --- 7. hyprland reload (theme.lua re-reads state) ---
if command -v hyprctl >/dev/null 2>&1; then
	hyprctl reload >/dev/null 2>&1 || true
	# Qt6.5+ built-in fallback (theme.lua also sets this on reload)
	if [ "$next" = latte ]; then
		qs=light
	else
		qs=dark
	fi
	hyprctl setenv QT_QPA_COLOR_SCHEME "$qs" >/dev/null 2>&1 || true
fi

# --- 8. waybar style reload (SIGUSR2); walker/hyprlock reload CSS on next open ---
if command -v pkill >/dev/null 2>&1; then
	pkill -USR2 waybar 2>/dev/null || true
	pkill -x walker 2>/dev/null || true
fi
# hyprlock picks colors on next lock; no need to kill a running lock screen

# --- 9. optional notification ---
if command -v notify-send >/dev/null 2>&1; then
	notify-send -u low "主题" "已切换到 $next" 2>/dev/null || true
fi

printf 'theme -> %s\n' "$next"
