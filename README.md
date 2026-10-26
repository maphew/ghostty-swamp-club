# Swamp Club — a theme for [Ghostty](https://ghostty.org)

The [swamp-club.com](https://swamp-club.com) palette in your terminal: a
black canvas, neutral gray text, the site's green accent, a `#39ff14` neon
cursor and bright-green, and the cyan and magenta of the logo's glitch.

![Ghostty running the Swamp Club theme](screenshots/ghostty.png)

It pairs with a sidebar theme for the [herdr](https://herdr.dev) workspace
manager so the panes and the chrome around them share one palette:
[herdr-swamp-club](https://github.com/sntxrr/herdr-swamp-club).

## Install

### One line

```sh
curl -fsSL https://raw.githubusercontent.com/sntxrr/ghostty-swamp-club/main/install.sh | bash
```

That writes the theme to `~/.config/ghostty/themes/swamp-club`, backs up
your Ghostty config next to itself, and sets `theme = swamp-club` (replacing
an existing `theme =` line if you had one). Then reload Ghostty:
**`⌘⇧,`** on macOS, **`Ctrl+Shift+,`** elsewhere.

The config it edits is the first one Ghostty actually reads (see
[where the config lives](#where-the-config-lives)), so a distro that ships
`config.ghostty` — Bluefin, Bazzite and other Universal Blue images do — is
edited in place instead of growing a second config file.

Add `--dry-run` to see what it would touch, or `--theme-only` to install the
file and leave your config alone.

### By hand

1. Save [`themes/swamp-club`](themes/swamp-club) to `~/.config/ghostty/themes/swamp-club`:

   ```sh
   mkdir -p ~/.config/ghostty/themes
   curl -fsSL https://raw.githubusercontent.com/sntxrr/ghostty-swamp-club/main/themes/swamp-club \
        -o ~/.config/ghostty/themes/swamp-club
   ```

   This is the only directory Ghostty searches for user themes — on macOS
   too, even if your config lives in `~/Library/Application Support/com.mitchellh.ghostty/`.

2. Add one line to your Ghostty config (`config.ghostty` on 1.2.3+,
   `config` before that):

   ```
   theme = swamp-club
   ```

3. Reload: `⌘⇧,` on macOS, `Ctrl+Shift+,` elsewhere.

### Light and dark

Ghostty can pick a theme per system appearance. Swamp Club is dark-only, so
pair it with something light:

```
theme = light:Catppuccin Latte,dark:swamp-club
```

## Uninstall

Remove the `theme = swamp-club` line (or restore the backup the installer
wrote), delete `~/.config/ghostty/themes/swamp-club`, and reload.

## Where the config lives

Ghostty 1.2.3+ reads, in this order:

| platform | path |
|---|---|
| all | `$XDG_CONFIG_HOME/ghostty/config.ghostty` |
| all | `$XDG_CONFIG_HOME/ghostty/config` |
| macOS | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| macOS | `~/Library/Application Support/com.mitchellh.ghostty/config` |

`XDG_CONFIG_HOME` defaults to `~/.config`. Every file that exists is loaded,
not just the first, and a later file wins where they disagree. Releases before
1.2.3 only look for `config` — the rename to `config.ghostty` landed in 1.2.3,
which is why a distro-provided file may be named either way.

The installer edits the first of those that exists (printing a note when more
than one does), or creates `config.ghostty` — `config` when the installed
Ghostty is older than 1.2.3 — when none does. Pass `--config PATH` to override.

## Palette

![Swamp Club palette](screenshots/palette.svg)

| slot | normal | bright |
|---|---|---|
| black | `#1a1a1a` | `#6b7280` |
| red | `#ff003c` | `#f87171` |
| green | `#05df72` | **`#39ff14`** |
| yellow | `#fde047` | `#fef08a` |
| blue | `#60a5fa` | `#93c5fd` |
| magenta | `#e879f9` | `#f0abfc` |
| cyan | `#00d3f2` | `#67e8f9` |
| white | `#d1d5db` | `#ffffff` |

| | |
|---|---|
| background | `#080808` |
| foreground | `#d1d5db` |
| cursor | `#39ff14` on `#080808` |
| selection | `#d1d5db` on `#062e16` |
| split divider | `#06411e` |

Every color is taken from swamp-club.com as it renders, not guessed from a
screenshot:

- **Canvas and text** are the site's: `#080808` panels, `#d1d5db` body text,
  `#fff` headings. No green tint -- the site keeps its neutrals neutral and
  lets the neon do the work.
- **Green** (`#05df72`) is the site's accent text color (Tailwind v4
  green-400), the most-used color on the page after the grays.
- **Bright green** (`#39ff14`) is the site's glow, scanline and input-caret
  neon. It's in the bright slot on purpose: it's what `ls`, git and most
  prompts reach for to mark success, so the glow shows up in everyday output
  while the normal green stays readable in bulk. The cursor is the same neon,
  as it is in the site's input fields.
- **Cyan** (`#00d3f2`) is the logo and the event counter; **magenta**
  (`#e879f9`) is the site's default profile accent; **red** (`#ff003c`) is its
  neon glitch.
- **Selection and divider** are the site's green-500 borders at 20% and 30%,
  flattened onto the background.

The site sets its text in [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
(`font-family = JetBrains Mono` in your Ghostty config) if you want the full
look.

## Tweaks

A theme file is just a Ghostty config file, and anything you set in your own
config wins over the theme. The knob people ask about first:

- **Comments too dim / too loud?** Bright black (`palette = 8=…`) is what most
  tools use for dim text. Override it in your config:

  ```
  palette = 8=#9ca3af
  ```

  `#9ca3af` is the site's own muted-text gray.

## Notes

- Tested on Ghostty 1.3. Any 1.x release with the `theme` option should work.
- The palette is borrowed, with affection, from [swamp-club.com](https://swamp-club.com).
  This project is not affiliated with Swamp Club, Inc.
- MIT licensed.
