#!/usr/bin/env bash
# waybar custom/memory — /proc/meminfo based JSON module

set -u

MEM_TOTAL_KB=0
MEM_AVAIL_KB=0
SWAP_TOTAL_KB=0
SWAP_FREE_KB=0

while IFS=': ' read -r key val _; do
	val=${val%% *}
	case "$key" in
	MemTotal) MEM_TOTAL_KB=$val ;;
	MemAvailable) MEM_AVAIL_KB=$val ;;
	SwapTotal) SWAP_TOTAL_KB=$val ;;
	SwapFree) SWAP_FREE_KB=$val ;;
	esac
done </proc/meminfo

if [ "$MEM_TOTAL_KB" -le 0 ]; then
	printf '{"text":"󰍛  N/A","tooltip":"Memory\\n无法读取 /proc/meminfo","class":"critical"}\n'
	exit 0
fi

MEM_USED_KB=$((MEM_TOTAL_KB - MEM_AVAIL_KB))
[ "$MEM_USED_KB" -lt 0 ] && MEM_USED_KB=0
PCT=$((100 * MEM_USED_KB / MEM_TOTAL_KB))

TOTAL_GIB=$(awk -v k="$MEM_TOTAL_KB" 'BEGIN{printf "%.1f", k/1024/1024}')
USED_GIB=$(awk -v k="$MEM_USED_KB" 'BEGIN{printf "%.1f", k/1024/1024}')
AVAIL_GIB=$(awk -v k="$MEM_AVAIL_KB" 'BEGIN{printf "%.1f", k/1024/1024}')

SWAP_LINE=""
if [ "$SWAP_TOTAL_KB" -gt 0 ]; then
	SWAP_USED_KB=$((SWAP_TOTAL_KB - SWAP_FREE_KB))
	[ "$SWAP_USED_KB" -lt 0 ] && SWAP_USED_KB=0
	SWAP_PCT=$((100 * SWAP_USED_KB / SWAP_TOTAL_KB))
	SWAP_TOTAL_G=$(awk -v k="$SWAP_TOTAL_KB" 'BEGIN{printf "%.1f", k/1024/1024}')
	SWAP_USED_G=$(awk -v k="$SWAP_USED_KB" 'BEGIN{printf "%.1f", k/1024/1024}')
	SWAP_LINE="\\n󰆠 Swap：${SWAP_USED_G} / ${SWAP_TOTAL_G} GiB（${SWAP_PCT}%）"
fi

if [ "$PCT" -ge 85 ]; then
	CLASS="critical"
elif [ "$PCT" -ge 70 ]; then
	CLASS="warning"
else
	CLASS="normal"
fi

printf '{"text":"󰍛  %s%%","tooltip":"Memory\\n󰍛 使用率：%s%%\\n󰋊 已使用：%s GiB\\n󰋊 总计：%s GiB\\n󰋊 可用：%s GiB%s","class":"%s"}\n' \
	"$PCT" "$PCT" "$USED_GIB" "$TOTAL_GIB" "$AVAIL_GIB" "$SWAP_LINE" "$CLASS"
