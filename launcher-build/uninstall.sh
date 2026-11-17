#!/bin/sh
# Vela launcher games, test build: puts the Vela 0.8.22 files back.
# Set every launcher game to Off in the Vela panel first: stock 0.8.22 does not know these games and cannot undo them.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
PLUGIN=${VELA_PLUGIN_DIR:-$HOME/homebrew/plugins/upscale}
BACKUP=${VELA_BACKUP_DIR:-$HOME/vela-backup-launcher-games}
die() { echo "vela-launcher-games: $*" >&2; exit 1; }

[ -d "$BACKUP" ] || die "no backup in $BACKUP: reinstall Vela 0.8.22 from the main repository instead"
[ -w "$PLUGIN/main.py" ] || die "no write access to $PLUGIN"
while read -r want_base want_new rel; do
  [ -n "$rel" ] || continue
  if [ -f "$BACKUP/$rel" ]; then
    cp -p "$BACKUP/$rel" "$PLUGIN/$rel.vela-old"
    mv -f "$PLUGIN/$rel.vela-old" "$PLUGIN/$rel"
  elif [ "$want_base" = "new" ]; then
    mv -f "$PLUGIN/$rel" "$BACKUP/removed-$(basename "$rel")"
  fi
done < "$HERE/MANIFEST"
echo "Vela 0.8.22 files are back. Reload Vela (Decky -> Plugins -> Vela -> Reload) or restart the handheld."
