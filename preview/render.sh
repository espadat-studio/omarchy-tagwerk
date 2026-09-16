#!/usr/bin/env bash
#
# Re-renders preview.png from BarWidget.qml.
#
#   preview/render.sh [theme] [out]
#
# Runs a throwaway Quickshell instance under a scratch HOME, so the theme
# applies to this render alone and the live bar is untouched. Needs a running
# Wayland compositor: grabToImage captures a real window.
set -euo pipefail

theme=${1:-flexoki-light}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out=${2:-$here/../preview.png}

shell_src=${OMARCHY_SHELL:-/usr/share/omarchy/shell}
theme_dir=${OMARCHY_THEMES:-/usr/share/omarchy/themes}/$theme

[[ -d $shell_src/Commons ]] || { echo "no Omarchy shell at $shell_src" >&2; exit 1; }
[[ -d $theme_dir ]] || { echo "no theme at $theme_dir" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Imported, not vendored: qs.Commons and qs.Ui resolve to the installed shell,
# so the card cannot drift from the Omarchy the widget actually runs under.
ln -s "$shell_src/Commons" "$work/Commons"
ln -s "$shell_src/Ui" "$work/Ui"
cp "$here/shell.qml" "$work/shell.qml"
cp "$here/../BarWidget.qml" "$work/TagwerkMeter.qml"

mkdir -p "$work/home/.local/state/omarchy/current" "$work/bin"
ln -s "$theme_dir" "$work/home/.local/state/omarchy/current/theme"

# A tagwerk that fails leaves apply() short of the minute properties, so the
# values declared per state in shell.qml survive. No fixture ledger needed.
printf '#!/bin/sh\nexit 1\n' >"$work/bin/tagwerk"
chmod +x "$work/bin/tagwerk"

HOME=$work/home PATH=$work/bin:$PATH PREVIEW_OUT=$out \
  quickshell -p "$work/shell.qml"

echo "wrote $out"
