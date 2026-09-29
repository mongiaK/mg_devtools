#!/usr/bin/env bash
# wlogout 没装时的备用电源菜单，用 bemenu（Catppuccin Mocha 配色）弹出选项
set -euo pipefail

choice=$(printf '  锁屏\n  睡眠\n  重启\n  关机\n  登出' | bemenu -i -p "电源" \
  --tb "#1e1e2e" --tf "#cdd6f4" \
  --fb "#1e1e2e" --ff "#cdd6f4" \
  --nb "#1e1e2e" --nf "#a6adc8" \
  --hb "#cba6f7" --hf "#1e1e2e" \
  --sb "#cba6f7" --sf "#1e1e2e" \
  --fn "JetBrainsMono Nerd Font 12")

case "$choice" in
  *锁屏) exec loginctl lock-session ;;
  *睡眠) exec systemctl suspend ;;
  *重启) exec systemctl reboot ;;
  *关机) exec systemctl poweroff ;;
  *登出) exec hyprctl dispatch exit ;;
esac
