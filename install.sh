#!/usr/bin/env bash
# Install the Swamp Club theme for Ghostty.
#
#   curl -fsSL https://raw.githubusercontent.com/sntxrr/ghostty-swamp-club/main/install.sh | bash
#
# What it does, in order:
#   1. writes the theme to ~/.config/ghostty/themes/swamp-club
#      (the only place Ghostty looks for user themes, on every OS)
#   2. finds the config file Ghostty actually reads, backs it up, and sets
#      `theme = swamp-club` (replacing an existing `theme =` line if there is one)
#   3. runs `ghostty +validate-config` when the CLI is on PATH
#
# Ghostty 1.2.3+ looks for `config.ghostty` and `config`, in that order, and
# loads both when both exist. Releases before 1.2.3 only look for `config`.
# So the file edited here is the first of those that exists, and a file is
# only created when neither exists.
#
# Flags:  --dry-run        show what would change, write nothing
#         --config PATH    use this config file instead of auto-detecting
#         --theme-only     install the theme file, leave your config alone
set -euo pipefail

THEME_URL="https://raw.githubusercontent.com/sntxrr/ghostty-swamp-club/main/themes/swamp-club"
XDG="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_DIR="$XDG/ghostty/themes"
MAC_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
CONFIG=""
DRY_RUN=0
THEME_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)    DRY_RUN=1 ;;
        --theme-only) THEME_ONLY=1 ;;
        --config)     CONFIG="$2"; shift ;;
        -h|--help)    sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "unknown flag: $1" >&2; exit 2 ;;
    esac
    shift
done

# Prefer a local copy when run from a clone; otherwise fetch from GitHub.
here=""
if here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"; then :; else here=""; fi
if [ -n "$here" ] && [ -f "$here/themes/swamp-club" ]; then
    theme="$(cat "$here/themes/swamp-club")"
else
    theme="$(curl -fsSL "$THEME_URL")"
fi
[ -n "$theme" ] || { echo "error: theme file is empty" >&2; exit 1; }

# Every config file Ghostty reads, most specific first. macOS also reads the
# XDG paths, but loads the Application Support ones afterwards, so they win.
candidates=()
if [ "$(uname -s)" = "Darwin" ]; then
    candidates+=("$MAC_CONFIG_DIR/config.ghostty" "$MAC_CONFIG_DIR/config")
fi
candidates+=("$XDG/ghostty/config.ghostty" "$XDG/ghostty/config")

# `config.ghostty` only exists from Ghostty 1.2.3 on. When nothing is found we
# have to invent a filename, so use the one the installed Ghostty will read.
reads_config_ghostty() {
    local version
    command -v ghostty >/dev/null 2>&1 || return 0  # not installed: assume current
    version="$(ghostty +version 2>/dev/null | sed -n 's/^Ghostty \([0-9][0-9.]*\).*/\1/p' | head -1)"
    [ -n "$version" ] || return 0
    awk -v have="$version" 'BEGIN {
        split("1.2.3", want, "."); split(have, got, ".")
        for (i = 1; i <= 3; i++) {
            if ((got[i] + 0) > want[i]) exit 0
            if ((got[i] + 0) < want[i]) exit 1
        }
        exit 0
    }'
}

if [ -z "$CONFIG" ]; then
    for c in "${candidates[@]}"; do
        if [ -f "$c" ]; then CONFIG="$c"; break; fi
    done
fi
if [ -z "$CONFIG" ]; then
    if reads_config_ghostty; then
        CONFIG="$XDG/ghostty/config.ghostty"
    else
        CONFIG="$XDG/ghostty/config"
    fi
fi

# Both names are read when both exist; say so when only one was edited.
note_other_configs() {
    local other
    for other in "${candidates[@]}"; do
        [ "$other" = "$CONFIG" ] && continue
        [ -f "$other" ] || continue
        echo "note   Ghostty also reads $other; the theme went to the file that wins"
    done
}

if [ "$DRY_RUN" = 1 ]; then
    echo "--- dry run ---"
    echo "would write  $THEME_DIR/swamp-club"
    if [ "$THEME_ONLY" = 0 ]; then
        echo "would edit   $CONFIG"
        if [ -f "$CONFIG" ] && grep -Eq '^[[:space:]]*theme[[:space:]]*=' "$CONFIG"; then
            echo "  replacing:  $(grep -E '^[[:space:]]*theme[[:space:]]*=' "$CONFIG" | head -1)"
        else
            echo "  appending:  theme = swamp-club"
        fi
        note_other_configs
    fi
    exit 0
fi

mkdir -p "$THEME_DIR"
printf '%s\n' "$theme" > "$THEME_DIR/swamp-club"
echo "wrote  $THEME_DIR/swamp-club"

if [ "$THEME_ONLY" = 0 ]; then
    mkdir -p "$(dirname "$CONFIG")"
    [ -f "$CONFIG" ] || : > "$CONFIG"
    backup="$CONFIG.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG" "$backup"
    if grep -Eq '^[[:space:]]*theme[[:space:]]*=' "$CONFIG"; then
        # Replace the first live `theme =` line in place; drop any later duplicates.
        awk 'BEGIN{done=0}
             /^[[:space:]]*theme[[:space:]]*=/ { if (!done) { print "theme = swamp-club"; done=1 }; next }
             { print }' "$backup" > "$CONFIG"
    else
        printf '\n# Swamp Club -- https://github.com/sntxrr/ghostty-swamp-club\ntheme = swamp-club\n' >> "$CONFIG"
    fi
    echo "wrote  $CONFIG  (theme = swamp-club)"
    echo "backup $backup"
    note_other_configs
fi

if command -v ghostty >/dev/null 2>&1; then
    if ghostty +validate-config >/dev/null 2>&1; then
        echo "valid  ghostty +validate-config passed"
    else
        echo "warn   ghostty +validate-config reported a problem:" >&2
        ghostty +validate-config >&2 || true
    fi
fi

echo
echo "Reload Ghostty to apply:  Cmd+Shift+,  on macOS   /   Ctrl+Shift+,  elsewhere"
