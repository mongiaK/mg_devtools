#!/usr/bin/env bash
# waybar custom/cpu — usage via /proc/stat delta, load, temp (Intel pkg + AMD Tctl/Tdie)

set -u

read_cpu() {
	awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat
}

set -- $(read_cpu)
t1=${1:-0}
i1=${2:-0}
sleep 0.3
set -- $(read_cpu)
t2=${1:-0}
i2=${2:-0}

dt=$((t2 - t1))
di=$((i2 - i1))
if [ "$dt" -gt 0 ]; then
	CPU=$((100 * (dt - di) / dt))
else
	CPU=0
fi
if [ "$CPU" -lt 0 ]; then CPU=0; fi
if [ "$CPU" -gt 100 ]; then CPU=100; fi

LOAD=$(awk '{printf "%s %s %s", $1, $2, $3}' /proc/loadavg 2>/dev/null || echo "N/A")

TEMP="N/A"
if command -v sensors >/dev/null 2>&1; then
	TEMP=$(sensors 2>/dev/null | awk '
		/Package id 0:/ {
			v = $4; gsub(/[+°C]/, "", v)
			if (v != "" && v != "*") { print v; exit }
		}
		/Tctl:/ || /Tdie:/ {
			v = $2; gsub(/[+°C]/, "", v)
			if (v != "" && v != "*") { print v; exit }
		}
	')
fi
[ -z "$TEMP" ] && TEMP="N/A"

if [ "$CPU" -ge 80 ]; then
	CLASS="critical"
elif [ "$CPU" -ge 60 ]; then
	CLASS="warning"
else
	CLASS="normal"
fi

printf '{"text":"󰻠  %s%%","tooltip":"CPU\\n󰻠 使用率：%s%%\\n󰅐 温度：%s°C\\n󰓅 Load：%s","class":"%s"}\n' \
	"$CPU" "$CPU" "$TEMP" "$LOAD" "$CLASS"
