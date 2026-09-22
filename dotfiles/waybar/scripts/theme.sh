#!/usr/bin/env bash
# waybar custom/theme — show current theme icon (moon = mocha/dark, sun = latte/light)

set -u

CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE=$(cat "$CONF/theme" 2>/dev/null || echo mocha)
STATE=$(printf '%s' "$STATE" | tr -d '[:space:]')

case "$STATE" in
latte)
	ICON="󰌽"
	CLASS="latte"
	TIP="当前：Latte 浅色\n点击切换 Mocha 深色"
	;;
*)
	ICON="󰆹"
	CLASS="mocha"
	TIP="当前：Mocha 深色\n点击切换 Latte 浅色"
	;;
esac

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$ICON" "$TIP" "$CLASS"
