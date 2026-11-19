#!/bin/sh
# Vela launcher games, test build: puts the changed plugin files over an installed Vela 0.8.22.
# Install Vela 0.8.22 from https://github.com/zrprod9-cmyk/vela/releases first; this adds nothing else.
# Usage: sh install.sh        (VELA_PLUGIN_DIR=<folder> for a plugin folder elsewhere)
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
PLUGIN=${VELA_PLUGIN_DIR:-$HOME/homebrew/plugins/upscale}
BACKUP=${VELA_BACKUP_DIR:-$HOME/vela-backup-launcher-games}
BASE=0.8.22

sum() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
die() { echo "vela-launcher-games: $*" >&2; exit 1; }

[ -f "$PLUGIN/package.json" ] || die "Vela is not installed in $PLUGIN: install Vela $BASE from the main repository first"
grep -q "\"version\": *\"$BASE\"" "$PLUGIN/package.json" || die "the installed Vela is not $BASE: this build is made for $BASE only"
[ -w "$PLUGIN/main.py" ] || die "no write access to $PLUGIN: run this as the user who owns it (or with sudo)"

# every file must be the stock one of the base version, already this build's (running it twice is fine), or an earlier
# launcher-games build's: then its stock file is in the backup (a file that build added has none and the backup exists)
earlier() {
  if [ "$2" = "new" ]; then [ -d "$BACKUP" ]; else [ -f "$BACKUP/$1" ] && [ "$(sum "$BACKUP/$1")" = "$2" ]; fi
}
while read -r want_base want_new rel; do
  [ -n "$rel" ] || continue
  if [ -f "$PLUGIN/$rel" ]; then
    have=$(sum "$PLUGIN/$rel")
    [ "$have" = "$want_new" ] || [ "$want_base" = "-" ] || [ "$have" = "$want_base" ] || earlier "$rel" "$want_base" || \
      die "$rel is neither Vela $BASE's nor a launcher-games build's: nothing was changed"
  else
    [ "$want_base" = "new" ] || die "$rel is missing in $PLUGIN: nothing was changed"
  fi
done < "$HERE/MANIFEST"

# the stock files are kept once: a file an earlier build already replaced has its stock copy there; a file only this
# build changes is added (an existing backup never gets the panel bundle or a file with no stock version)
FIRST=1
[ -d "$BACKUP" ] && FIRST=0
mkdir -p "$BACKUP"
while read -r want_base want_new rel; do
  [ -n "$rel" ] || continue
  [ -f "$PLUGIN/$rel" ] && [ ! -f "$BACKUP/$rel" ] || continue
  have=$(sum "$PLUGIN/$rel")
  if [ "$have" = "$want_base" ] || { [ "$FIRST" = 1 ] && [ "$have" != "$want_new" ]; }; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -p "$PLUGIN/$rel" "$BACKUP/$rel"
  fi
done < "$HERE/MANIFEST"
echo "the original files are kept in $BACKUP"

while read -r want_base want_new rel; do
  [ -n "$rel" ] || continue
  mkdir -p "$PLUGIN/$(dirname "$rel")"
  cp "$HERE/files/$rel" "$PLUGIN/$rel.vela-new"
  [ "$rel" = "main.py" ] && chmod 755 "$PLUGIN/$rel.vela-new"
  mv -f "$PLUGIN/$rel.vela-new" "$PLUGIN/$rel"
done < "$HERE/MANIFEST"

echo "Vela launcher games: installed over Vela $BASE."
echo "Now reload Vela: Quick Access -> Decky -> gear -> Plugins -> Vela -> Reload (or restart the handheld)."
