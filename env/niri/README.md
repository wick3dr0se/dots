<div align="center">
<h1>⚫ dots – Niri</h1>
<p>My minimalist Arch Linux dotfile configs for Niri</p>
<a href='#'><img src="https://img.shields.io/badge/Niri-dotfiles-_?style=flat-square&labelColor=232329&color=ffbc00&logo=wayland"/></a>
<a href='#'><img src="https://img.shields.io/badge/Maintained%3F-Yes-green.svg?style=flat-square&labelColor=232329&color=5277C3"></img></a>
<a href="https://opensourceforce.net/discord">
<img src="https://discordapp.com/api/guilds/913584348937207839/widget.png?style=shield"/></a>
</div>

---

![](/captures/niri.png)
![](/captures/firefox.png)
![](/captures/btop.png)
![](/captures/vscode.png)
![](/captures/vim.png)

## Components
- **Compistor/WM Shell**: `niri` + QuickShell UI (topbar, notifications, wallpaper selector, ..)
- **Terminal**: `foot`
- **App Launcher**: `fuzzel`
- **Browser**: `firefox`, [firefox color](https://color.firefox.com/?theme=XQAAAALvAgAAAAAAAABBKYhm849SCicxcUKvrXcGHf3p79EhVPW2QT7xcdxhbuQRrMyRsvXD-Fat7s_zx4jLBxDCYvra1XRRd-Q0UFgoE7Ye6A7ribA03iX0LiQ0JGOnpK6DLY7_Vfh6HxMDl05CQKsFq3jbslsYJDefMf7J4waCYEtDuCjGHV4pvd-ExucQCtauz_Xn903fC-MeHD61S_ZoGr8wamgvhdRU8_QdG1rj0tEpAd1iyFddNMLAjN0QbUdM2jPIC2TFsNlecnv5Nxv8dWefESiZgvvnTM6tXTjCiz3d4dqKF9p4DWLhND54ziuYtl6OE4yKjwi7dkpXRerzkeVX8mU0qozLeOxB86dDpa_n8UP_-Lj4qpgxNgl5BEERmpPdUr-aqlDLQoCLK7Hq1IG0si-ShS2LZOf48WwbdOVDqkkhNqewgf_UeXt4)
- **Shell**: `bash` + ble.sh
- **Theme**: Catppuccin
- **Resource Monitor**: `btop`
- **Image Viewer**: `swayimg`
- **Video Playback**: `mpv`
- **Networking**: `iwd`
- **Bluetooth**: `bluez`
- **Audio**: `pipewire`
- **Editor**: `vim`, `code` (vscode)
- **Misc**:
  - [`matrix`](https://github.com/wick3dr0se/matrix)(digital rain)
  - [`sysfetch`](https://github.com/wick3dr0se.sysfetch) (screenfetch)
  - [`snake`](https://github.com/wick3dr0se/snake) (game)

## Bindings
### Windows
Key | Desc
---|---
<kbd>Super</kbd>+<kbd>◀</kbd> | move left
<kbd>Super</kbd>+<kbd>▶</kbd> | move right
<kbd>Super</kbd>+<kbd>▲</kbd> | move up
<kbd>Super</kbd>+<kbd>▼</kbd> | move down
<kbd>Super</kbd>+<kbd>Space</kbd> | toggle floating
<kbd>Super</kbd>+<kbd>LMB</kbd> | move
<kbd>Super</kbd>+<kbd>RMB</kbd> | resize
<kbd>Super</kbd>+<kbd>Q</kbd> | kill active

### Programs
Cmd | Key | Desc
---|---|---
`kitty` | <kbd>Super</kbd>+<kbd>Return</kbd> | open terminal
`firefox` | <kbd>Super</kbd>+<kbd>W</kbd> | open browser
`code` | <kbd>Super</kbd>+<kbd>E</kbd> | open vscode
`reload` | <kbd>Super</kbd>+<kbd>R</kbd> | reload
`wofi` | <kbd>Super</kbd>+<kbd>M</kbd> | open app launcher
`exit` | <kbd>Super</kbd>+<kbd>Q</kbd> | exit shell (session)
`pactl-vol` | <kbd>Super</kbd>+<kbd>AudioMute</kbd> | toggle mute
`pactl-vol` | <kbd>Super</kbd>+<kbd>AudioLowerVolume</kbd> | reduce volumne 5%
`pactl-vol` | <kbd>Super</kbd>+<kbd>AudioRaiseVolume</kbd> | increase volume 5%

*Check out the [Niri config](config/niri/config.kdl) for more bindings*
