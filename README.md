# Vela for launcher games (armadaOS)

A fork of [**Vela**](https://github.com/zrprod9-cmyk/vela), the Decky plugin that replaces a game's upscaler with FSR 4 on
the handheld's NPU. This fork adds one thing: **Vela for non-Steam shortcuts made by a launcher** such as Heroic, Xodus
Nexus, or a store client running in a Proton prefix. Official Vela 0.8.22 reports those as "a Linux game".

This page lists only what is different here. For everything else (devices, models, the NPU part, usage, FAQ, reporting
problems) read the [upstream README](https://github.com/zrprod9-cmyk/vela#readme).

> [!NOTE]
> A test build. The changes are proposed upstream in [#3](https://github.com/zrprod9-cmyk/vela/pull/3),
> [#4](https://github.com/zrprod9-cmyk/vela/pull/4) and [#5](https://github.com/zrprod9-cmyk/vela/pull/5); once they are
> merged there, use the official release and ignore this fork.

## Install

1. Install **Vela 0.8.22** from the [main repository](https://github.com/zrprod9-cmyk/vela/releases/tag/v0.8.22), and its
   NPU part if you want FSR 4 on the NPU, exactly as [upstream's Install section](https://github.com/zrprod9-cmyk/vela#install)
   says. This fork ships no plugin zip and no NPU part of its own.
2. **Added step.** In Desktop mode, open Konsole and run:

   ```sh
   curl -fsSL https://github.com/indiesaudi/vela-armada/releases/download/v0.8.22-launcher-games/vela-launcher-games-0.8.22.tar.gz | tar xz -C /tmp && sh /tmp/vela-launcher-games/install.sh
   ```

   This puts seven changed plugin files (85 KB) over the installed Vela. It first checks that the installed Vela is a
   stock 0.8.22 and changes nothing if it is not. The original files are kept in `~/vela-backup-launcher-games`.
3. **Added step.** Reload Vela: Quick Access → Decky → gear → Plugins → Vela → **Reload**, or restart the handheld.

## Usage

Steam games, and shortcuts that point straight at a game's exe, work as upstream describes. For a launcher's game:

1. **Start the game once from its Steam shortcut and open Vela while it runs.** Vela reads where the game is from the
   running game; until then the panel says it has not seen a Windows game run from this shortcut.
2. Pick a model. The panel names the game folder it found. For a Heroic game, check it is the right game before picking.
3. Restart the game once, as with any game Vela is turned on for.

What to expect:

- **Start launcher games from Steam with the launcher closed.** If the launcher is already open, Vela's settings do not
  reach the game and the panel says so.
- **Vela's files go into the game's folder** for these games and are removed on **Off**. Upstream's "game folder is
  never touched" holds for Steam games only: a launcher's game cannot be reached the other way.
- **The launcher's own shortcut** (the one that opens Heroic or Nexus itself) is reported as a launcher: use each game's
  own shortcut.
- **32-bit games** are reported as not supported.
- **Unreal games** are switched to DirectX 12 through the game's own `Engine.ini` while Vela is on.

## Removal

Set every launcher game to **Off** in the panel first. Then run `sh /tmp/vela-launcher-games/uninstall.sh` (run the
install command's download again if `/tmp` was cleared) and reload Vela. Installing a newer official Vela also replaces
this build.

## Tested

One Snapdragon 8 Elite handheld on armadaOS 20261109, with Xodus Nexus, Heroic and Ubisoft Connect (NonSteamLaunchers):
Hi-Fi RUSH (Nexus) and Ghostrunner (Heroic) running FSR 4 on the NPU, eleven launcher games recognised, **Off**
restoring game folders exactly.

Not tested: Snapdragon 8 Gen 2 devices, flatpak or AppImage builds of Heroic, Lutris, Bottles, a launcher's
verify/repair or a game update with Vela on. The install script was tested on a copy of a 0.8.22 plugin folder, not yet
on a handheld. Details are in the pull requests.

## Source and licence

The three feature branches are [`launcher-games`](https://github.com/indiesaudi/vela-armada/tree/launcher-games),
[`launcher-live-settings`](https://github.com/indiesaudi/vela-armada/tree/launcher-live-settings) and
[`launcher-dx12`](https://github.com/indiesaudi/vela-armada/tree/launcher-dx12). The add-on is packed from them by
[`launcher-build/make_overlay.py`](launcher-build/make_overlay.py). GPL-3.0-only, like the plugin; see
[LICENSING.md](LICENSING.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), unchanged from upstream.

Problems with launcher games: comment on [pull request #3](https://github.com/zrprod9-cmyk/vela/pull/3). Anything else
belongs [upstream](https://github.com/zrprod9-cmyk/vela/issues).
