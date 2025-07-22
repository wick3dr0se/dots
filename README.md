<div align="center">
<h1>⚫ dots</h1>
<p>My minimalist dotfile configs for Niri & Hyprland </p>
<a href='#'><img src="https://img.shields.io/badge/Maintained%3F-Yes-green.svg?style=flat-square&labelColor=232329&color=5277C3"></img></a>
<a href="https://opensourceforce.net/discord">
<img src="https://discordapp.com/api/guilds/913584348937207839/widget.png?style=shield"/></a>
</div>

## Structure
dots/  
├── [config](config)/ - Common config files to symlink/copy into ~/.config/  
├── [env](env/)/ - Env-specific configurations & scripts  
│ ├── [hyprland](env/hyprland/)/  
│ │ ├── bin/ - Scripts only used for Hyprland  
│ │ ├── config)/ - Hyprland-specific configs (waybar, wofi)  
│ │ └── packages.txt) - Packages used with Hyprland (executed by `install.sh`)  
│ └── [niri](env/niri/)/  
│ │ ├── bin/ - Scripts only used for Niri  
│ │ ├── config/ - Niri-specific configs (niri, quickshell)  
│ │ └── packages.txt - Packages used with Niri  
├── [home](home/)/ - Common files to symlink/copy into ~/  
├── bootstrap_packages.txt - Common bootstrap packages (executed by `bootstrap.sh`)  
├── bootstrap.sh - System bootstrap script (Chaotic AUR, paru, base packages) for fresh installs  
└── install.sh - Main setup script (links/copies files, installs packages, ..)

## Getting Started
Clone the repo & `cd` in
```bash
git clone https://github.com/wick3dr0se/dots; cd dots 
```

### Prompted Auto Install
For Arch (derivatives) only; simply run the safe Stow-like install script & follow the prompts
```bash
bash install.sh
```

### Manual Install
Copy the configs to your `$HOME` & `$HOME/.config` respectively 
```bash
cp -r env/<ENVIRONMENT>/config/* ~/.config/
cp -r home/.* ~/
```

Copy any scripts you might want
```bash
cp env/<ENVIRONMENT>/bin/* ~/.local/bin/
```

> [!NOTE]
> If you didn’t copy `.bash_profile`, make sure `~/.local/bin` is in your `$PATH`

Install any packages you might want from relevant environment
```bash
# Arch example
pacman -S --needed $(<env/<ENVIRONMENT>/packages.txt)
```

> [!NOTE]
> See [Repology](https://repology.org/tools/project-by) to check how packages from `packages.txt` are named in other distros

Finally, source the prompt
```bash
. ~/.bashrc
```

## Environment Specific Configurations
<div align="center">
<h3>Hyprland</h3>
<a href="env/hyprland/"><img src="captures/hyprland.png"/></a>

<h3>Niri</h3>
<a href="env/niri"><img src="captures/niri.png"/></a>
</div>

> [!NOTE]
> I’ve switched to Niri (love it). Hyprland configs _may_ not get as much love
