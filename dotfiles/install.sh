#!/usr/bin/env bash
# install.sh — deploy this dotfiles repo
#   1) packages from pkgs.list (pacman + yay/paru)
#   2) symlink repo root -> ~/.config
#   3) copy greetd/* -> /etc/greetd (root)
#
# Usage:
#   ./install.sh                # full install
#   ./install.sh --skip-packages
#   ./install.sh --skip-greetd
#   ./install.sh --dry-run

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
GREETD_SRC="$REPO_DIR/greetd"
GREETD_DST="/etc/greetd"

SKIP_PACKAGES=0
SKIP_GREETD=0
DRY_RUN=0

for arg in "$@"; do
	case "$arg" in
	--skip-packages) SKIP_PACKAGES=1 ;;
	--skip-greetd) SKIP_GREETD=1 ;;
	--dry-run) DRY_RUN=1 ;;
	-h | --help)
		sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*)
		echo "unknown option: $arg" >&2
		exit 2
		;;
	esac
done

log() { printf '[install] %s\n' "$*"; }
run() {
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '[dry-run] %s\n' "$*"
	else
		"$@"
	fi
}

# ---------------------------------------------------------------
# 1. packages
# ---------------------------------------------------------------
install_packages() {
	if [ "$SKIP_PACKAGES" -eq 1 ]; then
		log "skip packages"
		return 0
	fi
	if [ ! -f "$REPO_DIR/pkgs.list" ]; then
		log "pkgs.list missing, skip packages"
		return 0
	fi

	# shellcheck source=/dev/null
	source "$REPO_DIR/pkgs.list"

	if [ "${#pkg[@]}" -gt 0 ]; then
		if command -v pacman >/dev/null 2>&1; then
			log "pacman -S --needed (${#pkg[@]} pkgs)"
			run sudo pacman -S --needed --noconfirm "${pkg[@]}"
		else
			log "pacman not found — skip official packages (not Arch?)"
		fi
	fi

	if [ "${#aur[@]}" -gt 0 ]; then
		local aur_helper=""
		if command -v yay >/dev/null 2>&1; then
			aur_helper=yay
		elif command -v paru >/dev/null 2>&1; then
			aur_helper=paru
		fi
		if [ -n "$aur_helper" ]; then
			log "$aur_helper -S --needed (${#aur[@]} aur)"
			run "$aur_helper" -S --needed --noconfirm "${aur[@]}"
		else
			log "no yay/paru — skip AUR: ${aur[*]}"
		fi
	fi
}

# ---------------------------------------------------------------
# 2. symlink repo -> ~/.config
# ---------------------------------------------------------------
link_config() {
	if [ -L "$TARGET_CONFIG" ]; then
		local cur
		cur=$(readlink "$TARGET_CONFIG")
		if [ "$cur" = "$REPO_DIR" ]; then
			log "~/.config already -> $REPO_DIR"
			return 0
		fi
		log "replace symlink ~/.config ($cur) -> $REPO_DIR"
		run ln -sfn "$REPO_DIR" "$TARGET_CONFIG"
		return 0
	fi

	if [ -d "$TARGET_CONFIG" ]; then
		local bak="$TARGET_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
		log "~/.config is a directory — move to $bak"
		run mv "$TARGET_CONFIG" "$bak"
	elif [ -e "$TARGET_CONFIG" ]; then
		local bak="$TARGET_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
		log "~/.config exists (not dir) — move to $bak"
		run mv "$TARGET_CONFIG" "$bak"
	fi

	log "ln -s $REPO_DIR $TARGET_CONFIG"
	run mkdir -p "$(dirname "$TARGET_CONFIG")"
	run ln -sfn "$REPO_DIR" "$TARGET_CONFIG"
}

# ---------------------------------------------------------------
# 3. required state files / exec bits (inside repo)
# ---------------------------------------------------------------
prepare_repo() {
	if [ ! -e "$REPO_DIR/colors/current.css" ]; then
		log "colors/current.css -> mocha.css"
		run ln -sfn mocha.css "$REPO_DIR/colors/current.css"
	fi
	if [ ! -f "$REPO_DIR/theme" ]; then
		log "create theme state (mocha)"
		if [ "$DRY_RUN" -eq 1 ]; then
			printf '[dry-run] echo mocha > %s\n' "$REPO_DIR/theme"
		else
			printf 'mocha\n' >"$REPO_DIR/theme"
		fi
	fi

	local f
	for f in \
		"$REPO_DIR/scripts/theme-toggle.sh" \
		"$REPO_DIR"/waybar/scripts/*.sh; do
		if [ -f "$f" ] && [ ! -x "$f" ]; then
			log "chmod +x ${f#"$REPO_DIR"/}"
			run chmod +x "$f"
		fi
	done
}

# ---------------------------------------------------------------
# 4. copy greetd -> /etc/greetd
# ---------------------------------------------------------------
copy_greetd() {
	if [ "$SKIP_GREETD" -eq 1 ]; then
		log "skip greetd"
		return 0
	fi
	if [ ! -d "$GREETD_SRC" ]; then
		log "greetd/ missing, skip"
		return 0
	fi
	if ! command -v pacman >/dev/null 2>&1 && [ ! -d "$GREETD_DST" ] && [ "$DRY_RUN" -eq 0 ]; then
		log "/etc/greetd not present and not Arch — skip (copy manually if needed)"
		return 0
	fi

	log "copy greetd -> $GREETD_DST"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '[dry-run] sudo mkdir -p %s && sudo cp -v %s/* %s/\n' "$GREETD_DST" "$GREETD_SRC" "$GREETD_DST"
		return 0
	fi
	sudo mkdir -p "$GREETD_DST"
	sudo cp -v "$GREETD_SRC"/* "$GREETD_DST"/
}

# ---------------------------------------------------------------

log "repo: $REPO_DIR"
log "target: $TARGET_CONFIG"

install_packages
link_config
prepare_repo
copy_greetd

log "done"
if [ "$DRY_RUN" -eq 0 ] && [ -L "$TARGET_CONFIG" ]; then
	log "deployed. re-login (or start Hyprland) to pick up env/autostart"
fi
