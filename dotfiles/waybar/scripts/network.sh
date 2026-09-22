#!/usr/bin/env bash
# waybar custom/network — iface via default route, wifi/eth/offline, bandwidth delta

set -u

human_rate() {
	awk -v b="$1" 'BEGIN {
		if (b >= 1073741824) printf "%.2f GiB/s", b / 1073741824
		else if (b >= 1048576) printf "%.1f MiB/s", b / 1048576
		else if (b >= 1024) printf "%.0f KiB/s", b / 1024
		else printf "%d B/s", b
	}'
}

json_escape() {
	printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

IFACE=$(ip -o route show default 2>/dev/null | awk '{for(i=1;i<NF;i++) if($i=="dev"){print $(i+1); exit}}')

if [ -z "$IFACE" ]; then
	printf '{"text":"󰖪  Offline","tooltip":"Network\\n󰖪 网络未连接","class":"disconnected"}\n'
	exit 0
fi

oper=$(cat "/sys/class/net/$IFACE/operstate" 2>/dev/null || echo down)
if [ "$oper" != "up" ] && [ "$oper" != "unknown" ]; then
	printf '{"text":"󰖪  Offline","tooltip":"Network\\n󰖪 网络未连接\\n󰒢 接口：%s","class":"disconnected"}\n' \
		"$(json_escape "$IFACE")"
	exit 0
fi

IP=$(ip -4 -o addr show "$IFACE" 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}')
[ -z "$IP" ] && IP="N/A"

# bandwidth: two snapshots of /proc/net/dev (fields: iface: bytes packets ... )
rx1=$(awk -v i="$IFACE:" '$1==i {print $2; exit}' /proc/net/dev 2>/dev/null || echo 0)
tx1=$(awk -v i="$IFACE:" '$1==i {print $10; exit}' /proc/net/dev 2>/dev/null || echo 0)
sleep 0.4
rx2=$(awk -v i="$IFACE:" '$1==i {print $2; exit}' /proc/net/dev 2>/dev/null || echo 0)
tx2=$(awk -v i="$IFACE:" '$1==i {print $10; exit}' /proc/net/dev 2>/dev/null || echo 0)

: "${rx1:=0}" "${tx1:=0}" "${rx2:=0}" "${tx2:=0}"
rxd=$((rx2 - rx1))
txd=$((tx2 - tx1))
[ "$rxd" -lt 0 ] && rxd=0
[ "$txd" -lt 0 ] && txd=0
# bytes over 0.4s → per second
rxd=$((rxd * 10 / 4))
txd=$((txd * 10 / 4))

DOWN=$(human_rate "$rxd")
UP=$(human_rate "$txd")

if [ -d "/sys/class/net/$IFACE/wireless" ]; then
	SSID=$(iw dev "$IFACE" link 2>/dev/null | awk -F': ' '/SSID/{print $2; exit}')
	[ -z "$SSID" ] && SSID="N/A"

	SIGNAL=$(awk -v iface="$IFACE" '
		$0 ~ iface":" {
			q = $3; gsub(/\./, "", q)
			if (q != "") { print int(q * 100 / 70); exit }
		}
	' /proc/net/wireless 2>/dev/null)
	[ -z "$SIGNAL" ] && SIGNAL=0
	if [ "$SIGNAL" -gt 100 ]; then SIGNAL=100; fi

	TEXT="󰖩  ${SSID}"
	TIP="Wi-Fi\\n󰖩 SSID：$(json_escape "$SSID")\\n󰤨 信号：${SIGNAL}%\\n󰩟 IP：${IP}\\n󰒢 接口：${IFACE}\\n󰇚 下载：${DOWN}\\n󰕒 上传：${UP}"
	CLASS="online"
else
	TEXT="󰈀  ${IP}"
	TIP="Ethernet\\n󰩟 IP：${IP}\\n󰒢 接口：${IFACE}\\n󰇚 下载：${DOWN}\\n󰕒 上传：${UP}"
	CLASS="online"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
	"$(json_escape "$TEXT")" "$TIP" "$CLASS"
