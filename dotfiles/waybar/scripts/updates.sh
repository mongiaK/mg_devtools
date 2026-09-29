#!/usr/bin/env bash
# 统计 pacman（以及 yay/paru 能看到的 AUR）可更新的包数，
# 输出 waybar custom 模块要的 JSON：{"text":..,"tooltip":..,"class":..}
set -euo pipefail

official=""
aur=""

if command -v checkupdates >/dev/null 2>&1; then
  # checkupdates 来自 pacman-contrib，不会碰正在用的数据库锁
  official="$(checkupdates 2>/dev/null || true)"
fi

if command -v yay >/dev/null 2>&1; then
  aur="$(yay -Qua 2>/dev/null || true)"
elif command -v paru >/dev/null 2>&1; then
  aur="$(paru -Qua 2>/dev/null || true)"
fi

all="$(printf '%s\n%s\n' "$official" "$aur" | sed '/^$/d')"
count="$(printf '%s\n' "$all" | sed '/^$/d' | wc -l)"

if [ "$count" -eq 0 ]; then
  printf '{"text":"0","tooltip":"系统已是最新","class":"up-to-date"}\n'
  exit 0
fi

# 悬浮提示最多列 12 行，包名和新版本号，多余的折叠成一行提示
tooltip_lines="$(printf '%s\n' "$all" | awk '{print $1"  →  "$4}' | head -n 12)"
more=$((count - 12))
if [ "$more" -gt 0 ]; then
  tooltip_lines="${tooltip_lines}
… 还有 ${more} 个"
fi

# JSON 转义换行和引号
tooltip_json="$(printf '%s' "$tooltip_lines" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g')"

printf '{"text":"%s","tooltip":"%s","class":"pending"}\n' "$count" "$tooltip_json"
